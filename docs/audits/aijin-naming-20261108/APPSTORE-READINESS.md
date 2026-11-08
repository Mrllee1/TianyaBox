# 爱锦 App Store 可行性分析 · 2026-11-08

后续进展：用户已授权更换应用身份；旧 `TianyaProxy` 已移除，新 `com.aijin.ai` App ID 和爱锦应用记录已建立。以下保留当时账号核验的快照，当前进展见[新应用注册与提交准备](../aijin-appstore-20261108/REPORT.md)。

2026-11-08 已使用用户提供的账号和验证码登录 Apple Developer 与 App Store Connect，完成只读核验；未上传构建、创建应用、签署协议或提交审核。
账号密码、验证码、号码、收码查询码及个人联系资料不写入本仓库。

## 账号资格和角色已核实

| 核验项 | 后台实测结果 |
| --- | --- |
| 开发者计划 | Apple Developer Program，个人会员（Individual） |
| 会员续期日 | August 24, 2027；当前会员有效 |
| 团队 | `WFJKWPCH2R`，与实际 R10 安装包开发签名团队一致 |
| 当前用户角色 | Account Holder、Admin；按提供的账号邮箱过滤 Users and Access 后读取自己的记录 |
| 应用访问范围 | All Apps |
| 角色层面的提交权限 | 具备；Apple 要求 Account Holder、Admin 或 App Manager |

这些结果来自已登录的 Developer 会员页和 App Store Connect Users and Access 页，不以安装成功代替账号资格证明。

来源：[加入开发者计划](https://developer.apple.com/programs/enroll/)、[提交应用所需角色](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app)、[上传构建所需角色](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)。

## 当前提交阻塞和应用归属

- **新版开发者协议尚待接受。** Developer 会员页显示需在 November 14, 2026 前接受最新 Apple Developer Program License Agreement；App Store Connect 应用列表明确提示，更新现有应用或提交新应用前，Account Holder 必须先接受更新协议。本次未代签。
- **现有应用记录不对应爱锦当前 Bundle ID。** App Store Connect 当前可见 `TianyaProxy`（Apple ID `6810680062`），状态 `iOS 1.0 Prepare for Submission`；App Information 中实际选中的 Bundle ID 为 `com.tianya.client`。
- **爱锦当前显式 App ID 和对应应用记录尚未看到。** Developer Identifiers 当前 App IDs 列表为 `com.tianya.client`、`com.tianya.client.tunnel` 和 `XC Wildcard`（`*`），未见当前爱锦的 `com.tianya.tempmail`。通配符开发配置可以解释实机开发签名成功，但不能替代 App Store 分发所需的显式 App ID。
- App Store Connect 另显示 EU DSA trader status 提示；若向欧盟发行，需核实并完成相应声明。本次未填写声明，也未将通用提示当作已完成商家身份核验。
- Paid Apps Agreement、税务和银行资料未在本次核验中逐项确认；不能据本次账号核验认定 VIP / 钻石的内购配置已经就绪。

结论：**会员资格有效、账号角色允许提交；当前仍有更新协议和爱锦应用注册配置待处理，尚不能直接提交现有 R10 包。**

来源：[开发者角色与更新协议](https://developer.apple.com/help/account/access/roles)、[欧盟 DSA 要求](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/)。

## 当前安装包不是上架包

R9 / R10 使用已注册测试手机的开发签名；本地严格签名验证和安装成功，不表示可以直接作为 App Store 提交包。
正式上传需使用正确团队下的显式 App ID、App Store Connect 分发配置和相应应用记录重新导出。

来源：[App Store Connect provisioning profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile)。

## 需要先处理实际功能

- 当前 B 面会下载、准备并执行其他原生应用/转换代码，存在审核规则 2.5.2 的直接冲突风险；不能用通用 H5 小程序规则替代对该原生运行器的判断。
- B 面已有成人内容入口，需要按 1.1.4 核对实际内容；不能因为改名或仅展示 AI 首页，就推定符合要求。
- 2.5.19 要求完整公开实际功能，不能把仍包含在应用中的 B 面作为隐藏功能规避审核。
- VIP / 钻石等数字内容的付款，需要按目标发行地区核对 3.1.1、外部购买链接及适用权利，不默认沿用 Android 接口返回的支付方式。
- 第三方 API、原版素材与内容的使用许可尚未核实；5.2.1 / 5.2.2 要求具备相应权利及服务授权。

来源：[Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)。

因此，会员有效、角色具备权限及命名清理均不构成审核通过证明。若继续保留当前 B 面，应先解决上述实际功能问题；另一可评估方向是独立的 AI 分发 target，明确不包含这些功能并如实提交。该方案尚未获实现指令，本轮没有移除或隐藏 B 面，也没有上传构建或提交审核。
