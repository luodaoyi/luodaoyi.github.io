---
title: "关于我"
date: 2015-03-10 00:13:27
description: 小学生一枚
---

小学生一枚。

## 最近折腾的项目

这里放一些我最近写过、整理过，或者还在持续维护的小东西。

### [memocap](https://github.com/luodaoyi/memocap)

`忆时` `记忆` `SQLite` `Codex` `Claude` `Pi` `OpenCode` `Grok`

忆时记忆系统，当前是 v0.1.4。一份本地 SQLite，给 Codex / Claude / Pi / OpenCode / Grok 共用：每轮先 recall，决策、偏好、任务、约定查过同类再 remember。也可以起带 token 的小服务，多机共用同一份库。

相关介绍：[我做了一个给多宿主共用的本地记忆：memocap（忆时）](/posts/memocap/)

### [grok-bridge-rs](https://github.com/luodaoyi/grok-bridge-rs)

`Grok` `grok-build` `Rust` `Codex` `Claude Code` `Runtime`

本地 Grok Runtime Bridge，当前是 grok-build v0.8.11。让 Codex、Claude Code 这类 Agent 把开发任务交给 Grok CLI，会话和终端输出由本机 Runtime 统一管理。

相关介绍：[让 Codex 和 Claude Code 调用 Grok：grok-build 本地 Runtime Bridge](/posts/%E8%AE%A9-codex-%E5%92%8C-claude-code-%E8%B0%83%E7%94%A8-grok-grok-build-%E6%9C%AC%E5%9C%B0-runtime-bridge/)

### [pdb_proxy](https://github.com/luodaoyi/pdb_proxy)

`PDB` `符号服务器` `缓存` `Go` `msdl`

微软符号服务器的本地代理，当前是 v1.1.0。上游走 msdl.microsoft.com，命中过的 PDB 留在本地缓存。对外节点只有 https://msdl.011f.com。

相关介绍：[我做了一个 PDB 符号代理：本地下载缓存，加速 msdl.microsoft.com](/posts/pdb-proxy/)

### [pi-zig-skills](https://github.com/luodaoyi/pi-zig-skills)

`Pi` `Zig` `zls` `Skill` `TypeScript`

给 Pi 用的 Zig 包，当前是 0.2.4。装上之后有 zig-0.16 和 zig-tiger-style 两个 Skill，再加上 zig_lsp_diagnostics，去问官方 zls 0.16。

相关介绍：[我给 Pi 做了个 Zig 包：两个 Skill，加上官方 zls 0.16 的诊断工具](/posts/pi-zig-skills/)

### [TAD6S4N10G-fnos](https://github.com/luodaoyi/TAD6S4N10G-fnos)

`fnOS` `TAD6S4N10G` `温度` `功耗` `风扇` `Go`

给 TAD6S4N10G 写的 fnOS 模块，当前是 v0.10.16。把温度、功耗、风扇和机箱按键放进飞牛原生界面。

相关介绍：[我给 TAD6S4N10G 写了个 fnOS 模块：温度、功耗、风扇和机箱按键](/posts/tad6s4n10g-fnos/)

### [CodexUsageBar](https://github.com/luodaoyi/codex-useage-win)

`Codex` `Windows` `Win32` `C++` `用量`

Windows 上的原生桌面挂件。读取本机 Codex 授权后，把 5 小时和每周用量直接显示在桌面上。

相关介绍：[Windows 上实时查看 Codex 用量：我做了一个原生桌面挂件](/posts/windows-%E4%B8%8A%E5%AE%9E%E6%97%B6%E6%9F%A5%E7%9C%8B-codex-%E7%94%A8%E9%87%8F-%E6%88%91%E5%81%9A%E4%BA%86%E4%B8%80%E4%B8%AA%E5%8E%9F%E7%94%9F%E6%A1%8C%E9%9D%A2%E6%8C%82%E4%BB%B6/)

### [Certwarden](https://github.com/luodaoyi/Certwarden)

`证书监控` `SSL/TLS` `多租户` `自托管` `Go` `React` `Docker`

一个面向团队、平台和托管场景的多租户 SSL/TLS 证书监控系统，当前是 v1.3.4。重点是持续检测证书状态、通知告警、历史记录和公开状态页。

相关介绍：[我写了一个证书监控系统，叫 Certwarden](/posts/%E6%88%91%E5%86%99%E4%BA%86%E4%B8%80%E4%B8%AA%E8%AF%81%E4%B9%A6%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-%E5%8F%AB-certwarden/)

### [BreatheLens](https://github.com/luodaoyi/BreatheLens)

`瑞思迈` `CPAP/APAP` `医疗数据` `本地分析` `Python` `PySide6` `QML`

一个本地版瑞思迈呼吸机 SD 卡数据分析工具。目标是把原始治疗数据整理成更容易看懂的图表、表格和建议。

相关介绍：[我做了一个本地版瑞思迈呼吸机数据分析工具：BreatheLens](/posts/%E6%88%91%E5%81%9A%E4%BA%86%E4%B8%80%E4%B8%AA%E6%9C%AC%E5%9C%B0%E7%89%88%E7%91%9E%E6%80%9D%E8%BF%88%E5%91%BC%E5%90%B8%E6%9C%BA%E6%95%B0%E6%8D%AE%E5%88%86%E6%9E%90%E5%B7%A5%E5%85%B7-breathelens/)

### [komari-zig-agent](https://github.com/luodaoyi/komari-zig-agent)

`Komari` `Zig` `Agent` `监控` `OpenWrt` `VPS` `小内存设备`

一个用 Zig 0.16 重写的 Komari Agent，当前是 v0.1.49。协议对齐官方 Go agent 1.2.60，同时把二进制体积、常驻内存和运行时负担压下来。

相关介绍：[我用 Zig 重写了 Komari Agent](/posts/%E6%88%91%E7%94%A8-zig-%E9%87%8D%E5%86%99%E4%BA%86-komari-agent/)

### [go-codex-notify](https://github.com/luodaoyi/go-codex-notify)

`Codex` `通知` `CLI` `Rust` `codex-notify` `Telegram`

给 OpenAI Codex 接通知，当前是 `codex-notify` v1.3.23。用 Rust 写的多渠道通知，任务跑完或告一段落时不用一直盯终端。

相关介绍：[给 OpenAI Codex 接上通知：现在用 codex-notify](/posts/%E7%BB%99-openai-codex-%E6%8E%A5%E4%B8%8A-telegram-%E9%80%9A%E7%9F%A5-%E4%BB%8E%E6%89%8B%E5%8A%A8%E4%B8%8B%E4%BA%8C%E8%BF%9B%E5%88%B6-%E5%88%B0%E4%B8%80%E6%9D%A1-npx-%E6%90%9E%E5%AE%9A/)