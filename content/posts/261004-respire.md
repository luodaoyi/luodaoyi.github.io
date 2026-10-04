---
title: "Respire：给 AI 工具一份能带走的记忆"
description: "Respire 是我现在的主要项目：本地优先的 AI 记忆系统。这里介绍 rsrs CLI 的安装、记忆读写、Agent 接入、加密同步，以及当前的平台和许可边界。"
categories: [ "项目", "开发工具" ]
tags: [ "Respire", "rsrs", "AI", "记忆", "本地优先", "Rust" ]
draft: false
slug: "respire"
date: "2026-10-04T13:50:00+08:00"
lastmod: "2026-10-04T13:50:00+08:00"
---

换一个 AI 工具，或者重新开一段会话，之前说过的项目背景、做过的决定、反复确认的约定，经常又得讲一遍。

我现在主要做的项目叫 **Respire**。它是一套本地优先的记忆系统：在自己的设备上保存和检索记忆，需要多设备协作时，再同步加密后的记录。终端命令只有一个，叫 **`rsrs`**。

先把项目介绍和上手方法放在这里。

- 官网：<https://rsrs.rs>
- CLI：<https://github.com/risense-ai/respire-cli>
- 文档：<https://github.com/risense-ai/respire-docs>

<!--more-->

## 它用来做什么

适合留下来的，是下次工作还用得上的东西。比如：

- 一个项目为什么选了现在的方案
- 已经确认过的命名、目录和协作约定
- 排查问题时找到的原因，以及最后怎么处理的
- 需要继续推进的事情，和相关的上下文

这些内容可以用 CLI 主动写入，也可以让接入的 AI 工具按指令先查再写。换工具时，仍然从同一份记忆里找背景，不必把资料再整理一遍。

最基本的工作流很简单：**先 recall，确认已有的内容；有值得留下的新信息，再 remember。** 检索结果需要结合当前任务判断，旧决定也可能需要更新。

## 记忆放在哪里

本机的记忆库是日常工作的基础。CLI 负责命令入口、身份、加密、存储和同步；Core 提供本地模型与检索能力；客户端通过 CLI 操作记忆。

记忆记录在本地加密保存，跨设备同步传输加密记录。服务端负责认证和同步存储，不持有客户端解密密钥。默认的快速检索在本地完成，不需要向同步服务器请求检索结果。

这里有两个边界要说清楚：

1. 本地优先不等于所有操作都不联网。安装程序、下载模型、登录和同步，都可能需要网络。
2. 显式选择高质量检索模式时，会把查询和限定数量的候选标题发给配置的模型接口。记忆正文和祖先正文不发送给这个筛选接口。使用前要看清接口地址和数据范围。

另外，本地派生的检索特征不能当成加密保护，运行时解密后的内容也需要保护。具体边界见 [架构说明](https://github.com/risense-ai/respire-docs/blob/main/docs/architecture.md) 和 [检索模式](https://github.com/risense-ai/respire-cli/blob/main/docs/retrieval.md)。

## 安装 rsrs

已经有 Node.js 和 npm 的话，可以直接装：

```shell
npm i -g @rsrsai/cli
```

用 pnpm 的话，二选一就行：

```shell
pnpm add -g @rsrsai/cli
```

装完先检查：

```shell
rsrs --version
rsrs help
rsrs doctor
```

截至 2026 年 10 月 4 日，npm 的 latest 和 CLI 稳定版都是 **1.0.8**。版本更新后，以 [npm 包](https://www.npmjs.com/package/@rsrsai/cli) 和 [CLI Releases](https://github.com/risense-ai/respire-cli/releases) 为准。

当前 CLI 的分发目标包括 Windows x64 / ARM64、Linux x64 / ARM64 和 Apple Silicon Mac。**Intel Mac 暂不在支持的分发目标里。** Linux 默认选择 musl 包；要用 GNU/glibc 包，需要兼容的 glibc 系统，并显式选择：

```shell
export RSRS_LIBC=glibc
rsrs doctor
```

glibc 包不能在 Alpine 上运行。如果安装时省略了 optional dependencies，需要补装与 `@rsrsai/cli` 相同版本的平台包。不要混用版本。平台包清单和说明见 [npm launcher](https://github.com/risense-ai/respire-cli/blob/main/npm/README.md)。

从 GitHub 手动下载时，要同时拿到同一版本、同一平台的可执行文件和 `runtime.tar.gz`，保留随包的运行库与许可文件。只下载一个可执行文件，不一定能正常运行。

## 从第一条记忆开始

### 1. 准备身份和模型

第一次使用，可以选纯本地身份，也可以注册、登录同步账号。先看自己安装版本的帮助：

```shell
rsrs keygen --help
rsrs register --help
rsrs login --help
rsrs model --help
```

在一个全新的、没有已有账号和记忆的本地环境里，可以用下面的命令创建本地身份：

```shell
rsrs keygen
```

按输出妥善保存恢复材料，不要贴到聊天、截图或仓库里。已有账号或记忆时，按登录与恢复流程继续使用原来的密钥，**不要为了修复登录问题重新生成密钥，更不要随手加 `--force`**。

本地检索还需要匹配的模型资源。按当前版本的诊断结果和 [模型安装说明](https://github.com/risense-ai/respire-cli/blob/main/docs/inference.md) 准备，再用下面的命令检查实际推理情况：

```shell
rsrs model probe --json
```

CPU 是默认引擎。GPU、NPU 需要显式选择、兼容硬件和模型，不能只看机器有这块硬件就认定能用。

### 2. 写入、查找和查看

身份和模型准备好之后，可以先拿一条不含敏感信息的项目约定试试：

```shell
rsrs remember "示例项目的接口字段统一使用 snake_case" --type decision --title "接口命名约定"
rsrs recall "接口字段怎么命名" --limit 3
rsrs tree
```

拿到结果里的 ID 后，查看完整内容：

```shell
rsrs show <id>
```

`<id>` 要替换成实际返回的 ID。想给脚本或 Agent 用，可以先只取标题和结构化结果，再读取需要的条目：

```shell
rsrs recall "接口字段怎么命名" --mode fast --titles --json
rsrs show <id> --json
```

写入时如果返回的是重复候选或合并建议，要先检查结果，再决定怎么处理；收到建议不代表新记忆已经写进去了。

## 接到 AI 工具里

`rsrs inject` 会把随 CLI 提供的指令写入支持的 Agent 配置。先查看本机识别到的目标和路径：

```shell
rsrs inject --targets
```

例如接入 Codex：

```shell
rsrs inject --id codex
```

注入会修改对应配置文件。先确认路径和写入方式，尤其是整文件写入的目标；使用自定义配置目录时，也要确认 Agent 实际读取的是哪一份。改完指令后，重新开会话或重启 Agent，让它加载新配置。

如果之后不再需要这份接入，可以按帮助移除：

```shell
rsrs inject --remove --id codex
```

受限沙箱里的客户端只连接已授权的本机运行时。远程容器和宿主机的 `127.0.0.1` 不是同一个地址，接不上时先检查运行时和认证配置。更完整的说明在 [Agent 接入](https://github.com/risense-ai/respire-docs/blob/main/docs/injection.md) 和 [运行时文档](https://github.com/risense-ai/respire-cli/blob/main/docs/runtime.md)。

## 多设备同步、备份和恢复

默认同步 API 是 `https://api.rsrs.rs`。有有效的同步账号后，可以手动触发一次同步：

```shell
rsrs sync
```

支持的写入也可以由运行时在后台同步。新设备除了登录，还需要对应的密钥恢复材料；服务器不能替你找回丢失的客户端解密秘密。

当前 CLI 默认使用 `~/.rsrs`，本机运行时默认端口是 `15169`。支持的旧默认目录会在启动时迁移，原目录保留；显式指定数据目录时，按指定目录处理。迁移前仍然建议先做备份，细节以 [入门文档](https://github.com/risense-ai/respire-docs/blob/main/docs/getting-started.md) 为准。

备份也要分清楚：`export` 导出的是明文记录，`backup` 保存的是本地 SQLite 数据库。前者要保护好导出文件，后者恢复时还需要匹配的密钥材料。不要只备份数据库，却把恢复材料丢了。具体操作见 [同步与密钥](https://github.com/risense-ai/respire-docs/blob/main/docs/sync-and-keys.md)。

## 网页和桌面端

```shell
rsrs web
```

这个命令会打开 [用户面板](https://dash.rsrs.rs)，不会启动本地 Web 服务器，也不代表本机运行时已经启动。

桌面端也在维护，代码放在 [respire-client](https://github.com/risense-ai/respire-client)。安装包以对应版本的 Releases 实际附件为准，本文先按 CLI 路线介绍上手过程。

## 代码和许可

项目分成几个仓库，按需要看就行：

- [respire-cli](https://github.com/risense-ai/respire-cli)：`rsrs` 命令、运行时和接入
- [respire-client](https://github.com/risense-ai/respire-client)：桌面界面与本地 CLI 桥接
- [respire-server](https://github.com/risense-ai/respire-server)：认证与加密记录同步
- [respire-docs](https://github.com/risense-ai/respire-docs)：使用文档与兼容约定
- [respire-releases](https://github.com/risense-ai/respire-releases/releases)：分发资源

当前公开仓库默认分支中的第一方代码和文档使用 **[Respire Noncommercial License 1.0](https://github.com/risense-ai/respire-cli/blob/main/LICENSE)**。允许个人非商业使用和非商业自托管；商业使用，包括企业内部业务部署，需要事先获得书面授权。具体范围见许可证和 [商业授权说明](https://github.com/risense-ai/respire-cli/blob/main/COMMERCIAL-LICENSE.md)。

历史版本按随版本附带的许可使用，已经授予的权利不因此撤销。本文介绍的安装版本与当前默认分支的许可政策，要分别看对应材料。

Core 实现源码不在这些公开仓库的许可范围里，单独分发的 Core 二进制另有许可。第三方组件和模型也保留各自的许可。公开能看到代码，不代表整套项目都按 MIT 或其他宽松开源许可提供。

Respire 是我现在的主要项目。想先试试，就从安装 `rsrs`、准备本地身份和模型、写入一条小记忆开始。先跑通，再接进自己常用的 AI 工具。
