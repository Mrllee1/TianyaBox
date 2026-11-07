import SwiftUI
import SafariServices

struct QQAPIListView: View {
  @EnvironmentObject private var store: QingqingStore
  let title: String
  let path: String
  var parameters: [String: String] = [:]
  var requiresLogin = false
  var embedded = false
  @State private var records: [QQRecord] = []
  @State private var loading = true
  @State private var error: String?
  var body: some View {
    Group {
      if requiresLogin && !store.loggedIn {
        VStack(spacing: 16) { QQEmptyState(text: "登录后查看"); Button("立即登录") { store.loginPresented = true }; Spacer() }
      } else if loading { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity) }
      else if let error { QQEmptyState(text: error) { Task { await load() } } }
      else if records.isEmpty { QQEmptyState() }
      else {
        List(records) { record in
          if path == "ai/systemMsg" {
            NavigationLink { QQSystemMessageView(message: record) } label: { row(record) }
          } else if path.contains("Coin") || path.contains("feedback") {
            row(record)
          } else if record["type"] == "simulator" {
            NavigationLink { QQChatView(role: record, kind: .simulator) } label: { row(record) }
          } else {
            NavigationLink(value: record) { row(record) }
          }
        }.listStyle(.plain).refreshable { await load() }
      }
    }.navigationTitle(title).navigationBarTitleDisplayMode(.inline)
      .task(id: store.loggedIn) { await load() }
  }
  private func row(_ record: QQRecord) -> some View {
    HStack(spacing: 12) {
      if !record.image.isEmpty { QQRemoteImage(address: record.image).frame(width: 52, height: 64).clipShape(RoundedRectangle(cornerRadius: 12)) }
      VStack(alignment: .leading, spacing: 8) {
        Text(record.first("name", "title", "desc", "remark", "type_name", "content")).font(.system(size: 15, weight: .semibold))
        Text(record.first("msg", "intro", "reply", "content", "created_at")).font(.system(size: 12)).lineLimit(2).foregroundStyle(.secondary)
      }
      Spacer()
      if !record["coin"].isEmpty { Text(record["coin"]).font(.system(size: 14, weight: .medium)) }
    }.padding(.vertical, 8)
  }
  private func load() async {
    guard !requiresLogin || store.loggedIn else { loading = false; return }
    loading = true; error = nil
    defer { loading = false }
    do { records = try await store.api.request(path, parameters: parameters).records }
    catch { self.error = error.localizedDescription }
  }
}

private struct QQSystemMessageView: View {
  @EnvironmentObject private var store: QingqingStore
  let message: QQRecord
  @State private var content: QQRecord?
  @State private var error: String?
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text((content ?? message).name).font(.system(size: 22, weight: .bold))
        Text((content ?? message).first("content", "body", "msg", "intro")).font(.system(size: 15)).lineSpacing(7)
        if let error { Text(error).foregroundStyle(.red) }
      }.padding(20)
    }.navigationTitle("消息详情").navigationBarTitleDisplayMode(.inline).task {
      do { content = QQRecord(try await store.api.request("ai/systemMsgDetail", parameters: ["id": message.id])) }
      catch { self.error = error.localizedDescription }
    }
  }
}

struct QQMemoryView: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  @State private var home: QQValue = .null
  @State private var memories: [QQRecord] = []
  @State private var editing: QQRecord?
  @State private var content = ""
  @State private var editor = false
  @State private var error: String?
  @State private var busy = false
  var body: some View {
    List {
      Section {
        HStack { Text("\(role.name)的记忆"); Spacer(); Text("\(home["home_used_memory_count"].text)/\(home["max_size"].text)").foregroundStyle(.secondary) }
        NavigationLink("扩展记忆容量") { QQMemberView(memoryRoleID: role.id) }
      }
      Section("记忆簿") {
        ForEach(memories) { memory in
          Button {
            editing = memory; content = memory.first("text", "memory_content", "content"); editor = true
          } label: { VStack(alignment: .leading, spacing: 8) { Text(memory.first("text", "memory_content", "content")).font(.system(size: 14)); Text(memory.first("date", "created_at")).font(.system(size: 11)).foregroundStyle(.secondary) }.padding(.vertical, 8) }
        }
        Button("＋ 新增记忆") { editing = nil; content = ""; editor = true }
      }
      if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
    }.navigationTitle("记忆簿").navigationBarTitleDisplayMode(.inline)
      .task { await load() }
      .sheet(isPresented: $editor) {
        NavigationStack {
          VStack(spacing: 20) {
            TextEditor(text: $content).padding(12).background(QQStyle.background, in: RoundedRectangle(cornerRadius: 16))
            if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
            QQPrimaryButton(title: "保存记忆", busy: busy) {
              busy = true; error = nil
              Task {
                defer { busy = false }
                do { _ = try await store.api.request("ai/saveMemoryContent", method: "POST", parameters: ["role_id": role.id, "memory_content": content, "id": editing?.id ?? ""]); editor = false; await load() }
                catch { self.error = error.localizedDescription }
              }
            }.disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
          }.padding(20).navigationTitle("编辑记忆").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("取消") { editor = false } } }
        }
      }
  }
  private func load() async {
    do {
      home = try await store.api.request("ai/getMemoryHome", parameters: ["role_id": role.id])
      memories = try await store.api.request("ai/getMemoryList", parameters: ["role_id": role.id]).records
    } catch { self.error = error.localizedDescription }
  }
}

struct QQGiftView: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  @State private var gifts: [QQRecord] = []
  @State private var selected: QQRecord?
  @State private var error: String?
  @State private var busy = false
  var body: some View {
    ScrollView {
      VStack(spacing: 18) {
        NavigationLink { QQIntimacyView(role: role) } label: { Label("查看与\(role.name)的亲密度", systemImage: "heart.fill").padding(16).frame(maxWidth: .infinity).background(.pink.opacity(0.08), in: RoundedRectangle(cornerRadius: 16)) }
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
          ForEach(gifts) { gift in
            Button { selected = gift } label: {
              VStack(spacing: 10) {
                QQRemoteImage(address: gift.first("image", "img_url", "image_url")).frame(height: 80)
                Text(gift.name).font(.system(size: 14))
                Text(gift.first("coin", "price") + " 钻石").font(.system(size: 12)).foregroundStyle(.secondary)
              }.padding(12).background(.white, in: RoundedRectangle(cornerRadius: 16))
            }.disabled(busy)
          }
        }
        if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
      }.padding(20)
    }.background(QQStyle.background).navigationTitle("送礼物").navigationBarTitleDisplayMode(.inline)
      .task { do { gifts = try await store.api.request("role/getGift").records } catch { self.error = error.localizedDescription } }
      .confirmationDialog("赠送礼物将消耗钻石", isPresented: Binding(get: { selected != nil }, set: { if !$0 { selected = nil } }), titleVisibility: .visible) {
        if let selected {
          Button("赠送\(selected.name)（\(selected.first("coin", "price"))钻石）") {
            busy = true
            Task {
              defer { busy = false; self.selected = nil }
              do { _ = try await store.api.request("role/sendGift", method: "POST", parameters: ["gift_id": selected.id, "role_id": role.id]); await store.refreshUser() }
              catch { self.error = error.localizedDescription }
            }
          }
        }
      }
  }
}

struct QQIntimacyView: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  @State private var info: QQValue = .null
  @State private var error: String?
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        QQRemoteImage(address: role.image).frame(width: 100, height: 100).clipShape(Circle())
        Text(role.name).font(.system(size: 24, weight: .bold))
        Image(systemName: "heart.fill").font(.system(size: 48)).foregroundStyle(.pink.opacity(0.7))
        Text(info["text_top"]["title"].text).font(.system(size: 22, weight: .bold))
        Text(info["text_top"]["intro"].text).font(.system(size: 14))
        Text("亲密度 " + info["intimacy"].text).font(.system(size: 17, weight: .semibold))
        ForEach(Array(info["middle_text"].list.enumerated()), id: \.offset) { _, value in Text(value.text).font(.system(size: 14)) }
        Text(info["next_stage_intro"].text).font(.system(size: 13)).foregroundStyle(.secondary)
        Text(info["bottom_text"].text).font(.system(size: 13)).foregroundStyle(.secondary)
        if let error { Text(error).foregroundStyle(.red) }
      }.padding(28).frame(maxWidth: .infinity)
    }.background(.pink.opacity(0.035)).navigationTitle("亲密度").navigationBarTitleDisplayMode(.inline)
      .task { do { info = try await store.api.request("role/getMemberRole", parameters: ["role_id": role.id]) } catch { self.error = error.localizedDescription } }
  }
}

struct QQMemberView: View {
  @EnvironmentObject private var store: QingqingStore
  var memoryRoleID: String? = nil
  @State private var data: QQValue = .null
  @State private var error: String?
  @State private var busy = false
  @State private var selected: QQRecord?
  @State private var payWays: [QQRecord] = []
  @State private var paying: QQRecord?
  @State private var paymentURL: URL?
  @State private var orderID: String?
  @State private var orderOutcomeUnknown = false
  @State private var statusText: String?
  @Environment(\.scenePhase) private var scenePhase
  var body: some View {
    ScrollView {
      VStack(spacing: 22) {
        Image(systemName: memoryRoleID == nil ? "crown.fill" : "book.fill").font(.system(size: 44)).foregroundStyle(Color(red: 0.68, green: 0.50, blue: 0.27))
        Text(memoryRoleID == nil ? "卿卿会员" : "记忆扩容").font(.system(size: 30, weight: .bold))
        Text("更多陪伴，更多心动").font(.system(size: 14)).foregroundStyle(.secondary)
        if !store.loggedIn { QQPrimaryButton(title: "登录查看专属权益") { store.loginPresented = true } }
        ForEach(packages) { package in
          Button { selected = package } label: {
            HStack {
              VStack(alignment: .leading, spacing: 9) { Text(package.name).font(.system(size: 18, weight: .semibold)); Text(package.first("desc", "info", "day")).font(.system(size: 13)).foregroundStyle(.secondary) }
              Spacer()
              Text(package["price"].isEmpty ? "" : "¥" + package["price"]).font(.system(size: 23, weight: .bold))
              if selected?.id == package.id { Image(systemName: "checkmark.circle.fill") }
            }.padding(20).background(selected?.id == package.id ? Color.orange.opacity(0.10) : .white, in: RoundedRectangle(cornerRadius: 18))
              .overlay { RoundedRectangle(cornerRadius: 18).stroke(selected?.id == package.id ? .orange.opacity(0.55) : .black.opacity(0.06)) }
          }
        }
        if let selected {
          ForEach(payWays) { way in
            QQPrimaryButton(title: "\(way.name)支付 ¥\(selected["price"])", busy: busy) { paying = way }
          }
        }
        if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        if let statusText { Text(statusText).font(.system(size: 14)).foregroundStyle(.secondary) }
        if orderID != nil { Button("查询支付结果") { Task { await checkOrder() } }.disabled(busy) }
      }.padding(24)
    }.background(LinearGradient(colors: [Color(red: 0.99, green: 0.94, blue: 0.84), .white], startPoint: .top, endPoint: .bottom))
      .navigationTitle(memoryRoleID == nil ? "会员中心" : "记忆套餐").navigationBarTitleDisplayMode(.inline)
      .task(id: store.loggedIn) {
        let pending = UserDefaults.standard.dictionary(forKey: pendingOrderKey) as? [String: String]
        orderID = pending?["rid"]
        orderOutcomeUnknown = pending != nil && orderID == nil
        if orderOutcomeUnknown { statusText = "上次订单的提交结果尚未确认，请先联系服务方核实。" }
        await load()
      }
      .sheet(isPresented: Binding(get: { paymentURL != nil }, set: { if !$0 { paymentURL = nil } })) {
        if let paymentURL { QQSafariView(url: paymentURL) }
      }
      .confirmationDialog("确认购买所选套餐？", isPresented: Binding(get: { paying != nil }, set: { if !$0 { paying = nil } }), titleVisibility: .visible) {
        if let paying, let selected { Button("确认支付 ¥\(selected["price"])") { Task { await createOrder(package: selected, way: paying) } } }
      }
      .onChange(of: scenePhase) { _, phase in if phase == .active && orderID != nil { Task { await checkOrder() } } }
  }
  private var packages: [QQRecord] {
    if !data.records.isEmpty { return data.records }
    let keys = memoryRoleID == nil ? ["packageList", "coin", "member", "vip", "member_list", "member_package", "memberPackage", "coinPackage", "list"] : ["package", "list", "role", "global"]
    return keys.flatMap { data[$0].records }.filter { !$0.id.isEmpty }
  }
  private func load() async {
    guard store.loggedIn else { return }
    error = nil
    do {
      if store.user == nil { await store.refreshUser() }
      guard let user = store.user, !user.id.isEmpty else { throw QQAPIError.authentication }
      data = try await store.api.request(memoryRoleID == nil ? "order/packageV2" : "ai/getMemoryPackage", parameters: memoryRoleID.map { ["role_id": $0] } ?? [:])
      payWays = try await store.api.request("order/payWay").records
      if packages.isEmpty { error = "当前暂无可购买的套餐" }
    } catch { self.error = error.localizedDescription }
  }
  private func createOrder(package: QQRecord, way: QQRecord) async {
    guard orderID == nil, !orderOutcomeUnknown, !busy else { statusText = "已有待确认订单，请先查询或联系服务方核实"; return }
    busy = true; error = nil
    orderOutcomeUnknown = true
    UserDefaults.standard.set(["intent": UUID().uuidString, "package_id": package.id, "price": package["price"], "created_at": ISO8601DateFormatter().string(from: Date())], forKey: pendingOrderKey)
    defer { busy = false; paying = nil }
    do {
      let result = try await store.api.request("order/create", method: "POST", parameters: ["package_id": package.id, "pay_code": way["code"], "obj_id": memoryRoleID ?? ""], json: true)
      let rid = result["rid"].text
      guard !rid.isEmpty else { throw QQAPIError.invalidResponse }
      orderID = rid
      orderOutcomeUnknown = false
      UserDefaults.standard.set(["rid": rid], forKey: pendingOrderKey)
      // Never retry order creation automatically: a timeout may still have created an order.
      let pay = try await store.api.request("third/pay", method: "POST", parameters: ["rid": rid, "pay_code": way["code"]], json: true)
      guard let url = URL(string: pay["payUrl"].text), url.scheme == "https" else { throw QQAPIError.invalidURL }
      paymentURL = url
    } catch { self.error = error.localizedDescription }
  }
  private func checkOrder() async {
    guard let orderID, !busy else { return }
    busy = true
    defer { busy = false }
    do {
      let result = try await store.api.request("order/status", parameters: ["rid": orderID])
      statusText = result["status"].text == "2" ? "支付成功" : "订单尚未确认支付，请稍后再查询"
      if result["status"].text == "2" {
        UserDefaults.standard.removeObject(forKey: pendingOrderKey)
        self.orderID = nil; orderOutcomeUnknown = false
        await store.refreshUser()
      }
    } catch { self.error = error.localizedDescription }
  }
  private var pendingOrderKey: String { "qingqing.pendingOrder." + (store.user?.id ?? "signed-out") }
}

struct QQSafariView: UIViewControllerRepresentable {
  let url: URL
  func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
  func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

struct QQInviteView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var info: QQValue = .null
  @State private var code = ""
  @State private var error: String?
  var body: some View {
    Form {
      Section("我的邀请") {
        LabeledContent("邀请码", value: info["invite_code"].text)
        Text(info["invite_note"].text).font(.system(size: 13))
        if !info["appshare_url"].text.isEmpty { ShareLink("邀请好友", item: info["appshare_url"].text) }
        else if !info["invite_code"].text.isEmpty { ShareLink("分享邀请码", item: info["invite_code"].text) }
      }
      Section("填写邀请码") {
        TextField("好友的邀请码", text: $code).textInputAutocapitalization(.never)
        Button("绑定邀请码") {
          store.requireLogin {
            Task { do { _ = try await store.api.request("member/bindInvite", method: "POST", parameters: ["invite_code": code]); code = "" } catch { self.error = error.localizedDescription } }
          }
        }.disabled(code.isEmpty)
      }
      NavigationLink("已邀请的好友") { QQAPIListView(title: "邀请记录", path: "member/getInviteList", requiresLogin: true) }
      if let error { Text(error).foregroundStyle(.red) }
    }.navigationTitle("邀请有奖").navigationBarTitleDisplayMode(.inline)
      .task { do { info = try await store.api.request("member/getInvite") } catch { self.error = error.localizedDescription } }
  }
}

struct QQSettingsView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var logout = false
  var body: some View {
    List {
      Section("账号") {
        if !store.loggedIn { Button("登录账号") { store.loginPresented = true } }
        else { LabeledContent("当前账号", value: store.user?.first("email", "nick", "id") ?? "") }
        if store.loggedIn { Button(store.hasBoundAccount ? "切换邮箱账号" : "绑定邮箱") { store.loginPresented = true } }
      }
      Section {
        NavigationLink("意见反馈") { QQFeedbackView() }
        LabeledContent("应用名称", value: "TianyaBox")
        LabeledContent("版本", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
      }
      if store.loggedIn { Button("退出登录", role: .destructive) { logout = true } }
    }.navigationTitle("设置").navigationBarTitleDisplayMode(.inline)
      .confirmationDialog("确认退出当前账号？", isPresented: $logout) { Button("退出登录", role: .destructive) { Task { await store.logout() } } }
  }
}

private struct QQFeedbackView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var text = ""
  @State private var contact = ""
  @State private var busy = false
  @State private var result: String?
  var body: some View {
    Form {
      Section("反馈内容") { TextEditor(text: $text).frame(height: 180) }
      Section("联系方式（选填）") { TextField("邮箱或手机号", text: $contact).textInputAutocapitalization(.never) }
      Button(busy ? "提交中…" : "提交反馈") {
        busy = true
        Task { defer { busy = false }; do { _ = try await store.api.request("feedback/create", method: "POST", parameters: ["content": text, "mobile": contact], json: true); text = ""; result = "感谢你的反馈" } catch { result = error.localizedDescription } }
      }.disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || busy)
      if let result { Text(result).font(.system(size: 13)) }
    }.navigationTitle("意见反馈").navigationBarTitleDisplayMode(.inline)
  }
}
