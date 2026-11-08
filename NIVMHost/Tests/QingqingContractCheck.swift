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
    let catalogContexts = [("order/packageV2", "GET", "1"), ("home/getRecommend", "GET", "2"), ("order/payWay", "GET", "2"),
      ("member/info", "GET", "2"), ("device/login", "POST", "2"), ("order/create", "POST", "2"),
      ("order/packageV2", "POST", "2")]
    for (path, method, expectedOS) in catalogContexts {
      FixtureProtocol.handler = { request in
        precondition(request.url?.path == "/" + path && request.httpMethod == method)
        let header = request.value(forHTTPHeaderField: "Chhw-Agent") ?? ""
        let fields = Dictionary(uniqueKeysWithValues: header.components(separatedBy: "&").map { item in
          let parts = item.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
          return (String(parts[0]), parts.count > 1 ? String(parts[1]) : "")
        })
        precondition(fields["os"] == expectedOS && fields["platform"] == "iOS" && fields["android_id"] == "")
        precondition(request.value(forHTTPHeaderField: "sign") == QQServiceSignature.sign(header: header, path: path, salt: "test-only"))
        return Data(#"{"code":200,"data":{}}"#.utf8)
      }
      _ = try await api.request(path, method: method)
    }
    print("PASS only GET member catalog uses os=1 with matching signatures; recommendation/account/payment/write requests retain os=2")
    FixtureProtocol.handler = { request in
      precondition(request.url?.path == "/home/searchRole2" && request.httpMethod == "POST")
      var body = request.httpBody ?? Data()
      if let stream = request.httpBodyStream {
        stream.open(); defer { stream.close() }
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable { let count = stream.read(&buffer, maxLength: buffer.count); if count <= 0 { break }; body.append(contentsOf: buffer.prefix(count)) }
      }
      let form = String(data: body, encoding: .utf8) ?? ""
      var components = URLComponents(); components.percentEncodedQuery = form
      let fields = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
      precondition(fields == ["keyword": "角色 A+B", "page": "2", "pageSize": "18"])
      return Data(#"{"code":200,"data":[{"id":"agent-42","name":"fixture"}]}"#.utf8)
    }
    let agents = try await api.searchAgents(keyword: "角色 A+B", page: 2)
    precondition(agents.first?.id == "agent-42")
    print("PASS agent picker searchRole2 form contract and original 18-item pagination")
    var deviceLoginCalls = 0
    FixtureProtocol.handler = { request in
      precondition(request.url?.path == "/device/login")
      deviceLoginCalls += 1
      return Data(#"{"code":200,"data":{"token":"synthetic-guest-session"}}"#.utf8)
    }
    async let bootstrapOne: Void = api.ensureDeviceSession()
    async let bootstrapTwo: Void = api.ensureDeviceSession()
    async let bootstrapThree: Void = api.ensureDeviceSession()
    _ = try await (bootstrapOne, bootstrapTwo, bootstrapThree)
    precondition(deviceLoginCalls == 1 && api.isLoggedIn)
    try await api.ensureDeviceSession()
    precondition(deviceLoginCalls == 1)
    print("PASS concurrent guest bootstrap shares one request and preserves the issued session")

    let retryAPI = QingqingAPI(session: session, baseURL: URL(string: "https://fixture.invalid/")!, serviceConfiguration: [:], useKeychain: false)
    FixtureProtocol.handler = { _ in Data(#"{"code":500,"msg":"fixture failure","data":null}"#.utf8) }
    do { try await retryAPI.ensureDeviceSession(); preconditionFailure("Failed bootstrap accepted") }
    catch QQAPIError.service(500, _) {}
    precondition(!retryAPI.isLoggedIn)
    FixtureProtocol.handler = { _ in Data(#"{"code":200,"data":{"token":"synthetic-recovered-session"}}"#.utf8) }
    try await retryAPI.ensureDeviceSession()
    precondition(retryAPI.isLoggedIn)
    print("PASS failed guest bootstrap clears its task and allows an explicit later retry")

    let capacityPayload = try JSONDecoder().decode(QQValue.self, from: Data(#"[{"package_id":71,"title":"same title","price":"fixture"},{"package_id":"72","title":"same title","price":"fixture"},{"title":"no order id"}]"#.utf8))
    let memoryInfo = try JSONDecoder().decode(QQValue.self, from: Data(#"{"global_status":0,"role_status":0,"pay_types":[{"code":"first"},{"code":"checked","checked":true},{"name":"missing code"}]}"#.utf8))
    let capacity = QQMemoryOffers(kind: .capacity, payload: capacityPayload, information: memoryInfo)
    precondition(capacity.packages.map(\.id) == ["71", "72"] && !capacity.owned)
    precondition(capacity.initialWay?.id == "checked" && capacity.payWays.count == 2)
    let unlocked = QQMemoryOffers(kind: .capacity, payload: capacityPayload, information: .object(["role_status": .number(1)]))
    precondition(unlocked.owned)
    let globalUnlocked = QQMemoryOffers(kind: .capacity, payload: capacityPayload, information: .object(["global_status": .number(1)]))
    precondition(globalUnlocked.owned)
    let unlockPayload = try JSONDecoder().decode(QQValue.self, from: Data(#"{"plans":[{"package_id":"unlock-9","title":"fixture","is_all":1}],"pay_types":[{"code":"unlock-way","checked":1}]}"#.utf8))
    let unlock = QQMemoryOffers(kind: .unlock, payload: unlockPayload, information: memoryInfo)
    precondition(unlock.packages.first?.id == "unlock-9" && unlock.initialWay?.id == "unlock-way")
    precondition(QQMemoryOffers(kind: .unlock, payload: .null, information: .null).packages.isEmpty)
    print("PASS memory capacity/unlock schemas, real package IDs, checked payment method and owned-state gates")
    precondition(!QQIdentityInput(name: "", gender: "男").canSubmit)
    precondition(!QQIdentityInput(name: " \n ", gender: "女").canSubmit)
    precondition(!QQIdentityInput(name: "fixture", gender: "").canSubmit)
    precondition(!QQIdentityInput(name: "fixture", gender: "invalid").canSubmit)
    let identityInput = QQIdentityInput(name: " \nfixture \n", gender: "其他")
    precondition(identityInput.canSubmit && identityInput.trimmedName == "fixture")
    print("PASS identity requires an explicit gender and a trimmed nonempty name")

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

    let identities = ["self", "advisor", "guard"].map { QQRecord(.object(["id": .string($0), "playable": .bool($0 == "self")])) }
    let agentA = QQRecord(.object(["id": .string("42")]))
    let agentB = QQRecord(.object(["id": .string("84")]))
    let cast = QQSimulatorCast(playerRoleID: "self", agentsByRole: ["guard": agentB, "advisor": agentA])
    let parameters = try cast.parameters(scenarioID: "7", roles: identities)
    precondition(parameters == ["scenario_id": "7", "select_role_id": "advisor|42,guard|84", "player_role_id": "self"])
    print("PASS simulator identity-to-agent request contract")
    for invalid in [QQSimulatorCast(playerRoleID: "", agentsByRole: ["advisor": agentA]), QQSimulatorCast(playerRoleID: "self", agentsByRole: [:]), QQSimulatorCast(playerRoleID: "self", agentsByRole: ["advisor": agentA, "guard": agentA]), QQSimulatorCast(playerRoleID: "self", agentsByRole: ["self": agentA]), QQSimulatorCast(playerRoleID: "guard", agentsByRole: ["advisor": agentA])] {
      do { _ = try invalid.parameters(scenarioID: "7", roles: identities); preconditionFailure("Invalid simulator cast was accepted") } catch QQAPIError.service {}
    }
    print("PASS simulator participation, playable-only self assignment and unique actor guards")
    precondition(QQTheaterSelection.index(selection: 0, slot: 0, count: 0) == nil)
    for count in 1...5 { for selection in -3...7 { for slot in 0..<5 { let index = QQTheaterSelection.index(selection: selection, slot: slot, count: count)!; precondition((0..<count).contains(index)) } } }
    print("PASS theater circular selection with empty, small and changed catalogs")
    precondition(QQChatDraft.recovering("first", alongside: "") == "first")
    precondition(QQChatDraft.recovering("first", alongside: "new") == "first\nnew")
    precondition(QQChatDraft.recovering("first", alongside: "first") == "first")
    precondition(QQChatDraft.recovering("", alongside: "new") == "new")
    print("PASS failed chat draft recovery preserves text typed during the request")
    let bracket = QQChatDraft.insertingParentheses(in: "你好🙂世界", selection: NSRange(location: 2, length: 2))
    precondition(bracket.0 == "你好（）世界" && bracket.1 == NSRange(location: 3, length: 0))
    precondition(QQChatDraft.insertingParentheses(in: "🙂", selection: NSRange(location: 1, length: 0)).0 == "🙂（）")
    print("PASS bracket insertion replaces the selection and keeps a Unicode-safe cursor inside")
    let offer = QQRecord(.object(["id": .string("qa-offer"), "price": .string("10")]))
    let otherWay = QQRecord(.object(["code": .string("qa-other")]))
    let checkedWay = QQRecord(.object(["code": .string("qa-checked"), "checked": .bool(true)]))
    precondition(QQMemberCatalog.initialWay([otherWay, checkedWay])?.id == checkedWay.id)
    precondition(QQMemberCatalog.valid(package: offer, way: checkedWay, packages: [offer], ways: [checkedWay]))
    precondition(!QQMemberCatalog.valid(package: QQRecord(.object(["name": .string("qa-offer"), "price": .string("10")])), way: checkedWay, packages: [offer], ways: [checkedWay]))
    precondition(!QQMemberCatalog.valid(package: offer, way: otherWay, packages: [offer], ways: [checkedWay]))
    precondition(["999", "1000", "4000", "20000"].map { QQMemberCatalog.diamondArtwork(coin: $0) } == ["purchase_ico_diamond02", "purchase_ico_diamond03", "purchase_ico_diamond04", "purchase_ico_diamond05"])
    print("PASS member catalog requires real IDs/prices/available payment codes and honors checked/default diamond tiers")
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
