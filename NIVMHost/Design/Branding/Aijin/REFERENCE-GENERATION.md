# 爱锦花帽大眼锦鲤 · 当前版本

2026-11-08。按用户提供的图片重新设计，使用内置 `image_gen.imagegen`；未使用 CLI 或外部 API key。

参考图：`References/Koi-User-Reference.jpg`（仅设计参考，不进入 App 资源目录）。
保留：正面圆身、红白配色、青绿色大眼睛、橙色扇形鱼鳍、鱼鳞纹花帽与粉色小花。
应用名称仍为「爱锦」，B 面业务保持不变。

| 文件 | 用途 | 背景 |
| --- | --- | --- |
| Aijin-Mascot-Master.png | 启动页、空状态、记忆空状态 | 透明 |
| Aijin-AppIcon-Master.png | 主 App 图标、品牌图标、默认头像 | 不透明黑色渐变 |
| Aijin-Invite-Master.png | 邀请码页插画 | 下方保留透明 |

执行 `xcrun swift scripts/generate_aijin_brand_assets.swift` 可从母版重导出 21 个独立图标 PNG（25 个图标槽位）及 3 个 imageset。该脚本只转换尺寸及像素格式，不重绘角色。
默认头像使用图标版本，保留花帽和尾巴在圆形裁剪中的安全边距。

## 吉祥物最终提示

输入：用户参考图；`transparent_background=true`。

```text
Use case: stylized-concept. Asset type: production transparent mascot master for the 爱锦 AI companion mobile app. The provided image is a VISUAL DESIGN REFERENCE, not a background or screenshot to reproduce. Design one cohesive, very cute chubby koi mascot closely guided by the reference's distinctive silhouette and facial character: a round upright red-and-creamy-white fish body, huge expressive aqua/teal irises with dark pupils and bright catchlights, generous cream-white patches surrounding both eyes and across the lower cheeks/belly, a tiny happy open pink mouth, subtle blush, short orange fan-shaped pectoral fins extending to both sides, and a compact flowing orange split tail curving toward the viewer's left. Give this koi its signature soft coral-orange bucket hat with a restrained koi-scale pattern, small dorsal fin at the crown, and ONE five-petal pale-pink flower with yellow center on the viewer's upper right side of the hat. Keep the large innocent eyes, plump proportions, hat/flower identity and friendly front-facing pose strongly aligned with the reference. Refine into a polished soft matte 3D toy illustration suitable for a mobile brand; simplify overly fine hat/scale texture for clean small-size legibility. Full character, centered square canvas, 10% clear margin on every side, no cropped fins or hat. Warm soft studio lighting, clean smooth contours. Genuinely TRANSPARENT background, no ground plane, no cast shadow outside character. No extra props or characters, no human limbs, no added prominent moustache, no typography, no watermark or social media markings, no screenshot, no scenery. Output one mascot only.
```

## App 图标初始提示（背景已调整为黑色渐变）

当前图标的背景调整提示见 [ICON-BLACK-GRADIENT-GENERATION.md](ICON-BLACK-GRADIENT-GENERATION.md)。

输入：新锦鲤母版；`transparent_background=false`。

```text
Use case: compositing. Asset type: final square iOS App icon for 爱锦. Image 1 is the EXACT approved new koi mascot identity to preserve. Create a single fully opaque square app icon using that same plump front-facing red/cream koi with its very large aqua eyes, orange fan fins, coral fish-scale bucket hat, pink flower and small dorsal fin. Preserve facial proportions, expression, markings, colors, flower and hat; do not invent a different fish. Place the complete mascot centrally on a very pale softly muted mint-jade background inspired by the user's reference. Use a clean flat background, soft matte 3D character shading. Fit the FULL hat, flower, fins and tail within the central 80% of canvas height and width, giving at least 10% padding on every side. Keep the flower, eyes and hat shape readable at small icon sizes. Do not crop any character part. Full-bleed square, no pre-rounded corners or border (iOS applies its own mask), no external shadow, no text, no letters, no watermark, no phone mockup, no variants. Output only the single finished app icon.
```

## 邀请页最终提示

输入 1：上一版邀请页母版（编辑目标）；输入 2：新锦鲤母版（身份参考）。

```text
Use case: precise-object-edit. Asset type: 爱锦 invitation-code header illustration. Image 1 is the EDIT TARGET (existing lavender gift-and-cloud header). Image 2 is the EXACT NEW koi identity reference. Replace only the old cream-and-orange small-eyed moustached fish in image 1 with the new round red/cream big-aqua-eyed koi from image 2. The replacement must clearly wear the same coral fish-scale bucket hat with pink flower, show the same huge aqua eyes, cream eye patches/cheeks, tiny pink smiling mouth, and orange fan fins. Keep the lavender sky, rainbow, stars, pink-purple present box, clouds and their existing composition as in image 1. Fit the new mascot in the previous fish's location, naturally peeking from the clouds next to the gift, and preserve the full hat and flower with enough breathing room. Preserve original header dimensions and approximately 6:5 aspect ratio. Keep the lower unused portion transparent as in the target, with a clean soft cloud boundary (no speckled fringes). No old fish or whiskers remain, no extra characters, no extra props, no text, no watermark. Change the mascot identity only; don't redesign the surrounding illustration.
```

