// Compile separately with QingqingA sources for visual QA. This entry point is
// excluded from the app target. qa-layout-only records exercise layout/error
// states only; they must never be reported as live chat or entitlement tests.
import SwiftUI
import Security
@main struct QingqingPreview: App {
  var body: some Scene { WindowGroup { PreviewScreen() } }
}
struct PreviewScreen: View {
  @StateObject var store = QingqingStore()
  @State private var ready = false
  private var mode: String { ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--qq=") })?.replacingOccurrences(of: "--qq=", with: "") ?? "home" }
  var body: some View {
    Group {
      if !ready { ProgressView() }
      else { switch mode {
      case "local-diagnostics": QQPreviewLocalDiagnostics()
      case "home-tabs-fixture": QQHomeTabsPreview()
      case "navigation-fixture", "discovery-fixture", "section-error-fixture": QQNavigationInteractionPreview(mode: mode)
      case "compact-navigation-fixture": QQNavigationInteractionPreview(mode: mode).frame(width: 320, height: 568)
      case "cast-guards-fixture": QQCastGuardsPreview()
      case "chat-draft-fixture": QQChatDraftInteractionPreview()
      case "chat-input-dark-fixture": QQChatDraftInteractionPreview(dark: true)
      case "member-purchase-fixture", "member-empty-fixture", "member-expiring-fixture", "compact-member-purchase-fixture": QQMemberInteractionPreview(mode: mode)
      case "long-header-fixture": QQLongHeaderInteractionPreview()
      case "background-sheet-fixture": QQBackgroundSheetPreview(custom: false)
      case "background-custom-fixture": QQBackgroundSheetPreview(custom: true)
      case "memory-capacity-fixture", "memory-unlock-fixture", "memory-owned-fixture": NavigationStack { QQMemoryOfferPreview(mode: mode) }
      case "agent-picker": NavigationStack { QQAgentPickerView(excludedIDs: [], select: { _ in }) }.environmentObject(store)
      case "tag-picker": QQTagPreview().environmentObject(store)
      case "ranking": NavigationStack { QQLibraryView(initialRanking: true) }.environmentObject(store)
      case "search": NavigationStack { QQSearchView() }.environmentObject(store)
      case "invited-friends": NavigationStack { QQAPIListView(title: "我邀请的好友", path: "member/getInviteList", requiresLogin: true) }.environmentObject(store)
      case "notifications": NavigationStack { QQAPIListView(title: "系统通知", path: "ai/systemMsg", requiresLogin: true) }.environmentObject(store)
      case "messages": QingqingRootView(initialTab: 2)
      case "group-detail", "simulator-detail", "simulator-cast", "author": NavigationStack { QQScenePreview(mode: mode) }.environmentObject(store)
      case "creator-notice": QQCreatorNoticeView()
      case "invite-rules": QQInviteRulesView().environmentObject(store)
      case "share": NavigationStack { QQInviteView() }.environmentObject(store)
      case "diamond-store": NavigationStack { QQMemberView(initialTab: 1) }.environmentObject(store)
      case "chat", "chat-settings", "background", "role", "gift", "intimacy", "live-identity", "live-memory": NavigationStack { QQRolePreview(mode: mode) }.environmentObject(store)
      case "diamond": NavigationStack { QQDiamondDetailView() }.environmentObject(store)
      case "settings": NavigationStack { QQSettingsView() }.environmentObject(store)
      case "profile": NavigationStack { QQProfileView() }.environmentObject(store)
      case "about": NavigationStack { QQAboutView() }.environmentObject(store)
      case "feedback": NavigationStack { QQFeedbackView() }.environmentObject(store)
      case "invite-code": NavigationStack { QQInvitationCodeView() }.environmentObject(store)
      case "sign-in": NavigationStack { QQSignInView() }.environmentObject(store)
      case "cancellation": NavigationStack { QQCancellationView() }.environmentObject(store)
      case "models": NavigationStack { QQModelSelectionView(selection: .constant("L1")) }.environmentObject(store).task { await store.start() }
      case "questions": NavigationStack { QQModelQuestionsView() }.environmentObject(store)
      case "memory": NavigationStack { QQMemoryView(role: QQRecord(.object(["id": .string("qa-layout-only"), "name": .string("角色")])) ) }.environmentObject(store)
      case "identity": NavigationStack { QQIdentityView(role: QQRecord(.object(["id": .string("qa-layout-only"), "name": .string("角色")])) ) }.environmentObject(store)
      case "login": QQLoginView().environmentObject(store)
      case "creator": NavigationStack { QQCreatorView() }.environmentObject(store)
      case "library": QingqingRootView(initialTab: 1)
      case "mine": QingqingRootView(initialTab: 3)
      case "group": QingqingRootView(initialHomeSection: 1)
      case "simulator": QingqingRootView(initialHomeSection: 2)
      case "theater": QingqingRootView(initialHomeSection: 3)
      case "member": NavigationStack { QQMemberView() }.environmentObject(store)
      default: QingqingRootView()
      } }
    }.task { if !mode.hasSuffix("-fixture") && !["local-diagnostics", "home", "library", "mine", "messages", "group", "simulator", "theater"].contains(mode) { await store.start() }; ready = true }
  }
}

private struct QQHomeTabsPreview: View {
  @StateObject private var store = QQInteractionFixtures.store(mode: "navigation")
  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        ForEach([false, true], id: \.self) { dark in
          VStack(spacing: 0) {
            ForEach(0..<4) { selected in
              QQHomeCategoryHeader(selection: selected, darkBackdrop: dark, select: { _ in })
            }
          }.background(dark ? Color(red: 0.06, green: 0.18, blue: 0.23) : Color(white: 249.0 / 255))
        }
      }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }.environmentObject(store)
  }
}

private struct QQBackgroundSheetPreview: View {
  let custom: Bool
  @State private var presented = false
  private var role: QQRecord { QQRecord(.object(["id": .string(custom ? "qa-custom-background-only" : "qa-background-only"), "name": .string("背景验收")])) }
  var body: some View {
    VStack(spacing: 20) {
      Text("合成背景验收 · 仅测试容器本地设置").font(.system(size: 13))
      Button("打开背景设置") { presented = true }
    }.sheet(isPresented: $presented) {
      QQBackgroundSettingView(role: role).presentationDetents([.height(450)]).presentationCornerRadius(30).presentationDragIndicator(.hidden)
    }.task {
      if custom, let data = UIImage(named: "qq_res_logo")?.pngData(), let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        let folder = directory.appendingPathComponent("QingqingChatBackgrounds", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let file = folder.appendingPathComponent("qa-synthetic-background.image")
        try? data.write(to: file, options: .atomic)
        UserDefaults.standard.set(file.path, forKey: QQChatBackground.key(role.id))
      }
      presented = true
    }
  }
}

private struct QQPreviewLocalDiagnostics: View {
  @State private var result = "正在检查本地测试容器…"
  var body: some View { Text(result).padding(30).task {
    let account = "disposable-qa-probe"
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: "com.tianyabox.qingqing.preview.probe", kSecAttrAccount as String: account]
    var add = query; add[kSecValueData as String] = Data("synthetic-test-only".utf8)
    let added = SecItemAdd(add as CFDictionary, nil)
    var read = query; read[kSecReturnData as String] = true
    var output: CFTypeRef?
    let readStatus = SecItemCopyMatching(read as CFDictionary, &output)
    let removed = SecItemDelete(query as CFDictionary)
    let configurationPresent = Bundle.main.url(forResource: "QingqingService", withExtension: "plist") != nil
    let diagnostic: [String: Any] = ["keychain_add_status": added, "keychain_read_status": readStatus, "keychain_delete_status": removed, "configuration_present": configurationPresent, "bundle_id": Bundle.main.bundleIdentifier ?? "", "os": ProcessInfo.processInfo.operatingSystemVersionString, "network_requests": 0]
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("preview-local-diagnostics.json")
    try? JSONSerialization.data(withJSONObject: diagnostic, options: [.prettyPrinted]).write(to: url)
    result = "本地 Keychain 写入：\(added)\n读取：\(readStatus)\n配置存在：\(configurationPresent)\n未发起网络请求"
  } }
}

private struct QQMemoryOfferPreview: View {
  let mode: String
  @State private var selected: QQRecord?
  @State private var way: QQRecord?
  private var kind: QQMemoryOfferKind { mode == "memory-unlock-fixture" ? .unlock : .capacity }
  private var offers: QQMemoryOffers {
    // Deliberately synthetic identifiers and text, confined to the QA target.
    let packages: QQValue = .array([
      .object(["package_id": .string("qa-only-single"), "title": .string("单角色布局测试"), "price": .string("测试"), "desc": .string("只核对布局，不是线上权益"), "tips": .array([.string("测试较长的规则文字换行和对齐"), .string("不会提交订单")]), "is_all": .number(0)]),
      .object(["package_id": .string("qa-only-all"), "title": .string("全部角色布局测试"), "price": .string("测试"), "desc": .string("只核对布局，不是线上权益"), "tag": .string("测试"), "tips": .array([.string("测试第二张卡片的样式"), .string("不会提交订单")]), "is_all": .number(1)])
    ])
    let payWays: QQValue = .array([.object(["code": .string("qa-only-way"), "name": .string("测试支付方式"), "checked": .bool(true)])])
    let info: QQValue = .object(["what_title": .string("什么是记忆条数"), "desc_list": .array([.string("合成文字仅用于检查字体、间距与换行"), .string("不代表真实套餐或账户权益")]), "role_status": .number(mode == "memory-owned-fixture" ? 1 : 0), "pay_types": payWays, "features": .array([.object(["title": .string("已购状态布局测试"), "desc": .string("不代表真实权益")])])])
    let payload: QQValue = kind == .capacity ? packages : .object(["plans": packages, "pay_types": payWays])
    return QQMemoryOffers(kind: kind, payload: payload, information: info)
  }
  var body: some View {
    QQPage(title: "", color: Color(red: 0.98, green: 0.96, blue: 1), backgroundArtwork: kind == .capacity ? "amount_pic_background" : "memory_pic_background2", artworkHeight: 600, closeOnRight: kind == .unlock) {
      ScrollView {
        Text("合成布局验收 · 未请求业务接口").font(.system(size: 11)).foregroundStyle(.red)
        QQMemoryOffersContent(offers: offers, selected: $selected, selectedWay: $way, loading: false, canPurchase: false, buy: {})
      }
    }.task { selected = offers.packages.first; way = offers.initialWay }
  }
}

private struct QQScenePreview: View {
  @EnvironmentObject var store: QingqingStore
  let mode: String
  @State var record: QQRecord?
  @State var player = ""
  @State var agents: [String: QQRecord] = [:]
  var body: some View {
    Group {
      if let record {
        switch mode {
        case "group-detail": QQRoleDetailView(role: record, kind: .multi)
        case "author": QQAuthorCenterView(authorID: record["uid"])
        case "simulator-cast": QQSimulatorCastView(title: record.name, scenarioID: record.id, roles: record.value["roles"].records, playerRoleID: $player, agents: $agents, busy: false, start: {})
        default: QQSimulatorDetailView(scenario: record)
        }
      } else { ProgressView() }
    }.task {
      if mode == "group-detail" { record = try? await store.api.request("home/getGroupRole", parameters: ["page":"1", "pageSize":"1"]).records.first }
      else if mode == "author" { record = try? await store.api.request("home/getRecommend", parameters: ["page":"1", "pageSize":"1"]).records.first }
      else if let scenario = try? await store.api.request("simulator/list", parameters: ["page":"1", "limit":"1"]).records.first {
        record = try? QQRecord(await store.api.request("simulator/detail", parameters: ["id":scenario.id]))
        player = record?.value["roles"].records.first(where: { $0["playable"] == "1" })?.id ?? ""
      }
    }
  }
}

private struct QQTagPreview: View {
  @EnvironmentObject var store: QingqingStore
  @State var config: QQValue = .null
  @State var tags = ""
  var body: some View { QQTagSelectionView(selection: $tags, configuration: config).id(config.isNull).task { config = (try? await store.api.request("ai/getRoleConfig")) ?? .null } }
}

private struct QQRolePreview: View {
  @EnvironmentObject var store: QingqingStore
  let mode: String
  @State var role: QQRecord?
  var body: some View {
    Group {
      if let role {
        switch mode {
        case "chat-settings": QQTalkSettingsPanel(role: role, modelName: store.models.first?.name ?? "", close: {}, identity: {}, background: {}, models: {})
        case "background": QQBackgroundSettingView(role: role)
        case "role": QQRoleDetailView(role: role)
        case "gift": QQGiftView(role: role)
        case "intimacy": QQIntimacyView(role: role)
        case "live-identity": QQIdentityView(role: role)
        case "live-memory": QQMemoryView(role: role)
        default: QQChatView(role: role)
        }
      } else { ProgressView() }
    }.task { role = try? await store.api.request("home/getRole", parameters: ["page": "1", "pageSize": "1", "category": "all"]).records.first }
  }
}

private struct QQNavigationInteractionPreview: View {
  @StateObject private var store: QingqingStore
  init(mode: String) {
    let store = QQInteractionFixtures.store(mode: mode == "discovery-fixture" ? "paging" : mode == "section-error-fixture" ? "section-error" : "navigation")
    if mode == "discovery-fixture" { store.selectedTab = 1 }
    _store = StateObject(wrappedValue: store)
  }
  var body: some View { QingqingRootView(store: store) }
}
private struct QQCastGuardsPreview: View {
  @StateObject private var store = QQInteractionFixtures.store(mode: "navigation")
  @State private var player = "lead"
  @State private var agents: [String: QQRecord] = [:]
  var body: some View { QQSimulatorCastView(title: "身份限制验收", scenarioID: "qa-only", roles: QQInteractionFixtures.roles, playerRoleID: $player, agents: $agents, busy: false, start: {}).environmentObject(store) }
}

private struct QQChatDraftInteractionPreview: View {
  var dark = false
  @StateObject private var store = QQInteractionFixtures.store(mode: "chat-draft")
  var body: some View { NavigationStack { QQChatView(role: QQRecord(.object(["id": .string("draft-role"), "name": .string("草稿验收角色")])) ) }.environmentObject(store).task { UserDefaults.standard.set(dark, forKey: "qingqing.chat.dark"); await store.start() } }
}
private struct QQMemberInteractionPreview: View {
  let mode: String
  @StateObject private var store: QingqingStore
  init(mode: String) { self.mode = mode; _store = StateObject(wrappedValue: QQInteractionFixtures.store(mode: mode == "member-empty-fixture" ? "member-empty" : mode == "member-expiring-fixture" ? "member-expiring" : "member")) }
  var body: some View {
    NavigationStack { QQMemberView() }.environmentObject(store).task { await store.start() }
      .frame(width: mode.hasPrefix("compact-") ? 320 : nil, height: mode.hasPrefix("compact-") ? 568 : nil)
  }
}
private struct QQLongHeaderInteractionPreview: View {
  @State private var presented = false
  var body: some View {
    NavigationStack {
      Button("打开长标题页面") { presented = true }
        .navigationDestination(isPresented: $presented) {
          QQPage(title: String(repeating: "很长的验收标题", count: 5)) { Color.gray }
        }
    }.frame(width: 320, height: 568)
  }
}
