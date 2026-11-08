# 爱锦新应用注册与提交准备 · 2026-11-08

## 已完成

- 按用户指示移除 App Store Connect 的 `TianyaProxy`（Apple ID `6810680062`）。第一次移除返回不可移除；按 Apple 官方要求，先在 Pricing and Availability 移除全部地区的可用性，再移除应用记录。最终 App Information 显示 `Restore App`，主应用列表不再显示该记录。Apple 保留“已移除应用”记录，并非永久删除所有历史。
- 在已核验团队 `WFJKWPCH2R` 注册显式 App ID `com.aijin.ai`，名称 `Aijin AI`。
- 创建新的 App Store Connect 应用 `爱锦`，Apple ID `6832195363`，iOS，主语言简体中文，SKU `AIJIN-IOS-20261108`，状态 `Prepare for Submission`。已从 App Information 实际选中项确认 Bundle ID 为 `com.aijin.ai`。
- 更新当前主工程的 Debug / Profile / Release Bundle ID 和测试 Bundle ID；默认签名团队改为 `WFJKWPCH2R`。API 元数据后备值、设备安装脚本、App Store 导出配置、校验逻辑和当前 README 同步使用新 Bundle ID。
- 正式打包脚本增加 AI 私有服务配置的存在检查和签名前注入，避免正式包缺少已验证的服务配置。配置值没有写入源码或报告。

应用后台：[爱锦 App Information](https://appstoreconnect.apple.com/apps/6832195363/distribution/info)。

## 已验证与实际限制

- 新 Bundle ID 的 iOS Release 无签名编译通过；读取实际产物确认名称 `爱锦`、可执行文件 `AijinAI`、Bundle ID `com.aijin.ai`、版本 `1.0.0`、build `1`。
- 52 项 A/B URL 路由检查通过；22 组现有 AI 接口契约检查通过；图标校验、工程 / plist 校验和两个打包脚本的 Bash 语法检查通过。
- 无签名产物已注入 AI 服务配置，解析后的配置与已验证 R10 一致；没有输出配置值。
- 本轮没有安装新 Bundle ID 到手机，没有生成 App Store 分发 IPA，没有上传构建或提交审核。编译和契约检查不等同于新 Bundle ID 的实机验收或 App Store 验证。
- 更换 Bundle ID 后是新的 iOS 应用身份；旧 `com.tianya.tempmail` 的沙盒和 Keychain 会话不会自动迁移。本轮未卸载旧测试版。
- UI 配色、锦鲤图标和 B 面功能未修改。尚未创建或假定获准创建仅含 A 面的构建目标。当前已有的完整 A/B 打包脚本继续保留 B 运行器。

## 仍待处理

1. 新版 Apple Developer Program License Agreement 仍显示待接受，期限为 2026-11-14。已打开协议阅读页面，未代为同意；已请求用户本人阅读并接受。应用记录已成功建立，不代表协议提示已经解除。
2. 已向用户确认上架范围：在同一仓库创建仅含 AI 的独立构建目标，或保留完整 A/B 并如实披露。此前“B 面保留”约束仍有效，未凭上架请求自动删除 B 面。
3. 确定发行范围后，完成 App Store 分发证书 / 描述文件 / 导出及实际上传验证、真实应用截图、支持与隐私页面、隐私披露、内容分级和审核资料。当前本机与该团队可见证书为开发类型，尚未完成分发签名准备。
4. 完整 A/B 的原生应用运行器和成人内容入口、AI 内数字内容支付以及第三方 API / 素材授权仍需按真实功能处理，不能以改名或新建记录代替。详见此前的[审核可行性分析](../aijin-naming-20261108/APPSTORE-READINESS.md)。

## 证据

不含账号密码或验证码的结构化证据保存在忽略目录 `NIVMHost/Build/QA/aijin-appstore-20261108/ASC-STATE.json`、`BUILD.json`；编译日志位于同目录 `build.log`。旧 R10 包仍是旧 Bundle ID 的开发测试包，未重标为新应用上架包。

Apple 官方流程：[移除应用](https://developer.apple.com/help/app-store-connect/create-an-app-record/remove-an-app)、[创建应用记录](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app)、[提交应用](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app/)。
