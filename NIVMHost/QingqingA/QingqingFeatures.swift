import SwiftUI
import SafariServices
import Photos
import CoreImage

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
  @State private var rulesPresented = false
  var body: some View {
    Group {
      if embedded { content }
      else { QQPage(title: title, color: path == "member/getInviteList" ? QQStyle.background : .white) { content }.overlay(alignment: .topTrailing) { if path == "member/getInviteList" { Button { rulesPresented = true } label: { QQArtwork(name: "invite_ico_question").frame(width: 20, height: 20).frame(width: 50, height: 50) }.accessibilityLabel("邀请规则") } } }
    }.task(id: store.loggedIn) { await load() }.sheet(isPresented: $rulesPresented) { QQInviteRulesView() }
  }
  private var content: some View {
    Group {
      if requiresLogin && !store.loggedIn {
        VStack(spacing: 16) { QQEmptyState(text: "登录后查看"); Button("立即登录") { store.loginPresented = true }; Spacer() }
      } else if loading { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity) }
      else if let error { QQEmptyState(text: error) { Task { await load() } } }
      else if records.isEmpty {
        if path == "member/getInviteList" { VStack(spacing: 10) { QQArtwork(name: "invite_pic_null").frame(width: 150, height: 150); Text("您暂时还没有邀请好友～").font(.system(size: 14)); Spacer() }.padding(.top, 166).frame(maxWidth: .infinity) }
        else { QQEmptyState() }
      }
      else {
        ScrollView { LazyVStack(spacing: 0) { ForEach(records) { record in
          if path == "ai/systemMsg" {
            NavigationLink { QQSystemMessageView(message: record) } label: { row(record) }
          } else if record["type"] == "system" {
            NavigationLink { QQAPIListView(title: "系统通知", path: "ai/systemMsg", requiresLogin: true) } label: { row(record) }
          } else if path.contains("Coin") || path.contains("feedback") {
            row(record)
          } else if record["type"] == "simulator" {
            NavigationLink { QQChatView(role: record, kind: .simulator) } label: { row(record) }
          } else {
            QQRoleChatLink(role: record.conversationRole, kind: ["group", "roleMany"].contains(record["type"]) ? .multi : .single) { row(record) }
          }
        } } }.buttonStyle(.plain).refreshable { await load() }
      }
    }
  }
  @ViewBuilder private func row(_ record: QQRecord) -> some View {
    if path == "ai/roleList" { messageRow(record) }
    else if path == "ai/systemMsg" { notificationRow(record) }
    else {
    HStack(spacing: 12) {
      if !record.image.isEmpty { QQRemoteImage(address: record.image).frame(width: 52, height: 64).clipShape(RoundedRectangle(cornerRadius: 12)) }
      VStack(alignment: .leading, spacing: 8) {
        Text(record.first("name", "title", "desc", "remark", "type_name", "content")).font(.system(size: 15, weight: .semibold))
        Text(record.first("msg", "intro", "reply", "content", "created_at")).font(.system(size: 12)).lineLimit(2).foregroundStyle(.secondary)
      }
      Spacer()
      if !record["coin"].isEmpty { Text(record["coin"]).font(.system(size: 14, weight: .medium)) }
    }.padding(.vertical, 8).padding(.horizontal, 15)
    }
  }
  private func messageRow(_ record: QQRecord) -> some View {
    HStack(alignment: .top, spacing: 13) {
      Group { if record["type"] == "system" { QQArtwork(name: "message_ico_notice") } else { QQRemoteImage(address: record.image) } }.frame(width: 68, height: 68).clipShape(RoundedRectangle(cornerRadius: 12))
      VStack(alignment: .leading, spacing: 7) {
        HStack { Text(record.name).font(.system(size: 15, weight: .bold)).lineLimit(1); Spacer(); Text(messageDate(record["time"])).font(.system(size: 12)).foregroundStyle(.gray) }.padding(.top, 5)
        Text(record["msg"]).font(.system(size: 12)).foregroundStyle(.black).lineLimit(record["type"] == "roleMany" ? 1 : 2)
        if record["type"] == "roleMany" {
          HStack(spacing: 3) { ForEach(Array(record.value["story_role"].records.prefix(5).enumerated()), id: \.offset) { _, actor in QQRemoteImage(address: actor.first("avatar", "avatarUrl")).frame(width: 18, height: 18).clipShape(Circle()) }; Text("\(record.value["story_role"].list.count)人").font(.system(size: 12)).foregroundStyle(.gray) }
        }
      }.frame(maxWidth: .infinity, alignment: .leading)
    }.padding(.horizontal, 15).padding(.vertical, 7.5).contentShape(Rectangle())
  }
  private func notificationRow(_ record: QQRecord) -> some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 12) { QQArtwork(name: "res_logo").frame(width: 54, height: 54).clipShape(RoundedRectangle(cornerRadius: 10)); VStack(alignment: .leading, spacing: 6) { HStack { Text("卿卿我我AI").font(.system(size: 15, weight: .bold)); Spacer(); Text(record["created_at"]).font(.system(size: 12)).foregroundStyle(.gray) }; Text(record["title"]).font(.system(size: 12)).foregroundStyle(.gray).lineLimit(1) } }
      if !record.image.isEmpty { QQRemoteImage(address: record.image, contentMode: .fit).aspectRatio(2, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 20)) }
      QQServiceRichText(value: record["content"]).font(.system(size: 12)).foregroundStyle(.gray)
      Divider().opacity(0.2)
    }.padding(.horizontal, 15).padding(.top, 22).padding(.bottom, 12)
  }
  private func messageDate(_ value: String) -> String {
    guard let timestamp = Double(value), timestamp > 0 else { return "" }
    let date = Date(timeIntervalSince1970: timestamp > 100_000_000_000 ? timestamp / 1000 : timestamp)
    return date.formatted(.dateTime.month(.twoDigits).day(.twoDigits))
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
    QQPage(title: "系统消息", color: .white) { ScrollView {
      VStack(alignment: .leading, spacing: 6) {
        if !(content ?? message).image.isEmpty { QQRemoteImage(address: (content ?? message).image, contentMode: .fit).aspectRatio(2, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.bottom, 4) }
        Text((content ?? message).name).font(.system(size: 14))
        QQServiceRichText(value: (content ?? message).first("content", "body", "msg", "intro")).font(.system(size: 14)).lineSpacing(7)
        Text((content ?? message)["created_at"]).font(.system(size: 12)).foregroundStyle(.gray).frame(maxWidth: .infinity, alignment: .trailing).padding(.top, 14).padding(.bottom, 30)
        if let error { Text(error).foregroundStyle(.red) }
      }.padding(20)
    } }.task {
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
  @State private var unlockPresented = false
  @State private var error: String?
  @State private var busy = false
  var body: some View {
    QQPage(title: "记忆簿") {
      ScrollView {
        VStack(spacing: 16) {
          HStack { Text("\(home["home_used_memory_count"].text)/\(home["max_size"].text)").font(.system(size: 13)); Spacer(); Button { unlockPresented = true } label: { Text("扩展记忆容量 ›").font(.system(size: 13)) } }.padding(.horizontal, 20).padding(.top, 10)
          if memories.isEmpty {
            QQArtwork(name: "memory_ico_null").frame(width: 150, height: 150).padding(.top, 130)
            Text("暂无记忆").font(.system(size: 18, weight: .bold)).padding(.top, 6)
            Text("您可以自主创建新的记忆哦～").font(.system(size: 14)).foregroundStyle(.gray)
            QQPrimaryButton(title: "创建记忆") { editing = nil; content = ""; editor = true }.frame(width: 200).padding(.top, 6)
          } else {
            ForEach(memories) { memory in
              Button { editing = memory; content = memory.first("text", "memory_content", "content"); editor = true } label: {
                VStack(alignment: .leading, spacing: 12) {
                  HStack { QQArtwork(name: "memory_ico_note").frame(width: 20, height: 17); Text(memory.first("date", "created_at")).font(.system(size: 12)).foregroundStyle(.gray); Spacer(); QQArtwork(name: "memory_ico_more").frame(width: 20, height: 20) }
                  Text(memory.first("text", "memory_content", "content")).font(.system(size: 14)).lineSpacing(5).frame(maxWidth: .infinity, alignment: .leading)
                }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 20)).padding(.horizontal, 15)
              }
            }
            QQPrimaryButton(title: "创建记忆") { editing = nil; content = ""; editor = true }.padding(.horizontal, 30)
          }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red).padding(15) }
        }.padding(.bottom, 30)
      }.background(alignment: .top) { QQArtwork(name: "memory_pic_background").frame(height: 300) }
    }.task { await load() }
      .sheet(isPresented: $unlockPresented, onDismiss: { Task { await load() } }) { NavigationStack { QQMemberView(memoryRoleID: role.id, memoryKind: .unlock) }.environmentObject(store).presentationDetents([.height(630), .large]).presentationDragIndicator(.hidden).presentationCornerRadius(20) }
      .sheet(isPresented: $editor) {
        VStack(spacing: 15) {
          ZStack {
            Text(editing == nil ? "添加记忆簿" : "编辑记忆簿").font(.system(size: 18, weight: .bold))
            HStack { Button("取消") { editor = false }.foregroundStyle(.gray); Spacer(); Button(busy ? "保存中" : "保存") { saveMemory() }.disabled(busy || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }.font(.system(size: 14))
          }.padding(.top, 13)
          TextEditor(text: $content).font(.system(size: 14)).scrollContentBackground(.hidden).padding(12).background(QQStyle.background, in: RoundedRectangle(cornerRadius: 15))
          Text("*为确保记忆效果，请选择明确姓名来编辑").font(.system(size: 12)).foregroundStyle(.gray).frame(maxWidth: .infinity, alignment: .leading)
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        }.padding(13).presentationDetents([.height(350)]).presentationCornerRadius(30)
      }
  }
  private func saveMemory() {
    busy = true; error = nil
    Task {
      defer { busy = false }
      do { _ = try await store.api.request("ai/saveMemoryContent", method: "POST", parameters: ["role_id": role.id, "memory_content": content, "id": editing?.id ?? ""]); editor = false; await load() }
      catch { self.error = error.localizedDescription }
    }
  }
  private func load() async {
    do {
      home = try await store.api.request("ai/getMemoryHome", parameters: ["role_id": role.id])
      memories = try await store.api.request("ai/getMemoryList", parameters: ["role_id": role.id]).records
    } catch { self.error = error.localizedDescription }
  }
}

struct QQMemberView: View {
  @EnvironmentObject private var store: QingqingStore
  var memoryRoleID: String? = nil
  var memoryKind: QQMemoryOfferKind = .capacity
  @State private var memoryInformation: QQValue = .null
  @State private var tab: Int
  @State private var data: QQValue = .null
  @State private var totals: QQValue = .null
  @State private var error: String?
  @State private var loading = true
  @State private var busy = false
  @State private var selected: QQRecord?
  @State private var selectedWay: QQRecord?
  @State private var payWays: [QQRecord] = []
  @State private var paying: QQRecord?
  @State private var paymentURL: URL?
  @State private var orderID: String?
  @State private var orderOutcomeUnknown = false
  @State private var statusText: String?
  @Environment(\.scenePhase) private var scenePhase
  init(memoryRoleID: String? = nil, memoryKind: QQMemoryOfferKind = .capacity, initialTab: Int = 0) {
    self.memoryRoleID = memoryRoleID
    self.memoryKind = memoryKind
    _tab = State(initialValue: initialTab)
  }
  private var coinMode: Bool { memoryRoleID == nil && tab == 1 }
  private var coinBackground: Color { Color(red: 209.0/255, green: 248.0/255, blue: 254.0/255) }
  private var purchaseGradient: LinearGradient { LinearGradient(colors: coinMode ? [Color(red: 119.0/255, green: 148.0/255, blue: 1), Color(red: 200.0/255, green: 102.0/255, blue: 1), Color(red: 231.0/255, green: 74.0/255, blue: 1)] : [Color(red: 1, green: 101.0/255, blue: 117.0/255), Color(red: 1, green: 15.0/255, blue: 190.0/255), Color(red: 1, green: 74.0/255, blue: 1)], startPoint: .leading, endPoint: .trailing) }
  var body: some View {
    QQPage(title: "", color: memoryRoleID != nil ? Color(red: 250.0/255, green: 246.0/255, blue: 1) : coinMode ? Color(red: 241.0/255, green: 253.0/255, blue: 1) : Color(red: 1, green: 0.94, blue: 0.98), backgroundArtwork: memoryRoleID == nil ? nil : memoryKind == .capacity ? "amount_pic_background" : "memory_pic_background2", artworkHeight: 600, closeOnRight: memoryRoleID != nil && memoryKind == .unlock) {
      if memoryRoleID != nil {
        ScrollView {
          QQMemoryOffersContent(offers: memoryOffers, selected: $selected, selectedWay: $selectedWay, loading: loading, canPurchase: selected != nil && selectedWay != nil && !busy && orderID == nil && !orderOutcomeUnknown) { paying = selectedWay }
          if !store.loggedIn { QQPrimaryButton(title: "登录查看套餐") { store.loginPresented = true }.padding(20) }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red).padding(20) }
          if let statusText { Text(statusText).font(.system(size: 13)).foregroundStyle(.secondary).padding(15) }
          if orderID != nil { Button("查询支付结果") { Task { await checkOrder() } }.disabled(busy).padding(15) }
        }
      } else {
      GeometryReader { geometry in
        ScrollView {
          VStack(spacing: 0) {
            if coinMode {
              QQDiamondBalance(totals: totals).padding(.horizontal, 15).padding(.top, 5)
              HStack { Text("购买钻石：").font(.system(size: 15, weight: .bold)); Spacer(); NavigationLink { QQDiamondDetailView() } label: { Text("钻石明细▸").font(.system(size: 12)).foregroundStyle(.gray).padding(.horizontal, 7).padding(.vertical, 4).background(.cyan.opacity(0.06), in: Capsule()) } }.padding(.horizontal, 15).padding(.vertical, 17)
            } else if memoryRoleID == nil { benefits.padding(.horizontal, 16).padding(.top, 5); Spacer(minLength: 20) }
            VStack(spacing: 20) {
              catalog
              if !packages.isEmpty { paymentWays }
              if !store.loggedIn { QQPrimaryButton(title: "登录查看套餐") { store.loginPresented = true } }
              else {
                Button { paying = selectedWay } label: { Text(memoryRoleID != nil ? "立即扩容" : coinMode ? "立即充值" : "立即开通").font(.system(size: 18, weight: .bold)).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 56).background(purchaseGradient, in: Capsule()) }.disabled(selected == nil || selectedWay == nil || busy || orderID != nil || orderOutcomeUnknown).opacity(selected == nil ? 0.4 : 1)
              }
              if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
              if let statusText { Text(statusText).font(.system(size: 13)).foregroundStyle(.secondary) }
              if orderID != nil { Button("查询支付结果") { Task { await checkOrder() } }.disabled(busy) }
            }.padding(coinMode ? 10 : 15).padding(.bottom, 10).background(coinMode ? coinBackground : .white, in: UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: coinMode ? 22 : 0, bottomTrailingRadius: coinMode ? 22 : 0, topTrailingRadius: 22)).padding(.horizontal, coinMode ? 15 : 0).padding(.bottom, coinMode ? 10 : 0)
          }.frame(minHeight: geometry.size.height, alignment: .top)
        }
      }
      }
    }.overlay(alignment: .top) {
      if memoryRoleID == nil {
        HStack(spacing: 24) { ForEach(0..<2) { index in Button { tab = index; selected = packages.first } label: { VStack(spacing: 7) { Text(index == 0 ? "开通VIP" : "钻石充值").font(.system(size: tab == index ? 18 : 16, weight: tab == index ? .bold : .regular)).foregroundStyle(tab == index ? QQStyle.ink : .gray); Capsule().fill(tab == index ? .cyan : .clear).frame(width: 12, height: 4) } } } }.frame(height: 50)
      }
    }.task(id: store.loggedIn) {
      let pending = UserDefaults.standard.dictionary(forKey: pendingOrderKey) as? [String: String]
      orderID = pending?["rid"]; orderOutcomeUnknown = pending != nil && orderID == nil
      if orderOutcomeUnknown { statusText = "上次订单的提交结果尚未确认，请先联系服务方核实。" }
      await load()
    }.sheet(isPresented: Binding(get: { paymentURL != nil }, set: { if !$0 { paymentURL = nil } })) { if let paymentURL { QQSafariView(url: paymentURL) } }
      .confirmationDialog("确认购买所选套餐？", isPresented: Binding(get: { paying != nil }, set: { if !$0 { paying = nil } }), titleVisibility: .visible) {
        if let paying, let selected { Button("确认支付 ¥\(selected["price"])") { Task { await createOrder(package: selected, way: paying) } } }
      }.onChange(of: scenePhase) { _, phase in if phase == .active && orderID != nil { Task { await checkOrder() } } }
  }
  private var benefits: some View {
    GeometryReader { geometry in
      let titleWidth = geometry.size.width * 0.36
      let valueWidth = geometry.size.width * 0.64 / 3
      VStack(spacing: 0) {
        HStack(spacing: 0) { Text("权益").frame(width: titleWidth); ForEach(["正式会员", "体验会员", "普通用户"], id: \.self) { Text($0).frame(width: valueWidth) } }.font(.system(size: 14, weight: .bold)).frame(height: 40)
        ForEach(Array(data["tips"].list.enumerated()), id: \.offset) { _, tip in
          HStack(spacing: 0) {
            Text(tip["title"].text).font(.system(size: 14, weight: .bold)).lineLimit(1).minimumScaleFactor(0.8).frame(width: titleWidth)
            ForEach(["lv2", "lv1", "lv0"], id: \.self) { key in
              Group { if tip[key].text == "1" { Image(systemName: "checkmark").font(.system(size: 13, weight: .bold)).foregroundStyle(Color(red: 1, green: 0.35, blue: 0.92)) } else if tip[key].text == "0" { Text("−").font(.system(size: 16, weight: .bold)).foregroundStyle(Color(white: 0.8)) } else { Text(tip[key].text).font(.system(size: 13)) } }.frame(width: valueWidth)
            }
          }.frame(height: 40)
        }
      }.background(.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 15))
        .overlay(alignment: .leading) { RoundedRectangle(cornerRadius: 12).stroke(LinearGradient(colors: [.pink.opacity(0.35), Color(red: 1, green: 0.3, blue: 0.94)], startPoint: .leading, endPoint: .trailing), lineWidth: 3).frame(width: valueWidth).offset(x: titleWidth) }
    }.frame(height: CGFloat(data["tips"].list.count + 1) * 40)
  }
  @ViewBuilder private var catalog: some View {
    if loading { ProgressView().frame(height: 120).frame(maxWidth: .infinity) }
    else if packages.isEmpty { Text("当前暂无可购买的套餐").font(.system(size: 14)).foregroundStyle(.gray).frame(height: 120).frame(maxWidth: .infinity) }
    else if coinMode {
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) { ForEach(packages) { package in packageCard(package) } }
    } else {
      ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 10) { ForEach(packages) { package in packageCard(package).frame(width: 120) } } }
    }
  }
  private func packageCard(_ package: QQRecord) -> some View {
    Button { selected = package } label: {
      VStack(spacing: 8) {
        if coinMode {
          QQRemoteImage(address: package.first("image_url", "image", "img_url"), contentMode: .fit).frame(height: 62)
          HStack(spacing: 4) { Text(package["coin"]).font(.system(size: 18, weight: .bold)); QQArtwork(name: "vip_ico_diamond").frame(width: 14, height: 14) }
          Text("¥ " + package["price"]).font(.system(size: 14, weight: .bold)).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 30).background(purchaseGradient, in: Capsule())
        } else {
          Text(package.name).font(.system(size: 14, weight: .bold)).lineLimit(1)
          Text(package.first("price_text1", "price")).font(.system(size: 24, weight: .bold))
          Text(package.first("price_text2", "desc")).font(.system(size: 12)).foregroundStyle(.gray)
          if !package["coin"].isEmpty { Text("赠送 💎 " + package["coin"]).font(.system(size: 12, weight: .bold)) }
        }
      }.padding(10).frame(maxWidth: .infinity).frame(height: coinMode ? 164 : 120).background(coinMode ? .white : Color(white: 0.96), in: RoundedRectangle(cornerRadius: coinMode ? 20 : 12)).overlay { RoundedRectangle(cornerRadius: coinMode ? 20 : 12).stroke(selected?.id == package.id ? purchaseGradient : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing), lineWidth: selected?.id == package.id ? 2 : 0) }
    }.buttonStyle(.plain)
  }
  private var paymentWays: some View {
    VStack(spacing: 14) { ForEach(payWays) { way in
      Button { selectedWay = way } label: { HStack(spacing: 10) { Image(systemName: way["code"].contains("wechat") ? "message.fill" : "a.circle.fill").font(.system(size: 26)).foregroundStyle(way["code"].contains("wechat") ? .green : .cyan); Text(way.name.components(separatedBy: "（").first ?? way.name).font(.system(size: 16)); Text(way["desc"]).font(.system(size: 14)).foregroundStyle(.gray); Spacer(minLength: 0); Image(systemName: selectedWay?.id == way.id ? "checkmark.circle.fill" : "circle").foregroundStyle(selectedWay?.id == way.id ? .cyan : Color(white: 0.85)) }.frame(height: 32) }.buttonStyle(.plain)
    } }
  }
  private var memoryOffers: QQMemoryOffers { QQMemoryOffers(kind: memoryKind, payload: data, information: memoryInformation) }
  private var packages: [QQRecord] {
    let records: [QQRecord]
    if memoryRoleID != nil { records = memoryOffers.owned ? [] : memoryOffers.packages }
    else { records = data[coinMode ? "coin" : "package"].records }
    return records.filter { !$0.id.isEmpty }
  }
  private func load() async {
    defer { loading = false }
    guard store.loggedIn else { return }
    error = nil
    do {
      if store.user == nil { await store.refreshUser() }
      guard let user = store.user, !user.id.isEmpty else { throw QQAPIError.authentication }
      if let memoryRoleID {
        if memoryKind == .capacity {
          async let catalog = store.api.request("ai/msgListPackage")
          async let information = store.api.request("ai/getMsgListInfo", parameters: ["role_id": memoryRoleID])
          (data, memoryInformation) = try await (catalog, information)
        } else {
          data = try await store.api.request("ai/getMemoryPackage", parameters: ["role_id": memoryRoleID])
        }
        payWays = memoryOffers.payWays
        selectedWay = memoryOffers.initialWay
      } else {
        data = try await store.api.request("order/packageV2")
        totals = try await store.api.request("member/getCoinTotal")
        payWays = try await store.api.request("order/payWay").records
        selectedWay = payWays.first
      }
      selected = packages.first
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

struct QQInviteRulesView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @State private var info: QQValue = .null
  @State private var error: String?
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 0) {
          QQArtwork(name: "invite_pic_banner").frame(height: 200)
          VStack(spacing: 18) {
            ForEach(Array(info["invite_note"].text.components(separatedBy: "<br>").filter { !$0.isEmpty }.enumerated()), id: \.offset) { _, rule in
              HStack(alignment: .top, spacing: 5) { Image(systemName: "star.fill").foregroundStyle(Color(red: 1, green: 0.78, blue: 0.2)); Text(rule).font(.system(size: 13)).lineSpacing(7).frame(maxWidth: .infinity, alignment: .leading) }
            }
            if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
            NavigationLink { QQInviteView() } label: { Text("立即邀请").font(.system(size: 14, weight: .bold)).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 50).background(LinearGradient(colors: [Color(red: 0.5, green: 0.55, blue: 1), Color(red: 0.95, green: 0.2, blue: 1)], startPoint: .leading, endPoint: .trailing), in: Capsule()) }
            Button("下次再说") { dismiss() }.font(.system(size: 14)).foregroundStyle(.gray).frame(height: 30)
          }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 22)).padding(.horizontal, 10).padding(.bottom, 11).padding(.top, -53)
        }.background(LinearGradient(colors: [Color(red: 0.56, green: 0.32, blue: 0.93), Color(red: 0.81, green: 0.37, blue: 1), Color(red: 0.97, green: 0.89, blue: 1)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 22)).padding(.horizontal, 30).padding(.vertical, 20)
      }.background(.clear).toolbar(.hidden, for: .navigationBar)
        .task { do { info = try await store.api.request("member/getInvite") } catch { self.error = error.localizedDescription } }
    }
  }
}

struct QQInviteView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var info: QQValue = .null
  @State private var result: String?
  @State private var busy = false
  var body: some View {
    QQPage(title: "分享", color: Color(red: 1, green: 0.91, blue: 0.97)) {
      GeometryReader { geometry in
        ScrollView {
          poster.frame(width: geometry.size.width - 30).padding(.top, 11)
          Button { savePoster(width: geometry.size.width - 30) } label: { HStack(spacing: 4) { QQArtwork(name: "post_ico_download").frame(width: 15, height: 18); Text(busy ? "保存中" : "保存图片") }.font(.system(size: 14)).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 56).background(LinearGradient(colors: [Color(red: 0.5, green: 0.55, blue: 1), Color(red: 0.95, green: 0.2, blue: 1)], startPoint: .leading, endPoint: .trailing), in: Capsule()) }.disabled(busy || info["code"].text.isEmpty).padding(.horizontal, 15).padding(.top, 34)
          if let result { Text(result).font(.system(size: 13)).padding(15) }
        }.frame(maxWidth: .infinity)
      }
    }.task { do { info = try await store.api.request("member/getInvite") } catch { result = error.localizedDescription } }
  }
  private var poster: some View {
    QQArtwork(name: "post_pic_role").aspectRatio(contentMode: .fit).overlay(alignment: .bottom) {
      VStack(alignment: .leading, spacing: 5) {
        Button { UIPasteboard.general.string = info["code"].text; result = "邀请码已复制" } label: { HStack(spacing: 3) { Text("邀请码："); Text(info["code"].text).bold(); QQArtwork(name: "yq_fx_ico_copy").frame(width: 15, height: 15) }.font(.system(size: 15)) }
        HStack(spacing: 5) { Text("输入邀请码奖励：").foregroundStyle(.gray); QQArtwork(name: "register_ico_diamond").frame(width: 15, height: 16); Text(info["bind_reward"].text.replacingOccurrences(of: "钻石", with: "") + "钻石").foregroundStyle(.pink) }.font(.system(size: 14))
        Rectangle().fill(.clear).frame(height: 2).overlay { Rectangle().stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 2])) }.padding(.vertical, 5)
        HStack(spacing: 8) {
          QQArtwork(name: "res_logo").frame(width: 50, height: 50)
          Text("扫描二维码\n即可开启与他的专属故事").font(.system(size: 12)).lineSpacing(3)
          Spacer(minLength: 0)
          if let qr = qrImage { Image(uiImage: qr).interpolation(.none).resizable().frame(width: 76, height: 76).padding(1).overlay { RoundedRectangle(cornerRadius: 6).stroke(QQStyle.gradient, lineWidth: 1) } }
        }
      }.padding(.horizontal, 15).padding(.vertical, 20).background(.white, in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 20)).padding(4)
    }
  }
  private var qrImage: UIImage? {
    let address = info["appshare_url"].text
    guard !address.isEmpty, let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(Data(address.utf8), forKey: "inputMessage")
    guard let output = filter.outputImage, let image = CIContext().createCGImage(output.transformed(by: CGAffineTransform(scaleX: 8, y: 8)), from: output.extent.applying(CGAffineTransform(scaleX: 8, y: 8))) else { return nil }
    return UIImage(cgImage: image)
  }
  private func savePoster(width: CGFloat) {
    guard !busy else { return }; busy = true; result = nil
    Task { @MainActor in
      defer { busy = false }
      let renderer = ImageRenderer(content: poster.frame(width: width)); renderer.scale = 3
      guard let image = renderer.uiImage else { result = "图片生成失败，请稍后重试"; return }
      let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
      guard status == .authorized || status == .limited else { result = "请在系统设置中允许保存图片"; return }
      do { try await PHPhotoLibrary.shared().performChanges { PHAssetChangeRequest.creationRequestForAsset(from: image) }; result = "已保存到相册" }
      catch { result = "保存失败，请稍后重试" }
    }
  }
}
