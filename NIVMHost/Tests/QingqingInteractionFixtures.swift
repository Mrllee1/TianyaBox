// Test-only transport. Every request is intercepted; no live account, order,
// message, game, gift, publication or external image request can be submitted.
import Foundation

@MainActor enum QQInteractionFixtures {
  static func store(mode: String) -> QingqingStore {
    QQInteractionProtocol.reset(mode)
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [QQInteractionProtocol.self]
    let api = QingqingAPI(session: URLSession(configuration: configuration), baseURL: URL(string: "https://fixture.invalid/")!, serviceConfiguration: [:], useKeychain: false)
    return QingqingStore(api: api)
  }
  static var roles: [QQRecord] {
    [QQRecord(.object(["id": .string("lead"), "name": .string("主控身份"), "playable": .bool(true)])),
     QQRecord(.object(["id": .string("support"), "name": .string("副控身份"), "playable": .bool(false)]))]
  }
}

final class QQInteractionProtocol: URLProtocol {
  private static let lock = NSLock()
  private static var mode = "navigation"
  private static var calls: [String: Int] = [:]
  private let cancellation = NSLock()
  private var stopped = false
  static func reset(_ value: String) { lock.lock(); defer { lock.unlock() }; mode = value; calls = [:] }
  static func count(_ key: String) -> Int { lock.lock(); defer { lock.unlock() }; return calls[key] ?? 0 }
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func stopLoading() { cancellation.lock(); stopped = true; cancellation.unlock() }
  override func startLoading() {
    let reply = Self.reply(request)
    DispatchQueue.global().asyncAfter(deadline: .now() + reply.delay) { [self] in
      cancellation.lock(); let cancelled = stopped; cancellation.unlock()
      guard !cancelled else { return }
      client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: reply.http, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: reply.data)
      client?.urlProtocolDidFinishLoading(self)
    }
  }
  private static func reply(_ request: URLRequest) -> (data: Data, http: Int, delay: Double) {
    lock.lock(); defer { lock.unlock() }
    let path = request.url!.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    let query = Dictionary(uniqueKeysWithValues: (URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
    let page = Int(query["page"] ?? "1") ?? 1, category = query["category"] ?? "all"
    let key = path == "home/getRole" ? "roles.\(category).\(page)" : path
    calls[key, default: 0] += 1
    var payload: Any = [], code = 200, http = 200, delay = 0.04
    let permittedPosts = ["device/login", "member/getRoleSetting", "home/getRoleDetail", "home/getGroupRoleDetail", "ai/chatList"] + (mode == "chat-draft" ? ["ai/chatV2"] : [])
    if request.httpMethod != "GET" && !permittedPosts.contains(path) {
      code = 405; http = 405
    } else {
      func record(_ id: String, _ name: String) -> [String: Any] {
        ["id": id, "name": name, "intro": String(repeating: "用于核对长文案的换行、点击和边界。", count: 5), "img_url": "", "tags": ["测试", "长文案", "测试"], "playable": true]
      }
      switch path {
      case "device/login": payload = ["token": "synthetic-preview-only"]
      case "member/info": payload = ["id": "qa-account", "nick": "验收账号", "coin": "0"]
      case "home/indexCategory": payload = [["code": "all", "name": "全部"], ["code": "slow", "name": "慢分类"], ["code": "fast", "name": "快分类"]]
      case "home/getModelListV2": payload = [["code": "qa", "name": "验收模式"]]
      case "home/getRecommend": payload = [record("recommend", "推荐验收角色")]
      case "home/getGroupRole":
        payload = [record("group", "群聊验收角色")]
        if mode == "section-error" { code = 500; delay = 0.35 }
      case "simulator/list": payload = [record("simulator", "模拟器验收剧情")]
      case "timetravel/scripts": payload = (0..<3).map { record("theater-\($0)", "剧场验收剧情\($0)") }; delay = mode == "section-error" ? 0.6 : 0.04
      case "home/getRole":
        payload = page <= 2 ? (1...20).map { record("\(category)-\((page - 1) * 20 + $0)", "\(category)角色\((page - 1) * 20 + $0)") } : []
        if category == "slow" { delay = 0.4 }
        if mode == "paging", page == 2, calls[key] == 1 { code = 500 }
        if mode == "refresh-failure", page == 1, calls[key, default: 0] > 1 { code = 500 }
      case "home/roleRankLabel": payload = [["type": "hot", "name": "热门"], ["type": "new", "name": "最新"]]
      case "home/roleRank": payload = [record("rank", "排行验收角色")]; delay = 0.25
      case "home/getRoleDetail", "home/getGroupRoleDetail": payload = record("detail", "详情验收角色")
      case "member/getRoleSetting": payload = ["name": "", "gender": "", "setting": ""]
      case "ai/chatList": payload = []
      case "ai/chatV2": http = 503; code = 503; delay = 3
      case "ai/getMemoryHome": payload = ["home_is_show": 0]
      case "role/getMemberRole", "role/getConfig": payload = [String: String]()
      case "member/getInvite": payload = ["invite_total": "0"]
      case "ai/getMemberRoleCount": payload = ["count": "0", "max": "3"]
      case "member/memberRoleList", "ai/roleList", "member/followList", "member/getInviteList", "member/getCoinList", "ai/systemMsg": payload = []
      case "member/getCoinTotal": payload = ["coin": "0"]
      default: code = 404; http = 404
      }
    }
    let data = try! JSONSerialization.data(withJSONObject: ["code": code, "data": payload, "msg": code == 200 ? "success" : "合成请求失败，请重试"])
    return (data, http, delay)
  }
}
