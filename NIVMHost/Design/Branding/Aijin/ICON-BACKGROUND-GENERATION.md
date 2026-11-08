# App 图标奶白背景调整 · 过程记录

当前版本已调整为深墨蓝，见 [ICON-DARK-BACKGROUND-GENERATION.md](ICON-DARK-BACKGROUND-GENERATION.md)。

2026-11-08。用户反馈原图标背景不好看。本轮使用内置 `image_gen.imagegen` 仅调整图标背景，保留现有花帽大眼锦鲤的构图和形象。

当时母版：`Aijin-AppIcon-Master.png`，背景为近似 #FFF8F1 的奶白色，不透明正方形。App 图标及共用的品牌图标均由此导出。页面配色、布局、业务代码以及透明吉祥物和邀请页母版保持本轮开始时的内容。

```text
Use case: precise-object-edit. Asset type: final opaque square iOS app icon for 爱锦. Edit the provided app-icon artwork by changing ONLY the background color. Replace the existing pale mint-green background with a clean uniform softly warm ivory-white, approximately #FFF8F1. This should be a very light neutral creamy white, not yellow, pink, green or a gradient. Preserve the existing koi character as faithfully as possible: same front-facing red-and-cream round fish, enormous aqua eyes, orange fan fins and tail, coral scale-pattern bucket hat with pale pink flower, expression, proportions, pose, exact placement and scale. Do not redesign or relight the fish. Keep all fins, hat and tail fully visible and keep the current margins. No texture, no extra decoration, no shadow added to the background, no border, no text, no watermark. Full-bleed square, fully opaque background, no pre-rounded corner mask, no phone mockup. Output the single edited icon only.
```

