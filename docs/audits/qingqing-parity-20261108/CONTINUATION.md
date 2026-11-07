# 卿卿 A 面续验收 R2（2026-11-08）

已完成本轮修复、原生交互回归、真机覆盖安装和 B 面目录复核。**全部页面 1:1 尚未通过**；未将合成布局、接口契约检查或编译成功计为完整页面验收。

## 修复与取证

- 选角：ADB 取得原版 RoleSearchActivity 初始态与空结果态；接口改为 POST `home/searchRole2`，keyword/page/pageSize=18。补齐 350ms 防抖、按关键词缓存第一页、滚动分页、过期响应隔离及防抖期间禁止串接其他关键词的分页。已参与的角色保留展示，点击提示“该角色已参与身份扮演”。优先使用原版的 img_url，保留 # 标签、原版遮罩方向和搜索图标。仍未完成所有分页、重复排除和上下文状态的双端交互验收。
- 记忆条数：补入独立背景、标题、说明卡、双套餐卡及已解锁权益布局；使用 `ai/msgListPackage` 与 `ai/getMsgListInfo`，不再误用解锁接口。聊天的记忆快捷区补上原版“记忆条数”入口，遵循 home_is_show。
- 解锁记忆：使用 `ai/getMemoryPackage` 的 plans/package_id/is_all/pay_types 字段，记忆簿打开底部弹层，关闭后刷新。支付套餐必须有服务端 package_id；默认支付方式使用 checked，global_status/role_status 决定条数权益的已购态。正式应用不内置示例价格或权益。保留确认购买、待核实订单和不自动重试的保护。
- 初次启动：恢复正常游客身份初始化；以前只在 QA 参数下执行。并发初始化共用一次请求，失败后允许后续明确重试，已有账号 token 不被游客请求覆盖。游客失败单独记录，公共目录仍可展示。
- 模拟器房间：畸形响应 code=-1 不再被当作明确业务拒绝而清掉待核实标记；未创建房间。
- QA 工程：改为独立 Xcode 预览 target，修复旧 swiftc/补签预览包的 Keychain -34018。零网络诊断确认 add/read/delete 均为 0。原因判读参考 [Apple DTS 的 entitlement 检查说明](https://developer.apple.com/forums/thread/114456)；该修复与后端游客 500 是两个问题。可复现脚本为 `NIVMHost/scripts/build_qingqing_preview.py`，生成物和私有配置均留在忽略的 Build 目录。

## 实际验证

1. 16 项协议/模型检查通过。新增选角表单与 18 条分页协议、并发游客去重、游客失败重试、两种记忆套餐结构/ID/默认支付方式/权益判断检查；均使用合成响应，不创建真实订单或会话。
2. 两项原生 XCUITest 通过，0 失败。最终结果：`native-preview/UI-20261108-051931.xcresult`。第一项使用真实公共选角接口，验证加载、滚动、无结果搜索及清空恢复；没有选择角色或创建游戏。第二项验证记忆条数、解锁、已购三种**合成布局**及禁用购买按钮，没有业务请求。六张测试附件已导出，原图只保存在本地忽略目录。
3. iOS Release 完整构建、codesign deep/strict 校验和 IPA ZIP 完整性通过。59 个直接 Artwork 引用均有对应资源；另有动态资源名称，未将 59 当作全部资源总数。新增 21 个原版资源来源/输出哈希见 ARTWORK-CONTINUATION.json。
4. 已覆盖安装到 iPhone 100 pro max。2026-11-07 21:20:38 UTC，公共目录与 member/info 返回 HTTP 200 / code 200，session_present=true，原有邮箱账号状态保留；未登出、未重新收码。脱敏状态见 DEVICE-STATUS-CONTINUATION.json。
5. 实机 B 面已安装目录仍有天涯、成人抖音、3188.tv、DYZB 官签、DYZB TF 五个入口。本轮没有逐个启动客体应用，不能据此宣称播放、直播通过。完成后返回 A 面，并关闭宿主持续截图。B 面代码未改。

## 仍未通过

- 独立模拟器游客登录仍为 HTTP 200 / code 500；本轮 macOS 自有临时测试会话也返回 code 500“登录错误”，因此未能继续读取三个记忆套餐接口。未尝试伪装平台/模拟器属性或复制手机、Android 凭据。手机已有会话 member/info=200 与新游客失败分别记录。此前 18 项只读检查是首轮历史结果，本轮没有重跑或冒充通过。
- 记忆条数/解锁已按 XML 和资源实现并做合成布局检查，仍缺原版运行截图、真实套餐展示及支付结果态的双端验收。底部弹层的高度、部分卡片细节和原生支付方式呈现仍需对照。
- 原版聊天、群聊和消息页的 FLAG_SECURE 仍妨碍 ADB 视觉对照；没有绕过保护。图集/图片独立页、模拟器人物/报告、若干会员/夜聊/挽留与编辑提示弹层、完整礼物动画等首轮缺口仍在，详见 PAGES.csv。
- 未触发真实支付、送礼、角色发布、账号注销、签到奖励或新房间创建，不将这些成功态标为通过。

## 产物与复现

- 最新 IPA：`dist/TianyaBox-AI-20261108-parity-r2.ipa`，134965394 字节。
- SHA-256：`8892e373b936bd6e94f31b2ea1eb5b3799889c3a875c6c65c5cab92baf99cf7f`。
- 元数据：BUILD-CONTINUATION.json；证据指纹：EVIDENCE-CONTINUATION.json。私有配置、原始账号资料、token、验证码及截图均未提交 Git。

```sh
python3 NIVMHost/scripts/build_qingqing_preview.py \
  --simulator <已启动的模拟器 UDID> \
  --configuration <本地私有服务 JSON 路径> --test
```

该命令只构建/测试 com.tianyabox.qingqing.preview，不包含正式宿主、B 面运行时或手机凭据。生成项目、配置与 xcresult 位于 `NIVMHost/Build/QA/qingqing-parity/native-preview/`。
