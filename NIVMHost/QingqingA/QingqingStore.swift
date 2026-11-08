import SwiftUI

@MainActor
final class QingqingStore: ObservableObject {
  let api: QingqingAPI
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
  @Published private(set) var loadingSections: Set<Int> = []
  @Published private(set) var sectionErrors: [Int: String] = [:]
  @Published private(set) var rolesLoading = false
  @Published private(set) var rolesError: String?
  @Published private(set) var configurationError: String?
  @Published var error: String?
  @Published var sessionError: String?
  @Published var loginPresented = false
  @Published var creatorPresented = false
  private var started = false
  private var sectionTasks: [Int: Task<Void, Never>] = [:]
  private var loadedSections: Set<Int> = []
  private var rolesRequestID = UUID()
  private var rolesScope: String?
  private(set) var lastLoadedRolePage = 0

  init(api: QingqingAPI? = nil) { self.api = api ?? QingqingAPI() }
  var loggedIn: Bool { api.isLoggedIn }
  var hasBoundAccount: Bool { !(user?.first("email", "mobile", "bind_mobile") ?? "").isEmpty }

  func start() async {
    guard !started else { return }
    started = true
    async let configuration: Void = loadConfiguration()
    async let home: Void = loadSection(homeSection)
    _ = await (configuration, home)
    if !loggedIn {
      do { try await api.ensureDeviceSession(); sessionError = nil }
      catch { sessionError = error.localizedDescription }
    }
    if loggedIn { await refreshUser() }
  }

  func loadConfiguration() async {
    configurationError = nil
    do { categories = try await api.request("home/indexCategory").records }
    catch { if !Self.cancelled(error) { configurationError = error.localizedDescription } }
    do { models = try await api.request("home/getModelListV2").records }
    catch { if !Self.cancelled(error) { configurationError = error.localizedDescription } }
  }

  func loadSection(_ index: Int, force: Bool = false) async {
    guard (0..<4).contains(index) else { return }
    if let task = sectionTasks[index] { await task.value; return }
    guard force || !loadedSections.contains(index) else { return }
    // Each section owns its request and presentation state. Leaving a tab does
    // not let its late response hide another tab's spinner or show its error.
    let task = Task { @MainActor in
      loadingSections.insert(index); sectionErrors.removeValue(forKey: index)
      defer { loadingSections.remove(index); sectionTasks[index] = nil }
      do {
        let records: [QQRecord]
        switch index {
        case 1: records = try await api.request("home/getGroupRole", parameters: ["page": "1", "pageSize": "20"]).records
        case 2: records = try await api.request("simulator/list", parameters: ["page": "1", "limit": "20"]).records
        case 3: records = try await api.request("timetravel/scripts").records
        default: records = try await api.request("home/getRecommend", parameters: ["page": "1", "pageSize": "20"]).records
        }
        switch index { case 1: groups = records; case 2: simulators = records; case 3: theaters = records; default: recommended = records }
        // An empty successful response may be transient. Retry it when the user
        // returns to the section instead of caching a blank home for this run.
        if records.isEmpty { loadedSections.remove(index) }
        else { loadedSections.insert(index) }
      } catch { if !Self.cancelled(error) { sectionErrors[index] = error.localizedDescription } }
    }
    sectionTasks[index] = task
    await task.value
  }

  @discardableResult
  func loadRoles(category: String = "all", keyword: String = "", page: Int = 1) async -> Int? {
    let scope = category + "\u{1f}" + keyword
    guard page > 0 else { return nil }
    if page > 1 {
      guard !rolesLoading, rolesScope == scope, page == lastLoadedRolePage + 1 else { return nil }
    } else {
      if rolesScope != scope { roles = []; lastLoadedRolePage = 0 }
      rolesScope = scope
    }
    let requestID = UUID(); rolesRequestID = requestID
    rolesLoading = true; rolesError = nil
    defer { if rolesRequestID == requestID { rolesLoading = false } }
    do {
      let result: [QQRecord]
      if keyword.isEmpty {
        result = try await api.request("home/getRole", parameters: ["page": String(page), "pageSize": "20", "category": category]).records
      } else {
        result = try await api.request("home/searchRole", method: "POST", parameters: ["keyword": keyword, "page": String(page), "pageSize": "20"]).records
      }
      guard rolesRequestID == requestID, !Task.isCancelled else { return nil }
      if page == 1 { roles = result } else { roles += result.filter { item in !roles.contains(where: { $0.id == item.id }) } }
      lastLoadedRolePage = page
      return result.count
    } catch {
      if rolesRequestID == requestID, !Self.cancelled(error) { rolesError = error.localizedDescription }
      return nil
    }
  }

  private static func cancelled(_ error: Error) -> Bool { error is CancellationError || (error as? URLError)?.code == .cancelled }

  func refreshUser() async {
    do { user = QQRecord(try await api.request("member/info")) }
    catch { if !Self.cancelled(error) { self.error = error.localizedDescription } }
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
