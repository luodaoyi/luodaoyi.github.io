---
title: '利用iptables转发服务器流量'
date: 2025-12-18T16:33:37+08:00
draft: false
---

这里提供一个“够用且可回滚”的最小 iptables 转发脚本：安装时交互式输入转发目标 IP、需要排除的不转发端口（可多个），并选择入口网卡；其余 TCP/UDP/ICMP 流量统一 DNAT 到后端。由 systemd 托管，重启不丢；一键卸载，出错可干净撤回。

## 依赖说明
管理脚本会检测 `iptables`/`ip`/`sysctl`/`systemctl`，缺失时可自动用 apt/dnf/yum 安装（也可提前设置 `AUTO_INSTALL=1` 静默安装）。在容器环境仍需 `CAP_NET_ADMIN` 等权限，否则无法生效。

## 可选：用 iptables-services 做持久化（CentOS/RHEL）
在 CentOS/RHEL 系里可以装 `iptables-services`，用系统自带的 `iptables.service` 来保存/恢复规则。优点是“符合老习惯”，缺点是会和 firewalld/现有防火墙管理产生冲突风险（尤其是机器上本来就跑着 firewalld 的场景），并且 Debian 系没有这个包。

因此本文默认不依赖 `iptables-services`，而是用一个独立 systemd unit 托管运行脚本来保证重启后规则生效；如果你明确要走 `iptables-services`，建议二选一：不要同时启用两套持久化机制。

## 适用场景
- 只想把流量全推到一台后端，不做负载均衡/协议解析。
- 重启后要自动恢复，必要时要一键还原。
- 环境为 Debian/Ubuntu 或 CentOS/RHEL，iptables + systemd 可用。

## 获取脚本（推荐）
脚本已放在 Gist，建议以 Gist 为准（文章内也附了同版本源码，便于直接阅读）。

- Gist 页面：https://gist.github.com/luodaoyi/1f6d406b6b797da078b0480608e61ae9
- 短链接（方便，但不建议在自动化里依赖）：https://dub.sh/Q24iKiU

下载并执行（建议保存为 `pfwd-manage.sh`）：
```bash
curl -fsSL https://dub.sh/Q24iKiU -o pfwd-manage.sh
chmod +x pfwd-manage.sh
sudo ./pfwd-manage.sh install
```

## 脚本（管理 ≠ 运行）
推荐分层：管理脚本只做安装/卸载；systemd 只调用运行脚本，避免循环调用。

1) 管理脚本（文件名与存放路径任意，这里示例为 `pfwd-manage.sh`，自行指定位置执行）
```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG=/etc/port-forward.conf
SERVICE=/etc/systemd/system/port-forward.service
RUNTIME=/usr/local/sbin/pfwd-apply.sh

log(){ echo "[*] $*"; }
die(){ echo "ERROR: $*" >&2; exit 1; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "缺少命令: $1"; }

detect_pm(){
  if command -v apt-get >/dev/null 2>&1; then echo apt; return 0; fi
  if command -v dnf >/dev/null 2>&1; then echo dnf; return 0; fi
  if command -v yum >/dev/null 2>&1; then echo yum; return 0; fi
  return 1
}

auto_install_deps(){
  local pm
  pm=$(detect_pm) || die "缺少依赖(ip/iptable)且无法识别包管理器(apt/dnf/yum)"
  log "自动安装依赖：$pm"
  case "$pm" in
    apt)
      apt-get update
      apt-get install -y iptables iproute2
      ;;
    dnf)
      dnf install -y iptables iproute
      ;;
    yum)
      yum install -y iptables iproute
      ;;
  esac
}

ensure_deps(){
  local missing=()
  command -v iptables >/dev/null 2>&1 || missing+=("iptables")
  command -v ip >/dev/null 2>&1 || missing+=("ip")
  if [ "${#missing[@]}" -gt 0 ]; then
    if [ "${AUTO_INSTALL:-0}" = "1" ]; then
      log "检测到缺少：${missing[*]}"
      auto_install_deps
    else
      echo "缺少命令：${missing[*]}"
      read -r -p "是否自动安装依赖包？[y/N] " ans
      case "${ans:-}" in
        y|Y) auto_install_deps ;;
        *) die "请先安装依赖后重试，或设置 AUTO_INSTALL=1" ;;
      esac
    fi
  fi
  need_cmd sysctl
  need_cmd systemctl
}

valid_ip(){
  [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS=. read -r a b c d <<<"$1"
  for x in "$a" "$b" "$c" "$d"; do [[ $x -le 255 ]] || return 1; done
}

valid_port(){
  [[ "$1" =~ ^[0-9]+$ ]] || return 1
  [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

normalize_ports(){
  local s="$1"
  s=${s//,/ }
  s=${s//;/ }
  echo "$s"
}

prompt_target_ip(){
  local target="${1:-}"
  while true; do
    [ -n "$target" ] || read -r -p "转发目标 IP: " target
    valid_ip "$target" && { echo "$target"; return 0; }
    echo "IP 不合法：$target"
    target=""
  done
}

prompt_exclude_ports(){
  local ports p
  read -r -p "不转发端口（TCP/UDP，空格/逗号分隔，默认 22）： " ports
  ports=$(normalize_ports "$ports")
  [ -n "$ports" ] || ports="22"
  for p in $ports; do valid_port "$p" || die "端口不合法：$p"; done
  echo "$ports"
}

choose_iface(){
  local ifaces=() line idx
  while IFS= read -r line; do
    line=${line%%@*}
    [ "$line" = "lo" ] && continue
    [ -n "$line" ] && ifaces+=("$line")
  done < <(ip -o link show | awk -F': ' '{print $2}')
  [ "${#ifaces[@]}" -gt 0 ] || die "未发现可用网卡"

  echo "可用网卡：" >&2
  for idx in "${!ifaces[@]}"; do
    printf "  %d) %s\n" "$((idx+1))" "${ifaces[$idx]}" >&2
  done
  if [ "${#ifaces[@]}" -eq 1 ]; then
    read -r -p "选择入口网卡[1]: " idx
    idx=${idx:-1}
  else
    read -r -p "选择入口网卡(1-${#ifaces[@]}): " idx
  fi
  while true; do
    [[ "$idx" =~ ^[0-9]+$ ]] || { echo "请输入数字"; continue; }
    [ "$idx" -ge 1 ] && [ "$idx" -le "${#ifaces[@]}" ] || { echo "超出范围"; continue; }
    echo "${ifaces[$((idx-1))]}"
    return 0
  done
}

write_runtime(){
  cat > "$RUNTIME" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

CONFIG=/etc/port-forward.conf
CHAIN_NAT=PFWD_NAT
CHAIN_FWD=PFWD_FWD

log(){ echo "[*] $*"; }
die(){ echo "ERROR: $*" >&2; exit 1; }

apply_rules(){
  local target="$1" in_iface="$2" exclude_ports="${3:-}" p
  log "应用转发规则：IN_IFACE=$in_iface TARGET_IP=$target EXCLUDE_PORTS=${exclude_ports:-无}"
  iptables -t nat -N "$CHAIN_NAT" 2>/dev/null || true
  iptables -t nat -F "$CHAIN_NAT"
  iptables -t nat -C PREROUTING -i "$in_iface" -j "$CHAIN_NAT" 2>/dev/null || iptables -t nat -A PREROUTING -i "$in_iface" -j "$CHAIN_NAT"
  for p in $exclude_ports; do
    iptables -t nat -A "$CHAIN_NAT" -p tcp --dport "$p" -j RETURN
    iptables -t nat -A "$CHAIN_NAT" -p udp --dport "$p" -j RETURN
  done
  iptables -t nat -A "$CHAIN_NAT" -p tcp  -j DNAT --to-destination "$target"
  iptables -t nat -A "$CHAIN_NAT" -p udp  -j DNAT --to-destination "$target"
  iptables -t nat -A "$CHAIN_NAT" -p icmp -j DNAT --to-destination "$target"
  iptables -t nat -C POSTROUTING -d "$target" -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -d "$target" -j MASQUERADE

  iptables -N "$CHAIN_FWD" 2>/dev/null || true
  iptables -F "$CHAIN_FWD"
  iptables -C FORWARD -j "$CHAIN_FWD" 2>/dev/null || iptables -A FORWARD -j "$CHAIN_FWD"
  iptables -A "$CHAIN_FWD" -d "$target" -j ACCEPT
  iptables -A "$CHAIN_FWD" -s "$target" -j ACCEPT

  log "开启内核转发开关"
  sysctl -q -w net.ipv4.ip_forward=1
}

clear_rules(){
  local target="$1" in_iface="${2:-}"
  log "清理转发规则"
  [ -n "$in_iface" ] && iptables -t nat -D PREROUTING -i "$in_iface" -j "$CHAIN_NAT" 2>/dev/null || true
  iptables -t nat -D PREROUTING -j "$CHAIN_NAT" 2>/dev/null || true
  iptables -t nat -D POSTROUTING -d "$target" -j MASQUERADE 2>/dev/null || true
  iptables -t nat -F "$CHAIN_NAT" 2>/dev/null || true
  iptables -t nat -X "$CHAIN_NAT" 2>/dev/null || true
  iptables -D FORWARD -j "$CHAIN_FWD" 2>/dev/null || true
  iptables -F "$CHAIN_FWD" 2>/dev/null || true
  iptables -X "$CHAIN_FWD" 2>/dev/null || true
}

case "${1:-}" in
  start)
    [ -f "$CONFIG" ] || die "缺少 $CONFIG"
    . "$CONFIG"
    [ -n "${TARGET_IP:-}" ] || die "缺少 TARGET_IP"
    [ -n "${IN_IFACE:-}" ] || die "缺少 IN_IFACE"
    apply_rules "$TARGET_IP" "$IN_IFACE" "${EXCLUDE_PORTS:-}"
    ;;
  stop)
    . "$CONFIG" 2>/dev/null || { TARGET_IP=0.0.0.0; IN_IFACE=""; }
    clear_rules "$TARGET_IP" "${IN_IFACE:-}"
    ;;
  *)
    echo "用法: $0 start|stop"
    exit 1
    ;;
esac
EOF
  chmod +x "$RUNTIME"
}

write_service(){
  cat > "$SERVICE" <<EOF
[Unit]
Description=Forward traffic with excluded ports
After=network.target

[Service]
Type=oneshot
ExecStart=$RUNTIME start
ExecStop=$RUNTIME stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
}

case "${1:-}" in
  install)
    log "开始安装"
    ensure_deps
    need_cmd sysctl
    need_cmd systemctl
    target=$(prompt_target_ip "${2:-}")
    exclude_ports=$(prompt_exclude_ports)
    in_iface=$(choose_iface)
    log "写入配置：TARGET_IP=$target EXCLUDE_PORTS=$exclude_ports IN_IFACE=$in_iface"
    cat > "$CONFIG" <<EOF
TARGET_IP=$target
EXCLUDE_PORTS="$exclude_ports"
IN_IFACE="$in_iface"
EOF
    log "生成运行脚本与 systemd unit"
    write_runtime
    write_service
    log "启用并启动服务"
    systemctl enable --now port-forward.service
    ;;
  uninstall)
    log "开始卸载"
    systemctl disable --now port-forward.service 2>/dev/null || true
    "$RUNTIME" stop 2>/dev/null || true
    rm -f "$SERVICE" "$RUNTIME" "$CONFIG"
    systemctl daemon-reload
    ;;
  *)
    echo "用法: $0 install [target_ip] | uninstall"
    exit 1
    ;;
esac
```

2) 运行脚本 `/usr/local/sbin/pfwd-apply.sh`（由管理脚本生成；仅支持 `start/stop`，不提供 `install`）。

## 使用方式
- 安装并立即生效（交互式输入目标 IP / 排除端口 / 网卡）：`sudo <管理脚本路径>/pfwd-manage.sh install`
- 卸载并清理：`sudo <管理脚本路径>/pfwd-manage.sh uninstall`

说明：
- 自动安装依赖只在管理脚本里做，`pfwd-apply.sh` 只负责 `start/stop`。
- 网卡列表只在管理脚本 `install` 过程中输出供选择。

## 验证步骤
- 排除端口规则正确：`iptables -t nat -S PFWD_NAT` 能看到对安装时输入的端口（EXCLUDE_PORTS）的 `RETURN`；同时用 `ss -tnlp | grep sshd` 确认 sshd 监听端口包含在排除列表里。
- 转发生效：外部机对服务器发 TCP/UDP/ICMP，目标机 `tcpdump -n host <服务器公网IP>` 能看到流量。
- 持久化：重启后 `systemctl status port-forward` 为 active；`iptables -t nat -S PFWD_NAT` 仍存在；`sysctl net.ipv4.ip_forward` 为 1。
- 卸载后：`iptables-save | grep PFWD` 应无输出，服务被禁用，运行脚本被删。

## 防呆与回滚
- 管理脚本只做安装/卸载，不被 systemd 回调。
- 目标 IP / 端口 / 网卡均有输入校验；运行时缺配置直接退出，不改规则。
- 规则都在 PFWD_* 链，卸载时清干净。

## 原理速记
1. PREROUTING DNAT：对排除端口先 `RETURN`，其余 TCP/UDP/ICMP 目的地址改为目标 IP。  
2. POSTROUTING MASQUERADE：对目标 IP 做源 NAT，避免回程绕路。  
3. FORWARD 放行：允许进出目标 IP 的转发流量。  
4. `net.ipv4.ip_forward=1` 打开内核转发开关。  

够用、简洁、可撤回。要负载均衡就用 HAProxy/Nginx；要多客户端隧道，另起 VPN/代理工具。

---

## 保留真实源 IP 的无 SNAT 方案（DNAT + 后端策略路由）
适合：转发机与后端 IP 都固定，后端路由可改，要求后端看到真实客户端 IP。

思路：转发机只做 DNAT，不做 MASQUERADE；后端把回程流量强制走转发机（改默认网关或策略路由）。两端各一脚本。

### A. 转发机脚本（仅 DNAT，无 MASQUERADE）
保存为 `pfwd-natonly-manage.sh`，流程与主脚本类似，但去掉 SNAT。
```bash
#!/usr/bin/env bash
set -euo pipefail
CONFIG=/etc/port-forward-natonly.conf
SERVICE=/etc/systemd/system/port-forward-natonly.service
RUNTIME=/usr/local/sbin/pfwd-natonly-apply.sh

log(){ echo "[*] $*"; }
die(){ echo "ERROR: $*" >&2; exit 1; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "缺少命令: $1"; }

detect_pm(){
  command -v apt-get >/dev/null 2>&1 && { echo apt; return; }
  command -v dnf >/dev/null 2>&1 && { echo dnf; return; }
  command -v yum >/dev/null 2>&1 && { echo yum; return; }
  return 1
}

auto_install(){
  local pm
  pm=$(detect_pm) || die "无法识别包管理器"
  log "自动安装依赖($pm)"
  case "$pm" in
    apt)
      apt-get update
      apt-get install -y iptables iproute2
      ;;
    dnf)
      dnf install -y iptables iproute
      ;;
    yum)
      yum install -y iptables iproute
      ;;
  esac
}

ensure_deps(){
  local miss=()
  command -v iptables >/dev/null 2>&1 || miss+=("iptables")
  command -v ip >/dev/null 2>&1 || miss+=("ip")
  if [ "${#miss[@]}" -gt 0 ]; then
    echo "缺少命令：${miss[*]}"
    read -r -p "自动安装？[y/N] " a
    [[ ${a:-n} =~ [yY] ]] || die "请先安装或设 AUTO_INSTALL=1"
    auto_install
  fi
  need_cmd sysctl
  need_cmd systemctl
}

valid_ip(){
  [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS=. read -r a b c d <<<"$1"
  for x in $a $b $c $d; do [ "$x" -le 255 ] || return 1; done
}

valid_port(){
  [[ $1 =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

norm_ports(){
  local s="$1"
  s=${s//[,;]/ }
  echo "$s"
}

ask_target(){
  local t="${1:-}"
  while true; do
    [ -n "$t" ] || read -r -p "目标 IP: " t
    valid_ip "$t" && { echo "$t"; return; }
    echo "IP 不合法：$t"
    t=""
  done
}

ask_exclude(){
  local ports p
  read -r -p "不转发端口(默认22，可多值): " ports
  ports=$(norm_ports "$ports")
  [ -n "$ports" ] || ports="22"
  for p in $ports; do valid_port "$p" || die "端口不合法：$p"; done
  echo "$ports"
}

pick_iface(){
  local ifs=() l i
  while IFS= read -r l; do
    l=${l%%@*}
    [ "$l" = lo ] && continue
    [ -n "$l" ] && ifs+=("$l")
  done < <(ip -o link show | awk -F': ' '{print $2}')
  [ "${#ifs[@]}" -gt 0 ] || die "未发现网卡"

  echo "可用网卡：" >&2
  for i in "${!ifs[@]}"; do
    printf "  %d) %s\n" $((i+1)) "${ifs[$i]}" >&2
  done

  read -r -p "选择入口网卡(1-${#ifs[@]}): " i
  [[ $i =~ ^[0-9]+$ ]] && [ $i -ge 1 ] && [ $i -le ${#ifs[@]} ] || die "选择无效"
  echo "${ifs[$((i-1))]}"
}

write_runtime(){
  cat > "$RUNTIME" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

CONFIG=/etc/port-forward-natonly.conf
CHAIN_NAT=PFWD_NAT_ONLY
CHAIN_FWD=PFWD_FWD_ONLY

log(){ echo "[*] $*"; }
die(){ echo "ERROR: $*" >&2; exit 1; }

apply_rules(){
  local target="$1" in_if="$2" excl="${3:-}" p
  log "DNAT 开启：IN=$in_if TARGET=$target EXCLUDE=${excl:-无}"

  iptables -t nat -N "$CHAIN_NAT" 2>/dev/null || true
  iptables -t nat -F "$CHAIN_NAT"
  iptables -t nat -C PREROUTING -i "$in_if" -j "$CHAIN_NAT" 2>/dev/null || \
    iptables -t nat -A PREROUTING -i "$in_if" -j "$CHAIN_NAT"

  for p in $excl; do
    iptables -t nat -A "$CHAIN_NAT" -p tcp --dport "$p" -j RETURN
    iptables -t nat -A "$CHAIN_NAT" -p udp --dport "$p" -j RETURN
  done

  iptables -t nat -A "$CHAIN_NAT" -p tcp  -j DNAT --to-destination "$target"
  iptables -t nat -A "$CHAIN_NAT" -p udp  -j DNAT --to-destination "$target"
  iptables -t nat -A "$CHAIN_NAT" -p icmp -j DNAT --to-destination "$target"

  iptables -N "$CHAIN_FWD" 2>/dev/null || true
  iptables -F "$CHAIN_FWD"
  iptables -C FORWARD -j "$CHAIN_FWD" 2>/dev/null || iptables -A FORWARD -j "$CHAIN_FWD"
  iptables -A "$CHAIN_FWD" -d "$target" -j ACCEPT
  iptables -A "$CHAIN_FWD" -s "$target" -j ACCEPT

  log "开启内核转发"
  sysctl -q -w net.ipv4.ip_forward=1
}

clear_rules(){
  local target="$1" in_if="${2:-}"
  log "清理规则"
  [ -n "$in_if" ] && iptables -t nat -D PREROUTING -i "$in_if" -j "$CHAIN_NAT" 2>/dev/null || true
  iptables -t nat -F "$CHAIN_NAT" 2>/dev/null || true
  iptables -t nat -X "$CHAIN_NAT" 2>/dev/null || true
  iptables -D FORWARD -j "$CHAIN_FWD" 2>/dev/null || true
  iptables -F "$CHAIN_FWD" 2>/dev/null || true
  iptables -X "$CHAIN_FWD" 2>/dev/null || true
}

case "${1:-}" in
  start)
    [ -f "$CONFIG" ] || die "缺少配置"
    . "$CONFIG"
    apply_rules "$TARGET_IP" "$IN_IFACE" "${EXCLUDE_PORTS:-}"
    ;;
  stop)
    . "$CONFIG" 2>/dev/null || { TARGET_IP=0.0.0.0; IN_IFACE=""; }
    clear_rules "$TARGET_IP" "$IN_IFACE"
    ;;
  *)
    echo "用法: $0 start|stop"
    exit 1
    ;;
esac
EOF
  chmod +x "$RUNTIME"
}

write_unit(){
  cat > "$SERVICE" <<EOF
[Unit]
Description=DNAT only forward (no SNAT)
After=network.target
[Service]
Type=oneshot
ExecStart=$RUNTIME start
ExecStop=$RUNTIME stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
}

case "${1:-}" in
  install)
    log "安装 DNAT-only"
    ensure_deps
    target=$(ask_target)
    excl=$(ask_exclude)
    iface=$(pick_iface)
    log "配置: TARGET=$target EXCLUDE=$excl IFACE=$iface"
    cat > "$CONFIG" <<EOF
TARGET_IP=$target
EXCLUDE_PORTS="$excl"
IN_IFACE="$iface"
EOF
    write_runtime
    write_unit
    log "启动服务"
    systemctl enable --now port-forward-natonly.service
    ;;
  uninstall)
    log "卸载 DNAT-only"
    systemctl disable --now port-forward-natonly.service 2>/dev/null || true
    "$RUNTIME" stop 2>/dev/null || true
    rm -f "$SERVICE" "$RUNTIME" "$CONFIG"
    systemctl daemon-reload
    ;;
  *)
    echo "用法: $0 install | uninstall"
    exit 1
    ;;
esac
```

### B. 后端服务器脚本（策略路由让回程走转发机）
后端应用零改动。脚本把默认网关切到转发机（可恢复），关闭 rp_filter 避免反向路由检查丢包。

保存为 `pfwd-backend-route.sh`：
```bash
#!/usr/bin/env bash
set -euo pipefail
CONFIG=/etc/pfwd-backend.conf
SERVICE=/etc/systemd/system/pfwd-backend.service
STATE=/run/pfwd-backend.oldroute

log(){ echo "[*] $*"; }
die(){ echo "ERROR: $*" >&2; exit 1; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "缺少命令: $1"; }

valid_ip(){
  [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  IFS=. read -r a b c d <<<"$1"
  for x in $a $b $c $d; do [ "$x" -le 255 ] || return 1; done
}

ask_fwd(){
  local g
  while true; do
    read -r -p "转发机内网 IP（作为网关）: " g
    valid_ip "$g" && { echo "$g"; return; }
    echo "IP 不合法：$g"
  done
}

save_route(){
  ip route show default > "$STATE" 2>/dev/null || true
}

restore_route(){
  [ -s "$STATE" ] || return 0
  log "恢复原默认路由"
  ip route flush default || true
  while read -r line; do [ -n "$line" ] && ip route add $line || true; done < "$STATE"
}

apply_route(){
  local gw="$1"
  log "设置默认路由 -> $gw"
  save_route
  ip route replace default via "$gw"
  log "关闭 rp_filter"
  sysctl -q -w net.ipv4.conf.all.rp_filter=0
  sysctl -q -w net.ipv4.conf.default.rp_filter=0
}

clear_route(){
  restore_route
  log "恢复 rp_filter=1"
  sysctl -q -w net.ipv4.conf.all.rp_filter=1
  sysctl -q -w net.ipv4.conf.default.rp_filter=1
}

write_unit(){
  cat > "$SERVICE" <<EOF
[Unit]
Description=Backend policy route for DNAT return
After=network.target
[Service]
Type=oneshot
ExecStart=$0 start
ExecStop=$0 stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
}

case "${1:-}" in
  install)
    need_cmd ip
    need_cmd sysctl
    gw=$(ask_fwd)
    echo "FORWARDER_IP=$gw" > "$CONFIG"
    write_unit
    log "应用路由"
    "$0" start
    systemctl enable --now pfwd-backend.service
    ;;
  start)
    [ -f "$CONFIG" ] || die "缺少 $CONFIG"
    . "$CONFIG"
    apply_route "$FORWARDER_IP"
    ;;
  stop)
    clear_route
    ;;
  uninstall)
    systemctl disable --now pfwd-backend.service 2>/dev/null || true
    "$0" stop 2>/dev/null || true
    rm -f "$SERVICE" "$CONFIG" "$STATE"
    systemctl daemon-reload
    ;;
  *)
    echo "用法: $0 install | start | stop | uninstall"
    exit 1
    ;;
esac
```

### 使用提示
1) 在转发机运行 `pfwd-natonly-manage.sh install`，仅做 DNAT 不做 SNAT。  
2) 在后端运行 `pfwd-backend-route.sh install`，把默认网关切到转发机，并关闭 rp_filter。  
3) 验证：后端 `tcpdump -n host <客户端IP>` 能看到真实源 IP；外部访问正常。  
4) 回滚：在后端执行 `pfwd-backend-route.sh uninstall` 恢复原默认路由；转发机执行 `pfwd-natonly-manage.sh uninstall` 清理 DNAT。
