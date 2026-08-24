---
title: "让 Codex 和 Claude Code 调用 Grok：grok-build 本地 Runtime Bridge"
categories: [ "项目", "工具", "开发" ]
tags: [ "Grok", "Codex", "Claude Code", "OpenCode", "Rust", "Agent Skill", "AI 编程" ]
draft: false
slug: "让-codex-和-claude-code-调用-grok-grok-build-本地-runtime-bridge"
date: "2026-07-23T13:00:00+08:00"
lastmod: "2026-08-24T20:00:00+08:00"
---

最近我做了一个更重要的项目：**grok-build**。

让 Codex、Claude Code、OpenCode 把活交给 **Grok CLI**（xAI 的 Grok，不是 Groq），会话别每次新建一个进程就扔了。仓库名是 grok-bridge-rs，装完用的 Skill 名称是 grok-build。

源代码仓库：

<https://github.com/luodaoyi/grok-bridge-rs>

当前最新是 **v0.8.11**。

<!--more-->

## 我为什么要做这个

表面上看只是启动一条命令：

~~~text
Codex -> 启动 Grok CLI -> 等待结果
~~~

真用起来马上就不对劲：每次请求都新建进程、不知道这个 Grok 属于哪一次 Codex 对话、想看终端只能盯原始日志、想追加要求或 Ctrl+C 不好做、Codex 一断后台就可能变成孤儿。

所以核心不是把 Grok 拉起来，而是把会话长期管住：能看、能续、能关，并且归到某个 Codex 对话下面。

项目分三块：

1. Agent Skill：告诉宿主什么时候该委托、怎么创建和检查会话
2. grok-bridge：Rust 写的本地 Runtime，管进程、PTY、会话和本机 IPC
3. WebUI / 终端客户端：看输出、发后续指令、停会话或手工接管

~~~text
Codex / Claude Code / OpenCode
              |
              v
       grok-build Skill
              |
              v
     grok-bridge Runtime
       |              |
       v              v
    Grok CLI       本地 WebUI
~~~

Runtime 统一持有 PTY 和会话状态。CLI、WebUI 和可选 GUI 终端都只是客户端。每个 Codex 对话可以带短标题和稳定身份，优先用 `CODEX_THREAD_ID`，没有就回退 `CODEX_SESSION_ID`。Hook 用来记生命周期（开始工作、等待、工具调用、错误、一轮完成），PTY 和 Runtime 仍是控制面。Codex 或浏览器断一下，不会立刻把还在干活或等待中的会话杀掉。

## 怎么装

先装好并登录 Grok CLI，终端确认：

~~~text
grok --version
~~~

项目不替你装 Grok，也不替你登录。

打开 [grok-bridge-rs Releases](https://github.com/luodaoyi/grok-bridge-rs/releases)，下载最新 Skill 压缩包。现在是 **v0.8.11**：

~~~text
grok-build-skill-v0.8.11.zip
grok-build-skill-v0.8.11.zip.sha256
~~~

建议先用 `.sha256` 校验，再解压到当前宿主 Agent 的用户级 Skill 目录。解压后的目录名应当是 `grok-build/`。包里有 `SKILL.md`、`agents/openai.yaml`、Hook 模板，以及 Windows / Linux / macOS 的 x86_64 和 ARM64 原生程序。仓库 README 现在也写了包管理器全局安装，装完用中文 TUI 更新 Skill；ZIP 仍然可用。

让 Claude Code、Codex 或 OpenCode 帮你装时，先让它检查自己的 Skill 发现规则，不要直接照搬另一个 Agent 的目录约定。

Windows x86_64：

~~~powershell
$bridge = "$env:USERPROFILE\.agents\skills\grok-build\bin\windows-x86_64\grok-bridge.exe"
& $bridge doctor
& $bridge hooks install
& $bridge server ui
~~~

Windows ARM64 把路径中的 `windows-x86_64` 换成 `windows-arm64`。

Linux x86_64：

~~~sh
bridge="$HOME/.agents/skills/grok-build/bin/linux-x86_64/grok-bridge"
"$bridge" doctor
"$bridge" hooks install
"$bridge" server ui
~~~

macOS 和 Linux ARM64 同理，换成 `macos-x86_64`、`macos-arm64` 或 `linux-arm64`。

`hooks install` 是幂等的，只管理 grok-build 自己的 Hook。`doctor` 用来尽早发现 Grok CLI、目录权限或平台二进制问题。

`server ui` 之后本机面板在：

~~~text
http://127.0.0.1:47653
~~~

默认只监听回环。别绑到公网。能打开面板就能看到工作目录、终端输出和会话状态。

0.8.3 之后我用下来比较有感的几处：WebUI 补了多语言和字体，Windows 上 named pipe 空读不再被当成 EOF，ConPTY 也会在 Grok PID 握手前先泵数据。

## 在 Codex 里怎么用

安装完成后按 Skill 说明：

~~~text
$grok-build
~~~

实际委托时把任务拆清楚：目标是什么、允许改哪些目录、验收标准、要跑哪些检查、哪些操作禁止。比如让 Codex 把「给当前项目补一个单元测试并运行测试」交给 Grok，而不是只说「帮我把项目做好」。Grok 负责一个具体实现任务，Codex 负责拆解、整合和最终验收。

主要命令都返回 JSON。常用的：`server start / status / stop / ui`，`create`，`list` / `show`，`read`，`send`，`wait`，`close`，`heartbeat`，`close-codex`，`terminal`。CLI 退出不等于 Grok 退出；只有明确关闭会话或停止 Runtime，进程才会被结束。

## 状态目录写不进去

如果 `create` 一直停在 `Starting session...`，或者提示 Grok 状态目录不可写，通常是 Runtime 跑在写不了 `GROK_HOME` 或 `~/.grok` 的环境里。先查看会话，确认没有误伤其他任务，然后：

~~~sh
grok-bridge server stop
grok-bridge server start
~~~

重新启动时确保当前用户能写入 Grok 状态目录。相对路径的 `GROK_HOME` 按会话工作目录解析。

Grok 及它调用的工具都用当前用户权限。不要把密码、Token、私钥放进 Prompt、会话标题、会显示在 WebUI 的环境变量，或终端截图。下载 Release 时建议校验官方 SHA-256。

## 版本

- 最新版本：v0.8.11
- Rust，MIT
- Windows / Linux / macOS：x86_64、ARM64
- WebUI：127.0.0.1:47653

没有人为设置 64 个会话上限，实际并发量取决于机器和 Grok CLI。没用的会话用 WebUI 或 `list` 清掉就行。

- [源代码仓库](https://github.com/luodaoyi/grok-bridge-rs)
- [最新 Releases](https://github.com/luodaoyi/grok-bridge-rs/releases)
- [项目说明](https://github.com/luodaoyi/grok-bridge-rs/blob/main/README-CN.md)
