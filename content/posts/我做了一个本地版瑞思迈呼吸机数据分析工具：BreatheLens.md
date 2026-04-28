---
title: "我做了一个本地版瑞思迈呼吸机数据分析工具：BreatheLens"
categories: [ "项目","开发","工具" ]
tags: [ "ResMed", "瑞思迈", "CPAP", "APAP", "Python", "PySide6", "QML", "医疗数据" ]
draft: false
slug: "我做了一个本地版瑞思迈呼吸机数据分析工具-breathelens"
date: "2026-04-28T13:50:00+08:00"
---

最近我做了一个新项目，叫 **BreatheLens**。

项目地址：

```text
https://github.com/luodaoyi/BreatheLens
```

它是一个专门用来分析 **ResMed 瑞思迈 CPAP / APAP 呼吸机 SD 卡数据** 的本地工具。目标很直接：**把原始治疗数据整理成更容易看懂的图表、表格和建议。**

很多人手里其实并不缺数据，缺的是一个足够直接、足够轻量、又不逼你折腾半天的查看方式。BreatheLens 就是朝这个方向做的。

<!--more-->

## 为什么我会做这个项目

如果你接触过呼吸机数据，大概率会遇到几个很现实的问题。

第一，数据虽然都在 SD 卡里，但原始文件本身并不适合直接看。

第二，很多时候你想看的不是“文件有没有”，而是：

- 最近 AHI 怎么样
- 漏气是不是越来越高
- 压力是不是经常顶到上限
- 哪几天需要优先关注

第三，有些工具虽然强，但对普通用户来说流程偏重，或者不够直观。

所以我做 BreatheLens 的思路一直很明确：

**本地运行，少依赖，选中目录就能分析。**

不用先上传云端，不用折腾数据库，也不用为了看几项核心指标先把整套流程学一遍。

## BreatheLens 能做什么

这个项目现在已经能覆盖一套比较完整的瑞思迈数据查看流程。

它可以直接读取呼吸机 SD 卡目录里的原始数据，主要包括：

- `STR.edf`
- `DATALOG/*_PLD.edf`
- `DATALOG/*_EVE.edf`
- `Identification.tgt`

然后把这些数据整理成更适合阅读的结果，比如：

- 每日使用时长
- AHI、CAI、OAI
- 95% 漏气
- 95% 压力
- 会话统计
- 事件明细
- 漏气观察
- 调整建议
- Excel 导出报告

你不用自己翻 EDF 文件，也不用先理解一堆底层结构，工具会直接把更关键的东西提炼出来。

## 这个工具最适合什么人

我觉得 BreatheLens 特别适合下面几类人：

### 1. 想快速看自己治疗数据的人

你只想知道最近治疗情况怎么样，哪里可能有问题，不想先学一堆复杂工具。

### 2. 手里已经有瑞思迈 SD 卡数据的人

只要目录里有 `STR.edf`、`DATALOG`、`SETTINGS` 这些内容，就可以直接拿来分析。

### 3. 更在意本地隐私的人

有些人不喜欢把医疗相关数据传到云端，那本地工具就会更安心一些。

### 4. 想先做“第一眼判断”的人

有时候你不是立刻要做专业医疗判断，而是先想看：

- 漏气有没有明显异常
- 压力是不是需要关注
- 哪些天的数据最值得优先看

这种场景下，BreatheLens 会比单纯看原始文件省事很多。

## 界面上，我想尽量做到“打开就会用”

BreatheLens 不是那种功能很多但很难上手的桌面程序。

它现在的界面重点主要放在几个地方：

- **主界面概览**
- **关键指标趋势图**
- **STR 每日汇总**
- **DATALOG 会话和事件**
- **Leak Watch 漏气观察**

这几个页面其实对应的是几种最常见的查看需求。

### 主界面

你可以先看到整体数据概览、建议、语言切换和目录选择。适合第一次导入数据时先快速扫一眼。

![BreatheLens 主界面](https://raw.githubusercontent.com/luodaoyi/BreatheLens/main/docs/images/1.png)

### 趋势图

内置了关键指标曲线，比如：

- AHI
- 95% 漏气
- 95% 压力

想看长期变化趋势，这里最直接。

![BreatheLens 关键图表](https://raw.githubusercontent.com/luodaoyi/BreatheLens/main/docs/images/2.png)

### STR 每日汇总

这页适合看长期治疗数据，比如每天用了多久、AHI 怎么变化、压力和漏气有没有持续异常。

![BreatheLens STR 汇总](https://raw.githubusercontent.com/luodaoyi/BreatheLens/main/docs/images/3.png)

### DATALOG 页面

适合看更细一点的会话时长和事件统计。

![BreatheLens DATALOG](https://raw.githubusercontent.com/luodaoyi/BreatheLens/main/docs/images/4.png)

### Leak Watch

这个页面我自己挺看重。很多时候先别急着改压力，**先看漏气**，反而更有效。它能帮助你先把高漏气日期快速筛出来。

![BreatheLens 漏气观察](https://raw.githubusercontent.com/luodaoyi/BreatheLens/main/docs/images/5.png)

## 不只是看数据，也会给出一些趋势建议

BreatheLens 不只是把数字堆出来，它还会基于数据趋势给出一些调整建议。

当然，这里要说清楚：

**它给的是数据层面的提示，不是医疗诊断。**

目前重点会关注这些方向：

- 漏气是否偏高
- 压力是否经常打到上限
- 中枢事件是否偏高

这类建议更像是“帮你先定位问题的方向”，而不是替代医生判断。

如果出现明显异常，比如：

- CAI 持续升高
- 夜间低氧
- 胸闷、心悸
- 白天明显嗜睡

那还是应该带着原始数据去找专业医生。

## 我觉得它有几个地方比较实用

### 1. 全程本地

不需要上传数据，这对呼吸机这种带隐私属性的数据来说很重要。

### 2. 不依赖 OSCAR 数据库

不是说别的工具不好，而是有时候你只是想**先快速看一眼数据**，BreatheLens 这条路径更短。

### 3. 支持 Excel 导出

现在可以导出包含这些 sheet 的 Excel：

- `Summary`
- `STR_Daily`
- `DATALOG_Daily`
- `Leak_Watch`
- `Suggestions`
- `Codebook`

如果你习惯留档或者发给别人看，这个会很方便。

### 4. 多语言支持

界面现在支持：

- 中文
- 英文
- 德文
- 法文
- 俄文
- 西班牙文
- 葡萄牙文
- 日文
- 韩文
- 阿拉伯文

对一个桌面工具来说，这个覆盖已经挺够用了。

### 5. 桌面工具体验更直接

项目基于 **PySide6 + QML**，界面是偏简洁实用的路线，不是那种为了“炫”而牺牲信息读取效率的设计。

## 怎么运行

如果你想自己跑起来，命令也很简单：

```bash
uv venv .venv
uv sync
uv run python main.py
```

如果你想自己打包：

```bash
uv run python build.py
```

构建结果会在 `dist/` 目录里。

## 这个项目现在已经开源了

仓库地址再放一次：

**https://github.com/luodaoyi/BreatheLens**

如果你自己就在用瑞思迈呼吸机，或者你对这类本地医疗数据工具感兴趣，可以直接去看看。

我做这个项目，不是为了把功能做得特别花，而是想把一件事情做得更顺手一点：

**让呼吸机数据从“躺在 SD 卡里”变成“几分钟内就能看懂”。**

如果这正好也是你想要的，那 BreatheLens 可能会对你有用。
