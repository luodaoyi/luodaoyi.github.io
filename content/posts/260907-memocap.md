---
title: "我做了一个给多宿主共用的本地记忆：memocap（忆时）"
categories: [ "项目", "开发工具" ]
tags: [ "memocap", "忆时", "记忆", "SQLite", "Codex", "Claude", "Pi", "OpenCode", "Grok" ]
draft: false
slug: "memocap"
date: "2026-09-07T11:30:00+08:00"
lastmod: "2026-09-07T11:30:00+08:00"
---

Codex、Claude、Pi、OpenCode、Grok 各记各的，换个宿主就丢上下文。

于是我做了 **memocap（忆时）**：一份本地 SQLite，多宿主共用。每轮先 recall；决策、偏好、任务、约定查过同类再 remember。

仓库：

<https://github.com/luodaoyi/memocap>

当前 Latest Release 是 **[v0.1.4](https://github.com/luodaoyi/memocap/releases/tag/v0.1.4)**。

<!--more-->

## 安装

```shell
pnpm add -g memocap
memocap install
```

`memocap install` 按宿主写配置：Codex 写 AGENTS.md，Claude 写 CLAUDE.md 和 skill。也可以 `memocap install --host grok,claude` 选宿主，`--all` 写入 Codex/Claude/Grok。Pi 用 `pi install npm:memocap`，OpenCode 用 `opencode plugin memocap`。

## 常用命令

```shell
memocap remember "周五上线"
memocap recall "周五"
memocap list
memocap forget
```

还有 `remember --force`、`recall --type`、`recall --limit 3`。默认走本机 SQLite，不联网。

## 可选：带 token 的小服务

想多机共用同一份库时，起服务并设 `MEMOCAP_TOKEN`，再把本机 `MEMOCAP_ADDR` 指过去（默认端口 8787）。没设 `MEMOCAP_ADDR` 时，CLI 只走本机。

## 和其他记忆工具的差别

claude-mem、agentmemory 一类偏自动抓会话；pi-memory 是 markdown。memocap 是主动 remember / recall：本机一份 SQLite，也可以挂带 token 的服务给多机用。

## 链接

- 仓库：<https://github.com/luodaoyi/memocap>
- Release：[v0.1.4](https://github.com/luodaoyi/memocap/releases/tag/v0.1.4)
