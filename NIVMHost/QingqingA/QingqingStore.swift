import SwiftUI

@MainActor
final class QingqingStore: ObservableObject {
  let api = QingqingAPI()
  @Published var selectedTab = 0
  @Published var homeSection = 0
  @Published var recommended: [QQRecord] = []
  @Published var roles: [QQRecord] = []
  @Published var groups: [QQRecord] = []
  @Published var simulators: [QQRecord] = []
  @Published var theaters: [QQRecord] = []
  @Published var categories: [QQRecord] = []
  @Published var models: [QQRecord] = []
  @Published var user: QQRecord?
  @Published var loading = false
  @Published var error: String?
  @Published var sessionError: String?
  @Published var loginPresented = false
  @Published var creatorPresented = false
  private var started = false
  private var rolesRequestID = UUID()

  var loggedIn: Bool { api.isLoggedIn }
  var hasBoundAccount: Bool { !(user?.first("email", "mobile", "bind_mobile") ?? "").isEmpty }

  func start() async {
    guard !started else { return }
    started = true
    await reload()
    if !loggedIn {
      do { try await api.ensureDeviceSession(); sessionError = nil; await refreshUser() }
      catch { sessionError = error.localizedDescription }
    }
  }

  func reload() async {
    loading = true; error = nil
    defer { loading = false }
    do {
      recommended = try await api.request("home/getRecommend", parameters: ["page": "1", "pageSize": "20"]).records
      categories = try await api.request("home/indexCategory").records
      models = try await api.request("home/getModelListV2").records
      if loggedIn { await refreshUser() }
    } catch is CancellationError {} catch { self.error = error.localizedDescription }
  }

  func loadSection(_ index: Int) async {
    loading = true; error = nil
    defer { loading = false }
    do {
      switch index {
      case 1: groups = try await api.request("home/getGroupRole", parameters: ["page": "1", "pageSize": "20"]).records
      case 2: simulators = try await api.request("simulator/list", parameters: ["page": "1", "limit": "20"]).records
      case 3: theaters = try await api.request("timetravel/scripts").records
      default: if recommended.isEmpty { await reload() }
      }
    } catch is CancellationError {} catch { self.error = error.localizedDescription }
  }

  func loadRoles(category: String = "all", keyword: String = "", page: Int = 1) async {
    let requestID = UUID(); rolesRequestID = requestID
    loading = true; error = nil
    defer { if rolesRequestID == requestID { loading = false } }
    do {
      let result: [QQRecord]
      if keyword.isEmpty {
        result = try await api.request("home/getRole", parameters: ["page": String(page), "pageSize": "20", "category": category]).records
      } else {
        result = try await api.request("home/searchRole", method: "POST", parameters: ["keyword": keyword, "page": String(page), "pageSize": "20"]).records
      }
      guard rolesRequestID == requestID, !Task.isCancelled else { return }
      if page == 1 { roles = result } else { roles += result.filter { item in !roles.contains(where: { $0.id == item.id }) } }
    } catch is CancellationError {} catch { if rolesRequestID == requestID { self.error = error.localizedDescription } }
  }

  func refreshUser() async {
    do { user = QQRecord(try await api.request("member/info")) }
    catch { self.error = error.localizedDescription }
  }

  func requireLogin(_ action: () -> Void) {
    if loggedIn { action() } else { loginPresented = true }
  }

  func logout() async {
    do {
      _ = try await api.request("member/logout")
      api.setToken(""); user = nil; selectedTab = 0
    } catch { self.error = error.localizedDescription }
  }
}
