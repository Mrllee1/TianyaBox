// Compile separately with QingqingA sources for visual QA. This entry point is
// excluded from the app target. qa-layout-only records exercise layout/error
// states only; they must never be reported as live chat or entitlement tests.
import SwiftUI
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
    }.task { if !["home", "library", "mine", "messages", "group", "simulator", "theater"].contains(mode) { await store.start() }; ready = true }
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
