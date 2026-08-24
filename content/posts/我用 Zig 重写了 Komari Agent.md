---
title: "我用 Zig 重写了 Komari Agent"
categories: [ "项目", "运维", "开发" ]
tags: [ "Komari", "Zig", "Agent", "监控", "OpenWrt", "VPS", "自托管" ]
draft: false
slug: "我用-zig-重写了-komari-agent"
date: "2026-05-02T18:24:00+08:00"
lastmod: "2026-08-24T20:00:00+08:00"
---

最近我又折腾了一个小项目，叫 **komari-zig-agent**。

项目地址：

```text
https://github.com/luodaoyi/komari-zig-agent
```

一句话概括：**这是一个用 Zig 重写的 Komari Agent，目标是直接替换原来的 Go agent，在协议兼容的前提下，把二进制体积和常驻内存压下来。**

如果你用 Komari 监控 VPS、OpenWrt 或者一些小内存机器，这个东西会比较有用。

<!--more-->

## 为什么要重写 Komari Agent

Komari 本身是一个挺顺手的探针监控面板。

它的 agent 负责在机器上采集信息，再把数据上报到面板。正常 VPS 上跑一个 Go agent 当然没什么问题，但如果机器比较小，比如：

- OpenWrt 路由器
- 小内存 VPS
- 低端 ARM 设备
- MIPS / MIPSEL 之类比较边缘的设备

那 agent 的常驻资源占用就会变得更敏感。

我做 `komari-zig-agent` 的目标不是重新设计一套协议，也不是做一个“差不多能用”的兼容品，而是尽量做到：

**Komari 现有面板不用改，原有使用方式尽量不变，只把 agent 换成更轻的 Zig 版本。**

## 它现在兼容哪些东西

这个项目对齐的是 `komari-monitor/komari-agent` 的协议和行为。

目前重点兼容这些能力：

- 基础信息上报
- 运行状态上报
- 网络流量统计
- Ping 任务
- 远程任务
- Web SSH 相关通道
- 自更新
- 原有 endpoint / token 配置方式

也就是说，它不是只会发几个指标的玩具 agent，而是按“替换原 agent”这个方向做的。

当前对齐官方 Go agent **1.2.60**，并吸收了 Snapshot-260727 的非 root systemd user 安装和 Windows NVIDIA 详细 GPU 指标。工具链是 Zig 0.16。Linux Release 覆盖 11 个架构，包含 loong64。自更新会校验 SHA256，失败不覆盖原二进制。


## 资源占用低很多

这个项目最直接的意义，就是轻。

我在 README 里放了一组对比数据，测试环境是 Debian Linux 6.1 x86_64，Go 版用官方 `komari-monitor/komari-agent` 1.2.13，Zig 版用本仓库 ReleaseSmall 构建。

表里的数字仍是 README 那组实测，我没有为这篇文章重新跑一遍。


| 指标 | 原 Go agent | Zig agent |
| --- | ---: | ---: |
| linux-amd64 二进制大小 | 8,585,378 B | 702,488 B |
| 常驻 RSS | 17,828 KB | 约 1,196 KB |
| systemd 当前内存记账 | 未记录 | 约 644 KB |
| 线程数 | 9 | 4 |
| CPU | 约 0.6% | 约 0.1% |

这个差距还是比较明显的。

Zig 版 linux-amd64 二进制大约 700 KB，RSS 约 1.2 MB，systemd 看到的当前内存记账甚至低于 1 MB。

重点是，这不是靠降低上报频率换来的。

采样等待、WebSocket 上报节奏、协议字段都尽量保持兼容。优化主要来自更小的运行时、更直接的内存管理，以及减少热路径上的堆分配。

## 我比较看重的几个实现点

### 1. 兼容优先

这种 agent 最怕“理论上更好，但实际接不上”。

所以我没有把它做成一个新协议客户端，而是尽量按 Komari 原 agent 的行为去对齐。

用户真正需要的是：

```text
原来怎么接 Komari，现在还是怎么接 Komari。
```

只是在机器上跑的那个二进制换了。

### 2. 热路径少分配

监控 agent 是长期运行的东西。

这类程序不怕启动时多花一点点功夫，怕的是每次采样、每次上报都不停制造临时对象。

所以 Zig 版里对上报 JSON、月流量采样、`/proc` 读取这些热路径做了不少处理，尽量用栈缓冲和短生命周期 arena，减少重复堆申请。

目标很简单：

**长期跑着别乱涨，别给小机器添负担。**

### 3. 多平台 Release

现在 Release 已经覆盖不少平台资产：

- Linux：amd64、arm64、386、arm、mips、mipsel、mips64、mips64el、riscv64、s390x、loong64
- FreeBSD：amd64、arm64、386、arm
- macOS：amd64、arm64
- Windows：amd64、arm64、386

其中我最在意的其实是 Linux 的小架构覆盖。

因为这类 agent 最容易被丢到各种奇怪的小机器上跑。只支持 amd64 和 arm64，很多场景就没法直接替换。

### 4. 自更新走自己的 Release

Zig 版启动后会检查本仓库的 GitHub Release：

```text
https://api.github.com/repos/luodaoyi/komari-zig-agent/releases/latest
```

也就是说，它不会再去下载原 Go 仓库的版本。

这点很重要。否则你刚替换成 Zig 版，下一次自更新又被换回 Go 版，那就很尴尬。

## 怎么安装

如果是新机器，直接安装 Zig 版：

```sh
curl -fsSL https://raw.githubusercontent.com/luodaoyi/komari-zig-agent/main/install.sh | sudo sh -s -- \
  --endpoint https://panel.example \
  --token TOKEN
```

没有 `curl` 的机器也可以用 `wget`：

```sh
wget -O- https://raw.githubusercontent.com/luodaoyi/komari-zig-agent/main/install.sh | sudo sh -s -- \
  --endpoint https://panel.example \
  --token TOKEN
```

脚本会自动识别 Linux、OpenWrt/procd、OpenRC、systemd、FreeBSD rc.d、macOS launchd，并创建对应服务。

## 已经装了 Go 版怎么办

如果机器上已经有原来的 Go 版 `komari-agent`，可以直接走替换脚本：

```sh
curl -fsSL https://raw.githubusercontent.com/luodaoyi/komari-zig-agent/bd2e0b8de76a11601d57b1663e9002912e1a82f2/replace.sh | sudo sh
```

国内访问 GitHub 不稳定时，README 给的是同一提交的 jsDelivr：

```sh
curl -fsSL https://cdn.jsdelivr.net/gh/luodaoyi/komari-zig-agent@bd2e0b8de76a11601d57b1663e9002912e1a82f2/replace.sh | sudo sh
```

脚本会校验 SHA256SUMS；下载、校验或启动失败时不覆盖正在用的 Agent。


这个脚本做了几件比较保守的事：

- 自动识别 CPU 架构并下载对应 Release 资产
- 下载失败会重试
- 下载后先试运行二进制，避免把错误页面或错误架构写进去
- 停止原服务前会备份原二进制
- 替换后重启服务
- systemd 启动失败会自动回滚
- 不改 endpoint、token、上报间隔等业务参数

也就是说，它尽量只替换二进制，不动你的业务配置。

## 当前版本

写这篇文章时，最新版本是：

```text
v0.1.47
```

对齐官方 Go 1.2.60，工具链 Zig 0.16，Linux 11 架构（含 loong64）。自更新带 SHA256 校验。Windows WebShell 仍有未关闭的问题，这里不写成已经修好。



## 适合谁用

我觉得它比较适合这些场景：

- 你已经在用 Komari
- 你有不少小内存机器
- 你想在 OpenWrt 上跑探针
- 你希望 agent 尽量轻
- 你想保留原 Komari 面板，不想换监控系统
- 你喜欢静态小二进制这种部署方式

如果你的机器资源很宽裕，Go 版当然也能用。

但如果你就是想把 agent 压到更小、更轻，`komari-zig-agent` 就是为这个方向做的。

## 最后

仓库地址再放一次：

**https://github.com/luodaoyi/komari-zig-agent**

这个项目的定位很明确：

**不是重新造一个 Komari，而是给 Komari 换一个更轻的 agent。**

能少占一点内存是一点，能少一点二进制体积是一点。尤其是那些小 VPS、小路由器、小 ARM/MIPS 设备，本来资源就不多，监控探针就应该尽量安静、稳定、轻一点。
