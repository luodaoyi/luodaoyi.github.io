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

Komari 现有面板不用改，原来怎么接还怎么接，只把机器上那个 agent 换成 Zig。协议对齐原来的 Go agent，二进制体积和常驻内存压下来。OpenWrt、小内存 VPS、低端 ARM / MIPS 这类机器会比较有感。

项目地址：

```text
https://github.com/luodaoyi/komari-zig-agent
```

<!--more-->

## 对齐到哪

对齐的是 `komari-monitor/komari-agent` 的协议和行为：基础信息上报、运行状态、网络流量、Ping 任务、远程任务、Web SSH 相关通道、自更新，以及原来的 endpoint / token。

当前对齐官方 Go agent **1.2.60**，并吸收了 Snapshot-260727 的非 root systemd user 安装和 Windows NVIDIA 详细 GPU 指标。工具链是 Zig **0.16**。Linux Release 覆盖 **11** 个架构，包含 **loong64**。自更新会校验 SHA256，失败不覆盖原二进制。

Windows WebShell 那个问题还在（[#16](https://github.com/luodaoyi/komari-zig-agent/issues/16)），没修。

## 有多轻

README 里放了一组对比。测试环境是 Debian Linux 6.1 x86_64，Go 版用官方 `komari-monitor/komari-agent` **1.2.13**，Zig 版用本仓库 ReleaseSmall。表里的数字仍是 README 那组实测，我没有为这篇文章重新跑一遍。

| 指标 | 原 Go agent | Zig agent |
| --- | ---: | ---: |
| linux-amd64 二进制大小 | 8,585,378 B | 702,488 B |
| 常驻 RSS | 17,828 KB | 约 1,196 KB |
| systemd 当前内存记账 | 未记录 | 约 644 KB |
| 线程数 | 9 | 4 |
| CPU | 约 0.6% | 约 0.1% |

采样等待、WebSocket 上报节奏、协议字段都尽量保持兼容。不是靠降低上报频率换来的。

Zig 版启动后会检查本仓库的 GitHub Release，不会再去下载原 Go 仓库的版本。不然刚换成 Zig，下一次自更新又被换回 Go。

## 新机器怎么装

```sh
curl -fsSL https://raw.githubusercontent.com/luodaoyi/komari-zig-agent/main/install.sh | sudo sh -s -- \
  --endpoint https://panel.example \
  --token TOKEN
```

没有 `curl` 也可以用 `wget`：

```sh
wget -O- https://raw.githubusercontent.com/luodaoyi/komari-zig-agent/main/install.sh | sudo sh -s -- \
  --endpoint https://panel.example \
  --token TOKEN
```

脚本会自动识别 Linux、OpenWrt/procd、OpenRC、systemd、FreeBSD rc.d、macOS launchd，并创建对应服务。

## 已经装了 Go 版

```sh
curl -fsSL https://raw.githubusercontent.com/luodaoyi/komari-zig-agent/bd2e0b8de76a11601d57b1663e9002912e1a82f2/replace.sh | sudo sh
```

国内访问 GitHub 不稳定时，README 给的是同一提交的 jsDelivr：

```sh
curl -fsSL https://cdn.jsdelivr.net/gh/luodaoyi/komari-zig-agent@bd2e0b8de76a11601d57b1663e9002912e1a82f2/replace.sh | sudo sh
```

脚本会校验 SHA256SUMS；下载、校验或启动失败时不覆盖正在用的 Agent。它会识别架构、下载失败重试、先试运行再替换、停原服务前备份、systemd 启动失败回滚，不改 endpoint、token、上报间隔。

## 平台和版本

当前最新是 **v0.1.47**。

- Linux：amd64、arm64、386、arm、mips、mipsel、mips64、mips64el、riscv64、s390x、loong64
- FreeBSD：amd64、arm64、386、arm
- macOS：amd64、arm64
- Windows：amd64、arm64、386

仓库：<https://github.com/luodaoyi/komari-zig-agent>
