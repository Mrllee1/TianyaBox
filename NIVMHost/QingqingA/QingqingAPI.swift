import Foundation
import Security
import CryptoKit
import CommonCrypto
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class QingqingAPI {
  static let defaultBaseURL = "https://tofai.yyapp123.com/"
  private let session: URLSession
  private(set) var token: String
  let baseURL: URL
  private let installID: String
  private let serviceConfiguration: [String: String]
  private let usesKeychain: Bool
  private var deviceSessionTask: Task<Void, Error>?

  init(session: URLSession = .shared, baseURL: URL? = nil, serviceConfiguration: [String: String]? = nil, useKeychain: Bool = true) {
    self.session = session
    usesKeychain = useKeychain
    let bundledConfiguration: [String: String]
    if let url = Bundle.main.url(forResource: "QingqingService", withExtension: "plist"),
      let data = try? Data(contentsOf: url),
      let value = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] { bundledConfiguration = value }
    else { bundledConfiguration = [:] }
    let configuration = serviceConfiguration ?? bundledConfiguration
    self.serviceConfiguration = configuration
    self.baseURL = baseURL ?? URL(string: configuration["baseURL"] ?? Bundle.main.object(forInfoDictionaryKey: "QingqingAPIBaseURL") as? String ?? "") ?? URL(string: Self.defaultBaseURL)!
    token = useKeychain ? QQKeychain.read("session") ?? "" : ""
    let existing = useKeychain ? QQKeychain.read("installation") : nil
    if let existing, existing.count == 32, existing.allSatisfy({ $0.isHexDigit }) { installID = existing }
    else {
      let value = Insecure.MD5.hash(data: Data((existing ?? UUID().uuidString).utf8)).map { String(format: "%02x", $0) }.joined()
      installID = value
      if useKeychain { QQKeychain.write(value, key: "installation") }
    }
  }

  func documentURL(privacy: Bool) -> URL? {
    guard baseURL.scheme == "https" else { return nil }
    var components = URLComponents(url: baseURL.appendingPathComponent(privacy ? "page/private" : "page/agreement"), resolvingAgainstBaseURL: false)
    components?.queryItems = [URLQueryItem(name: "appid", value: serviceConfiguration["appID"] ?? "1")]
    if let salt = serviceConfiguration["signatureSalt"] { components?.queryItems?.append(URLQueryItem(name: "s", value: salt)) }
    return components?.url
  }

  func setToken(_ token: String) { self.token = token; if usesKeychain { QQKeychain.write(token, key: "session") } }
  var isLoggedIn: Bool { !token.isEmpty }

  static let agentSearchPageSize = 18
  func searchAgents(keyword: String, page: Int) async throws -> [QQRecord] {
    try await request("home/searchRole2", method: "POST", parameters: ["keyword": keyword, "page": String(page), "pageSize": String(Self.agentSearchPageSize)]).records
  }

  func ensureDeviceSession() async throws {
    guard token.isEmpty else { return }
    let pending: Task<Void, Error>
    if let deviceSessionTask { pending = deviceSessionTask }
    else {
      let task = Task { @MainActor in
        defer { self.deviceSessionTask = nil }
        let data = try await self.request("device/login", method: "POST")
        guard !data["token"].text.isEmpty else { throw QQAPIError.invalidResponse }
        // A bound-account login may finish while the guest request is in flight.
        if self.token.isEmpty { self.setToken(data["token"].text) }
      }
      deviceSessionTask = task; pending = task
    }
    try await pending.value
  }

  func request(_ path: String, method: String = "GET", parameters: [String: String] = [:], json: Bool = false, body: QQValue? = nil) async throws -> QQValue {
    guard baseURL.scheme == "https" else { throw QQAPIError.insecureEndpoint }
    var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
    if method == "GET", !parameters.isEmpty {
      components.queryItems = parameters.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    guard let url = components.url else { throw QQAPIError.invalidURL }
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.timeoutInterval = 35
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("TianyaBox/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
    // Use this installation's identity and user-issued session only. Do not copy
    // Android identifiers, captured sessions, device attestation or APK signing keys.
    var agent = ["platform": "iOS", "device_id": installID, "app_version": "1.0", "bundle_id": Bundle.main.bundleIdentifier ?? "com.tianya.tempmail"]
    agent.merge(["os": "2", "os_sdid": installID, "sn": "sn", "channel": "other", "device_brand": "Apple", "root": "false", "imei": "", "md5_imei": "d41d8cd98f00b204e9800998ecf8427e", "oaid": "", "android_id": "", "android_id_level": "0", "net": "UNKNOWN", "build": "20261108"], uniquingKeysWith: { _, new in new })
    // This catalog exposes the reference app's VIP/coin products only with os=1.
    // Scope compatibility to this read before signing; account and order requests
    // retain their iOS context and this installation's own session/identity.
    if method == "GET", path == "order/packageV2" { agent["os"] = "1" }
    #if canImport(UIKit)
    // The service rejects Apple's short numeric version in device/login. Keep
    // the real Foundation version/build description, as verified end-to-end.
    agent["os_version"] = ProcessInfo.processInfo.operatingSystemVersionString
    agent["device_model"] = UIDevice.current.model
    #else
    agent["os_version"] = ProcessInfo.processInfo.operatingSystemVersionString
    agent["device_model"] = "macOS API verification"
    #endif
    #if targetEnvironment(simulator)
    agent["emu"] = "true"
    #else
    agent["emu"] = "false"
    #endif
    agent["time"] = String(Int(Date().timeIntervalSince1970))
    if let appName = serviceConfiguration["appName"] { agent["app_name"] = appName }
    if let appID = serviceConfiguration["appID"] { agent["appid"] = appID }
    if !token.isEmpty {
      agent["token"] = token
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    let header = agent.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    request.setValue(header, forHTTPHeaderField: "Chhw-Agent")
    if let salt = serviceConfiguration["signatureSalt"], !salt.isEmpty {
      request.setValue(QQServiceSignature.sign(header: header, path: path, salt: salt), forHTTPHeaderField: "sign")
    }
    if method != "GET" {
      if json {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try body.map { try JSONEncoder().encode($0) } ?? JSONSerialization.data(withJSONObject: parameters)
      } else {
        var form = URLComponents()
        form.queryItems = parameters.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = form.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8)
      }
    }
    let data: Data
    let response: URLResponse
    do { (data, response) = try await session.data(for: request) }
    catch {
      if usesKeychain { QQNetworkDiagnostics.record(path: path, http: 0, code: (error as NSError).code, encrypted: false) }
      throw error
    }
    guard let response = response as? HTTPURLResponse else { throw QQAPIError.invalidResponse }
    if response.statusCode == 401 { throw QQAPIError.authentication }
    guard (200..<300).contains(response.statusCode) else { throw QQAPIError.httpStatus(response.statusCode) }
    guard let payload = try? JSONDecoder().decode(QQValue.self, from: data) else { throw QQAPIError.invalidResponse }
    let code = Int(payload["code"].text) ?? -1
    var diagnosticContext: [String: Any] = [:]
    if usesKeychain {
      diagnosticContext = ["installation_length": installID.count, "installation_is_hex": installID.allSatisfy { $0.isHexDigit }, "session_present": !token.isEmpty,
        "bundle_id": agent["bundle_id"] ?? "", "platform": agent["platform"] ?? "", "os": agent["os"] ?? "", "os_version": agent["os_version"] ?? "", "device_model": agent["device_model"] ?? "", "app_version": agent["app_version"] ?? ""]
    }
    defer {
      if usesKeychain { QQNetworkDiagnostics.record(path: path, http: response.statusCode, code: code, encrypted: !payload["iv"].text.isEmpty, context: diagnosticContext) }
    }
    guard code == 200 || (code == 0 && (path.hasPrefix("timetravel/") || path.hasPrefix("v1/"))) else {
      if [401, 3003, 3004].contains(code) { throw QQAPIError.authentication }
      throw QQAPIError.service(code, payload["msg"].text)
    }
    let result: QQValue
    if !payload["iv"].text.isEmpty, !payload["data"].text.isEmpty {
      guard let secret = serviceConfiguration["responseSecret"] else { throw QQAPIError.invalidResponse }
      result = try QQResponseCipher.decode(payload, installation: installID, secret: secret)
    } else { result = payload["data"] }
    if usesKeychain, method == "GET", path == "order/packageV2" {
      // Counts only, to verify live catalog delivery without storing account data,
      // product payloads, session credentials or payment links in device diagnostics.
      diagnosticContext["vip_package_count"] = result["package"].records.count
      diagnosticContext["coin_package_count"] = result["coin"].records.count
      diagnosticContext["vip_displayable_count"] = result["package"].records.filter { !$0["id"].isEmpty }.count
      diagnosticContext["coin_displayable_count"] = result["coin"].records.filter { !$0["id"].isEmpty }.count
    }
    return result
  }
}

enum QQResponseCipher {
  static func decode(_ envelope: QQValue, installation: String, secret: String) throws -> QQValue {
    guard let encrypted = Data(base64Encoded: envelope["data"].text),
      let iv = Data(base64Encoded: envelope["iv"].text), iv.count == kCCBlockSizeAES128,
      !encrypted.isEmpty, encrypted.count.isMultiple(of: kCCBlockSizeAES128) else { throw QQAPIError.invalidResponse }
    let key = Data(SHA256.hash(data: Data((envelope["seed"].text + installation + secret).utf8)))
    var output = [UInt8](repeating: 0, count: encrypted.count + kCCBlockSizeAES128)
    var written = 0
    let status = key.withUnsafeBytes { keyBytes in
      iv.withUnsafeBytes { ivBytes in
        encrypted.withUnsafeBytes { bytes in
          CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBytes.baseAddress, key.count, ivBytes.baseAddress, bytes.baseAddress, encrypted.count, &output, output.count, &written)
        }
      }
    }
    guard status == kCCSuccess else { throw QQAPIError.invalidResponse }
    return try JSONDecoder().decode(QQValue.self, from: Data(output.prefix(written)))
  }
}

@MainActor
private enum QQNetworkDiagnostics {
  static func record(path: String, http: Int, code: Int, encrypted: Bool, context: [String: Any] = [:]) {
    // Status only: no URLs with query strings, headers, request bodies, email,
    // verification codes, session tokens or decrypted response data.
    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("TempMailTest")
    let file = directory.appendingPathComponent("qingqing-network-status.json")
    var records = (try? Data(contentsOf: file)).flatMap { try? JSONSerialization.jsonObject(with: $0) as? [[String: Any]] } ?? []
    var entry: [String: Any] = ["path": String(path.prefix(100)), "http": http, "code": code, "encrypted": encrypted, "time": ISO8601DateFormatter().string(from: Date())]
    entry.merge(context, uniquingKeysWith: { _, new in new })
    records.append(entry)
    records = Array(records.suffix(20))
    guard let bytes = try? JSONSerialization.data(withJSONObject: records) else { return }
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try? bytes.write(to: file, options: [.atomic, .completeFileProtection])
  }
}

enum QQServiceSignature {
  static func sign(header: String, path: String, salt: String) -> String {
    // Protocol compatibility, not a replacement for session authentication or TLS.
    let first = Insecure.MD5.hash(data: Data((header + salt + path).utf8)).map { String(format: "%02x", $0) }.joined()
    return Insecure.MD5.hash(data: Data(first.utf8)).map { String(format: "%02x", $0) }.joined()
  }
}

private enum QQKeychain {
  static func read(_ key: String) -> String? {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: "com.tianyabox.qingqing", kSecAttrAccount as String: key,
      kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
    var result: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
      let data = result as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }
  static func write(_ value: String, key: String) {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: "com.tianyabox.qingqing", kSecAttrAccount as String: key]
    SecItemDelete(query as CFDictionary)
    guard !value.isEmpty else { return }
    var item = query
    item[kSecValueData as String] = Data(value.utf8)
    item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    SecItemAdd(item as CFDictionary, nil)
  }
}
