import SwiftUI
import WebKit
import CryptoKit
import UniformTypeIdentifiers
#if canImport(ZIPFoundation)
import ZIPFoundation
#endif

struct QQSimulatorDetailView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  let scenario: QQRecord
  @State private var detail: QQValue = .null
  @State private var playerRole = ""
  @State private var agents: [String: QQRecord] = [:]
  @State private var game: QQRecord?
  @State private var busy = false
  @State private var error: String?
  @State private var castPresented = false
  @State private var galleryPresented = false
  @State private var galleryIndex = 0
  @State private var backdrop = Color(white: 0.25)
  @State private var outcomeUnknown = false
  private var current: QQRecord { detail.isNull ? scenario : QQRecord(detail) }
  private var roles: [QQRecord] { current.value["roles"].records }
  private var pendingKey: String { "qingqing.simulator.pending." + (store.user?.id ?? "anonymous") + "." + scenario.id }
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          Color.clear.frame(height: 321)
          Text(current.name).font(.system(size: 16, weight: .bold)).frame(height: 23)
          Text(current.tags.map { "#" + $0 }.joined(separator: " ")).font(.system(size: 12)).foregroundStyle(.white.opacity(0.6)).lineLimit(1).padding(.top, 14)
          HStack { metric(current["fansNum"], icon: "person.fill", color: .mint); Spacer(); metric(current["chatNum"], icon: "bubble.left.fill", color: .blue); Spacer(); metric(current["msgNum"], icon: "flame.fill", color: .pink) }.padding(.horizontal, 48).padding(.top, 14)
          Divider().overlay(.white.opacity(0.12)).padding(.horizontal, 20).padding(.top, 14)
          VStack(alignment: .leading, spacing: 8) { Text("简介").font(.system(size: 14)); Text(current.intro).font(.system(size: 12)).foregroundStyle(.white.opacity(0.6)).lineLimit(1) }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 14)
          HStack(spacing: 6) { Text("身份玩法").font(.system(size: 14)); Text("可邀请喜欢的角色扮演").font(.system(size: 12)).foregroundStyle(.white.opacity(0.6)); Spacer() }.padding(.horizontal, 20).padding(.top, 24)
          ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 12) { ForEach(Array(roles.enumerated()), id: \.element.id) { index, role in Button { galleryIndex = index; galleryPresented = true } label: { HStack(spacing: 16) { QQRemoteImage(address: role["avatar"]).frame(width: 100, height: 136).clipShape(RoundedRectangle(cornerRadius: 15)); VStack(alignment: .leading, spacing: 12) { Text(role.name).font(.system(size: 16, weight: .bold)); Text(role["description"]).font(.system(size: 13)).foregroundStyle(.white.opacity(0.6)).lineLimit(3) } }.padding(16).frame(width: 350, height: 160).background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 18)) } } }.padding(.horizontal, 30) }.padding(.top, 14).padding(.bottom, 8)
        }.foregroundStyle(.white).background { VStack(spacing: 0) { Color.clear.frame(height: 260); LinearGradient(colors: [.clear, backdrop], startPoint: .top, endPoint: .bottom).frame(height: 300); backdrop } }
        VStack(spacing: 16) {
          sceneSection("简介", text: current.intro)
          sceneSection("背景剧情", text: current["storyBackground"])
          sceneSection(current["openingLabel"].isEmpty ? "开场剧情" : current["openingLabel"], text: current["openingScene"])
          ForEach(roles) { role in sceneSection(role.name, text: role.first("detailedIntro", "description")) }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red); if outcomeUnknown { Button("查询已有房间") { Task { await load() } } } }
        }.padding(16).padding(.top, 10).frame(maxWidth: .infinity, alignment: .leading).background(.white, in: UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30))
      }
    }.background(alignment: .top) { QQRemoteImage(address: current.image).frame(height: 700).ignoresSafeArea(edges: .top) }.background(backdrop).overlay(alignment: .topLeading) { Button { dismiss() } label: { QQArtwork(name: "character_ico_close").frame(width: 20, height: 20).frame(width: 50, height: 50) }.accessibilityLabel("关闭") }
      .safeAreaInset(edge: .bottom) { HStack(spacing: 10) { if !current["gameId"].isEmpty { Button("创建新房间") { castPresented = true }.font(.system(size: 16, weight: .bold)).foregroundStyle(.cyan).frame(maxWidth: .infinity).frame(height: 56).background(.cyan.opacity(0.1), in: Capsule()); QQPrimaryButton(title: "继续玩") { continueGame(current["gameId"]) } } else { QQPrimaryButton(title: "开始游戏") { store.requireLogin { castPresented = true } } } }.padding(.horizontal, 20).padding(.vertical, 10).background(.white) }
      .toolbar(.hidden, for: .navigationBar).buttonStyle(.plain).navigationDestination(item: $game) { QQChatView(role: $0, kind: .simulator) }
      .sheet(isPresented: $castPresented) { QQSimulatorCastView(title: current.name, scenarioID: scenario.id, roles: roles, playerRoleID: $playerRole, agents: $agents, busy: busy || outcomeUnknown, submissionError: error) { createRoom() }.presentationDetents([.large]).presentationCornerRadius(30) }
      .sheet(isPresented: $galleryPresented) { QQRoleGalleryView(roles: roles, initialIndex: galleryIndex) }
      .task { await load() }
      .task(id: current.image) { if let palette = await QQImagePalette.backdrop(current.image), !Task.isCancelled { backdrop = palette.0 } }
  }
  private func metric(_ value: String, icon: String, color: Color) -> some View { HStack(spacing: 4) { Image(systemName: icon).foregroundStyle(color); Text(value) }.font(.system(size: 12, weight: .bold)) }
  private func sceneSection(_ title: String, text: String) -> some View { VStack(alignment: .leading, spacing: 10) { Text(title).font(.system(size: 18, weight: .bold)); Text(text).font(.system(size: 14)).foregroundStyle(.gray).lineSpacing(8).frame(maxWidth: .infinity, alignment: .leading) }.padding(16).background(Color(red: 241.0/255, green: 248.0/255, blue: 1), in: RoundedRectangle(cornerRadius: 16)) }
  private func load() async {
    do {
      detail = try await store.api.request("simulator/detail", parameters: ["id": scenario.id])
      if playerRole.isEmpty { playerRole = roles.first(where: { $0["playable"] == "1" })?.id ?? "" }
      outcomeUnknown = UserDefaults.standard.bool(forKey: pendingKey)
      if outcomeUnknown && !current["gameId"].isEmpty { outcomeUnknown = false; UserDefaults.standard.removeObject(forKey: pendingKey) }
      if outcomeUnknown { error = "上次创建结果尚未确认，请先查询已有房间，避免重复创建。" }
    } catch { self.error = error.localizedDescription }
  }
  private func continueGame(_ id: String) { store.requireLogin { game = QQRecord(.object(["game_id": .string(id), "name": .string(current.name), "img_url": .string(current.image)])) } }
  private func createRoom() {
    guard !busy, !outcomeUnknown else { return }
    let parameters: [String: String]
    do { parameters = try QQSimulatorCast(playerRoleID: playerRole, agentsByRole: agents).parameters(scenarioID: scenario.id, roles: roles) }
    catch { self.error = error.localizedDescription; return }
    busy = true; error = nil; outcomeUnknown = true; UserDefaults.standard.set(true, forKey: pendingKey)
    Task {
      defer { busy = false }
      do {
        let result = try await store.api.request("simulator/create", method: "POST", parameters: parameters)
        guard !result["id"].text.isEmpty else { throw QQAPIError.invalidResponse }
        outcomeUnknown = false; UserDefaults.standard.removeObject(forKey: pendingKey); castPresented = false
        await store.refreshUser(); continueGame(result["id"].text)
      } catch {
        if case QQAPIError.service(let code, _) = error, code > 0 { outcomeUnknown = false; UserDefaults.standard.removeObject(forKey: pendingKey) }
        self.error = error.localizedDescription
      }
    }
  }
}

struct QQTheaterView: View {
  @EnvironmentObject private var store: QingqingStore
  let script: QQRecord
  @State private var folder: URL?
  @State private var loading = false
  @State private var error: String?
  @State private var member = false
  var body: some View {
    QQPage(title: script.name) {
      Group {
        if let folder { QQTheaterWebView(folder: folder, scriptID: script.id, api: store.api, onLogin: { store.loginPresented = true }, onPay: { member = true }) }
        else if let error { QQEmptyState(text: error) { Task { await prepare() } } }
        else { ProgressView("正在加载剧情…").font(.system(size: 14)).frame(maxWidth: .infinity, maxHeight: .infinity) }
      }
    }.task(id: store.loggedIn) { if store.loggedIn { await prepare() } else { store.loginPresented = true } }
      .sheet(isPresented: $member) { NavigationStack { QQMemberView() }.environmentObject(store) }
  }
  private func prepare() async {
    guard !loading, folder == nil else { return }; loading = true; error = nil
    defer { loading = false }
    do { folder = try await QQTheaterPackage.prepare(script) } catch { self.error = error.localizedDescription }
  }
}

private enum QQTheaterPackage {
  static func prepare(_ script: QQRecord) async throws -> URL {
    let expected = script["h5_package_hash"].lowercased()
    guard expected.count == 64, expected.allSatisfy({ $0.isHexDigit }) else { throw QQAPIError.invalidResponse }
    let root = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("QingqingTheater", isDirectory: true)
    let destination = root.appendingPathComponent(expected, isDirectory: true)
    if FileManager.default.fileExists(atPath: destination.appendingPathComponent("index.html").path) { return destination }
    var lastError: Error = QQAPIError.invalidURL
    for key in ["h5_package_url_list_1", "h5_package_url_list_2"] {
      guard let url = URL(string: script[key]), url.scheme == "https", url.host != nil else { continue }
      do {
        var request = URLRequest(url: url); request.timeoutInterval = 35
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200, data.count < 30_000_000 else { throw QQAPIError.invalidResponse }
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        guard digest == expected else { throw QQAPIError.service(-1, "剧情资源校验失败，请稍后重试") }
        #if canImport(ZIPFoundation)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let temporary = root.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temporary) }
        let archive = try Archive(data: data, accessMode: .read)
        var total: UInt64 = 0; var count = 0
        for entry in archive {
          count += 1; total += UInt64(entry.uncompressedSize)
          guard count < 5000, total < 100_000_000, entry.type != .symlink,
            !entry.path.hasPrefix("/"), !entry.path.components(separatedBy: "/").contains("..") else { throw QQAPIError.invalidResponse }
          if entry.path.hasPrefix("__MACOSX/") { continue }
          let target = temporary.appendingPathComponent(entry.path)
          try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
          _ = try archive.extract(entry, to: target)
        }
        guard FileManager.default.fileExists(atPath: temporary.appendingPathComponent("index.html").path) else { throw QQAPIError.invalidResponse }
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: temporary, to: destination)
        return destination
        #else
        throw QQAPIError.service(-1, "当前预览环境不支持剧情资源加载")
        #endif
      } catch { lastError = error }
    }
    throw lastError
  }
}

/// A restricted adapter for the published theater package. Authentication stays
/// native; the package receives API results, never a copied or persisted token.
private struct QQTheaterWebView: UIViewRepresentable {
  let folder: URL
  let scriptID: String
  let api: QingqingAPI
  let onLogin: () -> Void
  let onPay: () -> Void
  func makeCoordinator() -> Coordinator { Coordinator(self) }
  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .nonPersistent()
    configuration.setURLSchemeHandler(context.coordinator, forURLScheme: "qingqing-content")
    configuration.userContentController.add(context.coordinator, name: "qingqing")
    let config: [String: String] = ["apiBase": api.baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")), "scriptId": scriptID]
    let json = String(data: try! JSONSerialization.data(withJSONObject: config), encoding: .utf8)!
    let bridge = """
    window.APP_CONFIG = \(json);
    window.ttAndroid={call:function(method,params,id){window.webkit.messageHandlers.qingqing.postMessage({type:'native',method:method,params:params,id:id})}};
    const originalFetch=window.fetch.bind(window);const pending={};let sequence=0;
    window.__qqResolve=function(id,result){if(pending[id]){pending[id](new Response(JSON.stringify(result),{status:200,headers:{'Content-Type':'application/json'}}));delete pending[id]}};
    window.fetch=function(input,options){const url=typeof input==='string'?input:input.url;const resolved=new URL(url,window.location.href);
      if(resolved.origin===new URL(window.APP_CONFIG.apiBase).origin){return new Promise(function(resolve){const id=String(++sequence);pending[id]=resolve;const timeout=setTimeout(function(){if(pending[id]){delete pending[id];resolve(new Response(JSON.stringify({code:-1,msg:'请求超时',data:null}),{status:200}))}},40000);const originalResolve=pending[id];pending[id]=function(v){clearTimeout(timeout);originalResolve(v)};window.webkit.messageHandlers.qingqing.postMessage({type:'api',id:id,url:resolved.href,method:(options||{}).method||'GET',body:String((options||{}).body||''),form:(options||{}).body instanceof URLSearchParams})})}
      return originalFetch(input,options)};
    """
    configuration.userContentController.addUserScript(WKUserScript(source: bridge, injectionTime: .atDocumentStart, forMainFrameOnly: true))
    let view = WKWebView(frame: .zero, configuration: configuration)
    view.navigationDelegate = context.coordinator
    context.coordinator.webView = view
    view.load(URLRequest(url: URL(string: "qingqing-content://local/index.html")!))
    return view
  }
  func updateUIView(_ view: WKWebView, context: Context) {}
  static func dismantleUIView(_ view: WKWebView, coordinator: Coordinator) { view.stopLoading(); view.configuration.userContentController.removeScriptMessageHandler(forName: "qingqing") }

  final class Coordinator: NSObject, WKURLSchemeHandler, WKScriptMessageHandler, WKNavigationDelegate {
    let owner: QQTheaterWebView
    weak var webView: WKWebView?
    init(_ owner: QQTheaterWebView) { self.owner = owner }
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
      guard let url = urlSchemeTask.request.url else { return }
      let file = owner.folder.appendingPathComponent(url.path).standardizedFileURL
      guard file.path.hasPrefix(owner.folder.path + "/"), let raw = try? Data(contentsOf: file) else { urlSchemeTask.didFailWithError(QQAPIError.invalidURL); return }
      var data = raw
      if file.lastPathComponent == "constant.min.js", let text = String(data: raw, encoding: .utf8),
         let regex = try? NSRegularExpression(pattern: "DEFAULT_HEADERS:\\{[^}]*\\}") {
        // Some upstream packages contain development fallback sessions. They must
        // never reach the renderer or be used for requests by this installation.
        data = Data(regex.stringByReplacingMatches(in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "DEFAULT_HEADERS:{}").utf8)
      }
      let type = file.pathExtension == "js" ? "application/javascript" : UTType(filenameExtension: file.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
      urlSchemeTask.didReceive(URLResponse(url: url, mimeType: type, expectedContentLength: data.count, textEncodingName: "utf-8"))
      urlSchemeTask.didReceive(data); urlSchemeTask.didFinish()
    }
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      decisionHandler(action.request.url?.scheme == "qingqing-content" ? .allow : .cancel)
    }
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
      guard message.frameInfo.isMainFrame, message.frameInfo.request.url?.scheme == "qingqing-content",
        let body = message.body as? [String: Any], let id = body["id"] as? String else { return }
      if body["type"] as? String == "native" {
        switch body["method"] as? String {
        case "loginRequired": owner.onLogin()
        case "paymentRequired": owner.onPay()
        default: break
        }
        let result = body["method"] as? String == "getConfig" ? ["baseUrl": owner.api.baseURL.absoluteString, "scriptId": owner.scriptID] : [:]
        resolveNative(id: id, result: result)
        return
      }
      guard let address = body["url"] as? String, let url = URL(string: address),
        url.scheme == "https", url.host == owner.api.baseURL.host,
        url.path.hasPrefix("/timetravel/") || url.path.hasPrefix("/v1/") else { return }
      var parameters = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value ?? "" } ?? [:]
      let content = body["body"] as? String ?? ""
      var jsonBody: QQValue?
      if body["form"] as? Bool == true {
        let form = URLComponents(string: "https://local/?" + content)
        for entry in form?.queryItems ?? [] { parameters[entry.name] = entry.value ?? "" }
      } else if let bytes = content.data(using: .utf8), !bytes.isEmpty { jsonBody = try? JSONDecoder().decode(QQValue.self, from: bytes) }
      Task { @MainActor in
        let result: QQValue
        do {
          let data = try await owner.api.request(String(url.path.dropFirst()), method: body["method"] as? String ?? "GET", parameters: parameters, json: jsonBody != nil, body: jsonBody)
          result = .object(["code": .number(200), "data": data, "msg": .string("success")])
        } catch {
          let code: Int
          if case QQAPIError.service(let value, _) = error { code = value }
          else if case QQAPIError.authentication = error { code = 3003 }
          else { code = -1 }
          result = .object(["code": .number(Double(code)), "msg": .string(error.localizedDescription), "data": .null])
        }
        guard let payload = try? JSONEncoder().encode(result), let text = String(data: payload, encoding: .utf8) else { return }
        webView?.evaluateJavaScript("window.__qqResolve(\(quoted(id)),\(text));", completionHandler: nil)
      }
    }
    private func quoted(_ value: String) -> String { String(data: try! JSONEncoder().encode(value), encoding: .utf8)! }
    private func resolveNative(id: String, result: [String: String]) {
      guard let data = try? JSONSerialization.data(withJSONObject: result), let text = String(data: data, encoding: .utf8) else { return }
      webView?.evaluateJavaScript("window.TTBridge._resolve(\(quoted(id)),\(quoted(text)));", completionHandler: nil)
    }
  }
}
