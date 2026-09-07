# 首页配图

## 故事分镜人物

- 文件：`assets/images/story-character.png`。
- 生成方式：内置 ImageGen，先根据用户提供的真人肖像和手绘头像生成一张六格图集，再做一次背景和格内留白修整。
- 输出尺寸：1536 × 1024，三列两行；按行依次为招呼、编程、修小主机、记笔记、交流、头像。
- 页面交付：Hugo 转换为 1536px WebP，浏览器通过格子坐标复用同一图集。原始真人照片不加入站点。
- 采用白色纸片背景，保留黑发、眼镜、黑色穿搭和水彩笔触；各幕文案由页面提供。

首次生成提示词见 [story-character.prompt.txt](assets/images/story-character.prompt.txt)。最终定向编辑使用内置 ImageGen，提示词如下：

```text
Use case: precise-object-edit. Edit this existing watercolor character sprite sheet for use on a personal developer website. Preserve the same man's identity, facial features, glasses, black tousled hair, dark blazer and shirt, watercolor paper-cut illustration style, and exactly the same six poses and props. Single targeted correction: replace ALL gray/white checkerboard background with a completely uniform solid pure white (#FFFFFF) background. No checkerboard, no grid, no gradients, no text, no borders or watermarks. Also normalize composition into exactly 3 columns x 2 rows of equal square cells on a 3:2 canvas. Each entire pose with all shoes, fingers, furniture and props must fit inside its own cell with at least 8% clear white margin on ALL four edges of that cell. Make the entire character a little smaller within each cell as necessary. Cells in exact reading order: top left standing waving; top middle seated typing at laptop desk; top right crouching repairing a small PC; bottom left seated writing notebook; bottom middle standing with coffee in one hand and the other hand open welcoming; bottom right portrait head-and-shoulders. Keep all six poses distinct and visually consistent. All cell corners and boundaries must be pure solid white; background must be opaque white, not transparency. Do not redraw as a different style or change the face. Output one final cleaned sprite sheet at 3:2 aspect ratio.
```

## 原桌面插画

此图保留作素材备份，当前首页使用上方人物分镜。

- 文件：`assets/images/developer-desk.png`
- 生成方式：内置 ImageGen；一次生成，无后续重绘。
- 输出尺寸：1254 × 1254。
- 页面交付：Hugo 在构建时压缩为 1000px WebP，保留原 PNG 供维护。
- 用途：个人首页右侧的原创开发者桌面插画，不代表作者真实工作环境。

最终提示词：

```text
Use case: stylized-concept
Asset type: original editorial illustration for the right-hand hero area of a personal software developer blog, displayed at approximately 500×500 pixels.
Primary request: an editorial paper-cut collage of a practical software developer's compact desktop.
Scene/backdrop: the objects sit on a very pale cool lavender torn notebook sheet with subtle ruled lines, isolated against a pure white background.
Subject: one open graphite laptop showing abstract dark code lines with no legible words; one small steel mini PC with simple vents; one open notebook and a blue pen.
Style/medium: hand-painted watercolor and pencil textures on real cutout paper, charming but mature.
Composition/framing: centered spacious composition, square 1024×1024, generous blank outer margin. Keep the objects clearly readable at a small hero illustration scale.
Lighting/mood: soft daylight and subtle paper shadows.
Color palette: restrained cobalt and indigo accents, graphite and soft paper gray.
Constraints: no people, no logos, no watermark, no text, no decorative unrelated objects. Do not generate a website mockup or screenshot. Generate exactly one image.
```
