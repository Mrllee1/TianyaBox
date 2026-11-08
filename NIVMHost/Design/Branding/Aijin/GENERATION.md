# 爱锦锦鲤品牌素材 · 首版记录

此稿已由用户提供参考图后的「花帽大眼锦鲤」版本替代。当前母版及最终生成提示见
[REFERENCE-GENERATION.md](REFERENCE-GENERATION.md)，下文仅保留首版生成记录。

2026-11-08。使用内置 `image_gen.imagegen`，未使用 CLI 或外部 API key。
用户要求：吉祥物改为胖嘟嘟的可爱锦鲤，App 图标同样使用锦鲤，App 名称改为「爱锦」。

| 母版 | 用途 | 背景 |
| --- | --- | --- |
| Aijin-Mascot-Master.png | 默认头像、空状态、记忆空状态、启动页 | 透明 |
| Aijin-AppIcon-Master.png | 主 App 图标、应用内品牌图标 | 不透明暖白 |
| Aijin-Invite-Master.png | 邀请码页锦鲤与礼物插画 | 保留底部透明区域 |

导出：在 NIVMHost 执行 `xcrun swift scripts/generate_aijin_brand_assets.swift`。
该脚本只转换尺寸与像素格式，保留母版身份；21 个独立图标 PNG 覆盖全部 25 个
iPhone、iPad 和商店图标槽位。`scripts/validate_app_icons.sh` 校验尺寸与不透明性。

## 吉祥物最终提示

```text
Use case: stylized-concept. Asset type: production mascot cutout for an AI companion mobile app named 爱锦. Create ONE original, irresistibly cute, very chubby juvenile KOI CARP character, in a polished soft 3D clay toy illustration style. A plump creamy-white rounded oval fish body with a few distinctive simple vermilion-orange koi patches (one on forehead and one on upper side), very short rounded pectoral fins, a small clearly split carp tail curved gently to the right, and tiny subtle carp barbels near its little smiling mouth so it reads as koi rather than goldfish. Two small dark expressive eyes, soft peach blush cheeks, kind and affectionate expression. Three-quarter view facing slightly toward the viewer and left, body and tail both fully visible, friendly floating pose, no ground. Warm diffuse studio lighting, smooth matte surfaces and restrained highlights. Chunky recognizable silhouette that remains legible at small mobile UI sizes. Center one full character in square canvas with roughly 12% clear margin. Genuinely TRANSPARENT background, no background color, no ground shadow, no text, no letters, no logo, no watermark, no props, no hearts, no multiple characters, no human limbs, no accessories. This is the master identity that must also work as an app icon.
```

## App 图标最终提示

输入：上述锦鲤母版；`transparent_background=false`。

```text
Use case: compositing. Asset type: final iOS app icon master for 爱锦. Use the provided chubby koi mascot as the exact identity reference. Preserve this ONE same koi character, its creamy-white round body, orange forehead and side patches, little smiling carp mouth with short barbels, cheek blush, tiny fins, split tail and polished soft clay rendering. Place the entire fish centrally on a perfectly square, fully opaque very pale warm ivory background. Let the fish fill about 80% of canvas width with comfortable equal breathing room and no cropping of fins or tail. Maintain a very readable silhouette and warm, friendly face at tiny icon sizes; simple flat backdrop without ornaments. Output a single finished square app icon artwork, FULL BLEED SQUARE, no rounded corner mask (iOS supplies the mask), no frame, no text, no letters, no mockup phone, no multiple options, no watermark. The fish and its exact markings must remain consistent with the input mascot.
```

## 邀请页最终提示

输入 1：原 `qq_invite_pic_banner2.imageset/invite_pic_banner2.png`，作为编辑目标；
输入 2：锦鲤母版，作为身份参考。保持原有邀请布局，替换旧兔子。

```text
Use case: precise-object-edit. Asset type: invitation-code header illustration for 爱锦. Image 1 is the edit TARGET; image 2 is the exact new KOI MASCOT identity reference. In image 1 replace only the white rabbit character with the chubby creamy-white/orange koi fish character from image 2, maintaining its orange forehead/side markings, rounded shape, happy small mouth and short barbels. Keep the lavender sky, rainbow, stars, pink/purple gift box, layered pastel clouds and composition from image 1. The koi peeks out from the clouds next to the present, at the previous rabbit's approximate position and visual size. Preserve the original header composition and approximately 6:5 aspect ratio, with the lower unused portion remaining truly transparent as in image 1. The new mascot must be recognizable as the SAME koi in image 2. No rabbit or rabbit ears remain. No human limbs. No text or watermarks. Do not introduce any other new objects or alter the gift or original decorative style.
```
