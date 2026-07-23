# nengyong（能用）

为 [luodaoyi.com](https://luodaoyi.com/) 量身设计的 Hugo 主题。

## 设计出发点

站点副标题是「**能用就行**」——不是敷衍，而是工程审美：

- 文章多为第一人称实战：项目介绍、运维脚本、工具折腾
- 正文重视「问题 → 为什么 → 怎么做 → 代码可复制」
- 大量代码块、表格、列表；中文长文需要好读而非花哨
- 语气直接、自嘲、务实，不需要营销式封面和堆叠动画

因此主题选择：

| 维度 | 选择 |
| --- | --- |
| 气质 | 工坊 / 终端旁的笔记 |
| 强调色 | 暖琥珀（工具、焊锡、够用） |
| 版心 | 阅读优先约 720px；有目录时加宽 |
| 字体 | 系统中文字体 + 等宽元信息 |
| 装饰 | 少；标题 `#` 标记、虚线分割即可 |

## 功能

- 明/暗/跟随系统三态主题切换（`localStorage` 记忆）
- 文章目录（桌面端 sticky + 滚动高亮）
- 代码高亮（Chroma）+ 一键复制
- 分类 / 标签 / 分页 / 相关文章 / 相邻文章
- Utterances 评论、Google Analytics、不蒜子统计
- 源码 / 编辑链接（对接 GitHub 仓库）

## 启用

```toml
theme = "nengyong"
```

兼容现有站点 `config.toml` 中的 `params.header`、`params.author`、`params.page.comment.utterances`、`params.analytics`、`params.busuanzi` 等字段。

## 本地预览

```shell
hugo server -D
```
