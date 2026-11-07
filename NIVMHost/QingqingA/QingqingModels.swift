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
  var id: String { first("id", "role_id", "code", "game_id", "title", "name") }
  var name: String { first("name", "title", "display_name", "nick") }
  var intro: String { first("intro", "summary", "role_intro", "storyBackground") }
  var image: String { first("img_url_webp", "cover_url", "img_url", "coverImage", "cover_img", "head_img") }
  var tags: [String] {
    let a = value["tags"].list.map(\.text).filter { !$0.isEmpty }
    return a.isEmpty ? self["tag"].components(separatedBy: CharacterSet(charactersIn: ",，、| ")).filter { !$0.isEmpty } : a
  }
  func first(_ keys: String...) -> String { keys.lazy.map { self[$0] }.first { !$0.isEmpty } ?? "" }
  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id && lhs.name == rhs.name }
  func hash(into hasher: inout Hasher) { hasher.combine(id); hasher.combine(name) }
}

struct QQMessage: Identifiable, Sendable {
  let id: String
  var text: String
  let isUser: Bool
  var sender = ""
  init(id: String = UUID().uuidString, text: String, isUser: Bool, sender: String = "") {
    self.id = id; self.text = text; self.isUser = isUser; self.sender = sender
  }
}

enum QQConversationKind: String, Sendable { case single, multi, simulator }

enum QQAPIError: LocalizedError {
  case service(Int, String), invalidResponse, invalidURL, authentication, insecureEndpoint
  var errorDescription: String? {
    switch self {
    case .service(_, let message): return message.isEmpty ? "服务暂不可用，请稍后重试" : message
    case .invalidResponse: return "服务返回的数据格式暂不支持"
    case .invalidURL: return "内容地址无效"
    case .authentication: return "请先登录后继续"
    case .insecureEndpoint: return "服务地址需要使用 HTTPS"
    }
  }
}
