---
title: '[转载] iptables配置无SNAT转发所有流量，保留来源真实ip'
date: 2025-12-19T14:08:04+08:00
draft: false
---


# iptables配置无SNAT转发所有流量，保留来源真实IP

## 前言

在网络架构中，我们经常需要通过中转机转发流量到后端服务器。传统方案通常使用 SNAT/MASQUERADE 来实现，但这会导致一个严重问题：**后端服务器看到的来源IP全部变成了中转机的IP**，丢失了真实客户端IP信息。

本文将介绍一种**无SNAT转发方案**，通过 DNAT + 策略路由的组合，在转发所有流量的同时保留客户端的真实IP地址。

## 方案对比

### 传统 SNAT/MASQUERADE 方案的劣势

```bash
# 传统方案示例
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
```

| 问题 | 说明 |
|------|------|
| ❌ 丢失真实IP | 后端看到的所有请求来源都是中转机IP |
| ❌ 日志分析困难 | 无法追踪真实用户来源 |
| ❌ 安全审计失效 | 无法基于真实IP做访问控制 |
| ❌ 地理位置识别失败 | 所有用户都会被识别为中转机所在地 |
| ❌ 风控系统失效 | 无法基于IP做反欺诈、频率限制等 |

### 本方案优势

| 优势 | 说明 |
|------|------|
| ✅ 保留真实IP | 后端服务器可以获取客户端真实IP |
| ✅ 日志完整 | 便于安全审计和问题排查 |
| ✅ 兼容性好 | 应用层无需任何修改 |
| ✅ 透明转发 | 对客户端和后端服务完全透明 |

## 前置条件

> ⚠️ **重要提示**：本方案建立在**已配置好内网隧道**的基础上！

在开始配置之前，你需要：

1. **已搭建好隧道**：前端中转机与后端服务器之间需要有一条可用的隧道连接
2. **支持的隧道类型**（任选其一）：
   - WireGuard
   - GRE Tunnel
   - OpenVPN (TUN模式)
   - TinyFecVPN
   - ZeroTier
   - 其他任何能创建虚拟网卡的隧道方案

3. **确认以下信息**：
   - 隧道网卡名称（如：`tun0`, `wg0`, `gre1` 等）
   - 前端隧道IP（如：`10.22.22.2`）
   - 后端隧道IP（如：`10.22.22.1`）
   - 隧道内网互通正常

```bash
# 验证隧道连通性
# 在前端执行
ping <后端隧道IP>

# 在后端执行  
ping <前端隧道IP>
```

## 网络架构

```
+----------------+       +------------------+       +------------------+
|     客户端     |       |    前端中转机    |       |    后端服务器    |
|                |       |                  |       |                  |
|  IP: 1.2.3.4   | ====> |  公网网卡:  eth0  | ====> |    业务服务      |
|                |  公网 |  隧道IP:          |  隧道 |    隧道IP:       |
|                |       |  10.22.22.2      |       |    10.22.22.1    |
+----------------+       +------------------+       +------------------+
```

### 流量走向

```
请求流程 (保留真实IP):

[1] 客户端 1.2.3.4
        |
        | 访问前端公网IP
        v
[2] 前端中转机
        |
        | DNAT: 目标IP改为 10.22.22.1，源IP保持 1.2.3.4 不变
        v
[3] 通过隧道转发
        |
        v
[4] 后端服务器收到请求
        |
        | 源IP: 1.2.3.4 ✅ (真实客户端IP)
        v
[5] 策略路由 + CONNMARK 标记
        |
        | 识别为隧道来源的连接，原路返回
        v
[6] 响应通过隧道返回前端
        |
        v
[7] 前端自动反向NAT
        |
        v
[8] 响应返回客户端 1.2.3.4
```

### 与传统 SNAT 方案对比

```
+------------------------------------------------------------------+
|  ❌ 传统 SNAT/MASQUERADE 方案                                    |
+------------------------------------------------------------------+
|                                                                  |
|  客户端 -----> 中转机 -----> 后端                                |
|  1.2.3.4       SNAT         看到的源IP:  10.22.22.2               |
|                             (中转机隧道IP, 丢失真实IP)           |
|                                                                  |
+------------------------------------------------------------------+

+------------------------------------------------------------------+
|  ✅ 本方案:  DNAT + 策略路由                                      |
+------------------------------------------------------------------+
|                                                                  |
|  客户端 -----> 中转机 -----> 后端                                |
|  1.2.3.4       DNAT         看到的源IP: 1.2.3.4                  |
|                (仅改目标)   (真实客户端IP完整保留)               |
|                                                                  |
+------------------------------------------------------------------+
```

## 配置步骤

### 一、前端中转机配置

在前端中转机上执行以下脚本：

```bash
#!/bin/bash

# ================= 配置变量区域 =================
# 前端公网接口名称
FRONT_PUB_IF="eth0"
# 排除转发的端口 (防止 SSH 断连)
EXCLUDE_PORT="22"
# 转发目标：后端的隧道 IP
BACK_TUN_IP="10.22.22.1"
# ===============================================

echo "1. 开启内核 IP 转发..."
sysctl -w net.ipv4.ip_forward=1 > /dev/null
# 确保配置永久生效
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl. conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

echo "2. 清理可能冲突的旧规则 (可选，视情况执行)..."
# iptables -t nat -F PREROUTING

echo "3. 配置防火墙 DNAT 规则..."
# 3.1 [重要] 排除 SSH 端口，使其直接进入本机，不进行转发
iptables -t nat -A PREROUTING -i $FRONT_PUB_IF -p tcp --dport $EXCLUDE_PORT -j RETURN

# 3.2 将所有从公网接口进入的流量，目标地址修改为后端的隧道 IP
iptables -t nat -A PREROUTING -i $FRONT_PUB_IF -j DNAT --to-destination $BACK_TUN_IP

echo "4. 配置转发放行规则..."
# 允许已建立的连接和流向目标的连接通过
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d $BACK_TUN_IP -j ACCEPT

echo "5. 优化 MTU (防止大包断流)..."
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

echo "前端配置完成。"
```

**配置说明：**

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `FRONT_PUB_IF` | 前端公网网卡名称 | `eth0` |
| `EXCLUDE_PORT` | 排除转发的端口（避免SSH断连） | `22` |
| `BACK_TUN_IP` | 后端服务器的隧道IP | `10.22.22.1` |

### 二、后端服务器配置

在后端服务器上执行以下脚本：

```bash
#!/bin/bash

# ================= 配置变量区域 =================
# 后端隧道接口名称
BACK_TUN_IF="tun0"
# 后端隧道网关 (即前端的隧道 IP)
FRONT_TUN_IP="10.22.22.2"
# 自定义路由表名称和 ID
RT_TABLE_NAME="via_relay"
RT_TABLE_ID="100"
# ===============================================

echo "1. 创建自定义路由表..."
# 检查是否已存在，不存在则添加
if ! grep -q "$RT_TABLE_NAME" /etc/iproute2/rt_tables; then
    echo "$RT_TABLE_ID $RT_TABLE_NAME" >> /etc/iproute2/rt_tables
    echo "路由表 $RT_TABLE_NAME 已创建"
fi

echo "2. 配置策略路由 (IP Rule & Route)..."
# 2.1 给自定义表添加默认路由：走隧道接口去往前端
ip route replace default via $FRONT_TUN_IP dev $BACK_TUN_IF table $RT_TABLE_NAME

# 2.2 设定规则：凡是标记为 0x1 的流量，查询自定义表
ip rule del fwmark 0x1 table $RT_TABLE_NAME 2>/dev/null || true
ip rule add fwmark 0x1 table $RT_TABLE_NAME

echo "3. 配置 iptables 标记规则 (Mangle)..."
# 3.1 入站标记：如果连接的数据包是从隧道接口进来的，给整个连接打上标记 0x1
iptables -t mangle -A PREROUTING -i $BACK_TUN_IF -j CONNMARK --set-mark 0x1

# 3.2 出站恢复：本机发出的数据包，如果属于被打标记的连接，则恢复标记 0x1
# 这样系统就会根据 ip rule 将其扔给自定义路由表
iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark

echo "4. 放宽反向路径过滤 (RP_Filter)..."
# 解决非对称路由丢包问题 (Strict mode 会丢弃回程包)
sysctl -w net.ipv4.conf.default.rp_filter=2 > /dev/null
sysctl -w net.ipv4.conf.all.rp_filter=2 > /dev/null
sysctl -w net.ipv4.conf.$BACK_TUN_IF. rp_filter=2 > /dev/null

# 写入配置文件以持久化
sed -i '/net.ipv4.conf.default.rp_filter/d' /etc/sysctl.conf
sed -i '/net.ipv4.conf.all.rp_filter/d' /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 2" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 2" >> /etc/sysctl.conf

echo "5. 优化 MTU..."
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

echo "后端配置完成。"
```

**配置说明：**

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `BACK_TUN_IF` | 后端隧道网卡名称 | `tun0`, `wg0`, `gre1` 等 |
| `FRONT_TUN_IP` | 前端中转机的隧道IP | `10.22.22.2` |
| `RT_TABLE_NAME` | 自定义路由表名称 | `via_relay` |
| `RT_TABLE_ID` | 路由表ID（1-252之间未使用的数字） | `100` |

## 配置持久化

上述脚本执行后是即时生效的，**重启会丢失**。使用以下方法持久化：

### 1. iptables 规则持久化

**Debian/Ubuntu:**
```bash
apt-get install iptables-persistent
netfilter-persistent save
```

**CentOS/RHEL:**
```bash
service iptables save
# 或
iptables-save > /etc/sysconfig/iptables
```

### 2. 策略路由持久化（后端）

将路由命令添加到 `/etc/rc.local`（确保在 `exit 0` 之前）：

```bash
# /etc/rc.local
ip route add default via 10.22.22.2 dev tun0 table via_relay
ip rule add fwmark 0x1 table via_relay

exit 0
```

或者使用 systemd 服务：

```ini
# /etc/systemd/system/policy-route.service
[Unit]
Description=Policy Route for Relay
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'ip route replace default via 10.22.22.2 dev tun0 table via_relay && ip rule add fwmark 0x1 table via_relay'

[Install]
WantedBy=multi-user.target
```

启用服务：
```bash
systemctl daemon-reload
systemctl enable policy-route.service
```

## 验证与排错

### 1. 验证隧道连通性

```bash
# 在中转机执行
ping 10.22.22.1
```

### 2. 验证转发功能

在任意客户端 ping 中转机公网IP，同时在后端抓包：

```bash
# 后端执行（替换 tun0 为你的隧道网卡名）
tcpdump -i tun0 icmp
```

**预期结果：** 能看到真实的客户端IP，而不是中转机IP。

### 3. 常见问题排查

#### 问题：Ping 不通

**检查 rp_filter 设置：**
```bash
cat /proc/sys/net/ipv4/conf/all/rp_filter
# 应该返回 2
```

**检查 FORWARD 链默认策略：**
```bash
iptables -L FORWARD -n -v
# 如果默认策略是 DROP，需要添加放行规则
```

#### 问题：SSH 断连

确认 SSH 端口已排除在转发规则之外：
```bash
iptables -t nat -L PREROUTING -n -v --line-numbers
# 确认 22 端口的 RETURN 规则在 DNAT 规则之前
```

#### 问题：大文件传输中断

检查 MTU 优化规则是否生效：
```bash
iptables -t mangle -L FORWARD -n -v
# 应该看到 TCPMSS clamp 规则
```

## 核心原理解析

### 为什么不需要 SNAT？

关键在于**策略路由**：

```
入站流程: 
+------------------+     +------------------+     +------------------+
| 数据包从隧道进入 | --> | CONNMARK打标记0x1 | --> |    连接被标记    |
+------------------+     +------------------+     +------------------+

出站流程:
+------------------+     +------------------+     +------------------+
| 响应数据包生成   | --> | CONNMARK恢复标记  | --> | 数据包带0x1标记  |
+------------------+     +------------------+     +------------------+
         |
         v
+------------------+     +------------------+     +------------------+
| ip rule匹配      | --> | 查询via_relay表   | --> | 从隧道返回前端   |
+------------------+     +------------------+     +------------------+

前端处理:
+------------------+     +------------------+
| DNAT自动反向转换 | --> |   返回客户端     |
+------------------+     +------------------+
```

1. **入站时**：通过 `CONNMARK` 给从隧道进入的连接打上标记 `0x1`
2. **出站时**：恢复连接标记，让响应包也带上 `0x1`
3. **路由决策**：带有 `0x1` 标记的包查询自定义路由表，走隧道返回
4. **DNAT 反向**：前端 netfilter 自动对响应包做反向 NAT

这样，响应包就能原路返回，无需 SNAT 来"骗"后端服务器。

### rp_filter 为什么要设为 2？

`rp_filter`（反向路径过滤）用于防止 IP 欺骗：

| 值 | 模式 | 说明 |
|----|------|------|
| `0` | 关闭 | 不检查 |
| `1` | 严格模式 | 回程包必须从同一接口返回 |
| `2` | 宽松模式 | 只要有任意路由可达即可 |

在本方案中，入站走隧道，出站也走隧道（策略路由），但源IP是外部IP，严格模式会认为这是欺骗而丢弃，所以需要设为宽松模式。

## 安全建议

1. **限制转发端口**：如果不需要转发所有端口，建议只转发必要端口
2. **添加速率限制**：防止 DDoS 放大攻击
3. **启用连接跟踪超时**：优化 conntrack 表大小
4. **定期检查规则**：确保没有意外的规则变更

```bash
# 只转发特定端口示例（80, 443）
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.22.22.1
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 10.22.22.1
```

## 总结

通过 **DNAT + 策略路由 + CONNMARK** 的组合，我们实现了：

- ✅ 流量全量转发
- ✅ 保留客户端真实IP
- ✅ 无需修改应用程序
- ✅ 对客户端完全透明

这种方案特别适合需要保留真实IP的场景，如：CDN中转、游戏加速、安全审计等。

---

*如有问题欢迎留言讨论！*


* 转载自nodeseek论坛:   [https://www.nodeseek.com/post-549107-1](https://www.nodeseek.com/post-549107-1)