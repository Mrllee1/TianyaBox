import SwiftUI

struct QQRoleDetailView: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  @State private var detail: QQRecord?
  @State private var talking = false
  @State private var followed = false
  @State private var error: String?
  private var current: QQRecord { detail ?? role }
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        QQRemoteImage(address: current.image).frame(height: 440)
          .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 10) {
              Text(current.name).font(.system(size: 28, weight: .bold))
              QQTags(tags: current.tags, dark: true)
            }.padding(22).frame(maxWidth: .infinity, alignment: .leading)
              .background(LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom))
          }.foregroundStyle(.white)
        VStack(alignment: .leading, spacing: 18) {
          HStack {
            Label(current.first("chat_num", "msg_num") + " 对话", systemImage: "bubble.left.and.bubble.right")
            Spacer()
            Button(followed ? "已关注" : "+ 关注") { store.requireLogin { Task { await follow() } } }
          }.font(.system(size: 13)).foregroundStyle(QQStyle.secondary)
          Text("角色介绍").font(.system(size: 18, weight: .semibold))
          Text(current.intro).font(.system(size: 14)).lineSpacing(6)
          if !current["open_remark"].isEmpty {
            Text("开场白").font(.system(size: 18, weight: .semibold))
            Text(current["open_remark"]).font(.system(size: 14)).lineSpacing(6).foregroundStyle(QQStyle.secondary)
          }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        }.padding(.horizontal, 20).padding(.bottom, 20)
      }
    }.ignoresSafeArea(edges: .top)
      .safeAreaInset(edge: .bottom) {
        QQPrimaryButton(title: "开始聊天") { store.requireLogin { talking = true } }
          .padding(.horizontal, 20).padding(.vertical, 10).background(.white)
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(isPresented: $talking) { QQChatView(role: current) }
      .task {
        do { detail = QQRecord(try await store.api.request("home/getRoleDetail", method: "POST", parameters: ["id": role.id])) }
        catch { self.error = error.localizedDescription }
      }
  }
  private func follow() async {
    do { _ = try await store.api.request("member/roleFollow", method: "POST", parameters: ["role_id": role.id, "status": followed ? "0" : "1"]); followed.toggle() }
    catch { self.error = error.localizedDescription }
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
      } else if !result["replyList"].list.isEmpty {
        replies = result["replyList"].list.enumerated().map { index, entry in
          QQMessage(id: result["id"].text + ":\(index)", text: entry["reply"].text, isUser: false, sender: entry["display_name"].text)
        }
      } else { replies = [QQMessage(id: result["id"].text.isEmpty ? UUID().uuidString : result["id"].text, text: result["reply"].text, isUser: false)] }
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
    data.list.enumerated().flatMap { index, item -> [QQMessage] in
      let id = item["id"].text.isEmpty ? String(index) : item["id"].text
      var result: [QQMessage] = []
      if !item["msg"].text.isEmpty { result.append(QQMessage(id: id + ":user", text: item["msg"].text, isUser: true)) }
      let reply = item["reply"].text.isEmpty ? item["content"].text : item["reply"].text
      if !reply.isEmpty { result.append(QQMessage(id: id, text: reply, isUser: item["type"].text == "user", sender: item["senderName"].text)) }
      return result
    }
  }
}

struct QQChatView: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  var kind: QQConversationKind = .single
  @StateObject private var chat = QQChatModel()
  @State private var input = ""
  @State private var modelCode = "L1"
  @State private var memoryPresented = false
  @State private var giftPresented = false
  @State private var restart = false
  @State private var showModels = false
  private var roleID: String { role.first("game_id", "role_id", "id") }

  var body: some View {
    ZStack {
      QQRemoteImage(address: role.image).ignoresSafeArea()
      Color.black.opacity(0.54).ignoresSafeArea()
      VStack(spacing: 0) {
        HStack(spacing: 12) {
          Text(role.name).font(.system(size: 18, weight: .semibold)).lineLimit(1)
          Spacer()
          NavigationLink { QQMemberView() } label: { Label(store.user?["coin"] ?? "", systemImage: "diamond.fill").font(.system(size: 13)) }
          Menu {
            Button("记忆簿", systemImage: "book") { memoryPresented = true }
            Button("送礼物", systemImage: "gift") { giftPresented = true }
            Button("对话模式", systemImage: "slider.horizontal.3") { showModels = true }
            Button("重启会话", systemImage: "arrow.counterclockwise", role: .destructive) { restart = true }
          } label: { Image(systemName: "ellipsis").padding(6) }
        }.padding(.horizontal, 20).padding(.vertical, 12).foregroundStyle(.white)
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
              if chat.messages.isEmpty && !role["open_remark"].isEmpty {
                messageBubble(QQMessage(id: "opening", text: role["open_remark"], isUser: false))
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
          }.onChange(of: chat.messages.count) { _, _ in withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo("bottom", anchor: .bottom) } }
        }
        inputBar
      }
    }.navigationBarTitleDisplayMode(.inline).toolbarBackground(.hidden, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await chat.history(store: store, roleID: roleID, kind: kind) }
      .sheet(isPresented: $showModels) { modelPicker.presentationDetents([.medium, .large]) }
      .sheet(isPresented: $memoryPresented) { NavigationStack { QQMemoryView(role: role) }.environmentObject(store) }
      .sheet(isPresented: $giftPresented) { NavigationStack { QQGiftView(role: role) }.environmentObject(store) }
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
      else { QQRemoteImage(address: role.image).frame(width: 34, height: 34).clipShape(Circle()) }
      VStack(alignment: .leading, spacing: 5) {
        if !message.sender.isEmpty { Text(message.sender).font(.system(size: 11)).foregroundStyle(.white.opacity(0.65)) }
        Text(message.text).font(.system(size: 15)).lineSpacing(5).textSelection(.enabled)
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
      HStack(spacing: 16) {
        Button { showModels = true } label: { Label(store.models.first(where: { $0["code"] == modelCode })?.name ?? "对话模式", systemImage: "sparkles") }
        Spacer()
        Button { memoryPresented = true } label: { Image(systemName: "book.closed") }
        Button { giftPresented = true } label: { Image(systemName: "gift") }
        Button { Task { await chat.candidateReplies(store: store, roleID: roleID, kind: kind) } } label: { Image(systemName: "wand.and.stars") }
      }.font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
      HStack(alignment: .bottom, spacing: 10) {
        TextField("说点什么，开启你们的故事…", text: $input, axis: .vertical)
          .lineLimit(1...5).font(.system(size: 14)).padding(13).background(.white, in: RoundedRectangle(cornerRadius: 22))
        Button { send() } label: { Image(systemName: "arrow.up").font(.system(size: 18, weight: .semibold)).frame(width: 43, height: 43).background(QQStyle.gradient, in: Circle()) }
          .disabled(chat.busy || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityLabel("发送消息")
      }
    }.padding(.horizontal, 16).padding(.vertical, 12).background(Color(red: 0.03, green: 0.03, blue: 0.06).opacity(0.94))
  }

  private var modelPicker: some View {
    NavigationStack {
      List(store.models) { model in
        Button {
          modelCode = model["code"]; showModels = false
        } label: {
          HStack {
            VStack(alignment: .leading, spacing: 8) {
              Text(model.name).font(.system(size: 17, weight: .semibold))
              Text(model["title"]).font(.system(size: 13))
              Text(model.first("price_desc", "info")).font(.system(size: 12)).foregroundStyle(.secondary)
            }
            Spacer()
            if modelCode == model["code"] { Image(systemName: "checkmark.circle.fill") }
          }.padding(.vertical, 8)
        }
      }.navigationTitle("对话模式").navigationBarTitleDisplayMode(.inline)
    }
  }
  private func send() {
    store.requireLogin {
      let message = input
      input = ""
      Task { if !(await chat.send(message, store: store, roleID: roleID, model: modelCode, kind: kind)) { input = message } }
    }
  }
}
