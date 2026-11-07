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
    NavigationStack { QQPage(title: "邮箱绑定", headerHeight: 46) {
      VStack(spacing: 0) {
        ScrollView {
          VStack(spacing: 10) {
            QQFieldCard(title: "邮箱号*") {
              TextField("请输入您的邮箱号", text: $email).keyboardType(.emailAddress).textContentType(.emailAddress)
                .textInputAutocapitalization(.never).autocorrectionDisabled().font(.system(size: 14))
                .padding(.horizontal, 13).frame(height: 50).background(Color(white: 242.0/255), in: RoundedRectangle(cornerRadius: 15))
            }
            QQFieldCard(title: "邮箱验证码*") {
              HStack(spacing: 4) {
                TextField("请输入您的验证码", text: $code).keyboardType(.numberPad).textContentType(.oneTimeCode).font(.system(size: 14))
                  .onChange(of: code) { _, value in code = String(value.filter { $0.isASCII && $0.isNumber }.prefix(6)) }
                TimelineView(.periodic(from: .now, by: 1)) { context in
                  let remaining = max(0, Int(ceil(nextCodeTime.timeIntervalSince(context.date))))
                  Button(remaining > 0 ? "\(remaining)s" : "发送验证码") { sendCode() }.font(.system(size: 12))
                    .foregroundStyle(remaining > 0 ? .cyan : QQStyle.ink).disabled(remaining > 0 || busy)
                }
              }.padding(.horizontal, 13).frame(height: 50).background(Color(white: 242.0/255), in: RoundedRectangle(cornerRadius: 15))
            }
            if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red).padding(.top, 12) }
          }.padding(.horizontal, 15).padding(.top, 30)
        }
        VStack(spacing: 15) {
          if !store.loggedIn { Button("游客登录") { guestLogin() }.font(.system(size: 14)).foregroundStyle(.gray).frame(height: 36).disabled(busy || !accepted) }
          QQPrimaryButton(title: "绑定", busy: busy) { login() }.disabled(email.isEmpty || code.count != 6 || !accepted)
          HStack(spacing: 3) {
            Button { accepted.toggle() } label: { Image(systemName: accepted ? "checkmark.circle.fill" : "circle").font(.system(size: 18)).foregroundStyle(accepted ? .cyan : Color(white: 0.86)).frame(width: 20, height: 20) }.accessibilityLabel("同意隐私政策与用户协议").accessibilityValue(accepted ? "已勾选" : "未勾选")
            Text("我已阅读并同意").foregroundStyle(Color(white: 145.0/255))
            NavigationLink { QQServiceDocumentView(title: "隐私政策") } label: { Text("《隐私政策》") }
            Text("与").foregroundStyle(Color(white: 145.0/255))
            NavigationLink { QQServiceDocumentView(title: "用户协议") } label: { Text("《用户协议》") }
          }.font(.system(size: 12)).minimumScaleFactor(0.85)
        }.padding(.horizontal, 15).padding(.bottom, 20)
      }
    } }
  }
  private func sendCode() {
    guard email.contains("@") else { error = "请输入有效的邮箱号"; return }
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

struct QQMineView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var invitation: QQValue = .null
  @State private var quota: QQValue = .null
  @State private var copied = false
  @State private var inviteRules = false
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        HStack(spacing: 20) {
          Spacer()
          NavigationLink { QQProfileView() } label: { QQArtwork(name: "mine_ico_edit").frame(width: 24, height: 24) }.accessibilityLabel("编辑资料")
          NavigationLink { QQSettingsView() } label: { QQArtwork(name: "mine_ico_set").frame(width: 24, height: 24) }.accessibilityLabel("设置")
        }.frame(height: 48)
        profile
        Text(store.user?["sign"].isEmpty == false ? store.user!["sign"] : "这个人很懒，什么也没留下～").font(.system(size: 12)).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
        NavigationLink { QQMemberView(initialTab: memberState == 3 ? 1 : 0) } label: { QQMineMemberCard(user: store.user) }.padding(.top, 20)
        HStack(spacing: 8) {
          VStack(alignment: .leading, spacing: 13) {
            Button { inviteRules = true } label: { HStack(spacing: 4) { Text("邀请有奖").font(.system(size: 15)); QQArtwork(name: "mine_ico_question").frame(width: 14, height: 14); Spacer() } }
            NavigationLink { QQAPIListView(title: "我邀请的好友", path: "member/getInviteList", requiresLogin: true) } label: { HStack(spacing: 0) { Text("已邀好友："); Text(invitation["invite_total"].text.isEmpty ? "0" : invitation["invite_total"].text); QQArtwork(name: "mine_ico_next").frame(width: 12, height: 12) }.font(.system(size: 12)) }
          }.padding(.horizontal, 19).frame(maxWidth: .infinity, alignment: .leading).frame(height: 80).background { Image("qq_mine_pic_background02").resizable() }
          NavigationLink { QQMemberView(initialTab: 1) } label: {
            VStack(alignment: .leading, spacing: 5) { Text("剩余钻石").font(.system(size: 15)); Text(store.user?["coin"] ?? "0").font(.system(size: 18)) }.foregroundStyle(Color(red: 227.0/255, green: 62.0/255, blue: 204.0/255)).padding(.horizontal, 19).frame(maxWidth: .infinity, alignment: .leading).frame(height: 80).background { Image("qq_mine_pic_background03").resizable() }
          }
        }.padding(.top, 10)
        Text("智能体（" + (quota["count"].text.isEmpty ? "0" : quota["count"].text) + "）").font(.system(size: 15, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading).frame(height: 66)
        Button { store.requireLogin { store.creatorPresented = true } } label: {
          VStack(spacing: 7) { QQArtwork(name: "mine_ico_add").frame(width: 20, height: 20); Text("免费创建我的角色").font(.system(size: 14)) }.frame(maxWidth: .infinity).frame(height: 74)
            .overlay { RoundedRectangle(cornerRadius: 20).stroke(Color(white: 0.8), style: StrokeStyle(lineWidth: 3, dash: [4, 4])) }
            .overlay(alignment: .topTrailing) { if !quota["max"].text.isEmpty { Text(quota["count"].text + "/" + quota["max"].text).font(.system(size: 10)).padding(.horizontal, 8).frame(height: 18).background(Color(red: 1, green: 0.74, blue: 0.94), in: Capsule()).offset(y: -8) } }
        }
        if store.loggedIn { QQOwnedRolesView().padding(.top, 15) }
        if copied { Text("已复制").font(.system(size: 12)).padding(10) }
      }.padding(.horizontal, 15).padding(.bottom, 20)
    }.background(alignment: .top) { Image("qq_mine_pic_background").resizable().scaledToFit().ignoresSafeArea(edges: .top) }.background(.white).buttonStyle(.plain)
      .sheet(isPresented: $inviteRules) { QQInviteRulesView().presentationDetents([.large]).presentationDragIndicator(.hidden).presentationCornerRadius(22) }
      .task(id: store.loggedIn) {
        guard store.loggedIn else { return }
        await store.refreshUser()
        invitation = (try? await store.api.request("member/getInvite")) ?? .null
        quota = (try? await store.api.request("ai/getMemberRoleCount")) ?? .null
      }
  }
  private var memberState: Int { Int(store.user?["member_show_status"] ?? "0") ?? 0 }
  private var profile: some View {
    HStack(spacing: 13) {
      NavigationLink { QQProfileView() } label: {
        Group { if let address = store.user?["head_img"], !address.isEmpty { QQRemoteImage(address: address) } else { QQArtwork(name: "wd_tx") } }.frame(width: 66, height: 66).clipShape(Circle()).overlay { Circle().stroke(.white, lineWidth: 2) }
      }
      VStack(alignment: .leading, spacing: 8) {
        if store.loggedIn { NavigationLink { QQProfileView() } label: { Text(store.user?.first("nick", "name") ?? "小伙伴").font(.system(size: 16, weight: .bold)) } }
        else { Button("小伙伴，点我登录") { store.loginPresented = true }.font(.system(size: 16, weight: .bold)) }
        if let user = store.user { Button { UIPasteboard.general.string = user.id; copied = true } label: { HStack(spacing: 5) { Text("ID:" + user.id); QQArtwork(name: "mine_ico_copy").frame(width: 12, height: 12) }.font(.system(size: 12)).foregroundStyle(.gray) } }
        HStack(spacing: 10) {
          NavigationLink { QQAPIListView(title: "聊过", path: "ai/roleList", requiresLogin: true) } label: { stat("聊过", value: store.user?["role_count"] ?? "0", icon: "mine_ico_chat") }
          NavigationLink { QQAPIListView(title: "关注", path: "member/followList", parameters: ["page": "1", "pageSize": "20"], requiresLogin: true) } label: { stat("关注", value: store.user?["follow_count"] ?? "0", icon: "mine_ico_attention") }
        }
      }
      Spacer(minLength: 0)
      NavigationLink { QQSignInView() } label: { HStack(spacing: 4) { QQArtwork(name: "mine_ico_register").frame(width: 14, height: 14); Text("签到").font(.system(size: 12, weight: .bold)) }.padding(.horizontal, 10).frame(height: 26).background(Color(red: 1, green: 0.91, blue: 0.49), in: Capsule()) }
    }
  }
  private func stat(_ title: String, value: String, icon: String) -> some View { HStack(spacing: 3) { QQArtwork(name: icon).frame(width: 16, height: 16); Text(title); Text(value) }.font(.system(size: 12)) }
}

private struct QQMineMemberCard: View {
  let user: QQRecord?
  private var state: Int { Int(user?["member_show_status"] ?? "0") ?? 0 }
  private var trial: Bool { user?["vip_type"] == "1" }
  private var title: String { state == 3 ? "永久会员，钻石畅充" : state == 2 && trial ? "体验升级，特权不设限" : "专属会员，权益全开" }
  private var subtitle: String {
    if state == 3 { return "100年会员，尽享全部特权～" }
    if state == 2 { return (trial ? "体验" : "正式") + "会员到期：" + (user?["end_time"] ?? "") }
    return state == 1 ? "您的会员已过期～" : "您暂时还未开通会员～"
  }
  var body: some View {
    ZStack(alignment: .leading) {
      Image("qq_mine_pic_member_background").resizable()
      QQAnimatedAsset(name: "mine_pic_vip").frame(width: 87, height: 80)
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 8) { Text(title).font(.system(size: 15, weight: .bold)); Text(subtitle).font(.system(size: 12)).lineLimit(1).minimumScaleFactor(0.8) }.padding(.leading, 83)
        Spacer(minLength: 4)
        ZStack {
          Capsule().fill(LinearGradient(colors: state == 3 ? [.purple, .pink] : [.orange, Color(red: 0.98, green: 0.37, blue: 0.24)], startPoint: .leading, endPoint: .trailing))
          QQAnimatedAsset(name: state == 3 ? "tv_normal_button_bg_forver" : state == 2 && !trial ? "tv_normal_button_bg_vip" : "tv_normal_button_bg_trial")
          HStack(spacing: 1) { Text(state == 3 ? "钻石充值" : state == 2 ? "立即续费" : state == 1 ? "重新开通" : "立即开通"); QQArtwork(name: "mine_ico_next").frame(width: 6, height: 8) }.font(.system(size: 12)).foregroundStyle(.white)
        }.frame(width: 75, height: 30).padding(.trailing, 13)
      }
    }.frame(height: 80).clipShape(RoundedRectangle(cornerRadius: 15))
  }
}

private struct QQOwnedRolesView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var records: [QQRecord] = []
  @State private var error: String?
  var body: some View {
    VStack {
      if let error { Text(error).font(.system(size: 13)).foregroundStyle(.secondary) }
      else if records.isEmpty { EmptyView() }
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
      HStack(spacing: 15) {
        ForEach(0..<2) { index in Button { section = index } label: { VStack(spacing: 3) { QQArtwork(name: index == 0 ? (section == 0 ? "chat_ico_msg2" : "chat_ico_msg1") : (section == 1 ? "chat_ico_follow2" : "chat_ico_follow1")).frame(width: 34, height: 20); Capsule().fill(section == index ? .cyan : .clear).frame(width: 12, height: 4) } }.accessibilityLabel(index == 0 ? "消息" : "关注") }
        Spacer()
        NavigationLink { QQMemberView() } label: { QQArtwork(name: "home_ico_vip").frame(width: 30, height: 30) }.accessibilityLabel("会员中心")
      }.padding(.leading, 20).padding(.trailing, 10).frame(height: 50)
      QQAPIListView(title: "", path: section == 0 ? "ai/roleList" : "member/followList", parameters: section == 0 ? [:] : ["page": "1", "pageSize": "20"], requiresLogin: true, embedded: true).id(section)
    }.background(.white).buttonStyle(.plain)
  }
}

struct QQCreatorView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @State private var name = ""
  @State private var gender = "男"
  @State private var intro = ""
  @State private var setting = ""
  @State private var opening = ""
  @State private var category = ""
  @State private var tags = ""
  @State private var roleConfiguration: QQValue = .null
  @State private var publicRole = false
  @State private var photo: PhotosPickerItem?
  @State private var imageData: Data?
  @State private var imageURL = ""
  @State private var busy = false
  @State private var error: String?
  @State private var notice = false
  private let draftKey = "qingqing.roleDraft.v1"
  @State private var tagPicker = false
  @State private var noticeBanner = true
  @State private var confirmExit = false
  private var completedFields: Int { [imageData != nil || !imageURL.isEmpty, !name.isEmpty, !gender.isEmpty, !intro.isEmpty, !setting.isEmpty, !opening.isEmpty, !category.isEmpty, !tags.isEmpty, true].filter { $0 }.count }
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 8) {
        Button { confirmExit = true } label: { Image(systemName: "xmark").font(.system(size: 22)).frame(width: 45, height: 50) }.accessibilityLabel("关闭")
        Spacer()
        Button("保存草稿") { saveDraft(); dismiss() }.font(.system(size: 12, weight: .bold)).padding(.horizontal, 10).frame(height: 30).background(Color(white: 0.92), in: Capsule())
        Button(busy ? "创建中" : "创建（\(completedFields)/9）") { publish() }.font(.system(size: 12, weight: .bold)).padding(.horizontal, 10).frame(height: 30).background(QQStyle.gradient, in: Capsule()).opacity(completedFields == 9 ? 1 : 0.2).disabled(completedFields < 9 || busy)
      }.padding(.trailing, 17)
      ScrollView {
        VStack(spacing: 10) {
          if noticeBanner {
            HStack { Image(systemName: "doc.text").foregroundStyle(.red).padding(7).background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8)); Text("创作者须知").font(.system(size: 16, weight: .bold)); Spacer(); Button { notice = true } label: { Text("查看 ›").font(.system(size: 12, weight: .bold)).padding(.horizontal, 10).frame(height: 28).background(.white.opacity(0.7), in: Capsule()) } }.padding(.horizontal, 16).frame(height: 60).background(.red.opacity(0.04), in: RoundedRectangle(cornerRadius: 22)).overlay(alignment: .topTrailing) { Button { noticeBanner = false } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.gray.opacity(0.3)).frame(width: 22, height: 22) } }
          }
          VStack(alignment: .leading, spacing: 16) {
            Text("角色形象*").font(.system(size: 16, weight: .bold))
            PhotosPicker(selection: $photo, matching: .images) {
              ZStack {
                Color(white: 0.96)
                if let imageData, let image = UIImage(data: imageData) { Image(uiImage: image).resizable().scaledToFill() }
                else if !imageURL.isEmpty { QQRemoteImage(address: imageURL) }
                else { Image(systemName: "plus").font(.system(size: 24, weight: .bold)).foregroundStyle(Color(white: 0.78)) }
              }.frame(width: 100, height: 136).clipped().clipShape(RoundedRectangle(cornerRadius: 15))
            }
            Text("图片分辨率建议576*1024（9：16）以上").font(.system(size: 12)).foregroundStyle(Color(white: 0.8))
          }.frame(maxWidth: .infinity, alignment: .leading).padding(16).padding(.vertical, 4).background(.white, in: RoundedRectangle(cornerRadius: 22))
          HStack(spacing: 14) { Text("名称*").font(.system(size: 16, weight: .bold)); Divider().frame(height: 16); TextField("为角色命名", text: $name).font(.system(size: 16)); Text("\(name.count)/7").font(.system(size: 13)).foregroundStyle(Color(white: 0.8)) }.padding(.horizontal, 16).frame(height: 64).background(.white, in: RoundedRectangle(cornerRadius: 22)).onChange(of: name) { _, value in name = String(value.prefix(7)) }
          VStack(alignment: .leading, spacing: 16) {
            Text("性别*").font(.system(size: 16, weight: .bold))
            HStack(spacing: 8) { ForEach(["男", "女", "其他"], id: \.self) { item in Button { gender = item } label: { Text(item == "男" ? "男性" : item == "女" ? "女性" : item).font(.system(size: 14, weight: .bold)).foregroundStyle(gender == item ? genderColor(item) : QQStyle.ink).frame(maxWidth: .infinity).frame(height: 42).overlay { Capsule().stroke(gender == item ? genderColor(item) : Color(white: 0.96), lineWidth: 3) } } } }
          }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22))
          editor("对外简介*", subtitle: "（不影响对话效果）", text: $intro, limit: 5000)
          editor("角色设定*", subtitle: "（决定回复效果）", text: $setting, limit: 5000)
          editor("开场白*", subtitle: "", text: $opening, limit: 500)
          VStack(alignment: .leading, spacing: 16) { fieldTitle("人物分类 *", count: category.components(separatedBy: ",").filter { !$0.isEmpty }.count, limit: 3); chips(roleConfiguration["role_category"].list.map(\.text), selection: $category, limit: 3) }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22))
          VStack(alignment: .leading, spacing: 16) {
            fieldTitle("人物标签 *", count: tags.components(separatedBy: ",").filter { !$0.isEmpty }.count, limit: 5)
            if !tags.isEmpty { Text(tags.replacingOccurrences(of: ",", with: "   ")).font(.system(size: 14)) }
            Button { tagPicker = true } label: { Text("＋添加").font(.system(size: 14, weight: .bold)).foregroundStyle(Color(white: 0.75)).padding(.horizontal, 12).frame(height: 38).overlay { Capsule().stroke(Color(white: 0.8), style: StrokeStyle(lineWidth: 2, dash: [4, 4])) } }
          }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22))
          VStack(alignment: .leading, spacing: 16) {
            Text("角色可见范围*").font(.system(size: 16, weight: .bold))
            HStack(spacing: 10) { visibilityOption("公开", value: true); visibilityOption("隐身", value: false) }
            Text(publicRole ? "公开的角色会展示给其他用户，提交后需经过审核。" : "仅自己可见，其他用户无法查看此角色。").font(.system(size: 12)).foregroundStyle(.gray)
          }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22))
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        }.padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 30)
      }
    }.background(QQStyle.background).toolbar(.hidden, for: .navigationBar).buttonStyle(.plain)
      .task {
        restoreDraft()
        noticeBanner = !UserDefaults.standard.bool(forKey: "qingqing.creator.hideNotice")
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
      .sheet(isPresented: $notice) { QQCreatorNoticeView().presentationDetents([.height(570), .large]).presentationCornerRadius(30).presentationDragIndicator(.hidden) }
      .sheet(isPresented: $tagPicker) { NavigationStack { QQTagSelectionView(selection: $tags, configuration: roleConfiguration) }.presentationDetents([.fraction(0.85), .large]).presentationCornerRadius(30).presentationDragIndicator(.hidden) }
      .interactiveDismissDisabled()
      .overlay {
        if confirmExit {
          ZStack {
            Color.black.opacity(0.5).ignoresSafeArea().onTapGesture { confirmExit = false }
            VStack(spacing: 20) {
              Text("是否存为草稿").font(.system(size: 18, weight: .bold))
              QQPrimaryButton(title: "保存并退出") { saveDraft(); dismiss() }
              Button("不保存") { dismiss() }.font(.system(size: 14)).foregroundStyle(.gray)
            }.padding(30).frame(width: 300).background(.white, in: RoundedRectangle(cornerRadius: 30))
          }
        }
      }
  }
  private func genderColor(_ value: String) -> Color { value == "男" ? .cyan : value == "女" ? .pink : .orange }
  private func visibilityOption(_ title: String, value: Bool) -> some View { Button { publicRole = value } label: { Text(title).font(.system(size: 14, weight: .bold)).foregroundStyle(publicRole == value ? .cyan : QQStyle.ink).frame(maxWidth: .infinity).frame(height: 42).overlay { Capsule().stroke(publicRole == value ? .cyan : Color(white: 0.95), lineWidth: 3) } } }

  private func fieldTitle(_ title: String, count: Int, limit: Int) -> some View { HStack { Text(title).font(.system(size: 16, weight: .semibold)); Spacer(); Text("\(count)/\(limit)").font(.system(size: 12)).foregroundStyle(.secondary) } }
  private func chips(_ options: [String], selection: Binding<String>, limit: Int) -> some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
      ForEach(options.reduce(into: [String]()) { if !$0.contains($1) { $0.append($1) } }, id: \.self) { option in
        let selected = selection.wrappedValue.components(separatedBy: ",").contains(option)
        Button {
          var values = selection.wrappedValue.components(separatedBy: ",").filter { !$0.isEmpty }
          if selected { values.removeAll { $0 == option } } else if values.count < limit { values.append(option) }
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
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 4) { Text(title).font(.system(size: 16, weight: .bold)); Text(subtitle).font(.system(size: 13)); Spacer(minLength: 0); Text("\(text.wrappedValue.count)/\(limit)").font(.system(size: 12)).foregroundStyle(Color(white: 0.8)) }
      ZStack(alignment: .topLeading) {
        TextEditor(text: text).font(.system(size: 14)).padding(8).scrollContentBackground(.hidden)
        if text.wrappedValue.isEmpty { Text(title == "开场白*" ? "会作为该设定下TA的第一句话开启聊天" : title == "角色设定*" ? "角色的性格、身份、说话风格、跟用户的关系等，请用“用户”来称呼与角色对话的人" : "在此处输入作者想说的话，及需要其他用户了解的智能体专属设定的信息，如背景、身份、人设、与用户的关系等。").font(.system(size: 14)).foregroundStyle(Color(white: 0.78)).lineSpacing(5).padding(14).allowsHitTesting(false) }
      }.frame(height: title == "开场白*" ? 80 : 100).background(Color(white: 0.97), in: RoundedRectangle(cornerRadius: 15))
      if title != "开场白*" { Text(title == "角色设定*" ? "决定智能体的对话效果，不对其他人展示" : "不影响对话效果，仅用于其他用户了解角色").font(.system(size: 12)).foregroundStyle(Color(white: 0.8)).lineLimit(1) }
    }.padding(16).padding(.vertical, 4).background(.white, in: RoundedRectangle(cornerRadius: 22)).onChange(of: text.wrappedValue) { _, value in text.wrappedValue = String(value.prefix(limit)) }
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
    name = draft["name"] ?? ""; gender = draft["gender"] ?? "男"; intro = draft["intro"] ?? ""; setting = draft["role_setting"] ?? ""; opening = draft["open_remark"] ?? ""; imageURL = draft["img_url"] ?? ""; publicRole = draft["public"] == "1"
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
