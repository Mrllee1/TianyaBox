import Foundation

/// The service uses both strings and numbers for identifiers and balances.
/// Preserve its payload without guessing absent values or substituting demo content.
enum QQValue: Codable, Sendable {
  case object([String: QQValue]), array([QQValue]), string(String), number(Double), bool(Bool), null

  init(from decoder: Decoder) throws {
    let c = try decoder.singleValueContainer()
    if c.decodeNil() { self = .null }
    else if let v = try? c.decode(Bool.self) { self = .bool(v) }
    else if let v = try? c.decode(Double.self) { self = .number(v) }
    else if let v = try? c.decode(String.self) { self = .string(v) }
    else if let v = try? c.decode([String: QQValue].self) { self = .object(v) }
    else { self = .array(try c.decode([QQValue].self)) }
  }

  func encode(to encoder: Encoder) throws {
    var c = encoder.singleValueContainer()
    switch self {
    case .object(let v): try c.encode(v)
    case .array(let v): try c.encode(v)
    case .string(let v): try c.encode(v)
    case .number(let v): try c.encode(v)
    case .bool(let v): try c.encode(v)
    case .null: try c.encodeNil()
    }
  }

  subscript(_ key: String) -> QQValue {
    if case .object(let v) = self { return v[key] ?? .null }
    return .null
  }
  var text: String {
    switch self {
    case .string(let v): return v
    case .number(let v): return v.rounded() == v ? String(format: "%.0f", v) : String(v)
    case .bool(let v): return v ? "1" : "0"
    default: return ""
    }
  }
  var list: [QQValue] { if case .array(let v) = self { return v }; return [] }
  var records: [QQRecord] {
    let values: [QQValue]
    if case .array = self { values = list }
    else if case .array = self["list"] { values = self["list"].list }
    else { values = self["data"].list }
    return values.compactMap { value in
      if case .object = value { return QQRecord(value) }; return nil
    }
  }
  var isNull: Bool { if case .null = self { return true }; return false }
}

struct QQRecord: Identifiable, Hashable, Sendable {
  let value: QQValue
  init(_ value: QQValue) { self.value = value }
  subscript(_ key: String) -> String { value[key].text }
  var id: String { first("id", "role_id", "roleId", "code", "game_id", "title", "name") }
  var name: String { first("name", "title", "role_name", "display_name", "nick") }
  var intro: String { first("intro", "summary", "role_intro", "storyBackground") }
  var image: String { first("img_url_webp", "cover_url", "role_img", "img_url", "coverImage", "cover_img", "head_img") }
  var tags: [String] {
    let a = value["tags"].list.map(\.text).filter { !$0.isEmpty }
    return a.isEmpty ? self["tag"].components(separatedBy: CharacterSet(charactersIn: ",，、| ")).filter { !$0.isEmpty } : a
  }
  func first(_ keys: String...) -> String { keys.lazy.map { self[$0] }.first { !$0.isEmpty } ?? "" }
  var conversationRole: QQRecord {
    guard case .object(var fields) = value, !self["role_id"].isEmpty else { return self }
    fields["id"] = .string(self["role_id"])
    return QQRecord(.object(fields))
  }
  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id && lhs.name == rhs.name }
  func hash(into hasher: inout Hasher) { hasher.combine(id); hasher.combine(name) }
}

enum QQMemoryOfferKind: String { case capacity, unlock }

enum QQMemberCatalog {
  static func initialWay(_ ways: [QQRecord]) -> QQRecord? { ways.first(where: { $0["checked"] == "1" }) ?? ways.first }
  static func diamondArtwork(coin: String) -> String {
    let amount = Int(coin) ?? 0
    return "purchase_ico_diamond0" + String(amount < 1000 ? 2 : amount < 4000 ? 3 : amount < 20000 ? 4 : 5)
  }
  static func valid(package: QQRecord, way: QQRecord, packages: [QQRecord], ways: [QQRecord]) -> Bool {
    guard !package["id"].isEmpty, !way["code"].isEmpty,
      package["price"].range(of: #"^\d+(\.\d{1,2})?$"#, options: .regularExpression) != nil,
      let price = Decimal(string: package["price"], locale: Locale(identifier: "en_US_POSIX")), price > 0 else { return false }
    return packages.contains(where: { $0["id"] == package["id"] && $0["price"] == package["price"] }) && ways.contains(where: { $0["code"] == way["code"] })
  }
}

struct QQIdentityInput {
  let name: String
  let gender: String
  var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
  var canSubmit: Bool { !trimmedName.isEmpty && ["男", "女", "其他"].contains(gender) }
}

enum QQTheaterSelection {
  static func index(selection: Int, slot: Int, count: Int) -> Int? {
    guard count > 0 else { return nil }
    return ((selection + slot - 2) % count + count) % count
  }
}

enum QQChatDraft {
  static func insertingParentheses(in text: String, selection: NSRange) -> (String, NSRange) {
    let value = text as NSString
    let boundaries = Set(text.indices).union([text.endIndex])
    let valid = Range(selection, in: text).map { boundaries.contains($0.lowerBound) && boundaries.contains($0.upperBound) } ?? false
    let safe = valid ? selection : NSRange(location: value.length, length: 0)
    return (value.replacingCharacters(in: safe, with: "（）"), NSRange(location: safe.location + 1, length: 0))
  }
  static func recovering(_ failed: String, alongside current: String) -> String {
    if current.isEmpty || current == failed { return failed }
    if failed.isEmpty { return current }
    return failed + "\n" + current
  }
}

/// The two original screens use different endpoints and payloads. Package IDs
/// are order identifiers; a display title must never substitute for one.
struct QQMemoryOffers {
  let kind: QQMemoryOfferKind
  let payload: QQValue
  let information: QQValue
  var owned: Bool { kind == .capacity && (information["global_status"].text == "1" || information["role_status"].text == "1") }
  var packages: [QQRecord] {
    (kind == .capacity ? payload.records : payload["plans"].records).compactMap { record in
      guard case .object(var fields) = record.value, !record["package_id"].isEmpty else { return nil }
      fields["id"] = .string(record["package_id"])
      return QQRecord(.object(fields))
    }
  }
  var payWays: [QQRecord] {
    (kind == .capacity ? information : payload)["pay_types"].records.filter { !$0["code"].isEmpty }
  }
  var initialWay: QQRecord? { payWays.first(where: { $0["checked"] == "1" }) ?? payWays.first }
}

struct QQMessage: Identifiable, Sendable {
  let id: String
  var text: String
  let isUser: Bool
  var sender = ""
  var senderRoleID = ""
  var avatar = ""
  init(id: String = UUID().uuidString, text: String, isUser: Bool, sender: String = "", senderRoleID: String = "", avatar: String = "") {
    self.id = id; self.text = text; self.isUser = isUser; self.sender = sender; self.senderRoleID = senderRoleID; self.avatar = avatar
  }
}

enum QQConversationKind: String, Sendable { case single, multi, simulator }

enum QQConversationMessages {
  static func history(_ data: QQValue) -> [QQMessage] {
    data.list.enumerated().flatMap { index, item -> [QQMessage] in
      let id = item["id"].text.isEmpty ? (item["mId"].text.isEmpty ? String(index) : item["mId"].text) : item["id"].text
      var messages: [QQMessage] = []
      if !item["msg"].text.isEmpty { messages.append(QQMessage(id: id + ":user", text: item["msg"].text, isUser: true)) }
      if !item["replyList"].list.isEmpty { messages += replies(item, fallbackID: id) }
      else {
        let text = [item["reply"].text, item["content"].text, item["text"].text].first(where: { !$0.isEmpty }) ?? ""
        if !text.isEmpty { messages.append(QQMessage(id: id, text: text, isUser: ["user", "player"].contains(item["type"].text), sender: item["senderName"].text.isEmpty ? item["roleName"].text : item["senderName"].text, senderRoleID: item["roleId"].text, avatar: item["senderAvatar"].text.isEmpty ? item["imgUrl"].text : item["senderAvatar"].text)) }
      }
      return messages
    }
  }
  static func replies(_ data: QQValue, fallbackID: String = UUID().uuidString) -> [QQMessage] {
    let id = data["id"].text.isEmpty ? fallbackID : data["id"].text
    if !data["replyList"].list.isEmpty {
      return data["replyList"].list.enumerated().compactMap { index, entry in
        let content = entry["content"].text
        guard !content.isEmpty else { return nil }
        return QQMessage(id: id + ":\(index)", text: content, isUser: false, sender: entry["display_name"].text, senderRoleID: entry["role_id"].text)
      }
    }
    return data["reply"].text.isEmpty ? [] : [QQMessage(id: id, text: data["reply"].text, isUser: false)]
  }
}

struct QQSimulatorCast {
  var playerRoleID: String
  var agentsByRole: [String: QQRecord]
  func parameters(scenarioID: String, roles: [QQRecord]) throws -> [String: String] {
    let allowed = Set(roles.map(\.id))
    guard !scenarioID.isEmpty, allowed.contains(playerRoleID), roles.contains(where: { $0.id == playerRoleID && $0["playable"] == "1" }), !agentsByRole.isEmpty,
      agentsByRole[playerRoleID] == nil,
      agentsByRole.allSatisfy({ allowed.contains($0.key) && !$0.value.id.isEmpty }),
      Set(agentsByRole.values.map(\.id)).count == agentsByRole.count else {
      throw QQAPIError.service(-1, "至少需要2人参与，且其中一人必须是自己；同一角色不能重复扮演多个身份")
    }
    let selected = roles.compactMap { role in agentsByRole[role.id].map { role.id + "|" + $0.id } }.joined(separator: ",")
    return ["scenario_id": scenarioID, "select_role_id": selected, "player_role_id": playerRoleID]
  }
}

enum QQAPIError: LocalizedError {
  case service(Int, String), httpStatus(Int), invalidResponse, invalidURL, authentication, insecureEndpoint
  var errorDescription: String? {
    switch self {
    case .service(_, let message): return message.isEmpty ? "服务暂不可用，请稍后重试" : message
    case .httpStatus(let status): return "网络请求失败（\(status)）"
    case .invalidResponse: return "服务返回的数据格式暂不支持"
    case .invalidURL: return "内容地址无效"
    case .authentication: return "请先登录后继续"
    case .insecureEndpoint: return "服务地址需要使用 HTTPS"
    }
  }
}

/// The original app's level/stage configuration, including its offline defaults.
struct QQIntimacyProgress {
  let value: Int
  let level: Int
  let stage: Int
  let stageName: String
  let need: Int
  let percent: Int
  init(value: Int, configuration: QQValue) {
    let safeValue = max(0, value)
    self.value = safeValue
    let defaults = [10, 25, 50, 150, 450, 800, 1500, 2300, 3700, 5400, 7600, 11000, 15000, 22000, 33000, 47000, 65000, 90000, 120000]
    let stageDefaults = ["初识", "初识", "熟悉", "熟悉", "熟悉", "靠近", "靠近", "靠近", "默契", "默契", "默契", "信任", "信任", "信任", "亲密", "亲密", "亲密", "羁绊", "羁绊", "羁绊"]
    let levels: [Int]
    if case .object(let map) = configuration["level"], !map.isEmpty { levels = Array(Set(map.values.compactMap { Int($0.text) })).sorted() } else { levels = defaults }
    let points = [0] + Array(levels.dropLast()) + [Int.max]
    let resolvedLevel = (1..<points.count).first(where: { safeValue < points[$0] }) ?? points.count - 1
    level = resolvedLevel
    var names = stageDefaults
    if case .object(let map) = configuration["stage"], !map.isEmpty {
      names = map.keys.sorted { (Int($0.replacingOccurrences(of: "lv", with: "")) ?? 0) < (Int($1.replacingOccurrences(of: "lv", with: "")) ?? 0) }.map { map[$0]?.text ?? "" }
    }
    stageName = names.indices.contains(resolvedLevel - 1) ? names[resolvedLevel - 1] : names.last ?? "初识"
    var distinct: [String] = []
    for name in names where !distinct.contains(name) { distinct.append(name) }
    stage = min(7, max(1, (distinct.firstIndex(of: stageName) ?? 0) + 1))
    let next = points[resolvedLevel]
    need = next == Int.max ? 0 : max(0, next - self.value)
    percent = need == 0 ? 100 : Int(min(100, max(0, Double(self.value) / Double(next) * 100)))
  }
}
