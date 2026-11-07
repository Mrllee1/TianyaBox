// Run with QingqingModels.swift and QingqingAPI.swift using swiftc -parse-as-library.
// Fixtures are synthetic. This executable never sends a live email, chat or order.
import Foundation

private final class FixtureProtocol: URLProtocol {
  static var handler: ((URLRequest) throws -> Data)?
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    do {
      let data = try Self.handler!(request)
      client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch { client?.urlProtocol(self, didFailWithError: error) }
  }
  override func stopLoading() {}
}

@main
struct QingqingContractCheck {
  @MainActor static func main() async throws {
    precondition(QQServiceSignature.sign(header: "app_name=chhw&platform=iOS&time=1", path: "ai/getRoleConfig", salt: "test-only") == "d74e7abcb8c9e00853a1c8b8b2f6826b")
    print("PASS request signature protocol vector")

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [FixtureProtocol.self]
    let session = URLSession(configuration: config)
    let api = QingqingAPI(session: session, baseURL: URL(string: "https://fixture.invalid/")!, serviceConfiguration: ["signatureSalt": "test-only", "appName": "fixture", "appID": "1"], useKeychain: false)
    FixtureProtocol.handler = { request in
      precondition(request.url?.path == "/home/getRole")
      let header = request.value(forHTTPHeaderField: "Chhw-Agent") ?? ""
      let fields = Dictionary(uniqueKeysWithValues: header.components(separatedBy: "&").map { field in
        let parts = field.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        return (String(parts[0]), parts.count > 1 ? String(parts[1]) : "")
      })
      precondition(fields["platform"] == "iOS")
      precondition(fields["device_id"]?.count == 32)
      precondition(fields["android_id"] == "")
      precondition(request.value(forHTTPHeaderField: "sign")?.count == 32)
      return Data(#"{"code":200,"data":[{"id":42,"name":"fixture"}]}"#.utf8)
    }
    let list = try await api.request("home/getRole", parameters: ["page": "1"])
    precondition(list.records.first?.id == "42")
    print("PASS fresh installation identity and mixed identifier decoding")

    FixtureProtocol.handler = { _ in Data(#"{"code":3003,"msg":"login required","data":null}"#.utf8) }
    do { _ = try await api.request("member/info"); preconditionFailure("Login gate was ignored") }
    catch QQAPIError.authentication {}
    print("PASS authentication response gate")

    FixtureProtocol.handler = { _ in Data(#"{"data":[]}"#.utf8) }
    do { _ = try await api.request("home/getRole"); preconditionFailure("Malformed response accepted") }
    catch QQAPIError.service(-1, _) {}
    print("PASS malformed business response rejection")

    // Independent OpenSSL AES-256-CBC vector, with SHA-256 derived key.
    let encryptedEnvelope = QQValue.object(["data": .string("xxQrSYaxLc2mEZ3byGycAQ=="), "iv": .string("AAECAwQFBgcICQoLDA0ODw=="), "seed": .string("seed")])
    let decoded = try QQResponseCipher.decode(encryptedEnvelope, installation: "0123456789abcdef0123456789abcdef", secret: "test-only")
    precondition(decoded["value"].text == "ok")
    print("PASS encrypted success response OpenSSL vector")

    let badEnvelope = QQValue.object(["data": .string("AAAA"), "iv": .string("AAAA"), "seed": .string("seed")])
    do { _ = try QQResponseCipher.decode(badEnvelope, installation: "fixture", secret: "test-only"); preconditionFailure("Invalid encrypted response accepted") }
    catch QQAPIError.invalidResponse {}
    print("PASS malformed encryption envelope rejection")
    session.invalidateAndCancel()
  }
}
