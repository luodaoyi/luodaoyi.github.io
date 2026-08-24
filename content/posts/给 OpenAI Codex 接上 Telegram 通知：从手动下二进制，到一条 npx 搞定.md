---
title: "给 OpenAI Codex 接上通知：现在用 codex-notify"
categories: [ "工具","开发" ]
tags: [ "codex", "telegram", "npm", "rust", "openai" ]
draft: false
slug: "给-openai-codex-接上-telegram-通知-从手动下二进制-到一条-npx-搞定"
date: "2026-04-20 12:42:32"
lastmod: "2026-08-24T20:00:00+08:00"
---

我最近把这个小工具又整了一轮：仓库还叫 `go-codex-notify`，本体已经是 Rust，当前最新是 v1.3.23。全局命令和原生程序都叫 `codex-notify`。

它还是给 Codex 接通知，但渠道不再只有 Telegram。Bark、OpeniLink Hub、Hermes Webhook 都能配，配了几个就同时发。

这个东西本身不复杂，但它解决的是一个很实际的问题：**AI 在后台干活的时候，你不想一直盯着终端。**

以前最大的别扭是分发。最早是自己下二进制，后来我推过一段时间用 Node 包装拉对应平台。那条路能用，也写进过旧文。现在更稳的做法是：全局装一次原生程序，命令统一用 `codex-notify`。

<!--more-->

## 它解决什么

如果你平时用 Codex 写代码，应该很容易碰到下面这种场景：

- 任务一跑就是十几分钟，甚至更久
- 你不想一直把终端窗口切回来看看结束没
- 你离开电脑去吃饭、开会、刷手机的时候，根本不知道它什么时候完成

这时候一个最朴素的需求就是：**跑完了通知我一下。**

Telegram 恰好很适合干这个事：

- 配一个 bot 很快
- 消息直达
- 自己给自己发、发群里都行
- 不依赖本地弹窗，也不怕远程机器没桌面环境


## 现在主推全局命令

最早是自己下 Release 文件。后来我改成一条包装命令，第一次运行再拉对应平台。那是当时最省事的分发。

现在项目已经换成 Rust。包管理器只负责放好当前系统的原生程序，后面直接跑 `codex-notify`。旧命令名还留着，但推荐用新名字。从更早版本过来的人，升级后再同步一次配置，避免旧入口和新 Hook 各发一遍。

## 它怎么工作

真正发消息的是 Rust 程序。它读 Codex 的 Hook 输入，把「用户输入」和「Codex 回应」发到已配置的渠道。会话 ID、工作目录、模型这些不会进通知正文。

包管理器只是分发层。Node 18+ 用来把原生程序放到全局命令，Windows 上是 `codex-notify.exe`。无参数且在交互终端里会进 TUI；否则用子命令。

渠道可以只留实际在用的：

- Telegram：Bot Token 和 Chat ID 都填才启用
- Bark：完整 HTTP POST 地址
- Hermes Webhook：地址，可选签名密钥
- OpeniLink Hub：地址加 Bearer Token

多个渠道会同时发送。配置文件默认在用户目录下的 Codex 配置里，也可用环境变量覆盖。TUI 保存时会同步二进制副本和 Hook：仅主代理只注册 Stop，主代理加 SubAgent 会再加上 SubagentStop。

## 怎么接 Telegram

### 第一步：准备 Telegram Bot Token

在 Telegram 里找 `@BotFather`，发送 `/newbot`，按提示创建一个 bot。

创建完成后会得到一个 token，长这样：

```text
123456789:ABCDEF_xxxxxxxxxxxxx
```

这就是你的：

```text
TELEGRAM_BOT_TOKEN
```

### 第二步：拿到 Chat ID

你需要先给这个 bot 发一条消息。

最稳妥的做法是先发一次 `/start`，然后打开：

```text
https://api.telegram.org/bot<你的BotToken>/getUpdates
```

在返回的 JSON 里找：

```text
message.chat.id
```

如果是私聊，通常是这样的纯数字：

```text
123456789
```

如果是群组，一般会长这样：

```text
-100xxxxxxxxxx
```

这个负号和前面的 `-100` 不要丢。

### 第三步：设置环境变量

比如在 macOS / Linux 上：

```bash
export TELEGRAM_BOT_TOKEN="123456789:xxxxxx"
export TELEGRAM_CHAT_ID="123456789"
```

Windows PowerShell 则可以这样：

```powershell
$env:TELEGRAM_BOT_TOKEN="123456789:xxxxxx"
$env:TELEGRAM_CHAT_ID="123456789"
```

## 现在怎么用

推荐全局装一次原生程序，命令统一用 `codex-notify`。旧的 npx 包装只留给已经在用的人升级。

最短路径：

1. 用包管理器全局装 `go-codex-notify@latest`，然后运行 `codex-notify`。
2. 在 TUI 里填至少一个渠道，通知范围建议「仅主代理」，保存。
3. 新开 Codex 会话，运行 `/hooks`，确认并信任指向本机 `codex-notify` 的 Hook。

Telegram 的 Bot Token 和 Chat ID 拿法没变。在 Telegram 找 BotFather 建 bot，给 bot 发一条消息，再从 getUpdates 里取 chat.id。也可以先只写环境变量再开 TUI。

需要检查状态或手工测一条时，用 `codex-notify status` 和 `codex-notify notify`。卸载本工具写入的 Hook，用对应的移除子命令，不会动别人的配置。

旧文里那条顶层 notify 包装命令，只当作升级路径看。新装不要再把它当主入口。

仓库还在原来的地址。旧的包装入口只留给已经在用的人升级，新上手请走全局命令和 TUI。

仓库：https://github.com/luodaoyi/go-codex-notify

