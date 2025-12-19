---
title: 'tinyfecVPN 全自动部署'
date: 2025-12-19T13:57:14+08:00
draft: false
---

这里提供一个“够用且可回滚”的 tinyfecVPN 一键部署脚本：自动安装依赖、拉取/更新源码（含 submodule）、编译 NOLIMIT（无限制）版本、安装二进制到 `/usr/local/bin/tinyvpn`，并生成/启用 systemd 服务（Server/Client 分开）。脚本全程交互式输入参数，直接写进 `ExecStart`，重启不丢；部署后默认删除源码目录（带路径保护），机器上只留下 `tinyvpn` + systemd unit。

## 适用场景
- 需要在 VPS 上快速部署 tinyfecVPN（Server / Client）并开机自启。
- 希望使用 NOLIMIT 编译版本（`make nolimit` / `-DNOLIMIT`）。
- 不想手动 clone/编译，也不想手写 systemd unit。

## 不做什么（边界）
- 不替你配置防火墙/NAT；只会在部署 Server 时“可选”开启 `net.ipv4.ip_forward=1`。
- 不保证你输入的 IP/端口/子网一定合理；脚本只负责把参数写入服务启动命令。
- `-k` 的默认值 `passwd` 只是示例：务必改成你自己的 key。

## 获取脚本（推荐）
- Gist 页面：https://gist.github.com/luodaoyi/41b57a9e55ce9e7263fe29aaa78fb356
- 脚本 raw 短链接（方便，但不建议在自动化里依赖）：https://dub.sh/MOoK1aP

下载并执行（建议保存为 `tinyfecvpn-deploy.sh`）：
```bash
curl -fsSL https://dub.sh/MOoK1aP -o tinyfecvpn-deploy.sh
chmod +x tinyfecvpn-deploy.sh
sudo ./tinyfecvpn-deploy.sh
```

## 依赖说明
脚本会尝试用 `apt-get`/`yum`/`dnf`/`pacman` 安装依赖：
- `git`
- `make`
- `g++`（或 `gcc-c++`）
- `iproute2`（或 `iproute`）
- `curl`
- `ca-certificates`
- `systemd`

需要 root 权限。无 systemd 的环境会跳过服务创建并提示手动运行命令（适合容器/最小系统临时跑一把）。

## 部署 Server（NOLIMIT）
菜单选择 `1) 部署/启动 Server（NOLIMIT）`，按提示依次填写：
- 仓库地址：默认 `https://github.com/wangyu-/tinyfecVPN.git`
- 安装目录：默认 `/opt/tinyfecVPN`（部署后会尝试删除此目录）
- 监听地址/端口：默认 `0.0.0.0:4096`（记得在安全组/防火墙放行）
- VPN 子网：默认 `10.22.22.0`（Server/Client 必须一致）
- TUN 设备名：默认随机 `tunXXX`（会写入 unit，重启保持不变）
- FEC 参数：默认 `20:10`
- 加密 key：隐藏输入（强烈建议改）
- 额外参数：按需填（例如 `--mode 0 --timeout 8`）

部署完成后会生成并启动：
- `/etc/systemd/system/tinyfecvpn-server.service`

## 部署 Client（NOLIMIT）
菜单选择 `2) 部署/启动 Client（NOLIMIT）`，参数类似，区别是：
- 填 Server 公网地址 `IP:PORT`（默认示例 `44.55.66.77:4096`）
- 默认附带 `--keep-reconnect`

部署完成后会生成并启动：
- `/etc/systemd/system/tinyfecvpn-client.service`

## 常用运维
```bash
systemctl status tinyfecvpn-server
systemctl status tinyfecvpn-client
journalctl -u tinyfecvpn-server -f
journalctl -u tinyfecvpn-client -f
systemctl restart tinyfecvpn-server
```

查看脚本写入的完整启动参数：
```bash
systemctl cat tinyfecvpn-server
systemctl cat tinyfecvpn-client
```

## 验证步骤（最小集）
- 服务正常：`systemctl is-active tinyfecvpn-server` / `tinyfecvpn-client` 返回 `active`
- TUN 存在：`ip link show` 能看到你设置的 `--tun-dev`（默认类似 `tun123`）
- 日志无明显报错：`journalctl -u tinyfecvpn-server -n 200 --no-pager`
- 端口监听（Server）：`ss -lunpt | grep 4096`（按你设置的端口替换）

## 卸载与回滚
菜单选择 `4) 卸载（停服务 + 删二进制）` 会：
- 停止并禁用 `tinyfecvpn-server.service` / `tinyfecvpn-client.service`（如果存在）
- 删除 `/usr/local/bin/tinyvpn`

注意：unit 文件本身默认不会删除；如果你需要“彻底清理”，手动执行：
```bash
sudo rm -f /etc/systemd/system/tinyfecvpn-server.service /etc/systemd/system/tinyfecvpn-client.service
sudo systemctl daemon-reload
```

## 防呆与注意事项
- 源码目录清理有路径保护：只会删除像 `/opt/tinyfecVPN` 这种“至少两级路径且非敏感目录”的路径；危险路径会拒绝删除。
- `net.ipv4.ip_forward=1` 只是内核转发开关；要做 NAT/转发还得配 iptables/nftables（可参考上一篇 `251218-iptables-forward-network.md` 的思路）。
- Server/Client 的关键参数要对齐：`--sub-net`、`-f`、`-k`、`--tun-dev` 这几项不一致，就别指望能通。

## 原理速记
1. 依赖安装：按发行版选包管理器装编译/运行依赖。  
2. 拉代码：clone 或更新 tinyfecVPN 仓库（含 submodule）。  
3. 编译：`make nolimit` 生成 NOLIMIT 版本并安装到 `/usr/local/bin/tinyvpn`。  
4. 持久化：生成 `tinyfecvpn-{server,client}.service`，把参数写进 `ExecStart`，并 `enable --now`。  
5. 清理：部署完成后尝试删除源码目录（路径保护避免误删）。  

## 脚本（部署脚本本体）
以下为本文撰写时对应版本源码；建议以 Gist 为准。

```bash
#!/usr/bin/env bash
set -euo pipefail

# =========================
# tinyfecVPN 交互式二合一部署脚本
# - 仅交互，不需要传参
# - 默认编译 NOLIMIT（无限制）版本：make nolimit（对应 makefile 的 -DNOLIMIT）
# - 交互式选择；systemd 参数直接写入 ExecStart
# - 部署后仅保留 /usr/local/bin/tinyvpn + systemd，自动清理源码目录（带路径保护）
# - 固定 TUN 设备名：默认自动生成 tunXXX（随机 3 位数字），写入 systemd，重启不变
# - 客户端默认开启 --keep-reconnect
# =========================

REPO_URL_DEFAULT="https://github.com/wangyu-/tinyfecVPN.git"
INSTALL_DIR_DEFAULT="/opt/tinyfecVPN"
BIN_NAME="tinyvpn"

RED="$(printf '\033[31m')"
GRN="$(printf '\033[32m')"
YEL="$(printf '\033[33m')"
RST="$(printf '\033[0m')"

need_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "${RED}需要 root 权限运行（请用 sudo 或切到 root）。${RST}" >&2
    exit 1
  fi
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

pkg_install() {
  if have_cmd apt-get; then
    apt-get update
    apt-get install -y git make g++ iproute2 ca-certificates curl systemd
    return
  fi
  for pm in yum dnf pacman; do
    if have_cmd "$pm"; then
      case "$pm" in
        yum)   yum install -y git make gcc-c++ iproute ca-certificates curl systemd ;;
        dnf)   dnf install -y git make gcc-c++ iproute ca-certificates curl systemd ;;
        pacman) pacman -Sy --noconfirm git make gcc iproute2 ca-certificates curl systemd ;;
      esac
      return
    fi
  done
  echo "${YEL}未识别的包管理器，请自行安装依赖：git, make, g++, iproute2, curl${RST}" >&2
  exit 1
}

prompt() {
  local var="$1" default="$2" text="$3"
  local input
  read -r -p "$text [$default]: " input || true
  if [[ -z "${input:-}" ]]; then
    printf -v "$var" "%s" "$default"
  else
    printf -v "$var" "%s" "$input"
  fi
}

prompt_secret() {
  local var="$1" default="$2" text="$3"
  local input
  read -r -s -p "$text（输入不可见）[默认同 README 示例]: " input || true
  echo
  if [[ -z "${input:-}" ]]; then
    printf -v "$var" "%s" "$default"
  else
    printf -v "$var" "%s" "$input"
  fi
}

pause() { read -r -p "回车继续..." _ || true; }

gen_tun_dev() {
  local n
  n=$(( (RANDOM % 900) + 100 ))   # 100-999
  echo "tun${n}"
}

clone_or_update_repo() {
  local repo_url="$1" install_dir="$2"
  if [[ -d "${install_dir}/.git" ]]; then
    echo "${GRN}检测到已有仓库，执行更新...${RST}" >&2
    git -C "$install_dir" fetch --all --prune
    git -C "$install_dir" submodule update --init --recursive
    git -C "$install_dir" pull --rebase
  else
    echo "${GRN}克隆仓库（含 submodule）...${RST}" >&2
    mkdir -p "$install_dir"
    git clone --recursive "$repo_url" "$install_dir"
  fi
}

build_nolimit() {
  local install_dir="$1"
  echo "${GRN}编译 NOLIMIT（无限制）版本...${RST}" >&2
  make -C "$install_dir" clean || true
  make -C "$install_dir" nolimit
  install -m 0755 "${install_dir}/${BIN_NAME}" "/usr/local/bin/${BIN_NAME}"
  echo "${GRN}已安装到 /usr/local/bin/${BIN_NAME}${RST}" >&2
}

has_systemd() {
  have_cmd systemctl && [[ -d /run/systemd/system ]]
}

write_systemd_service() {
  local role="$1" args="$2"
  local svc="/etc/systemd/system/tinyfecvpn-${role}.service"
  cat > "$svc" <<EOF
[Unit]
Description=tinyfecVPN (${role})
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/${BIN_NAME} ${args}
Restart=always
RestartSec=2
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  echo "${GRN}已生成 systemd service：${svc}${RST}" >&2
}

is_safe_delete_dir() {
  local dir="$1"
  [[ -n "${dir}" ]] || return 1
  [[ "${dir}" == /* ]] || return 1
  case "${dir}" in
    "/"|"/bin"|"/boot"|"/dev"|"/etc"|"/home"|"/lib"|"/lib64"|"/proc"|"/root"|"/run"|"/sbin"|"/sys"|"/tmp"|"/usr"|"/var"|"/opt")
      return 1
      ;;
  esac
  [[ "${dir}" =~ ^/[^/]+/[^/]+ ]] || return 1
  return 0
}

enable_ip_forward_hint() {
  echo "${YEL}提示：如需转发/NAT，一般需要 net.ipv4.ip_forward=1。${RST}" >&2
  echo "${YEL}注意：你要的“无限制版本”由 Server 端编译 -DNOLIMIT 决定；IP 转发是另一层配置。${RST}" >&2
  read -r -p "是否现在开启 IPv4 转发并写入 /etc/sysctl.conf? [y/N]: " yn || true
  if [[ "${yn:-N}" =~ ^[Yy]$ ]]; then
    sysctl -w net.ipv4.ip_forward=1 >/dev/null
    if ! grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf 2>/dev/null; then
      echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    fi
    echo "${GRN}已开启 net.ipv4.ip_forward=1${RST}" >&2
  fi
}

main_menu() {
  while true; do
    >&2 echo
    >&2 echo "================ tinyfecVPN 部署 ================="
    >&2 echo " 1) 部署/启动 Server（NOLIMIT）"
    >&2 echo " 2) 部署/启动 Client（NOLIMIT）"
    >&2 echo " 3) 仅编译（NOLIMIT）"
    >&2 echo " 4) 卸载（停服务 + 删二进制）"
    >&2 echo " 0) 退出"
    >&2 echo "=================================================="
    read -r -p "请选择 [0-4]: " choice || true
    case "${choice:-}" in
      0|1|2|3|4) echo "$choice"; return 0 ;;
      *) >&2 echo "${YEL}输入无效，请输入 0-4。${RST}" ;;
    esac
  done
}

deploy_common() {
  local role="$1" args="$2" install_dir="$3"
  if has_systemd; then
    write_systemd_service "$role" "$args"
    systemctl enable --now "tinyfecvpn-${role}.service"
    systemctl status --no-pager "tinyfecvpn-${role}.service" || true
  else
    echo "${YEL}未检测到 systemd，跳过服务创建。${RST}" >&2
    echo "${GRN}手动运行：${RST} /usr/local/bin/${BIN_NAME} ${args}" >&2
    return
  fi
  if is_safe_delete_dir "$install_dir"; then
    rm -rf "$install_dir"
    echo "${GRN}已删除源码目录：${install_dir}${RST}" >&2
  else
    echo "${RED}拒绝删除危险路径：${install_dir}${RST}" >&2
  fi
}

server_flow() {
  need_root
  pkg_install

  local repo_url install_dir listen_ip listen_port subnet fec key extra
  prompt repo_url "$REPO_URL_DEFAULT" "tinyfecVPN 仓库地址"
  prompt install_dir "$INSTALL_DIR_DEFAULT" "安装目录"
  prompt listen_ip "0.0.0.0" "Server 监听 IP（-l）"
  prompt listen_port "4096" "Server 监听端口（-l）"
  prompt subnet "10.22.22.0" "VPN 子网（--sub-net，例如 10.22.22.0）"
  local default_tun; default_tun="$(gen_tun_dev)"
  prompt tun_dev "$default_tun" "指定 TUN 设备名（--tun-dev），如 tun10"
  prompt fec "20:10" "FEC 参数（-f x:y）"
  prompt_secret key "passwd" "加密 key（-k）"
  prompt extra "" "额外参数（可留空，例如 --mode 0 --timeout 8）"

  clone_or_update_repo "$repo_url" "$install_dir"
  build_nolimit "$install_dir"

  enable_ip_forward_hint

  local args
  args="-s -l${listen_ip}:${listen_port} -f${fec} -k${key} --sub-net ${subnet} --tun-dev ${tun_dev}"
  [[ -n "$extra" ]] && args="${args} ${extra}"

  deploy_common "server" "$args" "$install_dir"
}

client_flow() {
  need_root
  pkg_install

  local repo_url install_dir
  prompt repo_url "$REPO_URL_DEFAULT" "tinyfecVPN 仓库地址"
  prompt install_dir "$INSTALL_DIR_DEFAULT" "安装目录"
  clone_or_update_repo "$repo_url" "$install_dir"
  build_nolimit "$install_dir"

  local server_ip server_port subnet fec key extra
  prompt server_ip "44.55.66.77" "Server 公网 IP（-r）"
  prompt server_port "4096" "Server 端口（-r）"
  prompt subnet "10.22.22.0" "VPN 子网（--sub-net）"
  local default_tun; default_tun="$(gen_tun_dev)"
  prompt tun_dev "$default_tun" "指定 TUN 设备名（--tun-dev），如 tun10"
  prompt fec "20:10" "FEC 参数（-f x:y）"
  prompt_secret key "passwd" "加密 key（-k）"
  prompt extra "" "额外参数（可留空，例如 --mode 0）"

  local args
  args="-c -r${server_ip}:${server_port} -f${fec} -k${key} --sub-net ${subnet} --tun-dev ${tun_dev} --keep-reconnect"
  [[ -n "$extra" ]] && args="${args} ${extra}"

  deploy_common "client" "$args" "$install_dir"
}

build_only_nolimit() {
  need_root
  pkg_install
  local repo_url install_dir
  prompt repo_url "$REPO_URL_DEFAULT" "tinyfecVPN 仓库地址"
  prompt install_dir "$INSTALL_DIR_DEFAULT" "安装目录"
  clone_or_update_repo "$repo_url" "$install_dir"
  build_nolimit "$install_dir"
}

uninstall_flow() {
  need_root

  if has_systemd; then
    systemctl stop tinyfecvpn-server.service 2>/dev/null || true
    systemctl stop tinyfecvpn-client.service 2>/dev/null || true
    systemctl disable tinyfecvpn-server.service 2>/dev/null || true
    systemctl disable tinyfecvpn-client.service 2>/dev/null || true
    echo "${GRN}已停止/禁用 systemd 服务（如存在）。${RST}" >&2
  else
    echo "${YEL}未检测到 systemd，跳过 systemd 卸载项。${RST}" >&2
  fi

  rm -f "/usr/local/bin/${BIN_NAME}"
  echo "${GRN}已删除 /usr/local/bin/${BIN_NAME}${RST}" >&2

  echo "${GRN}卸载流程结束。${RST}" >&2
}

main() {
  while true; do
    case "$(main_menu)" in
      1) server_flow ;;
      2) client_flow ;;
      3) build_only_nolimit ;;
      4) uninstall_flow ;;
      0) exit 0 ;;
    esac
    pause
  done
}

main "$@"
```
