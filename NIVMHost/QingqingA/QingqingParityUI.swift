import SwiftUI
import PhotosUI

// Measurements and artwork follow the 1.5.5 Android layouts. Native safe areas
// replace Android's added status-bar inset; content dimensions remain in points.
struct QQPage<Content: View>: View {
  @Environment(\.dismiss) private var dismiss
  let title: String
  var color = Color(white: 245.0 / 255)
  var headerHeight: CGFloat = 50
  var backgroundArtwork: String? = nil
  var artworkHeight: CGFloat = 250
  var closeOnRight = false
  @ViewBuilder let content: () -> Content
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Text(title).font(.system(size: 18, weight: .bold)).lineLimit(1).truncationMode(.tail).padding(.horizontal, 54).frame(maxWidth: .infinity)
        HStack {
          if closeOnRight { Spacer() }
          Button { dismiss() } label: { QQArtwork(name: closeOnRight ? "pop_ico_close" : "ico_back").frame(width: closeOnRight ? 18 : 24, height: closeOnRight ? 18 : 24).frame(width: 50, height: 50) }.accessibilityLabel(closeOnRight ? "关闭" : "返回")
          if !closeOnRight { Spacer() }
        }
      }.frame(height: headerHeight).zIndex(1)
      content().frame(maxWidth: .infinity, maxHeight: .infinity).clipped().contentShape(Rectangle())
    }.foregroundStyle(QQStyle.ink).background(alignment: .top) { if let backgroundArtwork { Image("qq_" + backgroundArtwork).resizable().frame(height: artworkHeight).ignoresSafeArea(edges: .top) } }.background(color.ignoresSafeArea())
      .toolbar(.hidden, for: .navigationBar).buttonStyle(.plain)
  }
}

struct QQSettingRow: View {
  let title: String
  var icon: String? = nil
  var value = ""
  var showsChevron = true
  var body: some View {
    HStack(spacing: 10) {
      if let icon { QQArtwork(name: icon).frame(width: 20, height: 20) }
      Text(title).font(.system(size: 14, weight: .bold))
      Spacer(minLength: 8)
      Text(value).font(.system(size: 14)).foregroundStyle(Color(white: 0.6)).lineLimit(1)
      if showsChevron { QQArtwork(name: "ico_setting_next").frame(width: 16, height: 16) }
    }.padding(.horizontal, 15).frame(height: 50).contentShape(Rectangle())
  }
}

struct QQFieldCard<Content: View>: View {
  let title: String
  @ViewBuilder let content: () -> Content
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title).font(.system(size: 16, weight: .bold))
      content()
    }.padding(.horizontal, 15).padding(.vertical, 20).frame(height: 122)
      .background(.white, in: RoundedRectangle(cornerRadius: 22))
  }
}

struct QQAboutView: View {
  @State private var document: String?
  var body: some View {
    QQPage(title: "关于我们") {
      VStack(spacing: 0) {
        QQArtwork(name: "res_logo").frame(width: 70, height: 70).padding(.top, 43)
        Text("卿卿我我AI").font(.system(size: 15, weight: .bold)).padding(.top, 13)
        Text("v" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")).font(.system(size: 12)).foregroundStyle(.gray).padding(.top, 8)
        VStack(spacing: 0) {
          ForEach(["用户协议", "隐私政策"], id: \.self) { title in Button { document = title } label: { HStack { Text(title).font(.system(size: 14)); Spacer(); QQArtwork(name: "ico_setting_next").frame(width: 16, height: 16) }.padding(.horizontal, 15).frame(height: 63) } }
        }.background(.white, in: RoundedRectangle(cornerRadius: 22)).padding(.horizontal, 15).padding(.top, 25)
        Spacer()
      }
    }.sheet(item: Binding(get: { document.map(QQDocumentChoice.init) }, set: { document = $0?.id })) { selection in QQServiceDocumentView(title: selection.id) }
  }
}

struct QQDocumentChoice: Identifiable { let id: String }
struct QQServiceDocumentView: View {
  let title: String
  @EnvironmentObject private var store: QingqingStore
  @State private var url: URL?
  @State private var failure: String?
  var body: some View {
    QQPage(title: title) {
      Group {
        if let url { QQSafariView(url: url) }
        else if let failure { QQEmptyState(text: failure) }
        else { ProgressView() }
      }
    }.task {
      url = store.api.documentURL(privacy: title == "隐私政策")
      if url == nil { failure = "服务协议链接暂不可用" }
    }
  }
}

struct QQInvitationCodeView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var code = ""
  @State private var info: QQValue = .null
  @State private var busy = false
  @State private var result: String?
  var body: some View {
    QQPage(title: "", color: Color(red: 248.0/255, green: 245.0/255, blue: 1), backgroundArtwork: "invite_pic_banner2", artworkHeight: 300) {
      ScrollView {
        VStack(spacing: 0) {
          Text("填写邀请码").font(.system(size: 24, weight: .bold)).padding(.top, 164)
          HStack(spacing: 0) { Text("输入邀请码奖励"); Text(info["bind_reward"].text.replacingOccurrences(of: "钻石", with: "")); Text("个"); QQArtwork(name: "register_ico_diamond").frame(width: 15, height: 15); Text("（选填）") }.font(.system(size: 12)).foregroundStyle(.gray).padding(.top, 10)
          TextField("请输入邀请码", text: $code).font(.system(size: 14)).multilineTextAlignment(.center).textInputAutocapitalization(.never).autocorrectionDisabled()
            .frame(width: 280, height: 58).background(.white, in: RoundedRectangle(cornerRadius: 15)).padding(.top, 35)
          QQPrimaryButton(title: "确定", busy: busy) {
            store.requireLogin {
              busy = true
              Task { defer { busy = false }; do { _ = try await store.api.request("member/bindInvite", method: "POST", parameters: ["invite_code": code]); result = "绑定成功" } catch { result = error.localizedDescription } }
            }
          }.frame(width: 280).padding(.top, 30).disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)
          if let result { Text(result).font(.system(size: 13)).padding(20) }
        }.frame(maxWidth: .infinity).padding(.bottom, 30)
      }
    }.task { info = (try? await store.api.request("member/getInvite")) ?? .null }
  }
}

@MainActor
struct QQProfileView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @State private var nick = ""
  @State private var sign = ""
  @State private var preferences: Set<Int> = []
  @State private var photo: PhotosPickerItem?
  @State private var imageData: Data?
  @State private var busy = false
  @State private var error: String?
  var body: some View {
    QQPage(title: "编辑资料", color: Color(white: 248.0/255)) {
      VStack(spacing: 0) {
        ScrollView {
          VStack(spacing: 0) {
            avatarPicker
            nicknameField.padding(.top, 25)
            introductionField.padding(.top, 10)
            Text("角色偏好推荐").font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 20)
            preferenceOptions.padding(.top, 15)
            if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red).padding(10) }
          }.padding(.horizontal, 15).padding(.bottom, 25)
        }
        QQPrimaryButton(title: "确认", busy: busy) { save() }.disabled(nick.trimmingCharacters(in: .whitespaces).isEmpty).padding(.horizontal, 15).padding(.top, 10).padding(.bottom, 20)
      }
    }.onChange(of: nick) { _, value in nick = String(value.prefix(10)) }.onChange(of: sign) { _, value in sign = String(value.prefix(200)) }
      .onChange(of: photo) { _, value in Task { guard let value else { return }; if let raw = try? await value.loadTransferable(type: Data.self), let image = UIImage(data: raw), let jpeg = image.jpegData(compressionQuality: 0.8), jpeg.count <= 8_000_000 { imageData = jpeg } else { error = "请选择小于 8MB 的图片" } } }
      .task { nick = store.user?["nick"] ?? ""; sign = store.user?["sign"] ?? ""; for (i, key) in ["tj_boy", "tj_girl", "tj_other"].enumerated() where store.user?[key] == "1" { preferences.insert(i) } }
  }
  private var avatarPicker: some View {
    let selectedImage = imageData.flatMap { UIImage(data: $0) }
    let avatarAddress = store.user?.first("head_img", "avatar") ?? ""
    return PhotosPicker(selection: $photo, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
              Group {
                if let selectedImage { Image(uiImage: selectedImage).resizable().scaledToFill() }
                else if !avatarAddress.isEmpty { QQRemoteImage(address: avatarAddress) }
                else { QQArtwork(name: "wd_tx") }
              }.frame(width: 100, height: 100).clipShape(Circle())
              QQArtwork(name: "profile_ico_camear").frame(width: 25, height: 25)
            }
          }.padding(.top, 28)
  }
  private var nicknameField: some View {
          HStack(spacing: 15) { Text("昵称").font(.system(size: 16, weight: .bold)); TextField("可爱小泥鳅", text: $nick); Text("\(nick.count)/10").foregroundStyle(.gray).font(.system(size: 12)) }.font(.system(size: 14)).padding(.horizontal, 15).frame(height: 56).background(.white, in: RoundedRectangle(cornerRadius: 22))
  }
  private var introductionField: some View {
          VStack(alignment: .leading, spacing: 16) {
            Text("个人简介").font(.system(size: 16, weight: .bold))
            ZStack(alignment: .bottomTrailing) {
              TextEditor(text: $sign).font(.system(size: 14)).scrollContentBackground(.hidden).frame(height: 107).padding(.horizontal, 8).background(Color(white: 248.0/255), in: RoundedRectangle(cornerRadius: 15))
              if sign.isEmpty { Text("请输入个人简介").font(.system(size: 14)).foregroundStyle(.gray.opacity(0.5)).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(13).allowsHitTesting(false) }
              Text("\(sign.count)/200").font(.system(size: 12)).foregroundStyle(.gray).padding(.trailing, 10).padding(.bottom, 6)
            }
          }.padding(.horizontal, 15).padding(.vertical, 20).frame(height: 182).background(.white, in: RoundedRectangle(cornerRadius: 22))
  }
  private var preferenceOptions: some View {
          VStack(spacing: 10) {
            ForEach(0..<3) { index in
              Button { if preferences.contains(index) { preferences.remove(index) } else { preferences.insert(index) } } label: {
                HStack(spacing: 16) {
                  QQArtwork(name: ["profile_pic_man", "profile_pic_women", "profile_pic_else"][index]).frame(width: 90, height: 90)
                  Text(["男生", "女生", "所有人"][index]).font(.system(size: 18, weight: .bold)); Spacer()
                  Image(systemName: preferences.contains(index) ? "checkmark.circle.fill" : "circle").font(.system(size: 18)).foregroundStyle(preferences.contains(index) ? .cyan : Color(white: 0.88))
                }.padding(.horizontal, 15).frame(height: 120).background(.white, in: RoundedRectangle(cornerRadius: 22))
              }
            }
          }
  }
  private func save() {
    busy = true; error = nil
    Task {
      defer { busy = false }
      do {
        var image = store.user?["head_img"] ?? ""
        if let imageData { let uploaded = try await store.api.request("feedback/upload", method: "POST", parameters: ["file": "data:image/jpeg;base64," + imageData.base64EncodedString()], json: true)
          guard let address = uploaded.list.first?.text, URL(string: address)?.scheme == "https" else { throw QQAPIError.invalidResponse }
          image = address }
        _ = try await store.api.request("member/setInfo", method: "POST", parameters: ["nick": nick, "sign": sign, "head_img": image, "tj_boy": preferences.contains(0) ? "1" : "0", "tj_girl": preferences.contains(1) ? "1" : "0", "tj_other": preferences.contains(2) ? "1" : "0"], json: true)
        await store.refreshUser(); dismiss()
      } catch { self.error = error.localizedDescription }
    }
  }
}

struct QQSettingsView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var logout = false
  @State private var boundInviteCode = ""
  @State private var toast: String?
  var body: some View {
    QQPage(title: "设置") {
      VStack(spacing: 0) {
        ScrollView {
          VStack(spacing: 0) {
            QQArtwork(name: "res_logo").frame(width: 100, height: 100).padding(.top, 28)
            Text("卿卿我我AI").font(.system(size: 18, weight: .bold)).tracking(1.26).padding(.top, 16)
            Text("v" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")).font(.system(size: 12)).foregroundStyle(Color(white: 0.6)).padding(.top, 6)
            VStack(spacing: 0) {
              Button { store.loginPresented = true } label: { QQSettingRow(title: "邮箱号", icon: "set_ico_faction01", value: store.user?["email"] ?? "") }
              NavigationLink { QQInvitationCodeView() } label: { QQSettingRow(title: "填写邀请码", icon: "set_ico_faction02", value: boundInviteCode.isEmpty ? "未填写" : boundInviteCode, showsChevron: boundInviteCode.isEmpty) }.disabled(!boundInviteCode.isEmpty)
              Button { URLCache.shared.removeAllCachedResponses(); toast = "缓存已清除" } label: { QQSettingRow(title: "清除缓存", icon: "set_ico_faction03", value: ByteCountFormatter.string(fromByteCount: Int64(URLCache.shared.currentDiskUsage), countStyle: .file)) }
              NavigationLink { QQFeedbackView() } label: { QQSettingRow(title: "意见反馈", icon: "set_ico_faction04") }
              NavigationLink { QQAboutView() } label: { QQSettingRow(title: "关于我们", icon: "set_ico_faction05") }
              NavigationLink { QQCancellationView() } label: { QQSettingRow(title: "注销帐号", icon: "set_ico_faction06") }
              Button { toast = "当前版本：TianyaBox " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0") } label: { QQSettingRow(title: "版本更新", icon: "set_ico_faction07") }
            }.padding(.top, 25)
          }
        }
        Button(store.loggedIn ? "退出登录" : "登录账号") { if store.loggedIn { logout = true } else { store.loginPresented = true } }
          .font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity).frame(height: 56).background(.white, in: Capsule()).padding(.horizontal, 15).padding(.bottom, 30)
      }
    }.task { if store.loggedIn, let info = try? await store.api.request("member/getInvite") { boundInviteCode = info["invite_code"].text } }
      .confirmationDialog("确认退出当前账号？", isPresented: $logout, titleVisibility: .visible) { Button("退出登录", role: .destructive) { Task { await store.logout() } } }
      .alert("提示", isPresented: Binding(get: { toast != nil }, set: { if !$0 { toast = nil } })) { Button("知道了") { toast = nil } } message: { Text(toast ?? "") }
  }
}

struct QQFeedbackView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var text = ""
  @State private var contact = ""
  @State private var photos: [PhotosPickerItem] = []
  @State private var images: [Data] = []
  @State private var busy = false
  @State private var result: String?
  var body: some View {
    QQPage(title: "意见反馈") {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text("感谢您使用 卿卿我我AI").font(.system(size: 18, weight: .bold)).padding(.top, 15)
          Text("您的体验对我们至关重要，欢迎在此留下您的意见或问题。我们的团队会尽快通过电邮回复您。").font(.system(size: 13)).foregroundStyle(.gray).lineSpacing(5).padding(.top, 5)
          Text("联系方式*").font(.system(size: 16, weight: .bold)).padding(.top, 4)
          TextField("请输入您的手机号码", text: $contact).font(.system(size: 14)).textInputAutocapitalization(.never).padding(.horizontal, 13).frame(height: 50).background(.white, in: RoundedRectangle(cornerRadius: 15))
          Text("反馈内容*").font(.system(size: 16, weight: .bold)).padding(.top, 4)
          ZStack(alignment: .bottomTrailing) {
            TextEditor(text: $text).font(.system(size: 14)).scrollContentBackground(.hidden).padding(8).frame(height: 160).background(.white, in: RoundedRectangle(cornerRadius: 15))
            if text.isEmpty { Text("欢迎反馈宝贵意见").font(.system(size: 14)).foregroundStyle(.gray).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(13).allowsHitTesting(false) }
            Text("\(text.count)/200").font(.system(size: 12)).foregroundStyle(.gray).padding(13)
          }
          Text("屏幕截图*").font(.system(size: 16, weight: .bold))
          HStack(spacing: 10) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, data in
              if let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill().frame(width: 90, height: 90).clipped().clipShape(RoundedRectangle(cornerRadius: 12))
                  .overlay(alignment: .topTrailing) { Button { images.remove(at: index) } label: { QQArtwork(name: "set_ico_delete").frame(width: 18, height: 18) } }
              }
            }
            if images.count < 3 { PhotosPicker(selection: $photos, maxSelectionCount: 3 - images.count, matching: .images) { QQArtwork(name: "set_ico_add").frame(width: 30, height: 30).frame(width: 90, height: 90).background(.white, in: RoundedRectangle(cornerRadius: 12)) }.accessibilityLabel("添加屏幕截图") }
          }
          if let result { Text(result).font(.system(size: 13)).foregroundStyle(.secondary) }
          QQPrimaryButton(title: "确认提交", busy: busy) { submit() }.padding(.top, 30).disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contact.isEmpty)
        }.padding(.horizontal, 15).padding(.bottom, 30)
      }
    }.onChange(of: text) { _, value in text = String(value.prefix(200)) }.onChange(of: photos) { _, value in Task {
      for photo in value { if let raw = try? await photo.loadTransferable(type: Data.self), let image = UIImage(data: raw), let data = image.jpegData(compressionQuality: 0.8), data.count < 8_000_000, images.count < 3 { images.append(data) } }
      photos = []
    } }
  }
  private func submit() {
    busy = true; result = nil
    Task {
      defer { busy = false }
      do {
        let files = images.map { "data:image/jpeg;base64," + $0.base64EncodedString() }
        var parameters = ["content": text, "mobile": contact]
        if !files.isEmpty { parameters["file"] = String(data: try JSONEncoder().encode(files), encoding: .utf8) }
        _ = try await store.api.request("feedback/create", method: "POST", parameters: parameters, json: true)
        text = ""; images = []; result = "感谢您的反馈"
      } catch { result = error.localizedDescription }
    }
  }
}

struct QQCancellationView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var understood = false
  @State private var confirm = false
  @State private var error: String?
  var body: some View {
    QQPage(title: "注销账户") {
      VStack(spacing: 15) {
        ScrollView { Text("很遗憾我们无法继续为您服务，在您进一步提交账户注销申请之前，为避免非本人操作带来的损失，在注销之前需要人工进行审核。\n\n账号注销需要您提供以下信息用以验证，请您提前做好准备，点击“确认注销”发送给客服人员进行审核，审核通过后我们将对账户进行注销。\n\n1. 账号的常用登陆地点\n2. 账号绑定的账号或者手机号").font(.system(size: 14)).lineSpacing(5).frame(maxWidth: .infinity, alignment: .leading).padding(20).background(.white, in: RoundedRectangle(cornerRadius: 22)).padding(.top, 20) }
        if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        Button { understood.toggle() } label: { HStack(spacing: 8) { Image(systemName: understood ? "checkmark.circle.fill" : "circle"); Text("我已了解以上后果") }.font(.system(size: 12)).foregroundStyle(.gray) }
        QQPrimaryButton(title: "立即注销") { confirm = true }.disabled(!understood || !store.loggedIn).padding(.bottom, 38)
      }.padding(.horizontal, 15)
    }.alert("提交注销申请？", isPresented: $confirm) {
      Button("取消", role: .cancel) {}
      Button("确认注销", role: .destructive) { Task { do { _ = try await store.api.request("member/cancel"); store.api.setToken(""); store.user = nil; store.selectedTab = 0 } catch { self.error = error.localizedDescription } } }
    } message: { Text("提交后将由服务方审核，审核通过后注销。账号权益和数据可能无法恢复。") }
  }
}

struct QQSignInView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var calendar: QQValue = .null
  @State private var busy = false
  @State private var result: String?
  var body: some View {
    QQPage(title: "", backgroundArtwork: "register_pic_banner", artworkHeight: 250) {
      VStack(spacing: 0) {
        Color.clear.frame(height: 160)
        ScrollView {
          VStack(spacing: 20) {
            Text(calendar["month"].text).font(.system(size: 18)).padding(.top, 5)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
              ForEach(["周日", "周一", "周二", "周三", "周四", "周五", "周六"], id: \.self) { Text($0).font(.system(size: 12)).foregroundStyle(.gray).padding(.bottom, 12) }
              ForEach(Array(calendar["list"].list.enumerated()), id: \.offset) { _, day in
                calendarCell(day)
              }
            }
            if let result { Text(result).font(.system(size: 13)).foregroundStyle(.secondary) }
            Button {
              store.requireLogin {
                busy = true
                Task { defer { busy = false }; do { _ = try await store.api.request("member/sign"); result = "签到成功"; await load(); await store.refreshUser() } catch { result = error.localizedDescription } }
              }
            } label: { Text(todaySigned ? "今日已签到" : busy ? "签到中" : "立即签到").font(.system(size: 14, weight: .bold)).foregroundStyle(todaySigned ? QQStyle.ink.opacity(0.4) : .white).frame(maxWidth: .infinity).frame(height: 56).background(LinearGradient(colors: todaySigned ? [Color(white: 0.9)] : [Color(red: 254.0/255, green: 151.0/255, blue: 59.0/255), Color(red: 253.0/255, green: 76.0/255, blue: 123.0/255)], startPoint: .leading, endPoint: .trailing), in: Capsule()) }.disabled(busy || todaySigned || calendar.isNull).frame(width: 300).padding(.top, 20)
          }.padding(15).padding(.bottom, 30).frame(maxWidth: .infinity)
        }.background(.white, in: UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22))
      }
    }.task { await load() }
  }
  private var todaySigned: Bool { calendar["list"].list.first { $0["day"].text == calendar["today"].text }?["state"].text == "1" }
  @ViewBuilder private func calendarCell(_ day: QQValue) -> some View {
    let number = Int(day["day"].text)
    let today = Int(calendar["today"].text) ?? 0
    let signed = day["state"].text == "1"
    Group {
      if number == nil { Color.clear }
      else if number == today || signed {
        VStack(spacing: 4) {
          QQArtwork(name: "register_ico_diamond").frame(width: 22, height: 23).overlay { if signed { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white) } }.padding(.top, 4)
          Text(day["reward"].text).font(.system(size: 12, weight: .bold)).foregroundStyle(number == today ? Color(red: 205.0/255, green: 81.0/255, blue: 62.0/255) : .gray).frame(maxWidth: .infinity).frame(height: 16).background(number == today ? Color(red: 1, green: 214.0/255, blue: 196.0/255) : .clear)
        }.frame(width: 48, height: 48).background(number == today ? Color(red: 1, green: 243.0/255, blue: 1) : .clear, in: RoundedRectangle(cornerRadius: 8)).clipShape(RoundedRectangle(cornerRadius: 8)).overlay { if number == today { RoundedRectangle(cornerRadius: 8).stroke(.orange, lineWidth: 2) } }
      } else { Text(day["day"].text).font(.system(size: 16)).foregroundStyle((number ?? 0) < today ? Color(white: 205.0/255) : QQStyle.ink) }
    }.frame(height: 48)
  }
  private func load() async { do { calendar = try await store.api.request("member/signList") } catch { result = error.localizedDescription } }
}

struct QQIdentityView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  let role: QQRecord
  @State private var name = ""
  @State private var gender = ""
  @State private var setting = ""
  @State private var identity: QQValue = .null
  @State private var identityLoaded = false
  private var input: QQIdentityInput { QQIdentityInput(name: name, gender: gender) }
  @State private var busy = false
  @State private var error: String?
  var body: some View {
    QQPage(title: "我的身份设定") {
      VStack(spacing: 0) {
        ScrollView {
          VStack(spacing: 0) {
            QQRemoteImage(address: role.image).frame(width: 90, height: 90).clipShape(RoundedRectangle(cornerRadius: 16)).padding(.top, 20)
            Text(role.name).font(.system(size: 14)).padding(.top, 6)
            HStack(spacing: 16) { Text("名字*").fontWeight(.bold); Divider().frame(height: 16); TextField("角色将会用这个名字称呼你", text: $name) }.font(.system(size: 16)).padding(.horizontal, 16).frame(height: 64).background(.white, in: RoundedRectangle(cornerRadius: 22)).padding(.top, 30)
            VStack(alignment: .leading, spacing: 16) {
              Text("性别*").font(.system(size: 16, weight: .bold))
              HStack(spacing: 8) { ForEach(["男", "女", "其他"], id: \.self) { item in Button { gender = item } label: { Text(item == "男" ? "男性" : item == "女" ? "女性" : item).font(.system(size: 14, weight: .bold)).foregroundStyle(gender == item ? genderColor(item) : QQStyle.ink).frame(maxWidth: .infinity).frame(height: 42).overlay { Capsule().stroke(gender == item ? genderColor(item) : Color(white: 244.0/255), lineWidth: 3) } } } }
            }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22)).padding(.top, 10)
            VStack(spacing: 16) {
              HStack { Text("描述").font(.system(size: 16, weight: .bold)); Spacer(); Text("\(setting.count)/1000").font(.system(size: 14)).foregroundStyle(.gray.opacity(0.5)) }
              ZStack(alignment: .topLeading) {
                TextEditor(text: $setting).font(.system(size: 14)).scrollContentBackground(.hidden).padding(.horizontal, 8).padding(.top, 8).frame(height: 136)
                if setting.isEmpty { Text("可添加任何你希望角色永久记住的信息，如经历、关系、背景等…记得用'我'指代自己。").font(.system(size: 14)).foregroundStyle(.gray.opacity(0.5)).lineSpacing(3).padding(14).allowsHitTesting(false) }
              }.background(Color(white: 242.0/255), in: RoundedRectangle(cornerRadius: 15))
            }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22)).padding(.top, 10)
            if let error { VStack(spacing: 8) { Text(error).font(.system(size: 13)).foregroundStyle(.red); Button("重新加载") { Task { await loadIdentity() } }.font(.system(size: 13)) }.padding(10) }
          }.padding(.horizontal, 20).padding(.bottom, 20)
        }
        QQPrimaryButton(title: "提交", busy: busy) {
          guard identityLoaded, input.canSubmit else { return }
          busy = true
          Task { defer { busy = false }; do { _ = try await store.api.request("member/setRole", method: "POST", parameters: ["role_id": role.id, "id": identity["id"].text, "name": input.trimmedName, "gender": gender, "setting": setting, "background": identity["background"].text], json: true); dismiss() } catch { self.error = error.localizedDescription } }
        }.disabled(!identityLoaded || !input.canSubmit).padding(.horizontal, 20).padding(.bottom, 20)
      }
    }.task { await loadIdentity() }
      .onChange(of: setting) { _, value in setting = String(value.prefix(1000)) }
  }
  private func loadIdentity() async {
    identityLoaded = false; error = nil
    do {
      identity = try await store.api.request("member/getRoleSetting", method: "POST", parameters: ["role_id": role.id])
      name = identity["name"].text
      let savedGender = identity["gender"].text
      gender = savedGender.isEmpty ? "" : ["男", "女"].contains(savedGender) ? savedGender : "其他"
      setting = identity["setting"].text; identityLoaded = true
    } catch { self.error = error.localizedDescription }
  }
  private func genderColor(_ value: String) -> Color { value == "男" ? .cyan : value == "女" ? Color(red: 1, green: 131.0/255, blue: 249.0/255) : Color(red: 1, green: 184.0/255, blue: 107.0/255) }
}

struct QQModelSelectionView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @Binding var selection: String
  @State private var draft = ""
  @State private var busy = false
  @State private var error: String?
  @State private var questionsPresented = false
  var body: some View {
    QQPage(title: "对话模式") {
      ScrollView {
        VStack(spacing: 10) {
          ForEach(store.models) { model in
            Button { draft = model["code"] } label: {
              VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 5) { Text(model.name).font(.system(size: 16, weight: .bold)); Text(model["title"]).font(.system(size: 13)).lineLimit(1).minimumScaleFactor(0.8); Spacer(minLength: 0); if !model["price"].isEmpty && model["price"] != "0" { QQArtwork(name: "register_ico_diamond").frame(width: 15, height: 15); Text(model["price"]).font(.system(size: 14, weight: .bold)) } }
                Text(model["info"]).font(.system(size: 13)).foregroundStyle(Color(white: 156.0/255)).lineLimit(1).minimumScaleFactor(0.75)
                HStack(spacing: 8) {
                  if model["type"] == "1" { badge("非会员可用", colors: [Color(white: 0.96)], white: false) }
                  if ["1", "2"].contains(model["type"]) { badge("体验会员畅聊", colors: [.cyan]) }
                  if ["2", "3"].contains(model["type"]) { badge("💎 正式会员畅聊", colors: [.orange.opacity(0.7), Color(red: 1, green: 0.4, blue: 0.3)]) }
                  if ["4", "5"].contains(model["type"]) { badge("💎 正式会员专享", colors: [.pink.opacity(0.4), Color(red: 1, green: 0.3, blue: 0.95)]) }
                }
              }.padding(.horizontal, 15).padding(.vertical, 20).frame(height: 124).background(.white, in: RoundedRectangle(cornerRadius: 20)).overlay { RoundedRectangle(cornerRadius: 20).stroke(draft == model["code"] ? .cyan : .clear, lineWidth: 4) }
            }
          }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        }.padding(.horizontal, 15).padding(.top, 15)
      }.safeAreaInset(edge: .bottom) { QQPrimaryButton(title: "确认", busy: busy) {
        store.requireLogin {
          busy = true; error = nil
          Task { defer { busy = false }; do { _ = try await store.api.request("member/setting", method: "POST", parameters: ["model": draft]); selection = draft; await store.refreshUser(); dismiss() } catch { self.error = error.localizedDescription } }
        }
      }.disabled(draft.isEmpty).padding(15).background(QQStyle.background) }
    }.overlay(alignment: .topTrailing) { Button { questionsPresented = true } label: { Image(systemName: "info.circle.fill").font(.system(size: 17)).foregroundStyle(.gray.opacity(0.6)).frame(width: 50, height: 50) }.accessibilityLabel("常见问题") }.onAppear { draft = selection }
      .sheet(isPresented: $questionsPresented) { QQModelQuestionsView().presentationDetents([.height(440), .large]).presentationCornerRadius(30).presentationDragIndicator(.hidden) }
  }
  private func badge(_ text: String, colors: [Color], white: Bool = true) -> some View { Text(text).font(.system(size: 12)).foregroundStyle(white ? .white : QQStyle.ink).padding(.horizontal, 10).frame(height: 26).background(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing), in: Capsule()) }
}

struct QQModelQuestionsView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @State private var questions: [QQRecord] = []
  @State private var error: String?
  var body: some View {
    VStack(spacing: 20) {
      Text("常见问题").font(.system(size: 20, weight: .bold)).padding(.top, 40)
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          ForEach(Array(questions.enumerated()), id: \.offset) { _, question in
            VStack(alignment: .leading, spacing: 10) {
              HStack(spacing: 5) { Text("◆").font(.system(size: 7)).foregroundStyle(.cyan); Text(question["q"]).font(.system(size: 16, weight: .bold)) }
              Text(question["a"]).font(.system(size: 13)).foregroundStyle(Color(white: 156.0/255)).lineSpacing(7)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(15).background(.white, in: RoundedRectangle(cornerRadius: 20))
          }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
        }.padding(.horizontal, 20).padding(.bottom, 20)
      }
    }.background(QQStyle.background).overlay(alignment: .topTrailing) { Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 17, weight: .bold)).foregroundStyle(.gray.opacity(0.5)).frame(width: 32, height: 32).background(.white, in: Circle()) }.padding(20).accessibilityLabel("关闭") }.toolbar(.hidden, for: .navigationBar)
      .task { do { questions = try await store.api.request("home/getQa").records } catch { self.error = error.localizedDescription } }
  }
}

struct QQDiamondBalance: View {
  let totals: QQValue
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 6) { Text(totals["total_coin"].text).font(.system(size: 30, weight: .bold)); QQArtwork(name: "purchase_ico_diamond").frame(width: 30, height: 30) }.padding(.top, 15)
      Text("钻石总数").font(.system(size: 14, weight: .bold)).foregroundStyle(.gray).padding(.top, 5)
      Spacer(minLength: 10)
      HStack(spacing: 4) { Text("限时钻石：").foregroundStyle(.gray); Text(totals["limit_time_coin"].text); QQArtwork(name: "vip_ico_diamond").frame(width: 14, height: 14); Spacer(); Label("优先使用", systemImage: "exclamationmark.circle.fill").font(.system(size: 11)).padding(.horizontal, 7).frame(height: 22).foregroundStyle(.white).background(.cyan, in: Capsule()) }.font(.system(size: 14, weight: .bold)).padding(.horizontal, 10).frame(height: 36).background(Color(red: 185.0/255, green: 243.0/255, blue: 254.0/255), in: RoundedRectangle(cornerRadius: 12)).padding(10)
    }.frame(height: 135).frame(maxWidth: .infinity).background(Color(red: 209.0/255, green: 248.0/255, blue: 254.0/255), in: RoundedRectangle(cornerRadius: 22))
  }
}

struct QQDiamondDetailView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var totals: QQValue = .null
  @State private var records: [QQRecord] = []
  @State private var selected = 0
  @State private var page = 1
  @State private var loading = false
  @State private var exhausted = false
  @State private var error: String?
  @State private var requestID = UUID()
  var body: some View {
    QQPage(title: "钻石明细", color: Color(red: 241.0/255, green: 253.0/255, blue: 1)) {
      VStack(spacing: 15) {
        QQDiamondBalance(totals: totals).padding(.horizontal, 15).padding(.top, 15)
        HStack(spacing: 26) { ForEach(0..<4) { index in Button { selected = index } label: { VStack(spacing: 7) { Text(["全部", "收入", "支出", "已过期"][index]).font(.system(size: 16, weight: selected == index ? .bold : .regular)).foregroundStyle(selected == index ? QQStyle.ink : .gray); Capsule().fill(selected == index ? .cyan : .clear).frame(width: 20, height: 4) } } } }.frame(height: 26).padding(.top, 6)
        ScrollView {
          LazyVStack(spacing: 10) {
            ForEach(Array(records.enumerated()), id: \.offset) { _, record in
              HStack {
                VStack(alignment: .leading, spacing: 7) { Text(record["business_type_name"]).font(.system(size: 14)); Text(record["type_name"]).font(.system(size: 12)).foregroundStyle(.gray) }
                Spacer()
                VStack(alignment: .trailing, spacing: 7) { Text(record["created_at"]).font(.system(size: 12)).foregroundStyle(.gray); Text(record["coin"]).font(.system(size: 16, weight: .bold)).foregroundStyle(record["type"] == "add" ? Color(red: 241.0/255, green: 109.0/255, blue: 237.0/255) : .cyan) }
              }.frame(height: 72).padding(.horizontal, 12).background(.white, in: RoundedRectangle(cornerRadius: 15))
            }
            if loading { ProgressView().padding(20) }
            else if let error { QQEmptyState(text: error) { Task { await load(reset: true) } } }
            else if records.isEmpty { QQEmptyState(text: "暂无记录") }
            else if !exhausted { Button("加载更多") { Task { await load(reset: false) } }.font(.system(size: 13)).padding(20) }
          }.padding(10)
        }.background(Color(red: 209.0/255, green: 248.0/255, blue: 254.0/255), in: RoundedRectangle(cornerRadius: 22)).padding(.horizontal, 15).padding(.bottom, 40).refreshable { await load(reset: true) }
      }
    }.task(id: selected) { await load(reset: true) }
  }
  private func load(reset: Bool) async {
    guard reset || !loading else { return }
    let attempt = UUID(); requestID = attempt
    let requestedType = ["all", "add", "sub", "expired"][selected]
    let requestedPage = reset ? 1 : page
    loading = true; error = nil
    if reset { records = []; exhausted = false }
    defer { if requestID == attempt { loading = false } }
    do {
      let newTotals = reset ? try await store.api.request("member/getCoinTotal") : totals
      let data = try await store.api.request("member/getCoinList", parameters: ["page": String(requestedPage), "pageSize": "20", "type": requestedType]).records
      guard requestID == attempt, !Task.isCancelled else { return }
      totals = newTotals
      if reset { records = data } else { records += data }
      exhausted = data.count < 20; page = requestedPage + 1
    } catch { if requestID == attempt, !Task.isCancelled { self.error = error.localizedDescription } }
  }
}
