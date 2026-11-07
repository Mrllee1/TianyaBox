import SwiftUI
import PhotosUI

struct QQLoginView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @State private var email = ""
  @State private var code = ""
  @State private var accepted = false
  @State private var busy = false
  @State private var error: String?
  @State private var nextCodeTime = Date.distantPast
  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 26) {
        Text("欢迎来到\n卿卿我我 AI").font(.system(size: 30, weight: .bold)).lineSpacing(10).padding(.top, 40)
        Text("登录后，开启属于你的故事").font(.system(size: 14)).foregroundStyle(QQStyle.secondary)
        VStack(spacing: 20) {
          TextField("请输入您的邮箱号", text: $email).keyboardType(.emailAddress).textContentType(.emailAddress)
            .textInputAutocapitalization(.never).autocorrectionDisabled().padding(.vertical, 16).overlay(alignment: .bottom) { Divider() }
          HStack {
            TextField("请输入您的验证码", text: $code).keyboardType(.numberPad).textContentType(.oneTimeCode)
            TimelineView(.periodic(from: .now, by: 1)) { context in
              let remaining = max(0, Int(nextCodeTime.timeIntervalSince(context.date)))
              Button(remaining > 0 ? "\(remaining)s" : "获取验证码") { sendCode() }
                .font(.system(size: 13)).disabled(remaining > 0 || busy || !email.contains("@"))
            }
          }.padding(.vertical, 16).overlay(alignment: .bottom) { Divider() }
        }.font(.system(size: 15))
        if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red).fixedSize(horizontal: false, vertical: true) }
        QQPrimaryButton(title: "登录", busy: busy) { login() }.disabled(email.isEmpty || code.isEmpty || !accepted)
        Button("游客体验") { guestLogin() }.font(.system(size: 14)).frame(maxWidth: .infinity).disabled(busy || !accepted)
        Toggle(isOn: $accepted) {
          Text("登录使用卿卿服务；游客体验会为此设备创建独立的游客账号。")
            .font(.system(size: 12)).foregroundStyle(QQStyle.secondary)
        }.toggleStyle(.checkboxCompat)
        Spacer()
      }.padding(.horizontal, 28).foregroundStyle(QQStyle.ink)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("关闭") { dismiss() } } }
    }
  }
  private func sendCode() {
    guard accepted else { error = "请先阅读并勾选登录说明"; return }
    email = email.trimmingCharacters(in: .whitespacesAndNewlines)
    busy = true; error = nil
    Task {
      defer { busy = false }
      do {
        try await store.api.ensureDeviceSession()
        _ = try await store.api.request("sendMailCode", method: "POST", parameters: ["email": email], json: true)
        code = ""
        nextCodeTime = Date().addingTimeInterval(60)
      }
      catch { self.error = error.localizedDescription }
    }
  }
  private func login() {
    email = email.trimmingCharacters(in: .whitespacesAndNewlines)
    code = code.trimmingCharacters(in: .whitespacesAndNewlines)
    guard code.count == 6, code.utf8.allSatisfy({ (48...57).contains($0) }) else { error = "请输入邮件中的 6 位数字验证码"; return }
    busy = true; error = nil
    Task {
      defer { busy = false }
      do {
        try await store.api.ensureDeviceSession()
        let data = try await store.api.request("mail/login", method: "POST", parameters: ["email": email, "code": code])
        let token = data["token"].text
        guard !token.isEmpty else { throw QQAPIError.invalidResponse }
        store.api.setToken(token)
        await store.refreshUser()
        dismiss()
      } catch { self.error = error.localizedDescription }
    }
  }
  private func guestLogin() {
    busy = true; error = nil
    Task {
      defer { busy = false }
      do {
        try await store.api.ensureDeviceSession()
        await store.refreshUser()
        dismiss()
      } catch { self.error = error.localizedDescription }
    }
  }
}

private struct QQCheckboxStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button { configuration.isOn.toggle() } label: {
      HStack(alignment: .top, spacing: 8) {
        Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle").foregroundStyle(configuration.isOn ? QQStyle.ink : .gray)
        configuration.label.multilineTextAlignment(.leading)
      }
    }.buttonStyle(.plain).accessibilityValue(configuration.isOn ? "已勾选" : "未勾选")
  }
}
private extension ToggleStyle where Self == QQCheckboxStyle { static var checkboxCompat: QQCheckboxStyle { QQCheckboxStyle() } }

struct QQMineView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var signing = false
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        HStack(spacing: 14) {
          if let user = store.user { QQRemoteImage(address: user.first("head_img", "avatar")).frame(width: 64, height: 64).clipShape(Circle()) }
          else { QQArtwork(name: "wd_tx").frame(width: 64, height: 64) }
          VStack(alignment: .leading, spacing: 10) {
            Button { if !store.hasBoundAccount { store.loginPresented = true } } label: {
              Text(store.user?.first("nick", "name", "nickname") ?? "小伙伴，点我登录").font(.system(size: 20, weight: .semibold))
            }
            Text(store.user?["sign"] ?? "登录后享受更多权益～").font(.system(size: 12)).foregroundStyle(QQStyle.secondary)
          }
          Spacer(minLength: 0)
          NavigationLink { QQSettingsView() } label: { QQArtwork(name: "mine_ico_set").frame(width: 24, height: 24) }.accessibilityLabel("设置")
        }.padding(.top, 25)
        HStack(spacing: 40) {
          NavigationLink { QQAPIListView(title: "聊过", path: "ai/roleList", requiresLogin: true) } label: { statistic("聊过", value: store.user?.first("chat_num", "talk_count") ?? "0") }
          NavigationLink { QQAPIListView(title: "关注", path: "member/followList", parameters: ["page": "1", "pageSize": "20"], requiresLogin: true) } label: { statistic("关注", value: store.user?.first("follow_num", "follow_count") ?? "0") }
          Spacer()
          Button {
            store.requireLogin {
              signing = true
              Task {
                defer { signing = false }
                do { _ = try await store.api.request("member/sign"); await store.refreshUser() }
                catch { store.error = error.localizedDescription }
              }
            }
          } label: { Label(signing ? "签到中" : "签到", systemImage: "calendar").font(.system(size: 12)).foregroundStyle(.orange).padding(10).background(.orange.opacity(0.08), in: Capsule()) }.disabled(signing)
        }
        NavigationLink { QQMemberView() } label: {
          HStack {
            VStack(alignment: .leading, spacing: 8) {
              Text("卿卿会员").font(.system(size: 23, weight: .bold))
              Text("解锁更多心动，享受专属权益").font(.system(size: 12))
            }
            Spacer()
            Text("立即开通 ›").font(.system(size: 13, weight: .semibold)).padding(10).background(.white.opacity(0.65), in: Capsule())
          }.padding(20).foregroundStyle(Color(red: 0.28, green: 0.21, blue: 0.15))
            .background(LinearGradient(colors: [Color(red: 0.98, green: 0.90, blue: 0.77), Color(red: 0.96, green: 0.83, blue: 0.66)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 18))
        }
        HStack(spacing: 12) {
          NavigationLink { QQInviteView() } label: {
            VStack(alignment: .leading, spacing: 12) { Text("邀请有奖").font(.system(size: 16, weight: .semibold)); Text("邀请好友，一起心动").font(.system(size: 11)) }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(Color(red: 0.89, green: 0.94, blue: 1), in: RoundedRectangle(cornerRadius: 14))
          }
          NavigationLink { QQAPIListView(title: "钻石明细", path: "member/getCoinList", parameters: ["page": "1", "pageSize": "20", "type": "all"], requiresLogin: true) } label: {
            VStack(alignment: .leading, spacing: 12) { Text("剩余钻石").font(.system(size: 16, weight: .semibold)); HStack { Text(store.user?["coin"] ?? "0"); Spacer(); QQArtwork(name: "mine_pic_diamond").frame(width: 32, height: 20) } }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(Color(red: 0.93, green: 0.90, blue: 1), in: RoundedRectangle(cornerRadius: 14))
          }
        }
        QQPrimaryButton(title: "＋ 免费创建我的角色") { store.requireLogin { store.creatorPresented = true } }
        HStack { Text("智能体").font(.system(size: 20, weight: .bold)); Spacer(); NavigationLink("管理 ›") { QQAPIListView(title: "我的智能体", path: "member/memberRoleList", parameters: ["page": "1", "pageSize": "20"], requiresLogin: true) }.font(.system(size: 13)).foregroundStyle(QQStyle.secondary) }
        if !store.loggedIn { QQEmptyState(text: "登录后，创建你的专属智能体") }
        else { QQOwnedRolesView() }
        if let error = store.error { Text(error).font(.system(size: 12)).foregroundStyle(.red) }
      }.padding(.horizontal, 20).padding(.bottom, 20)
    }.background(LinearGradient(colors: [Color(red: 0.92, green: 0.95, blue: 1), .white, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
      .task { if store.loggedIn { await store.refreshUser() } }
  }
  private func statistic(_ title: String, value: String) -> some View { VStack(spacing: 6) { Text(value).font(.system(size: 20, weight: .bold)); Text(title).font(.system(size: 13)) } }
}

private struct QQOwnedRolesView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var records: [QQRecord] = []
  @State private var error: String?
  var body: some View {
    VStack {
      if let error { Text(error).font(.system(size: 13)).foregroundStyle(.secondary) }
      else if records.isEmpty { QQEmptyState() }
      else {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
          ForEach(records) { record in NavigationLink(value: record) { QQRoleTile(role: record) } }
        }
      }
    }.task {
      do { records = try await store.api.request("member/memberRoleList", parameters: ["page": "1", "pageSize": "20"]).records }
      catch { self.error = error.localizedDescription }
    }
  }
}

struct QQMessagesView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var section = 0
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 24) {
        ForEach(["消息", "关注"].indices, id: \.self) { index in Button { section = index } label: { VStack(spacing: 6) { Text(["消息", "关注"][index]).font(.system(size: 22, weight: section == index ? .bold : .regular)); Capsule().fill(section == index ? .black : .clear).frame(width: 12, height: 4) } } }
        Spacer()
        NavigationLink { QQAPIListView(title: "系统消息", path: "ai/systemMsg", requiresLogin: true) } label: { Image(systemName: "bell") }
      }.padding(20)
      QQAPIListView(title: "", path: section == 0 ? "ai/roleList" : "member/followList", parameters: section == 0 ? [:] : ["page": "1", "pageSize": "20"], requiresLogin: true, embedded: true).id(section)
    }.background(.white)
  }
}

struct QQCreatorView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @State private var name = ""
  @State private var gender = "女"
  @State private var intro = ""
  @State private var setting = ""
  @State private var opening = ""
  @State private var category = ""
  @State private var tags = ""
  @State private var roleConfiguration: QQValue = .null
  @State private var publicRole = true
  @State private var photo: PhotosPickerItem?
  @State private var imageData: Data?
  @State private var imageURL = ""
  @State private var busy = false
  @State private var error: String?
  @State private var notice = false
  private let draftKey = "qingqing.roleDraft.v1"
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Button("创作者须知  ›") { notice = true }.font(.system(size: 13)).frame(maxWidth: .infinity, alignment: .trailing)
        Text("角色形象*").font(.system(size: 16, weight: .semibold))
        PhotosPicker(selection: $photo, matching: .images) {
          ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.035)).frame(width: 126, height: 176)
            if let imageData, let image = UIImage(data: imageData) { Image(uiImage: image).resizable().scaledToFill().frame(width: 126, height: 176).clipped().clipShape(RoundedRectangle(cornerRadius: 16)) }
            else if !imageURL.isEmpty { QQRemoteImage(address: imageURL).frame(width: 126, height: 176).clipShape(RoundedRectangle(cornerRadius: 16)) }
            else { Image(systemName: "plus").font(.system(size: 28)).foregroundStyle(.gray) }
          }
        }
        Text("图片分辨率建议 576 × 1024（9:16）以上").font(.system(size: 11)).foregroundStyle(.secondary)
        fieldTitle("名称*", count: name.count, limit: 7)
        TextField("给角色起个名字", text: $name).padding(14).background(.white, in: RoundedRectangle(cornerRadius: 12)).onChange(of: name) { _, v in name = String(v.prefix(7)) }
        Text("性别*").font(.system(size: 16, weight: .semibold))
        Picker("性别", selection: $gender) { Text("男性").tag("男"); Text("女性").tag("女"); Text("其他").tag("其他") }.pickerStyle(.segmented)
        editor("对外简介*", subtitle: "不影响对话效果，仅用于其他用户了解角色", text: $intro, limit: 5000)
        editor("角色设定*", subtitle: "决定智能体的对话效果，不对其他人展示", text: $setting, limit: 5000)
        editor("开场白*", subtitle: "角色会对你说的第一句话", text: $opening, limit: 500)
        Text("人物分类*").font(.system(size: 16, weight: .semibold))
        if roleConfiguration["role_category"].list.isEmpty {
          TextField("填写人物分类", text: $category).padding(14).background(.white, in: RoundedRectangle(cornerRadius: 12))
        } else { chips(roleConfiguration["role_category"].list.map(\.text), selection: $category) }
        Text("人物标签*").font(.system(size: 16, weight: .semibold))
        chips(roleConfiguration["tag"]["bj"].list.map(\.text) + roleConfiguration["tag"]["xg"].list.map(\.text), selection: $tags)
        TextField("添加角色标签，使用逗号分隔", text: $tags).padding(14).background(.white, in: RoundedRectangle(cornerRadius: 12))
        Text("角色可见范围*").font(.system(size: 16, weight: .semibold))
        Picker("角色可见范围", selection: $publicRole) { Text("公开").tag(true); Text("隐身").tag(false) }.pickerStyle(.segmented)
        if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        HStack(spacing: 14) {
          Button("保存草稿") { saveDraft(); dismiss() }.frame(maxWidth: .infinity).frame(height: 56).background(.white, in: Capsule())
          QQPrimaryButton(title: "发布", busy: busy) { publish() }
        }
      }.padding(20)
    }.background(QQStyle.background).navigationTitle("创建智能体").navigationBarTitleDisplayMode(.inline)
      .toolbar { ToolbarItem(placement: .topBarLeading) { Button("关闭") { saveDraft(); dismiss() } } }
      .task {
        restoreDraft()
        do { roleConfiguration = try await store.api.request("ai/getRoleConfig") }
        catch { self.error = error.localizedDescription }
      }
      .task(id: photo) {
        guard let photo else { return }
        do {
          guard let raw = try await photo.loadTransferable(type: Data.self), let image = UIImage(data: raw), let data = image.jpegData(compressionQuality: 0.8), data.count <= 8_000_000 else { error = "请选择小于 8MB 的图片"; return }
          imageData = data
        } catch { self.error = error.localizedDescription }
      }
      .alert("创作者须知", isPresented: $notice) {
        Button("知道了", role: .cancel) {}
      } message: { Text("请使用有权发布的图片和内容。公开角色会提交给服务端审核，审核结果以角色状态为准。角色设定决定对话效果，对外简介用于介绍角色。") }
  }
  private func fieldTitle(_ title: String, count: Int, limit: Int) -> some View { HStack { Text(title).font(.system(size: 16, weight: .semibold)); Spacer(); Text("\(count)/\(limit)").font(.system(size: 12)).foregroundStyle(.secondary) } }
  private func chips(_ options: [String], selection: Binding<String>) -> some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 10) {
      ForEach(Array(Set(options)).sorted(), id: \.self) { option in
        let selected = selection.wrappedValue.components(separatedBy: ",").contains(option)
        Button {
          var values = selection.wrappedValue.components(separatedBy: ",").filter { !$0.isEmpty }
          if selected { values.removeAll { $0 == option } } else { values.append(option) }
          selection.wrappedValue = values.joined(separator: ",")
        } label: {
          Text(option).font(.system(size: 12)).frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(selected ? Color.cyan.opacity(0.15) : .white, in: Capsule())
            .overlay { Capsule().stroke(selected ? .cyan : .clear) }
        }
      }
    }
  }
  private func editor(_ title: String, subtitle: String, text: Binding<String>, limit: Int) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      fieldTitle(title, count: text.wrappedValue.count, limit: limit)
      Text(subtitle).font(.system(size: 11)).foregroundStyle(.secondary)
      TextEditor(text: text).frame(height: 120).padding(8).scrollContentBackground(.hidden).background(.white, in: RoundedRectangle(cornerRadius: 12))
        .onChange(of: text.wrappedValue) { _, v in text.wrappedValue = String(v.prefix(limit)) }
    }
  }
  private func saveDraft() {
    UserDefaults.standard.set(["name": name, "gender": gender, "intro": intro, "role_setting": setting, "open_remark": opening, "img_url": imageURL, "role_category": category, "tag": tags, "public": publicRole ? "1" : "0"], forKey: draftKey)
    if let imageData {
      try? FileManager.default.createDirectory(at: draftImageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try? imageData.write(to: draftImageURL, options: [.atomic, .completeFileProtection])
    }
  }
  private var draftImageURL: URL { FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("qingqing-role-draft.jpg") }
  private func restoreDraft() {
    guard let draft = UserDefaults.standard.dictionary(forKey: draftKey) as? [String: String] else { return }
    name = draft["name"] ?? ""; gender = draft["gender"] ?? "女"; intro = draft["intro"] ?? ""; setting = draft["role_setting"] ?? ""; opening = draft["open_remark"] ?? ""; imageURL = draft["img_url"] ?? ""; publicRole = draft["public"] != "0"
    imageData = try? Data(contentsOf: draftImageURL)
    category = draft["role_category"] ?? ""; tags = draft["tag"] ?? ""
  }
  private func publish() {
    guard !name.isEmpty, !intro.isEmpty, !setting.isEmpty, !opening.isEmpty, !category.isEmpty, !tags.isEmpty, imageData != nil || !imageURL.isEmpty else { error = "请填写完整的角色信息并选择角色形象、分类和标签"; return }
    busy = true; error = nil
    Task {
      defer { busy = false }
      do {
        if let imageData {
          let result = try await store.api.request("feedback/upload", method: "POST", parameters: ["file": "data:image/jpeg;base64," + imageData.base64EncodedString()], json: true)
          guard let address = result.list.first?.text, URL(string: address)?.scheme == "https" else { throw QQAPIError.invalidResponse }
          imageURL = address
        }
        _ = try await store.api.request("member/memberRoleSave", method: "POST", parameters: ["name": name, "gender": gender, "intro": intro, "role_setting": setting, "open_remark": opening, "img_url": imageURL, "is_caogao": "0", "adv_setting": publicRole ? "open" : "close", "role_category": category, "tag": tags, "version": "1"], json: true)
        UserDefaults.standard.removeObject(forKey: draftKey); try? FileManager.default.removeItem(at: draftImageURL)
        dismiss()
      } catch { saveDraft(); self.error = error.localizedDescription }
    }
  }
}
