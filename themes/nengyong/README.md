# nengyong（能用）

为 [luodaoyi.com](https://luodaoyi.com/) 量身设计的 Hugo 主题。

## 页面风格

按 [Justin3go](https://github.com/Justin3go/justin3go.com) 的个人首页和博客阅读风格适配，继续使用 Hugo，保留本站内容、固定链接与 GitHub Pages 构建流程。

| 维度 | 选择 |
| --- | --- |
| 首页 | 本人形象五幕故事分镜、项目卡片、关于、最近文章、联系 |
| 配色 | 纯白与蓝色链接；深色背景与黄色强调 |
| 列表 | 大号空心日期、细边框标签、文章摘要、右侧目录 |
| 阅读 | 688px 正文列、64px 间隔、224px 目录 |
| 字体 | 本地 Niconne 标识、系统正文、等宽代码 |

## 功能

- 明/暗/跟随系统三态主题切换（`localStorage` 记忆）
- 个人作品首页，项目资料位于根目录 `data/profile.toml`
- 五幕手绘人物随滚动换场、左右移动，四段切换各含三张中间姿势，共十七帧；手机与减少动态效果模式显示静态分镜
- 文章目录与首页章节导航（sticky + 滚动高亮）
- 代码高亮（Chroma）+ 一键复制
- 分类 / 标签 / 分页 / 相关文章 / 相邻文章
- Utterances 评论、Google Analytics、不蒜子统计
- 源码 / 编辑链接（对接 GitHub 仓库）

## 启用

```toml
theme = "nengyong"
```

兼容现有站点 `config.toml` 中的 `params.header`、`params.author`、`params.page.comment.utterances`、`params.analytics`、`params.busuanzi` 等字段。

首页展示个人作品；完整文章列表位于 `/posts/`，旧的 `/page/N/` 分页链接仍可访问。首页最近文章自动读取已发布内容。

首页样式在 `assets/css/profile.css`，共享阅读样式在 `assets/css/main.css`。项目文字取自本站原有关于页；更改项目时同步维护 `data/profile.toml` 与 `content/about/index.md`。

故事分镜的文案与主姿势坐标位于 `data/storyboard.toml`，三列两行的角色图集在 `assets/images/story-character.png`（最后一格用于首页小头像）。三列四行的中间姿势图集在 `assets/images/story-transitions.png`，每行依次连接相邻两幕，三列对应动作进度 25%、50%、75%。分镜样式与滚动逻辑分别为 `assets/css/storyboard.css` 和 `assets/js/storyboard.js`。

桌面动画按滚动进度显示一个人物姿势，拖动滚动条跳转时会短暂补帧；说明文字先淡出再切换，避免人物与文字重影。中间姿势图片只在启用桌面动画时加载，两张图集就绪后才显示浮层。只有首页加载分镜脚本，关闭 JavaScript 时仍可阅读各幕插图和文案。

中间图集的实际像素尺寸及行边界记录在 `data/storyboard.toml` 的 `transitions` 中。生成图片的行高有轻微偏差，裁切按这些边界去除参考线，并居中补白，不拉伸人物；替换图集时同步更新边界。

字体及参考样式的来源见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)，原创配图记录见 [ASSETS.md](ASSETS.md)。

## 本地预览

```shell
hugo server -D
```
