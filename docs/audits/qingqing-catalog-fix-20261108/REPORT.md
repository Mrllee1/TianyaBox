# VIP / 钻石真实套餐恢复 R7（2026-11-08）

按用户明确要求，将原版 `os=1` 兼容限定在 `GET order/packageV2`。两页继续共用服务端的 `package` / `coin` 目录，不内置商品、价格、权益或倒计时。B 面保持原样。

## 改动与原因

同一独立测试会话的单变量对照确认：`os=2` 只返回权益 `tips`，`os=1` 返回完整 `package`、`coin`、`middle_banner`、`tips`。版本号、渠道、平台名称和 bundle 单独改变均未恢复目录。本轮按用户选择接入该商品目录；脱敏对照见 [CATALOG-COMPARISON.json](CATALOG-COMPARISON.json)。

兼容字段在请求签名前设置，只匹配套餐目录 GET。`platform=iOS`、本安装设备标识、账号会话保留；登录、资料、支付方式、创建订单及其他写请求继续 `os=2`。诊断只增加 VIP / 钻石目录数量与可展示 ID 数量，不保存商品正文、价格、邮箱、验证码或凭据。

## 验证

- 22 项协议 / 逻辑检查通过，覆盖套餐 GET 的 `os=1` 和重算签名，以及账号、支付、POST 请求的 `os=2` 范围保护。
- 使用当前生产 API 源码和独立游客会话，真实接口返回 **4 个 VIP 套餐、3 个钻石档位、2 种支付方式**；全部商品的 ID、价格和可用支付方式校验通过，账号资料读取成功。见 [LIVE-STATUS.json](LIVE-STATUS.json)。这是独立测试会话，实机账号另行验收。
- 3 项模拟器原生 UI 检查通过，38.325 秒：真实网络 VIP / 钻石展示、两页切换；合成夹具的套餐与支付选择保留、空目录禁止购买。真实页面截图已人工检查；夹具与真实网络检查分别记录。
- Release 构建、深度严格签名校验、IPA ZIP 完整性通过；R7 已覆盖安装并启动到 iPhone 100 pro max。四个实机启动接口均 HTTP 200 / 业务 200、会话存在，见 [DEVICE-STATUS.json](DEVICE-STATUS.json)。实机 UI 自动点按因 `Timed out while enabling automation mode` 未能初始化，已请求用户在手机确认 XCTest / UI 自动化；该步骤不计为实机页面验收通过。
- B 面源代码未改。最终导出包沿用 R6 的 63 个已签名运行库，319 个运行库文件逐字节一致；重签宿主根包后深度严格校验通过。见 [runtime-comparison.json](runtime-comparison.json)。未据此宣称重新验收全部 B 面客体。

本轮目标为真实套餐展示与选择，不包含实际下单、付款或付费聊天验收。测试没有点击真实购买确认，也没有修改 B 面数据。

构建和测试结果包索引见 [BUILD.json](BUILD.json)。原始截图、私有商品快照、测试日志、结果包和 IPA 保留在忽略的 `NIVMHost/Build/QA/qingqing-catalog-fix-20261108/` / `dist/`，不提交服务配置和账号数据。
