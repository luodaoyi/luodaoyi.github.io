---
title: "让 Codex 和 Claude Code 调用 Grok：grok-build 本地 Runtime Bridge"
categories: [ "项目", "工具", "开发" ]
tags: [ "Grok", "Codex", "Claude Code", "OpenCode", "Rust", "Agent Skill", "AI 编程" ]
draft: false
slug: "让-codex-和-claude-code-调用-grok-grok-build-本地-runtime-bridge"
date: "2026-07-23T13:00:00+08:00"
---

最近我做了一个更重要的项目：**grok-build**。

源代码仓库：

<https://github.com/luodaoyi/grok-bridge-rs>

一句话概括：**它是一个用 Rust 写的本地 Runtime Bridge，让 Codex、Claude Code、OpenCode 这类 Agent 可以把开发任务交给 Grok CLI，同时保留会话、终端、状态和人工接管能力。**

<!--more-->

先说明一个容易混淆的地方：这个项目对接的是 **Grok CLI**，也就是 xAI 的 Grok，不是 Groq API。仓库名是 grok-bridge-rs，安装后使用的 Skill 名称是 grok-build。

## 我为什么要做这个 Bridge

让一个 Agent 调另一个 Agent，表面上看只是启动一个命令：

~~~text
Codex -> 启动 Grok CLI -> 等待结果
~~~

但真正用起来，很快就会遇到一堆问题：

- 每次请求都新建一个进程，任务多了以后很难管理
- 不知道某个 Grok 进程属于哪一次 Codex 对话
- 想看它当前的终端输出，只能盯着原始日志
- 想追加要求、发送 Ctrl+C 或停止任务，不容易做得可靠
- Codex 断开后，后台进程可能变成没人负责的孤儿
- 多个 Codex 同时工作时，会话和工作目录容易混在一起

我更希望它像一个真正的本地开发运行时，而不是一层“一次请求、一次进程”的薄包装。

因此 grok-build 的核心不是把 Grok 启动起来，而是把 Grok 的会话**长期、可见、有归属地管理起来**。

## 它的整体结构

grok-build 由三部分组成：

1. Agent Skill：告诉 Codex 或其他宿主 Agent，什么时候应该委托任务、怎样创建和检查会话
2. grok-bridge：Rust 编写的本地 Runtime Server 和 CLI，负责进程、PTY、会话和本地 IPC
3. WebUI / 终端客户端：查看实时输出、发送后续指令、停止会话或手工接管

可以把数据流理解成这样：

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
       |
       v
    真实终端会话
~~~

Runtime 会统一持有 Grok 的 PTY 和会话状态。CLI、WebUI 和可选的 GUI 终端都只是客户端，不会各自偷偷创建一套后台进程。

这就是它和普通 shell wrapper 最大的区别。

## 它具体解决了什么问题

### 1. 一个本地 Runtime 管理所有会话

Runtime 会按需启动，并由它负责创建和保存 Grok 会话。

后续操作不是再次启动 Grok，而是对已有会话执行：

- 创建
- 查看列表
- 查看状态
- 读取终端输出
- 发送后续指令
- 调整终端尺寸
- 等待空闲或进程退出
- 中断或关闭

因此一个长任务可以先让 Codex 创建，再在需要时读取它的状态，最后继续发送要求，而不用丢失上下文。

### 2. 终端是真实可交互终端

Grok 在自己的 PTY 中运行，不是把输出拼成一段字符串就结束。

你可以：

- 查看当前终端画面
- 读取增量输出
- 继续发送指令
- 发送中断
- 调整终端行列
- 连接 GUI 终端进行人工接管

这对真实开发任务很重要。任务可能会等待确认、需要补充信息，或者执行到一半发现方向需要调整。可交互会话比一次性返回结果可靠得多。

### 3. 会话有清晰的 Codex 归属

每个 Codex 对话可以带一个短标题和稳定身份。

多个 Codex 同时工作时，WebUI 会按 Codex 对话分组，每组下面再显示属于它的 Grok 会话。这样你能很快回答：

- 这个 Grok 在为哪个任务工作
- 它的工作目录是什么
- 现在是运行中、等待中还是已经结束
- 关闭这个会话会不会影响别的 Codex

项目会优先使用 CODEX_THREAD_ID，并兼容回退到 CODEX_SESSION_ID，避免只靠容易重复的标题来判断归属。

### 4. Hook 能补充生命周期状态

grok-build 不只看终端标题，还提供 Hook 来记录 Grok 的生命周期：

- 开始工作
- 等待用户或工具
- 工具调用
- 错误
- 一轮完成
- 权限或子任务相关事件

Hook 是观察通道，PTY 和 Runtime 仍然是最终控制面。即使 Hook 暂时不可用，也不会把它误判成任务失败。

### 5. 断开后不会立刻误杀任务

Codex 或浏览器暂时断开，不代表 Grok 任务应该马上被杀掉。

Runtime 使用 lease、heartbeat 和 orphan grace 机制：

- 正在工作或等待中的会话会保留
- 连接恢复后可以继续查看
- 空闲或已结束的会话，经过安全阶段和宽限期后才会清理
- 需要时可以只关闭一个会话，也可以关闭某个 Codex 对话创建的全部会话

这让“网络断了一下”和“任务已经应该结束”不再混为一谈。

## WebUI 有什么用

执行 server ui 后，项目会启动一个只监听本机回环地址的面板：

~~~text
http://127.0.0.1:47653
~~~

面板里可以看到：

- Codex 对话分组
- 每个 Grok 会话的状态
- 最近的 Hook 活动
- 当前活动工具和等待原因
- 工作目录
- 进程信息
- 实时终端输出
- lease 和清理倒计时
- 关闭单个会话或整个 Codex 分组

最近版本的 WebUI 使用实时 WebSocket 事件流和 xterm.js 终端，不需要一直用两秒一次的轮询去刷新整页。终端默认是只读的，需要手工输入时再显式打开输入能力。

WebUI 的定位是“查看和管理”，不是替代编辑器或 Git。代码、命令和文件仍然在本机工作目录里。

## 怎么安装

### 第一步：准备 Grok CLI

先安装并登录 Grok CLI，在终端确认：

~~~text
grok --version
~~~

项目不会替你安装 Grok CLI，也不会替你处理登录。它假设 Grok 已经可以在当前用户环境中正常运行。

### 第二步：下载 grok-build Skill

打开 [grok-bridge-rs Releases](https://github.com/luodaoyi/grok-bridge-rs/releases) 页面，下载最新的 Skill 压缩包。

截至 2026 年 7 月 23 日，最新版本是 **v0.8.2**：

~~~text
grok-build-skill-v0.8.2.zip
grok-build-skill-v0.8.2.zip.sha256
~~~

建议先用 .sha256 文件校验压缩包，再解压到当前宿主 Agent 的用户级 Skill 目录。解压后的目录名应当是：

~~~text
grok-build/
~~~

压缩包里包含：

- SKILL.md
- agents/openai.yaml
- Hook 模板
- Windows x86_64 / ARM64 原生程序
- Linux x86_64 / ARM64 原生程序
- macOS Intel / Apple Silicon 原生程序

如果你让 Claude Code、Codex 或 OpenCode 帮你安装，应该先让它检查自己的 Skill 发现规则，不要直接照搬另一个 Agent 的目录约定。

### 第三步：检查并打开本地面板

Windows x86_64 可以这样运行：

~~~powershell
$bridge = "$env:USERPROFILE\.agents\skills\grok-build\bin\windows-x86_64\grok-bridge.exe"
& $bridge doctor
& $bridge hooks install
& $bridge server ui
~~~

Windows ARM64 把路径中的 windows-x86_64 换成 windows-arm64。

Linux x86_64：

~~~sh
bridge="$HOME/.agents/skills/grok-build/bin/linux-x86_64/grok-bridge"
"$bridge" doctor
"$bridge" hooks install
"$bridge" server ui
~~~

macOS 和 Linux ARM64 同理，替换为对应的 macos-x86_64、macos-arm64 或 linux-arm64。

hooks install 是幂等操作，只管理 grok-build 自己的 Hook 配置，并保留其他无关 Hook。doctor 用来尽早发现 Grok CLI、目录权限或平台二进制问题。

## 在 Codex 里怎么用

安装完成后，Codex 可以按 Skill 说明使用：

~~~text
$grok-build
~~~

实际委托时，应该把任务拆成一个边界清晰的工作单元，并告诉它：

- 目标是什么
- 允许修改哪些目录
- 验收标准是什么
- 需要运行哪些检查
- 哪些操作明确禁止

例如让 Codex 把“给当前项目补一个单元测试并运行测试”交给 Grok，而不是只说“帮我把项目做好”。这样 Runtime 的会话才有明确的责任边界，Codex 也能在最后独立检查 diff 和测试结果。

Skill 的设计原则是：**Grok 负责一个具体实现任务，Codex 负责拆解、整合和最终验收。**

这也是我比较看重的地方。它不是让一个 Agent 失去控制权，而是给它增加一个可观察、可追问、可关闭的协作工位。

## CLI 里有哪些核心命令

所有主要命令都返回 JSON，适合 Agent 自动化：

| 命令 | 用途 |
| --- | --- |
| server start / status / stop | 管理本地 Runtime |
| server ui | 启动 Runtime 并打开 WebUI |
| create | 创建一个 Grok 会话 |
| list / show | 查看会话列表和详细状态 |
| read | 按游标读取增量终端输出 |
| send | 发送后续文本或中断 |
| write / resize | 写入原始字节或调整 PTY 尺寸 |
| wait | 等待 TUI 空闲或进程退出 |
| close | 关闭指定会话 |
| heartbeat | 刷新当前 Codex 的 lease |
| close-codex | 关闭当前 Codex 创建的全部会话 |
| terminal | 创建或接管一个 GUI 终端 |

命令背后是一个 Server 持有所有会话。CLI 退出不等于 Grok 退出；只有明确关闭会话或停止 Runtime，进程才会被结束。

## 为什么它比普通 Wrapper 更适合长期使用

普通 Wrapper 适合“一次命令，一次结果”：

~~~text
启动 -> 等待 -> 输出 -> 结束
~~~

但 Agent 编程更像这样：

~~~text
创建任务 -> 观察终端 -> 等待工具 -> 追加要求
        -> 发现问题 -> 中断或继续 -> 检查结果
~~~

grok-build 解决的是后面这种状态机问题。

它把“调用 Grok”从一次性的进程启动，提升成一个本地可管理的开发会话。会话可见、身份清楚、输出可增量读取、可以继续交互，也可以在需要时由人接管。

如果你只是偶尔让 Agent 生成一段代码，普通命令包装也许够用；如果你希望让 Codex 长时间、批量、并发地把真实开发任务交给 Grok，这种 Runtime 结构会舒服很多。

## 当前版本和平台

截至 2026 年 7 月 23 日：

- 最新版本：v0.8.2
- 项目语言：Rust
- 许可证：MIT
- Windows：x86_64、ARM64
- Linux：x86_64、ARM64
- macOS：Intel、Apple Silicon
- WebUI 默认地址：127.0.0.1:47653

项目没有人为设置 64 个会话上限，实际并发量取决于机器资源和 Grok CLI 的承载能力。会话越多，越应该通过 WebUI 或 list 定期清理已经无用的任务。

## 安全边界一定要看清

这个项目很方便，但它不是一个可以随便暴露到公网的服务。

### WebUI 没有登录认证

默认只监听：

~~~text
127.0.0.1:47653
~~~

请不要把它绑定到公网网卡。只要能访问 WebUI，别人就可能看到本机的工作目录、终端输出和会话状态。

### Grok 使用当前用户权限

Grok 及它调用的工具都使用当前用户权限运行。启用自动批准前，先确认工作目录、提示词和命令来源可信。

### 不要把秘密放进会话

不要把密码、Token、私钥或其他秘密放进：

- Prompt
- 会话标题
- 会显示在 WebUI 的环境变量
- 终端截图和日志

下载 Release 时也建议校验官方提供的 SHA-256 文件。

## 遇到状态目录不可写怎么办

如果 create 一直停在 Starting session...，或者提示 Grok 状态目录不可写，通常是 Runtime 运行在不能写入 GROK_HOME 或默认 ~/.grok 的沙箱环境里。

可以先查看会话，再确认没有误伤其他任务，然后执行：

~~~sh
grok-bridge server stop
grok-bridge server start
~~~

重新启动时确保当前用户能写入 Grok 状态目录，再重试 create。相对路径的 GROK_HOME 也应该按照会话工作目录解析，避免 Agent 和 Runtime 实际写入两个不同的位置。

## 最后

grok-build 的定位很明确：

**给 Codex 和其他 Agent 一个本地、持久、可观察的 Grok 协作运行时。**

它不是云端中转，不需要 Python，不需要 MCP Server，也不要求额外安装一个独立后台服务。下载 Skill、准备好 Grok CLI 后，剩下的会话管理、终端输出、Hook、WebUI 和清理，都由本机的 Runtime 统一处理。

如果你正在使用 Codex、Claude Code 或 OpenCode，又希望把一部分真实开发工作交给 Grok，建议直接试试：

- [源代码仓库](https://github.com/luodaoyi/grok-bridge-rs)
- [最新 Releases](https://github.com/luodaoyi/grok-bridge-rs/releases)
- [项目说明](https://github.com/luodaoyi/grok-bridge-rs/blob/main/README-CN.md)

这个项目最有价值的地方，不是“又多了一个调用模型的脚本”，而是让另一个 Agent 真正拥有了一个能长期工作、能被观察、能被接管的本地开发会话。
