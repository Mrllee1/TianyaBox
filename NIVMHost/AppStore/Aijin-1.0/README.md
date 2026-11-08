# 爱锦 1.0 完整功能版提交资料

Bundle ID：`com.aijin.ai`；App Store Connect Apple ID：`6832195363`。

本目录是当前爱锦的资料入口，保留 AI 与原生应用空间。旧 TempMail 的邮箱描述、旧账号资料及旧邮箱截图均不适用于本次应用，不得混用。

- `metadata/release-config.json`：已验证配置与尚未确认的信息，未知项使用 `null`，不编造主体、联系方式、账号或授权。
- `metadata/description.zh-Hans.txt`：完整功能的商店描述草稿。
- `metadata/review-notes.zh-Hans.txt`：实际功能、入口和测试步骤的内部审核草稿。
- `metadata/privacy-data-map.json`：代码可确认的数据流和待核实的第三方数据处理。
- `metadata/app-privacy-answer-draft.json`：8 类已保存草稿的数据类型，以及逐项可确认的最低用途、身份关联和源码位置；新增角色关注状态对应的“产品交互”，后台保存并刷新核验通过。追踪及其他第三方用途仍有未知值，单类数据设置未回答必填追踪问题时无法保存，因此尚未发布完整隐私标签。
- `metadata/privacy-policy.zh-Hans.txt`：当前已发布的 11 节隐私政策，使用开发者姓名与获准公开的支持邮箱，说明已确认的客户端处理和未核实的第三方规则。`privacy-policy.published-content.json` 为生成来源；12 节内部核验草稿另行保留。按用户要求移除独立目录/下载章节与开头的对应介绍语，其他处理披露保持原样。
- `metadata/privacy-policy-parties.json` 与 `metadata/privacy-policy-review.json`：已核实的发布者 / 联系资料，以及政策发布后仍未完成核验的运营事项；网址已发布不等于规则、隐私标签或上架资格全部核实。
- `metadata/age-rating-evidence.json`：完整 A/B 功能分级的已知证据及未知项，没有据此提交未经核实的分级问卷。
- `metadata/encryption-declaration.json`：按实际第三方标准加密及不在法国发行保存的问卷结果，不等同于未使用加密代码。
- `metadata/icp-prefill.json`：App ICP 备案流程和已知应用技术字段；主体、域名和云资源资料待补，尚未发起备案申请。中国大陆已按用户指示排除，当前首发地区不使用这份备案草稿。
- `metadata/submission-readiness.json`：当前已完成的后台配置、未完成项目及所需真实资料；用户最新指示已授权助手最终提交，实际提交入口仍被必填资料校验拦截。
- `screenshots/`：已上传后台的 iPhone / iPad 各 4 张截图与来源说明，均通过后台处理；截图来自实际 Swift UI 源码和在线内容的模拟器运行。
- `support-site/`：已发布的支持网站源码，客服邮箱经用户明确授权公开。后台支持网址已保存为 https://aijin-support-20261108.well-boot-4687.chatgpt.site/support.html 。首页、使用帮助、隐私与数据页已按用户逐次要求移除“应用空间”段落。数据说明页保留为可选的用户隐私选择网址；新增 https://aijin-support-20261108.well-boot-4687.chatgpt.site/privacy-policy 已发布并保存到后台 Privacy Policy URL，通过 API 回读与三种宽度的线上浏览器检查。

资料准备不代表审核完成或已经送审。当前主应用包含原生应用包下载和执行、成人内容入口及外部数字内容支付；隐瞒这些功能或仅提高年龄分级不能解决相应审核问题。未对运营主体、数据保留承诺或第三方使用权作虚构声明。

当前选入后台版本草稿的构建为 `1.0.0 (2)`，已通过苹果校验、上传和处理（`VALID`），加密问卷按原有实际加密实现与不在法国发行保存。该构建仅更新 A 面内的发布者隐私政策入口，服务协议入口不变；18 个 B 面源文件、宿主配置和 63 个运行库的代码 / 非签名资源与 build 1 保持一致。52 项路由、22 组 API 契约及公共政策链接检查通过；本轮未把分发包上传等同于装机验证。用户随后授权助手最终提交；已实际点击 Add for Review，Apple 仍因内容权利、年龄分级和隐私标签三项缺失而拦截，后台状态回读仍为 `PREPARE_FOR_SUBMISSION`，没有送审成功。

分发证书、私钥、描述文件和密码位于被 Git 忽略的 `.private/apple-distribution/`，不应复制进本目录。构建与后台状态见 `docs/audits/aijin-appstore-20261108/REPORT.md`。
