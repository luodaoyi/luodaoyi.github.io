---
title: "我给 Pi 做了个 Zig 包：两个 Skill，加上官方 zls 0.16 的诊断工具"
categories: [ "项目", "开发工具" ]
tags: [ "Pi", "Zig", "zls", "Skill", "pi-zig-skills" ]
draft: false
slug: "pi-zig-skills"
date: "2026-08-24T20:20:00+08:00"
---

最近我把写 Zig 时常用的两份说明，和官方 **zls 0.16** 的诊断通道，收进了一个 Pi 包：**pi-zig-skills**。

仓库：

<https://github.com/luodaoyi/pi-zig-skills>

写这篇文章时，已经发到 **0.2.2**（npm `pi-zig-skills@0.2.2`，主分支提交 `0eb8535240843f1d213f0366ef50b949fc3487e0`）。一句话概括：**装上之后自动出现 `zig-0.16`  和 `zig-tiger-style` 两个 skill，扩展再注册 `zig_lsp_diagnostics`，去问官方 zls 0.16，不依赖别的包有没有占住 `/lsp`。**

<!--more-->

主安装方式：

```bash
pi install npm:pi-zig-skills
```

也可以看这三个地址：

- GitHub：<https://github.com/luodaoyi/pi-zig-skills>
- npm 0.2.2：<https://www.npmjs.com/package/pi-zig-skills/v/0.2.2>
- Pi 包页：<https://pi.dev/packages/pi-zig-skills>

已经装过 **0.1.x** 的人必须再跑一次 `pi update`（或 `pi update npm:pi-zig-skills`）。Pi 会继续用缓存里的 0.1.x，不更新就不会到 0.2.2。

不想走 npm 时，仓库 README 还写了 git 安装：

```bash
pi install git:github.com/luodaoyi/pi-zig-skills
```

## 两个 skill，装完就在

包里只挂了两个 skill，路径写在 `package.json` 的 `pi.skills` 里：

- **zig-0.16**：钉在 Zig **0.16.0** 稳定版的 API 和移植笔记。覆盖面就是包说明里写的那些：`std.Io`、`@Type` 移除、`@cImport` 弃用。
- **zig-tiger-style**：从 TigerBeetle 的 TigerStyle 抽出来的 Zig 写法，优先级是 **Safety > Performance > Developer Experience**，常见条目是安全、断言、命名和布局。

README 写得很直接：加进包之后会自动出现，不用再手工拷目录。

## `zig_lsp_diagnostics` 只跟官方 zls 0.16 说话

扩展入口是 `extensions/zls/index.ts`。加载时会解析一份 zls 0.16，再 `registerTool` 注册 **`zig_lsp_diagnostics`**。工具描述写明了：对 `.zig` / `.zon` 跑官方 zls 0.16 的诊断。

zls 从哪来，规则只有两条：

1. **PATH 上已有 zls**，并且 `--version` 报的是 **0.16.x**（排除带 `dev` / `git` / `dirty` / `nightly` 的字样），就用这一份。
2. 否则从 **zigtools/zls 的 0.16.0 Release** 拉对应平台的预编译包，写进用户缓存。**解压前先核对官方资源的 SHA256**；对不上就拒绝解压。不会去下随机 nightly。

缓存目录按平台走：`XDG_CACHE_HOME/pi-zig-skills`， Windows 是 `%LOCALAPPDATA%\pi-zig-skills`，其他是 `~/.cache/pi-zig-skills`，下面再放 `zls-0.16.0`。

工具本身用 stdio 跟这份二进制谈 LSP。可以指定 `paths`、 `root`、 `limit`；不传 `paths` 就扫工作区根，默认最多打开 50 个 `.zig` / `.zon`。0.2.2 里还有一处实际修过的行为：pull diagnostic 返回空数组时，不把它当成最终结果，会再等 `publishDiagnostics`。

## `/lsp` 被别的 pi-lsp 占了也没关系

机器上如果已经装了另一个 **pi-lsp**，它可能拥有 `/lsp`，列表里看不到 zls。这是预期情况，不是装失败。

用我们这个工具：**`zig_lsp_diagnostics`**。不要去依赖另一个包的 `/lsp` 或 `lsp_diagnostics`。

## 我核对过的诊断

我在一份示例 `.zig` 上跑过 `zig_lsp_diagnostics`，**未使用的局部常量**能报出来。

这篇只写我核对过的这一条。类型错误、Sema 之类的，我没有在同一条验证路径上核对，就不写。

## 版本和链接

当前就是 **0.2.2**：

- 仓库：<https://github.com/luodaoyi/pi-zig-skills>
- npm：<https://www.npmjs.com/package/pi-zig-skills/v/0.2.2>
- Pi：<https://pi.dev/packages/pi-zig-skills>
- 对应提交： `0eb8535240843f1d213f0366ef50b949fc3487e0`

装完看两个 skill 在不在，再对一个带未使用局部常量的 `.zig` 调一次 `zig_lsp_diagnostics`，就能确认这条诊断通道是通的。
