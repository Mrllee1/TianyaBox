# 爱锦新应用注册与提交准备 · 2026-11-08

## 已完成

- 按用户指示移除 App Store Connect 的 `TianyaProxy`（Apple ID `6810680062`）。第一次移除返回不可移除；按 Apple 官方要求，先在 Pricing and Availability 移除全部地区的可用性，再移除应用记录。最终 App Information 显示 `Restore App`，主应用列表不再显示该记录。Apple 保留“已移除应用”记录，并非永久删除所有历史。
- 在已核验团队 `WFJKWPCH2R` 注册显式 App ID `com.aijin.ai`，名称 `Aijin AI`。
- 创建新的 App Store Connect 应用 `爱锦`，Apple ID `6832195363`，iOS，主语言简体中文，SKU `AIJIN-IOS-20261108`，状态 `Prepare for Submission`。已从 App Information 实际选中项确认 Bundle ID 为 `com.aijin.ai`。
- 更新当前主工程的 Debug / Profile / Release Bundle ID 和测试 Bundle ID；默认签名团队改为 `WFJKWPCH2R`。API 元数据后备值、设备安装脚本、App Store 导出配置、校验逻辑和当前 README 同步使用新 Bundle ID。
- 正式打包脚本增加 AI 私有服务配置的存在检查和签名前注入，避免正式包缺少已验证的服务配置。配置值没有写入源码或报告。
- 账户持有人已于 2026-11-08 亲自接受 2026-10-30 发布的新版开发者协议；重新登录 Developer 与 App Store Connect 核验，待接受提示均已消失。
- 已创建并下载匹配团队的 Apple Distribution 证书及 `Aijin App Store WFJKWPCH2R 20261108` 描述文件，后者仅授权 `WFJKWPCH2R.com.aijin.ai`，`get-task-allow=false`，不含测试设备列表。私钥、P12 密码、专用签名 Keychain 和描述文件保存在 Git 忽略的 `.private/apple-distribution/`。
- 已修复手动签名参数向 Pods 目标传播的问题：工作区先无签名归档，完成资源注入后显式签名，再按手动分发配置导出；归档部署目标保持现有宿主的 iOS 26.0。宿主 Keychain 权限仅授权新应用自身的组，保证 AI 会话可持久化。
- 支持从已验证 R10 包指定完整运行库，避免重新拼装出不同的 B 面运行环境。本次没有剥离运行库符号或删除 B 面功能。

应用后台：[爱锦 App Information](https://appstoreconnect.apple.com/apps/6832195363/distribution/info)。

## 分发包与测试

- 完整 A/B 的 App Store 分发 IPA 已成功归档和导出：`NIVMHost/dist/Aijin-full-appstore-20261108/export/AijinAI.ipa`，135,997,895 字节，SHA-256 `39110cfefcb91d1a8d50ffa587ac751dfa348f2a76f1edb7fa306bfa7563fff0`。
- 实际包名称 `爱锦`、可执行文件 `AijinAI`、Bundle ID `com.aijin.ai`、版本 `1.0.0`、build `1`。ZIP 完整性、深度严格签名、图标、描述文件、团队与应用权限校验通过；包内不含分发私钥、P12 或 Keychain 文件。
- 后续仅为 A 面政策入口更新，另行导出 `NIVMHost/dist/Aijin-policy-appstore-20261108-build2/export/AijinAI.ipa`，版本 `1.0.0 (2)`，135,998,425 字节，SHA-256 `e42abbaf1756d01de324b1d5074b5fc1e60418fc16aba20f299551a2049644b1`。签名、ZIP、描述文件、图标、政策 URL 与版本验证均通过；苹果 `altool --validate-app` 返回无错误。原 build 1 的分发包保留未覆盖。
- build 2 与 build 1 对比，根 Info.plist 仅变更 `AijinPrivacyPolicyURL` 和 `CFBundleVersion`；B 面四项宿主配置与 AI 私有配置相同。18 个 B 面源文件哈希未变，63 个运行库的 1,784 个二进制区段与全部非签名资源一致；不同的完整可执行文件哈希来自重新签名。新分发包没有因这次改链接而重新声称完成装机验收。
- 保留 63 个运行库；与 R10 比较的 1,784 个二进制区段全部一致，非签名资源无意外变化。导出时仅省略不被客户端读取的构建记录 `flutter-simulator-runtime.json`；可执行文件整体签名字节因分发签名而变化。
- B 面宿主服务配置和 AI 服务配置与 R10 一致，配置值未输出至报告。
- 新 Bundle ID 的开发签名测试版已安装到先前的测试手机，A 面和 B 面入口均已启动并截图核验，最后切回 AI 页面。设备日志显示 `device/login`、`member/info`、首页分类、模型和推荐接口 HTTP / 业务码均为 200，推荐页实收 20 条。
- B 面显示真实 5 个目录条目及图标；另一次独立 HTTPS 请求解密目录通过。本轮未下载或运行客体应用、未创建或付款真实订单；不把目录验收等同于重新完成全部客体运行验收。
- 设备日志中另有切换测试时终止进程导致的 `-999` 取消记录，后续同类请求正常返回 200。
- 52 项 A/B URL 路由检查、22 组现有 AI 接口契约检查、图标和工程 / plist 校验通过；归档/导出已实际运行通过。
- 更换 Bundle ID 后是新的 iOS 应用身份；旧 `com.tianya.tempmail` 的数据不会自动迁移。本轮保留旧测试版与其账号数据。装机验证使用开发签名副本，不能声称 App Store 分发 IPA 已直接装机或经过 TestFlight 验证。
- UI 配色、锦鲤图标和 B 面业务逻辑未修改；用户已确认保留完整 A/B，没有创建仅含 A 面的构建目标。

## 已准备的材料

- 当前资料入口为 `NIVMHost/AppStore/Aijin-1.0/`：应用身份、版本、商店描述草稿、完整功能审核说明草稿、隐私数据流表及 SDK 隐私清单。
- 旧 TempMail 上架描述、邮箱截图与旧账号资料移至 `docs/archive/tempmail-appstore-1.0/`，不用于本次应用。
- 支持网站已通过 Sites 发布，用户明确授权把后台审核联系人邮箱公开为客服邮箱。首页、使用帮助和隐私与数据说明完成图片、联系链接及无横向溢出检查；随后按用户逐次指示移除这三个页面中的“应用空间”段落。新政策页发布过程中，首页、使用帮助、通用样式和锦鲤图片保持字节不变。
- 后台支持网址已保存为 https://aijin-support-20261108.well-boot-4687.chatgpt.site/support.html ，并通过 App Store Connect API 回读核验。隐私与数据页面仍提供查询 / 删除联系步骤，对应可选的 `User Privacy Choices URL` 为 https://aijin-support-20261108.well-boot-4687.chatgpt.site/privacy 。新增隐私政策页 https://aijin-support-20261108.well-boot-4687.chatgpt.site/privacy-policy 已发布并保存到正式 `privacyPolicyUrl`，API 回读逐字一致；没有据此发布仍缺少实际第三方规则的隐私标签。
- 已读取 63 个运行库内的 31 份隐私清单，全部可解析；这不代表第三方服务端或客体数据处理已经核实，也不能据宿主的空 collection 数组声明整个应用不收集数据。
- 原分发构建 `1.0.0 (1)` 已上传并处理为 `VALID`。后续政策入口更新构建 `1.0.0 (2)` 同样校验 / 上传 / 处理通过，构建 ID `e94b36f6-f6c7-4efa-ac5b-20a156628fdf`；加密问卷按实际标准加密及不在法国发行保存后，现已替换版本草稿中的选中构建，并通过版本 build relationship 回读验证。旧 build 1 和原始 IPA 保留，未删除历史。下载价格仍为免费。
- 审核联系人四项已保存，AI 功能测试 PDF 已替换为修改版。最终提交仍由用户操作，未触发 Add for Review 或 Submit for Review。
- 推广文案、营销网址已保存，并通过 API 回读；保留现有应用描述和关键词，保留原审核备注全文后追加游客测试说明。全新模拟器安装的 `device/login` 与 `member/info` 返回 HTTP / 业务码 200，因此核心 AI 内容无需手动输入账号；后台已取消空的强制用户名 / 密码要求。未宣称游客拥有付费权益。
- 上传了 iPhone 1206×2622 与 iPad 2064×2752 各 4 张截图，主题为群聊、模拟器、互动剧场和角色创作。API 回读 8 张全部为 `COMPLETE`，无上传错误。截图由原生 iOS 模拟器使用未改动的 `QingqingA` 业务源码与真实在线数据生成，没有使用测试假数据或修改截图。iPad 截图入口的显示名与爱锦一致；截图不是分发 IPA 在模拟器运行的证明。实体手机 XCTest 启用自动化超时，未将此失败记为通过；应用源码、B 面和已上传的分发包没有因此修改。
- 发行范围按用户最新指示设为 147 个地区，排除欧盟 27 国及中国大陆。重新载入后台后显示 `147 Available / 28 Not Available`；逐行核验上述 28 个地区均为 `Not Available`，香港、澳门、台湾以及美国、英国、挪威、瑞士均为 `Available on App Release`。本轮只追加排除中国大陆，港澳台未被移除。
- 商务后台 DSA 问卷选择并保存了“不属于经营者或不计划在欧盟发行”这一组合选项，依据是用户明确排除欧盟发行，未据此推断实际经营者身份。没有公开地址或电话，未代签新的付费协议。原“Complete Compliance Requirements”提示已消失，商务页显示 DSA 合规记录。
- 出口加密问卷如实选择包含 Apple 系统以外的标准加密实现，并在法国从发行范围移除后回答不在法国发行。后台保存后的构建 `usesNonExemptEncryption=false`；这不表示包内不存在加密代码，未虚构法国批准文件，未修改 Info.plist 中的加密声明。
- App Privacy 后台保存了邮箱、照片/视频、客服内容、其他用户内容、用户标识、设备标识和购买记录 7 类已知数据的草稿。第三方用途与追踪情况未确认，因此没有发布隐私标签；新政策页面直接说明这些未确认事项，不能以已填写网址替代标签核验。
- 用户确认版权人采用开发者账号姓名后，从当前团队分发证书读取主体名称，并与实时 Developer 账号页面交叉核对。后台版权字段已保存为 `2026 + 该开发者姓名`，通过 App Store Connect API 回读逐字一致；没有用开源许可证文档中的版权人替代应用版权人。此确认不自动构成对第三方内容、API 或客体软件的授权确认。
- 隐私政策根据当前客户端代码、已导出包的 AI / 目录接入域名、存储和接口行为整理后发布，明确说明运营主体、训练、追踪、处理地区、保存和删除规则仍有待核实，没有虚构固定期限或不训练承诺。最初发布版本为 12 节；按用户随后要求移除“目录、下载与第三方软件”独立章节及开头对应介绍语，当前为 11 节，其他处理披露保留。发布版来源为 `metadata/privacy-policy.published-content.json`，文本为 `metadata/privacy-policy.zh-Hans.txt`；内部 12 节核验草稿保留，`metadata/privacy-policy-review.json` 持续记录未确认事项。政策发布和 URL 保存不代表已经完成全部服务规则核验。
- 当前支持站沿用原 Sites 项目，发布版本为 6，源提交 `02466561cd8a81b55aaa7bab98fa58ec71c9611c`，部署状态 `succeeded`。线上政策页 HTTP 200，320、390 与 1280 像素宽度均无横向溢出，11 节编号与目录链接连续，指定章节标题与介绍语均不存在；联系链接、标志和未核实事项提示保持可见。移除描述未改变 B 面源码或运行配置。
- A 面内的隐私政策链接调整为读取 `AijinPrivacyPolicyURL` 公共 HTTPS 地址，不携带服务签名参数；服务协议链接和未配置时的原接口后备行为保持不变。针对真实 API 实现的公共链接检查、22 组现有 API 契约检查及 52 项 A/B 路由检查均通过。构建脚本核验最终归档中的政策地址与源 plist 一致；该修改已包含在上传并选中的 build 2，本轮没有另行安装到手机。
- 再次完整读取接口方公开隐私文档，仍显示 Saylo，未出现爱锦或卿卿。文档涉及保存、删除、训练、共享和广告等话题，但适用于当前爱锦接入关系的证据仍缺少，未将其承诺复制为爱锦自己的已核实事实。完整功能的年龄分级证据另记为 `metadata/age-rating-evidence.json`，没有把未知选项默认填成 None。

## 仍待处理

### 后台三项阻塞复核

后续用户明确指示“帮我提交审核吧”，已替代此前最终提交由用户亲自操作的限制。助手重新读取后台并实际点击 `Add for Review`，Apple 返回 `Unable to Add for Review`，仍列出 Content Rights、Age Ratings 与 App Privacy 三项必填缺失。随后 API 回读状态为 `PREPARE_FOR_SUBMISSION`，没有创建成功的审核提交，也没有用猜测的授权、追踪或年龄答案消除校验。此次实际尝试记录在 `USER-AUTHORIZED-SUBMISSION-ATTEMPT.json`；后续在必填资料如实完成后，可依据这次授权继续提交，无需重复索取提交权限。

再次按实际业务核对后，确认 A 面的 `member/roleFollow` 会提交并保存账号关联的角色关注状态，角色详情接口会读取该状态。依据 Apple 对 Product Interaction 的定义，将“产品交互”补入后台数据类型草稿；保存后刷新页面确认现有 8 类，原 7 类均保留。没有为核验而提交真实关注动作，也没有将未知的第三方用途或追踪字段默认填为否。源码隐私清单、公开政策与待执行软件的行为仍须区分；接口方公开政策 3.3.2、4.4、9.2 包含标识/邮箱与合作方资料关联投放或衡量广告的描述，不能用未发现 ATT SDK 来证明无追踪。

本轮直接询问必要使用权的事实时，用户选择“这个跳过就好”，因此 Content Rights 按要求保留未填写，未据此推断已经获得授权。分级问卷仍未完整保存，隐私标签仍未发布。在新增数据类型保存后再次点击 Add for Review，三项必填校验仍拦截；API 回读仍为 `PREPARE_FOR_SUBMISSION`。证据为 `PRODUCT-INTERACTION-DRAFT-SAVED.json`、`SUBMISSION-AFTER-EIGHT-DATA-CATEGORIES.json`。未修改 A/B 业务代码、运行配置或已上传构建，18 个 B 面源码哈希仍与基线一致。

用户反馈的 Content Rights、Age Ratings 与 App Privacy 三项提示仍对应未完成的真实字段，政策网址和 build 2 并未丢失。账号网页具有编辑能力；提示中的 Admin 不是对当前登录账号缺少管理员权限的单独诊断。

- 内容权利表单再次核对：Yes 同时确认具有必要使用权，No 表示没有包含、展示或访问第三方内容。A 面本身也调用第三方 AI、展示原版素材，因此先不另交 B 面附件并不能自动得出任一完整声明。接口方 `/page/agreement` 当前仍显示 Saylo Terms of Service；第 9 节为受限制的用户使用许可，第 12.8 节对商业用途及转许可设有限制。文件适用性与爱锦的单独接入 / 再发布许可尚未确认，没有据此勾选已有权利。
- 年龄问卷第一步有 8 个功能问题。A 面公开角色、发现列表、作者页和关注可确认用户生成内容及社交内容发现；AI 多角色聊天本身不能直接当作用户之间的聊天。两项正向事实已记录在资料草稿，网页不支持跳过其余必填问题。依 Apple 官方 API 仅提交这两项的部分更新返回 403，回读确认所有年龄答案未变化，没有反复重试或填写未知项来换取保存。当前没有已完成或已保存的年龄分级。
- App Privacy 已逐项整理 7 类 A 面数据的最低已知用途、身份关联和源码位置，另确认资料设置提交角色推荐偏好，用于产品个性化。单类邮箱设置实际走到必填追踪问题后，界面只有 Yes / No，未选时 Save 禁用；没有“未知”选项，也不能将源码中未发现 ATT / IDFA 当成全部第三方不追踪的证明。取消未完成的设置，没有发布标签。
- Apple 当前年龄表明确：若完整功能包含露骨性内容，无论频率高低均属于 Unrated，不能在 App Store 发布。这是针对实际内容待核验的规则，不是将当前应用擅自保存为 Unrated，也不是仅提高到 18+ 就能解决的事项。

详细草稿与当前阻塞为 `metadata/app-privacy-answer-draft.json`、`metadata/age-rating-evidence.json` 和 `metadata/review-blockers-current.json`。本轮没有修改 A / B 业务源码、没有重新打包或替换网站内容、没有进行最终送审。

1. 正式支持网址、政策网址及获准公开的客服邮箱已经配置；第三方运营主体、完整数据用途、保留和删除安排仍待核实。政策正文明确列出这些未知事项，没有编造信息，尚不能据此完成隐私标签与发布资格核验。
2. 已验证核心 AI 内容的自动设备游客测试方式，但未提供具有付费权益的审核账号。第三方 AI API、素材与客体应用的授权证明仍缺少；不能自行签发第三方授权文件。
3. 原生应用包下载和执行、成人内容入口、数字内容外部付款仍是当前完整功能版的实际审核问题，需按真实功能和发行地区处理，不能以改名、提高年龄分级或隐瞒功能替代。详见此前的[审核可行性分析](../aijin-naming-20261108/APPSTORE-READINESS.md)。
4. 版权字段已完成，尚未完成正式隐私披露、完整功能的内容分级和内容权利声明。已核实内容权利表单中的 Yes 选项同时声明拥有必要权利，未在缺少授权依据时勾选。根目录的 AGPL 许可证不构成素材与第三方 API 授权的证明。中国大陆已排除，因此不再把 App ICP 备案号列为当前首发地区的缺项；没有猜造备案号或许可证。后台显示的付费协议及税务资料未完成，未代签协议或虚构税务 / 银行信息。当前版本状态仍为 `Prepare for Submission`，未提交审核；版权、截图、加密及发行范围的保存不等同于已经具备上架资格。

## 证据

结构化证据位于忽略目录 `NIVMHost/Build/QA/aijin-appstore-20261108/`：`AGREEMENT-RECHECK.json`、`DISTRIBUTION-CONFIG.json`、`APPSTORE-ARTIFACT.json`、`RUNTIME-COMPARE.json`、`SERVICE-CONFIG-COMPARE.json`、`DEVICE-VERIFICATION.json`、`SUPPORT-PREVIEW.json`。实际分发构建日志为 `distribution-build.log`；旧 R10 包保留原身份，没有重标为本次新应用分发包。

本轮补充证据位于其 `upload/`：`SELECTED-BUILD.json`、`CURRENT-PREPARATION-STATE.json`、`SUPPORT-URL-SAVED.json`、`PUBLIC-SUPPORT-QA.json`、`SUPPORT-SITE-PUBLISHED.json`、`ENCRYPTION-PREFLIGHT.json`、`ATTACHMENT-REPLACEMENT.json`。

后续后台补齐证据：`SCREENSHOT-UPLOAD-READBACK.json`、`TERRITORY-READBACK.json`、`LATEST-SAVED-METADATA.json`、`GUEST-REVIEW-INSTRUCTIONS.json`、`FRESH-SIMULATOR-SESSION.json`、`ENCRYPTION-QUESTIONNAIRE-SAVED.json`。截图及来源说明保存在 `NIVMHost/AppStore/Aijin-1.0/screenshots/`。

本轮追加 `CHINA-EXCLUSION-VERIFIED.json`、`PRIVACY-CHOICES-URL-SAVED.json` 与 `REMAINING-METADATA-RECHECK.json`。未完成项目和所需真实信息逐项列在 `NIVMHost/AppStore/Aijin-1.0/metadata/submission-readiness.json`，不是已通过审核的声明。

版权及政策草稿的追加证据：`COPYRIGHT-SAVED.json`、`PROVIDER-POLICY-RECHECK.json`、`PRIVACY-POLICY-DRAFT-PREPARED.json`。账号姓名的私有核验中间文件未输出至报告；正式版权字段与拟公开的政策主体资料按照用户授权保存。

政策正式页面与后续指定删除的证据：`POLICY-PAGE-QA.json`（最初 12 节版本）、`PRIVACY-POLICY-URL-SAVED.json`、`POLICY-V6-PUBLISHED.json`、`LIVE-POLICY-V6-VERIFIED.json`。A 面链接回归与 B 面基线见 `PrivacyLinkCheck.swift`、`POLICY-API-CONTRACT-CHECK.log`、`POLICY-LINK-B-SOURCE-BASELINE.json`；发布政策页面并未执行最终送审。

build 2 最终证据：`POLICY-BUILD2-ARTIFACT.json`、`POLICY-BUILD2-RUNTIME-COMPARE.json`、`POLICY-LINK-TEST-RESULTS.json`、`policy2-validate-result.json`、`policy2-upload-result.json`、`POLICY-BUILD2-FINAL-HANDOFF.json`。回读确认政策及隐私选择网址、版权、审核联系人和游客测试方式保留，当前状态仍为 `PREPARE_FOR_SUBMISSION`；未调用或点击最终送审。

Apple 官方流程：[移除应用](https://developer.apple.com/help/app-store-connect/create-an-app-record/remove-an-app)、[创建应用记录](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app)、[提交应用](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app/)。

完整功能与隐私要求：[审核指南 2.5.19 / 2.5.2 / 1.1.4](https://developer.apple.com/app-store/review/guidelines/)、[App 隐私披露](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy)。
