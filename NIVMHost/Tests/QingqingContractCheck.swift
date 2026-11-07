// Run with QingqingModels.swift and QingqingAPI.swift using swiftc -parse-as-library.
// Fixtures are synthetic. This executable never sends a live email, chat or order.
import Foundation

private final class FixtureProtocol: URLProtocol {
  static var handler: ((URLRequest) throws -> Data)?
  static var status = 200
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    do {
      let data = try Self.handler!(request)
      client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: Self.status, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
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
    FixtureProtocol.status = 503
    do { _ = try await api.request("role/sendGift", method: "POST", parameters: ["gift_id":"fixture", "role_id":"fixture"]); preconditionFailure("HTTP failure accepted as a business response") }
    catch QQAPIError.httpStatus(503) {}
    FixtureProtocol.status = 200
    print("PASS HTTP failure remains distinct from confirmed business rejection")

    // Independent OpenSSL AES-256-CBC vector, with SHA-256 derived key.
    let encryptedEnvelope = QQValue.object(["data": .string("xxQrSYaxLc2mEZ3byGycAQ=="), "iv": .string("AAECAwQFBgcICQoLDA0ODw=="), "seed": .string("seed")])
    let decoded = try QQResponseCipher.decode(encryptedEnvelope, installation: "0123456789abcdef0123456789abcdef", secret: "test-only")
    precondition(decoded["value"].text == "ok")
    print("PASS encrypted success response OpenSSL vector")

    let badEnvelope = QQValue.object(["data": .string("AAAA"), "iv": .string("AAAA"), "seed": .string("seed")])
    do { _ = try QQResponseCipher.decode(badEnvelope, installation: "fixture", secret: "test-only"); preconditionFailure("Invalid encrypted response accepted") }
    catch QQAPIError.invalidResponse {}
    print("PASS malformed encryption envelope rejection")

    let identities = ["self", "advisor", "guard"].map { QQRecord(.object(["id": .string($0)])) }
    let agentA = QQRecord(.object(["id": .string("42")]))
    let agentB = QQRecord(.object(["id": .string("84")]))
    let cast = QQSimulatorCast(playerRoleID: "self", agentsByRole: ["guard": agentB, "advisor": agentA])
    let parameters = try cast.parameters(scenarioID: "7", roles: identities)
    precondition(parameters == ["scenario_id": "7", "select_role_id": "advisor|42,guard|84", "player_role_id": "self"])
    print("PASS simulator identity-to-agent request contract")
    for invalid in [QQSimulatorCast(playerRoleID: "", agentsByRole: ["advisor": agentA]), QQSimulatorCast(playerRoleID: "self", agentsByRole: [:]), QQSimulatorCast(playerRoleID: "self", agentsByRole: ["advisor": agentA, "guard": agentA]), QQSimulatorCast(playerRoleID: "self", agentsByRole: ["self": agentA])] {
      do { _ = try invalid.parameters(scenarioID: "7", roles: identities); preconditionFailure("Invalid simulator cast was accepted") } catch QQAPIError.service {}
    }
    print("PASS simulator participation, unique actor and self-assignment guards")
    let initial = QQIntimacyProgress(value: 0, configuration: .null)
    precondition(initial.level == 1 && initial.stage == 1 && initial.need == 10 && initial.percent == 0)
    let boundary = QQIntimacyProgress(value: 10, configuration: .null)
    precondition(boundary.level == 2 && boundary.need == 15 && boundary.percent == 40)
    let configured = QQValue.object(["level": .object(["lv1": .number(3), "lv2": .number(10), "lv3": .number(99)]), "stage": .object(["lv1": .string("初识"), "lv2": .string("熟悉"), "lv3": .string("靠近")])])
    let overridden = QQIntimacyProgress(value: 3, configuration: configured)
    precondition(overridden.level == 2 && overridden.stage == 2 && overridden.need == 7)
    precondition(QQIntimacyProgress(value: 1000000, configuration: configured).percent == 100)
    print("PASS original intimacy defaults, threshold boundaries and service configuration")
    let multi = try JSONDecoder().decode(QQValue.self, from: Data(#"{"id":"m1","msg":"fixture question","replyList":[{"role_id":"42","display_name":"actor A","content":"reply A"},{"role_id":"84","display_name":"actor B","content":"reply B"}]}"#.utf8))
    let conversation = QQConversationMessages.history(.array([multi]))
    precondition(conversation.count == 3 && conversation[0].isUser && conversation[1].text == "reply A" && conversation[2].senderRoleID == "84")
    let reply = QQConversationMessages.replies(multi)
    precondition(reply.count == 2 && reply[1].sender == "actor B" && reply[1].text == "reply B")
    let simulatorHistory = try JSONDecoder().decode(QQValue.self, from: Data(#"[{"mId":"s1","type":"player","text":"player text"},{"mId":"s2","type":"npc","roleId":"guard","roleName":"Guard","text":"npc text","imgUrl":"https://fixture.invalid/a.png"}]"#.utf8))
    let decodedHistory = QQConversationMessages.history(simulatorHistory)
    precondition(decodedHistory.count == 2 && decodedHistory[0].isUser && !decodedHistory[1].isUser && decodedHistory[1].avatar.hasSuffix("a.png"))
    print("PASS multi-role content replies and simulator player/text history schemas")
    let rank = QQRecord(.object(["id": .string("rank-entry"), "role_id": .string("42"), "role_name": .string("actor"), "role_img": .string("https://fixture.invalid/actor.png")]))
    precondition(rank.name == "actor" && rank.image.hasSuffix("actor.png") && rank.conversationRole.id == "42")
    print("PASS ranking role identity, title and artwork mapping")
    session.invalidateAndCancel()
  }
}
