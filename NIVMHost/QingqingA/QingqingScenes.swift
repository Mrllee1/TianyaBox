import SwiftUI
import WebKit
import CryptoKit
import UniformTypeIdentifiers
#if canImport(ZIPFoundation)
import ZIPFoundation
#endif

struct QQSimulatorDetailView: View {
  @EnvironmentObject private var store: QingqingStore
  let scenario: QQRecord
  @State private var detail: QQValue = .null
  @State private var selectedRole = ""
  @State private var playerRole = ""
  @State private var game: QQRecord?
  @State private var busy = false
  @State private var error: String?
  private var roles: [QQRecord] { (detail.isNull ? scenario.value : detail)["roles"].records }
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        QQRemoteImage(address: scenario.image).frame(height: 280).clipShape(RoundedRectangle(cornerRadius: 20))
        Text(scenario.name).font(.system(size: 26, weight: .bold))
        QQTags(tags: scenario.tags)
        Text(scenario.intro).font(.system(size: 14)).lineSpacing(6)
        Text("选择与你互动的角色").font(.system(size: 17, weight: .semibold))
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 12) {
            ForEach(roles) { role in
              Button { selectedRole = role.id } label: {
                VStack(spacing: 8) {
                  QQRemoteImage(address: role.first("avatar", "image", "img_url", "roleImage")).frame(width: 95, height: 128).clipShape(RoundedRectangle(cornerRadius: 12))
                  Text(role.name).font(.system(size: 13)).lineLimit(1)
                }.padding(6).background(selectedRole == role.id ? Color.purple.opacity(0.13) : .clear, in: RoundedRectangle(cornerRadius: 14))
              }
            }
          }
        }
        Text("我的身份").font(.system(size: 17, weight: .semibold))
        Picker("我的身份", selection: $playerRole) {
          Text("请选择身份").tag("")
          ForEach(roles) { role in Text(role.name).tag(role.id) }
        }.pickerStyle(.menu)
        if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        QQPrimaryButton(title: "开始故事", busy: busy) {
          store.requireLogin {
            guard !selectedRole.isEmpty, !playerRole.isEmpty else { error = "请选择互动角色和你的身份"; return }
            busy = true
            Task {
              defer { busy = false }
              do {
                let result = try await store.api.request("simulator/create", method: "POST", parameters: ["scenario_id": scenario.id, "select_role_id": selectedRole, "player_role_id": playerRole])
                guard !result["id"].text.isEmpty else { throw QQAPIError.invalidResponse }
                game = QQRecord(.object(["game_id": result["id"], "name": .string(scenario.name), "img_url": .string(scenario.image)]))
              } catch { self.error = error.localizedDescription }
            }
          }
        }
      }.padding(20)
    }.navigationTitle("模拟器").navigationBarTitleDisplayMode(.inline)
      .navigationDestination(item: $game) { QQChatView(role: $0, kind: .simulator) }
      .task {
        do { detail = try await store.api.request("simulator/detail", parameters: ["id": scenario.id]) }
        catch { self.error = error.localizedDescription }
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
    Group {
      if let folder {
        QQTheaterWebView(folder: folder, scriptID: script.id, api: store.api,
          onLogin: { store.loginPresented = true }, onPay: { member = true })
      } else {
        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            QQRemoteImage(address: script.image).frame(height: 360).clipShape(RoundedRectangle(cornerRadius: 22))
            Text(script.name).font(.system(size: 26, weight: .bold))
            QQTags(tags: script.tags)
            Text(script.intro).font(.system(size: 15)).lineSpacing(7)
            if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
            QQPrimaryButton(title: loading ? "正在加载剧情…" : "进入剧情", busy: loading) {
              store.requireLogin {
                loading = true; error = nil
                Task {
                  defer { loading = false }
                  do { folder = try await QQTheaterPackage.prepare(script) }
                  catch { self.error = error.localizedDescription }
                }
              }
            }
          }.padding(20)
        }
      }
    }.navigationTitle(script.name).navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $member) { NavigationStack { QQMemberView() }.environmentObject(store) }
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
