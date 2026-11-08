# 爱锦 AI 命名清理 R10 · 2026-11-08

当前宿主产品及可执行文件由 TempMail 改为 AijinAI，显示名继续为爱锦。
本轮是移除已退役功能和命名整理，不改变页面配色或 B 面业务。

## 已调整

- 删除 TempMailA 的 6 个 Swift 文件及未使用的 MailboxSurface 包装视图；从 Xcode 编译组移除。
- 删除该旧模块使用的 13 个 imageset、旧邮件图标母版及失效的本地化脚本。
- Launcher、CatalogService、SurfaceCoordinator、AssetCrypto、entitlements 文件改为 Aijin 命名；宿主、Scene、浮层及运行器内部类型和函数统一命名。
- 移除只服务于旧临时邮箱 API 的 AES/gzip 辅助方法，保留 B 面实际使用的图片解密。
- 新配置使用 AijinCatalogBaseURL / AijinClientAESKey / AijinAssetAESKey / AijinAssetAESIV；代码兼容读取旧配置键。
- 新标准入口是 aijin://ai、aijin://box；旧 tempmail:// 回调继续兼容。
- 同步 Xcode 产品/模块、测试宿主、桥接头、构建脚本、日志前缀及当前 README。
- 将已退役的支持站点移至 docs/archive/mail-support-site，仅保留历史资料，没有部署或改写线上隐私政策。

## 有意保留的历史标识

- com.tianya.tempmail 与对应签名、Keychain 权限：保留覆盖安装、账号和现有应用数据。
- 旧 tempmail:// 回调、B 面状态/安装记录键、原有 plist 和诊断目录：保留安装记录、客体重启及回到宿主。
- 历史审核/验收资料、未参与当前 target 的旧供应商代码与归档资料不伪装为新的 AI 功能。

这些剩余字符串是兼容标识，不是临时邮箱类、页面或 API。

## 验证

- 52 项独立路由兼容检查通过：新旧 scheme、历史激活键、AI/B 路由、客体返回及无关 URL。
- 完整 iOS Release 构建、plist、Shell/Python 语法、git diff 检查通过。
- 主运行器源码反向归一化命名及可访问性标识后，与基线逐字节相同；没有增加或删除运行器控制逻辑。
- 558 个保留的 AI/品牌资源文件逐字节相同，包含已确认的黑色渐变锦鲤。
- 最终安装包中不包含 TempMailRootView / TempMailStore / TempMailAPIClient。
- 63 个 B 面框架、319 个文件沿用 R9（与 R8 相同），逐字节一致；服务配置和签名权限保留。
- R10（500.0.0 / 构建 12）已覆盖安装到 iPhone 100 pro max，AijinAI 进程运行正常。
- aijin://ai 启动、旧 tempmail://box 打开 B 面、旧 tempmail://privacy 回到 AI 页均成功；原账号会话存在，新响应 HTTP 200 / 业务 200。
- 本轮未重新运行全部 B 面客体，也未执行购买、聊天发送、发布或注销。

安装包与哈希见 [BUILD.json](BUILD.json)。原始日志、签名、兼容值清单及检查结果位于忽略的 NIVMHost/Build/QA/aijin-naming-20261108。
