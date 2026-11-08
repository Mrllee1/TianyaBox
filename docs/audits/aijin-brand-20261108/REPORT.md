# 爱锦品牌替换验收 · 2026-11-08

## 范围与结果

用户指定 App 名称为「爱锦」，吉祥物和 App 图标为胖嘟嘟的可爱锦鲤。
本轮完成源码与品牌素材接入；整体主题方向仍是待选方案。

- 新增橘白锦鲤透明母版、暖白底 App 图标母版、邀请码页锦鲤插画。
- 桌面显示名、启动页、设置、关于、通知来源、反馈致谢及权限说明统一为爱锦。
- AijinBrand 集中解析品牌图标、默认头像、空状态和记忆空状态；用户头像及角色内容不替换。
- 全部构建配置使用 AijinAppIcon；归档脚本的名称校验和 iPad 独立图标路径同步更新。
- 主仓库与分支仍为 TianyaBox / main。宿主内部 TempMail 产品名、Bundle ID、URL scheme、账号存储键保持兼容。
- 未修改 B 面源代码、运行时、目录接口、安装与启动流程；未修改 A 面协议、登录、聊天和套餐逻辑。

## 验证

1. `xcrun swift NIVMHost/scripts/generate_aijin_brand_assets.swift`：导出 21 个独立 PNG，覆盖 25 个图标槽位，另有 3 个品牌 imageset。
2. `NIVMHost/scripts/validate_app_icons.sh`：全部源图标尺寸正确，无透明通道。
3. `plutil -lint`：正式 Info.plist、Runner 工程及独立预览工程模板通过；确认正式显示名为爱锦，内部身份和回调保持原值。
4. `bash -n`：归档与图标校验脚本通过；归档品牌检查已改为爱锦。
5. `ibtool`：正式 LaunchScreen.storyboard 编译通过，无错误、警告或提示。
6. 独立 iOS 预览 target 编译成功并安装到本地 iOS 27 模拟器；确认编译后主图标名为 AijinAppIcon，无备用图标。构建存在原有异步建议、Text 拼接弃用和 headermap 警告，无编译错误。
7. 以 about-fixture、settings-fixture、empty-home-fixture 检查关于、设置和空状态，名称及锦鲤图片正确，未出现旧品牌图标或图片变形。
8. 四方向 HTML 样机同步新品牌。1440px 桌面与 390px 手机宽度下无横向溢出或坏图；4 个方向及 4 个选择按钮均存在，参数调节与确认取消通过。没有代替用户选择主题。
9. `git diff --check` 通过。

## 证据与限制

- iOS 截图：`NIVMHost/Build/QA/aijin-brand/{about,settings,empty-home}.png`。
- 预览构建日志：`NIVMHost/Build/QA/aijin-brand/native-preview/build.log`。
- HTML 截图与检查：`design-previews/2026-11-08-theme-system/qa/`。
- 母版与最终生成提示：`NIVMHost/Design/Branding/Aijin/GENERATION.md`。
- 仅安装了独立模拟器预览包。本轮没有正式宿主归档、真机覆盖安装或支付/聊天端到端测试。

## 用户参考图修订

用户随后提供 `a4d424d537fd3f1cd99f66a0a9f65f6e.jpg`，要求按该图设计。
当前三个母版已替换为参考图风格：正面红白圆身、青绿色大眼睛、橙色扇形鱼鳍、
鱼鳞纹花帽与粉色小花。App 图标使用浅青绿不透明背景，默认头像使用图标版本
保留圆形裁剪安全边距。首版母版备份保留在忽略的 Build/QA/aijin-brand/initial-masters。

- 当前提示集：`NIVMHost/Design/Branding/Aijin/REFERENCE-GENERATION.md`；首版 GENERATION.md 已标注被替代。
- 重新导出全部图标及三个 imageset；图标校验通过。
- 独立 iOS 预览增量构建成功；关于和空状态截图为 `about-reference.png`、`empty-home-reference.png`。
- 四方向 HTML 的嵌入图片与本地素材均已同步；1440px/390px 检查再次通过，无溢出、坏图或脚本异常。
- 检查 B 面 Launcher、目录/运行时路径和 A 面 API/Store 未发生改动；未覆盖真机。

## 黑色渐变图标正式打包与手机安装 R9

用户最终确认使用黑色渐变，并明确要求打包安装，其他 UI 配色和 B 面不变。
本阶段已完成正式宿主 Release 构建、签名、IPA 打包、真机覆盖安装及启动。

- 图标母版使用 ICON-BLACK-GRADIENT-GENERATION.md 记录的黑色至深灰柔光渐变。
- App 名称「爱锦」，版本 500.0.0 / 构建 11；Bundle ID、URL 回调、Keychain 权限及服务配置保留。
- 直接从 SHA-256 已验证的 R8 安装包提取 63 个运行库，签名时仅重签宿主根包。最终 App 与 IPA 中的 319 个运行库文件均与 R8 逐字节一致。
- 确认 UI 配色、业务代码与透明吉祥物、邀请页图片保持本次打包开始时的内容。没有落实待选的整体主题重构。
- Release 构建、深度严格签名、源图标与包内 167px 图标校验、ZIP 完整性检查通过。
- 已覆盖安装到「iPhone 100 pro max」，系统安装信息回读名称为爱锦、构建为 11，启动成功且进程保持运行。
- 手机系统返回的实际图标确认是黑色渐变锦鲤，未返回占位图。证据：`NIVMHost/Build/QA/aijin-brand/device-r9/device-icon-after.png`，该图是系统返回图标，不是桌面截图。
- 覆盖安装后，新产生的 member/info、首页分类、模型列表与推荐接口均 HTTP 200 / 业务 200，session_present 为 true。只验证原会话与启动状态，不据此宣称推荐一定非空或重新验收聊天/支付。
- 未重新启动 B 面客体或执行购买、聊天发送、发布、注销。

安装包：`NIVMHost/dist/爱锦-黑色渐变-R9-20261108.ipa`。
构建、签名、安装、图标回读与启动日志保留在忽略的 `NIVMHost/Build/QA/aijin-brand/device-r9/`。
公开验收索引为 [BUILD.json](BUILD.json) 和 [runtime-comparison.json](runtime-comparison.json)。
