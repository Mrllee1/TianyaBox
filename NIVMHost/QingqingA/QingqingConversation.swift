import SwiftUI

struct QQRoleDetailView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  let role: QQRecord
  var kind: QQConversationKind = .single
  @State private var detail: QQRecord?
  @State private var talking = false
  @State private var followed = false
  @State private var error: String?
  private var current: QQRecord { detail ?? role }
  var body: some View {
    Group { if kind == .multi { QQGroupDetailView(role: role) } else { singleBody } }
  }
  private var singleBody: some View {
    ScrollView {
      VStack(spacing: 0) {
        HStack(alignment: .top, spacing: 16) {
          QQRemoteImage(address: current.image).frame(width: 160, height: 220).clipShape(RoundedRectangle(cornerRadius: 18)).rotationEffect(.degrees(-3))
          VStack(alignment: .leading, spacing: 12) {
            Text(current.name).font(.system(size: 22, weight: .bold)).lineLimit(2)
            Text(current.tags.map { "#" + $0 }.joined(separator: " ")).font(.system(size: 12)).lineLimit(2)
            Text(current.intro).font(.system(size: 12)).foregroundStyle(.white.opacity(0.6)).lineSpacing(3).lineLimit(4)
            HStack(spacing: 12) { statistic(current["fans_num"], icon: "person.fill", color: .mint); statistic(current["chat_num"], icon: "bubble.left.fill", color: .cyan); statistic(current["msg_num"], icon: "flame.fill", color: .orange) }
            Divider().overlay(.white.opacity(0.15))
            if !current["uid"].isEmpty { NavigationLink { QQAuthorCenterView(authorID: current["uid"]) } label: { QQAuthorBadge(role: current) } }
          }.padding(.trailing, 20)
        }.foregroundStyle(.white).padding(.top, 66).padding(.bottom, 30).frame(height: 316, alignment: .top).background { QQRemoteImage(address: current.image).overlay(.black.opacity(0.9)) }
        VStack(spacing: 12) {
          descriptionCard("简介", text: current.intro)
          if !current["open_remark"].isEmpty { descriptionCard("开场白", text: current["open_remark"]) }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
          Spacer(minLength: 30)
        }.padding(.horizontal, 16).padding(.top, 36).frame(maxWidth: .infinity).frame(minHeight: 430, alignment: .top).background(.white, in: UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22))
      }
    }.background(.black).overlay(alignment: .top) {
      HStack { Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 21, weight: .bold)).frame(width: 60, height: 40) }.accessibilityLabel("关闭"); Spacer(); Button { store.requireLogin { Task { await follow() } } } label: { Image(systemName: followed ? "star.fill" : "star").font(.system(size: 23, weight: .bold)).frame(width: 60, height: 40) }.accessibilityLabel(followed ? "取消关注" : "关注") }.foregroundStyle(.white)
    }.safeAreaInset(edge: .bottom) { QQPrimaryButton(title: "和TA聊天", icon: "character_ico_chat") { store.requireLogin { talking = true } }.padding(.horizontal, 20).padding(.vertical, 10).background(.white) }
      .toolbar(.hidden, for: .navigationBar).buttonStyle(.plain)
      .navigationDestination(isPresented: $talking) { QQChatView(role: current, kind: kind) }
      .task {
        do { let record = QQRecord(try await store.api.request(kind == .multi ? "home/getGroupRoleDetail" : "home/getRoleDetail", method: "POST", parameters: ["id": role.id])); detail = record; followed = record["follow"] == "1" }
        catch { self.error = error.localizedDescription }
      }
  }
  private func descriptionCard(_ title: String, text: String) -> some View { VStack(alignment: .leading, spacing: 10) { Text(title).font(.system(size: 18, weight: .bold)).background(alignment: .leading) { LinearGradient(colors: [.cyan.opacity(0.15), .clear], startPoint: .leading, endPoint: .trailing).frame(width: 40, height: 26) }; Text(text).font(.system(size: 14)).foregroundStyle(Color(red: 119.0/255, green: 125.0/255, blue: 126.0/255)).lineSpacing(8).frame(maxWidth: .infinity, alignment: .leading) }.padding(16).background(Color(red: 241.0/255, green: 248.0/255, blue: 1), in: RoundedRectangle(cornerRadius: 16)) }
  private func statistic(_ value: String, icon: String, color: Color) -> some View { HStack(spacing: 3) { Image(systemName: icon).foregroundStyle(color); Text(value) }.font(.system(size: 12, weight: .bold)) }
  private func follow() async { do { _ = try await store.api.request("member/roleFollow", method: "POST", parameters: ["role_id": role.id, "status": followed ? "0" : "1"]); followed.toggle() } catch { self.error = error.localizedDescription } }
}

struct QQAuthorBadge: View {
  let role: QQRecord
  var body: some View { HStack(spacing: 4) { QQRemoteImage(address: role["head_img"]).frame(width: 18, height: 18).clipShape(Circle()); Text(role["author"]).font(.system(size: 12)); Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)) }.padding(4).background(.white.opacity(0.25), in: Capsule()) }
}

struct QQAuthorCenterView: View {
  @EnvironmentObject private var store: QingqingStore
  let authorID: String
  @State private var data: QQValue = .null
  @State private var error: String?
  var body: some View {
    QQPage(title: "", color: .white) {
      ScrollView {
        HStack(spacing: 12) {
          QQRemoteImage(address: data["user"]["head_img"].text).frame(width: 90, height: 90).clipShape(Circle())
          VStack(alignment: .leading, spacing: 20) { Text(data["user"]["nick"].text).font(.system(size: 20, weight: .bold)); Text("ID:" + data["user"]["id"].text).font(.system(size: 16, weight: .bold)).foregroundStyle(.gray) }; Spacer()
        }.padding(.horizontal, 16).padding(.top, 15).padding(.bottom, 20)
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) { ForEach(data["list"].records) { role in QQRoleChatLink(role: role) { QQRoleTile(role: role) } } }.padding(.horizontal, 10)
        if let error { QQEmptyState(text: error) } else if data["list"].records.isEmpty && !data.isNull { QQEmptyState() }
      }
    }.task { do { data = try await store.api.request("member/userRoleList", parameters: ["id": authorID]) } catch { self.error = error.localizedDescription } }
  }
}

@MainActor
final class QQChatModel: ObservableObject {
  @Published var messages: [QQMessage] = []
  @Published var busy = false
  @Published var error: String?
  @Published var suggestions: [String] = []
  @Published var panel: [QQRecord] = []
  var draftAfterFailure: String?

  func history(store: QingqingStore, roleID: String, kind: QQConversationKind) async {
    busy = true; error = nil
    defer { busy = false }
    do {
      if kind == .simulator {
        let data = try await store.api.request("simulator/getMoChatMsg", parameters: ["game_id": roleID, "id": "0"])
        messages = decode(data["message"])
        panel = data["panelAttributes"].records
      } else {
        let data = try await store.api.request("ai/chatList", method: "POST", parameters: ["role_id": roleID, "type": "new", "id": "0", "is_sy": "0"])
        messages = decode(data)
      }
    } catch { self.error = error.localizedDescription }
  }

  func send(_ text: String, store: QingqingStore, roleID: String, model: String, kind: QQConversationKind) async -> Bool {
    guard !busy, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
    busy = true; error = nil; suggestions = []
    defer { busy = false }
    let pendingID = UUID().uuidString
    messages.append(QQMessage(id: pendingID, text: text, isUser: true))
    do {
      let path = kind == .single ? "ai/chatV2" : kind == .multi ? "ai/chatMany" : "simulator/trun"
      let params = kind == .simulator ? ["game_id": roleID, "message": text] : ["role_id": roleID, "msg": text, "model_name": model, "go": "0", "is_sy": "0"]
      let result = try await store.api.request(path, method: "POST", parameters: params)
      let replies: [QQMessage]
      if kind == .simulator {
        replies = decode(result["message"])
        panel = result["panelAttributes"].records
      } else { replies = QQConversationMessages.replies(result) }
      guard replies.contains(where: { !$0.text.isEmpty }) else { throw QQAPIError.invalidResponse }
      messages += replies.filter { !$0.text.isEmpty }
      await store.refreshUser()
      return true
    } catch {
      messages.removeAll { $0.id == pendingID }
      self.error = error.localizedDescription
      return false
    }
  }

  func candidateReplies(store: QingqingStore, roleID: String, kind: QQConversationKind) async {
    guard !busy else { return }
    busy = true; error = nil
    defer { busy = false }
    do {
      let path = kind == .single ? "ai/chatReply" : kind == .multi ? "ai/chatManyReply" : "simulator/chatReply"
      var params = kind == .simulator ? ["game_id": roleID] : ["role_id": roleID]
      params["msg"] = messages.last?.text ?? ""
      suggestions = try await store.api.request(path, method: "POST", parameters: params).list.map(\.text)
    } catch { self.error = error.localizedDescription }
  }

  private func decode(_ data: QQValue) -> [QQMessage] {
    QQConversationMessages.history(data)
  }
}

struct QQChatView: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  @Environment(\.dismiss) private var dismiss
  @AppStorage("qingqing.chat.dark") private var darkMode = false
  @AppStorage("qingqing.chat.halfScreen") private var halfScreen = false
  @State private var showSettings = false
  @State private var showIdentity = false
  @State private var showBackground = false
  @State private var showActions = false
  @State private var backgroundChoice = ""
  @FocusState private var inputFocused: Bool
  @State private var detail: QQRecord?
  private var current: QQRecord { detail ?? role }
  var kind: QQConversationKind = .single
  @StateObject private var chat = QQChatModel()
  @State private var input = ""
  @State private var modelCode = "L1"
  @State private var memoryPresented = false
  @State private var giftPresented = false
  @State private var memoryHome: QQValue = .null
  @State private var intimacy: QQValue = .null
  @State private var intimacyConfiguration: QQValue = .null
  @State private var restart = false
  @State private var showModels = false
  private var roleID: String { role.first("game_id", "role_id", "id") }

  var body: some View {
    ZStack {
      QQChatBackgroundView(role: current, selection: backgroundChoice).ignoresSafeArea()
      Color.black.opacity(darkMode ? 0.7 : 0.4).ignoresSafeArea()
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Button { dismiss() } label: { QQArtwork(name: "chat_ico_back").frame(width: 24, height: 24).frame(width: 45, height: 50) }.accessibilityLabel("返回")
          NavigationLink { QQRoleDetailView(role: current, kind: kind) } label: { Text(current.name).font(.system(size: 18)).lineLimit(1) }
          Spacer(minLength: 4)
          NavigationLink { QQMemberView(initialTab: 1) } label: { HStack(spacing: 4) { QQArtwork(name: "chat_ico_diamond").frame(width: 16, height: 16); Text(store.user?["coin"] ?? "").font(.system(size: 14)); QQArtwork(name: "chat_ico_diamond_add").frame(width: 16, height: 16).padding(.leading, 6) }.padding(.horizontal, 7).frame(height: 30).background(.black.opacity(0.5), in: Capsule()) }
          Button { showSettings = true } label: { QQArtwork(name: "chat_ico_set").frame(width: 18, height: 18).frame(width: 30, height: 30).background(.black.opacity(0.5), in: Circle()) }.padding(.leading, 5).accessibilityLabel("对话设置")
        }.padding(.trailing, 15).foregroundStyle(.white)
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
              if chat.messages.isEmpty && !current["open_remark"].isEmpty {
                messageBubble(QQMessage(id: "opening", text: current["open_remark"], isUser: false))
              }
              ForEach(chat.messages) { messageBubble($0).id($0.id) }
              if chat.busy { HStack { ProgressView().tint(.white); Text("正在输入…").font(.system(size: 12)) }.foregroundStyle(.white.opacity(0.8)).padding(12) }
              if let error = chat.error {
                VStack(spacing: 8) {
                  Text(error).font(.system(size: 13)).multilineTextAlignment(.center)
                  if !store.loggedIn { Button("登录后继续") { store.loginPresented = true } }
                }.foregroundStyle(.white).padding(14).frame(maxWidth: .infinity).background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
              }
              Color.clear.frame(height: 2).id("bottom")
            }.padding(16)
          }.mask { GeometryReader { geometry in
            let fadeHeight = halfScreen && !inputFocused ? max(80, geometry.size.height / 2 - 20) : 80
            VStack(spacing: 0) { Color.clear.frame(height: max(0, fadeHeight - 80)); LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom).frame(height: 80); Color.black }
          } }.animation(.easeInOut(duration: 0.15), value: halfScreen).onChange(of: chat.messages.count) { _, _ in withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo("bottom", anchor: .bottom) } }
        }
        inputBar
      }
    }.toolbar(.hidden, for: .navigationBar)
      .overlay(alignment: .topTrailing) {
        if kind == .single && !intimacy.isNull {
          let progress = QQIntimacyProgress(value: Int(intimacy["intimacy"].text) ?? 0, configuration: intimacyConfiguration)
          NavigationLink { QQIntimacyView(role: current) } label: {
            VStack(spacing: 0) {
              QQArtwork(name: String(format: "lv_ico_heart%02d", progress.stage)).frame(width: 30, height: 28)
              Text("\(progress.level)").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
              Text(progress.stageName).font(.system(size: 10)).foregroundStyle(.white).padding(.horizontal, 10).frame(height: 18).background(.cyan.opacity(0.8), in: Capsule())
            }.frame(width: 54, height: 60).background(.black.opacity(0.2), in: Circle())
          }.accessibilityLabel("亲密度").padding(.trailing, 15).padding(.top, 65)
        }
      }
      .overlay { if showSettings { QQTalkSettingsPanel(role: current, modelName: store.models.first(where: { $0["code"] == modelCode })?.name ?? "", close: { showSettings = false }, identity: { showSettings = false; showIdentity = true }, background: { showSettings = false; showBackground = true }, models: { showSettings = false; showModels = true }) } }
      .task {
        backgroundChoice = QQChatBackground.selection(roleID)
        if let chosen = store.user?["model"], !chosen.isEmpty { modelCode = chosen }
        if kind != .simulator { detail = try? QQRecord(await store.api.request(kind == .multi ? "home/getGroupRoleDetail" : "home/getRoleDetail", method: "POST", parameters: ["id": roleID])) }
        if kind == .single {
          memoryHome = (try? await store.api.request("ai/getMemoryHome", parameters: ["role_id": roleID])) ?? .null
          intimacy = (try? await store.api.request("role/getMemberRole", parameters: ["role_id": roleID])) ?? .null
          intimacyConfiguration = (try? await store.api.request("role/getConfig")) ?? .null
        }
        await chat.history(store: store, roleID: roleID, kind: kind)
      }
      .sheet(isPresented: $showIdentity) { NavigationStack { QQIdentityView(role: current) } }
      .sheet(isPresented: $showBackground, onDismiss: { backgroundChoice = QQChatBackground.selection(roleID) }) { QQBackgroundSettingView(role: current).presentationDetents([.height(420)]).presentationCornerRadius(30) }
      .sheet(isPresented: $showModels) { NavigationStack { QQModelSelectionView(selection: $modelCode) }.presentationDetents([.large]) }
      .sheet(isPresented: $memoryPresented) { NavigationStack { QQMemoryView(role: current) }.environmentObject(store) }
      .sheet(isPresented: $giftPresented) { NavigationStack { QQGiftView(role: current) }.environmentObject(store) }
      .confirmationDialog("重启会话后，将重新开始当前角色的剧情。", isPresented: $restart, titleVisibility: .visible) {
        Button("重启会话", role: .destructive) {
          Task {
            do {
              _ = try await store.api.request(kind == .simulator ? "simulator/restart" : "ai/roleReset", method: kind == .simulator ? "GET" : "POST", parameters: kind == .simulator ? ["id": roleID] : ["role_id": roleID, "is_sy": "0"])
              await chat.history(store: store, roleID: roleID, kind: kind)
            } catch { chat.error = error.localizedDescription }
          }
        }
      }
  }

  private func messageBubble(_ message: QQMessage) -> some View {
    HStack(alignment: .top, spacing: 10) {
      if message.isUser { Spacer(minLength: 42) }
      else { QQRemoteImage(address: avatar(message)).frame(width: 34, height: 34).clipShape(Circle()) }
      VStack(alignment: .leading, spacing: 5) {
        if !message.isUser { Text(message.sender.isEmpty ? current.name : message.sender).font(.system(size: 14)).foregroundStyle(.white) }
        Text(message.text).font(.system(size: 14)).lineSpacing(5).textSelection(.enabled)
          .foregroundStyle(message.isUser ? QQStyle.ink : .white)
          .padding(14).background(message.isUser ? Color(red: 0.73, green: 0.88, blue: 0.99) : .black.opacity(0.35), in: RoundedRectangle(cornerRadius: 16))
      }
      if !message.isUser { Spacer(minLength: 24) }
    }
  }

  private var inputBar: some View {
    VStack(spacing: 10) {
      if !chat.suggestions.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack { ForEach(Array(chat.suggestions.enumerated()), id: \.offset) { _, text in Button(text) { input = text }.font(.system(size: 12)).padding(10).background(.white.opacity(0.15), in: Capsule()).foregroundStyle(.white) } }
        }
      }
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          quickAction("对话模式", icon: "chat_ico_func02") { showModels = true }
          if memoryHome["home_is_show"].text == "1" {
            quickAction("记忆簿（\(memoryHome["home_used_memory_count"].text)/\(memoryHome["max_size"].text)）", icon: "chat_ico_func03") { memoryPresented = true }
            quickAction("送礼物", icon: "chat_ico_func05") { giftPresented = true }
          }
        }
      }
      HStack(alignment: .bottom, spacing: 5) {
        TextField("自由输入…", text: $input, axis: .vertical).focused($inputFocused).lineLimit(1...2).font(.system(size: 14)).foregroundStyle(.white).tint(.white).padding(.vertical, 13).padding(.leading, 15)
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          Button { Task { await chat.candidateReplies(store: store, roleID: roleID, kind: kind) } } label: { QQArtwork(name: "chat_ico_ai01").frame(width: 24, height: 24).frame(height: 50) }.accessibilityLabel("回复灵感").disabled(chat.busy)
          Button { showActions.toggle() } label: { QQArtwork(name: "chat_ico_more").frame(width: 24, height: 24).frame(height: 50) }.accessibilityLabel("更多功能")
        } else {
          Button { send() } label: { QQArtwork(name: "chat_ico_send").frame(width: 24, height: 24).frame(height: 50) }.disabled(chat.busy).accessibilityLabel("发送消息")
        }
      }.padding(.trailing, 14).background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
      if showActions {
        HStack(spacing: 11) {
          moreAction("重启会话", icon: "chat_ico_more01") { restart = true }
          moreAction("礼物", icon: "chat_ico_more02") { giftPresented = true }
          moreAction("替换背景", icon: "chat_ico_more03") { showBackground = true }
        }.padding(.top, 6).padding(.bottom, 24)
      }
    }.padding(.horizontal, 15).padding(.vertical, 12)
  }
  private func avatar(_ message: QQMessage) -> String {
    if !message.avatar.isEmpty { return message.avatar }
    if let actor = current.value["characters"].records.first(where: { $0["roleId"] == message.senderRoleID || (!message.sender.isEmpty && $0.name == message.sender) }) { return actor.first("avatar", "avatarUrl") }
    return current.image
  }
  private func quickAction(_ title: String, icon: String, action: @escaping () -> Void) -> some View { Button(action: action) { HStack(spacing: 5) { QQArtwork(name: icon).frame(width: 16, height: 16); Text(title).font(.system(size: 12)) }.padding(.horizontal, 12).frame(height: 34).foregroundStyle(.white).background(.black.opacity(0.5), in: Capsule()) } }
  private func moreAction(_ title: String, icon: String, action: @escaping () -> Void) -> some View { Button(action: action) { VStack(spacing: 10) { QQArtwork(name: icon).frame(width: 30, height: 30); Text(title).font(.system(size: 12)) }.frame(maxWidth: .infinity).frame(height: 86).foregroundStyle(.white).background(.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 16)) } }

  private func send() {
    store.requireLogin {
      let message = input
      input = ""
      Task { if !(await chat.send(message, store: store, roleID: roleID, model: modelCode, kind: kind)) { input = message } }
    }
  }
}
