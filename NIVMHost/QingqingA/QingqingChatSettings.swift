import SwiftUI
import PhotosUI

struct QQTalkSettingsPanel: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  let modelName: String
  let close: () -> Void
  let identity: () -> Void
  let background: () -> Void
  let models: () -> Void
  @AppStorage("qingqing.chat.dark") private var dark = false
  @AppStorage("qingqing.chat.halfScreen") private var halfScreen = false
  @State private var info: QQValue = .null
  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        Color.clear.contentShape(Rectangle()).frame(width: 60).onTapGesture(perform: close)
        ScrollView {
          VStack(alignment: .leading, spacing: 13) {
            Text("我的身份设定").font(.system(size: 16, weight: .bold))
            VStack(spacing: 16) {
              row("名字", value: info["name"].text, placeholder: "智能体对我的称呼", action: identity)
              row("性别", value: info["gender"].text, placeholder: "智能体对我的性别认知", action: identity)
              row("描述", value: info["setting"].text, placeholder: "智能体对我的身份认知", action: identity)
            }.padding(.vertical, 20).background(.white, in: RoundedRectangle(cornerRadius: 22))
            Text("对话设置").font(.system(size: 16, weight: .bold)).padding(.top, 7)
            VStack(spacing: 16) {
              Button(action: background) { HStack { Text("当前对话背景"); Spacer(); QQRemoteImage(address: role.image).frame(width: 22, height: 40).clipShape(RoundedRectangle(cornerRadius: 4)); QQArtwork(name: "ico_setting_next").frame(width: 18, height: 18) }.padding(.horizontal, 15).frame(height: 40) }
              row("全局对话模式", value: modelName, placeholder: "", action: models)
              switchRow("暗夜模式", isOn: $dark)
              switchRow("半屏模式", isOn: $halfScreen)
            }.font(.system(size: 14, weight: .bold)).foregroundStyle(Color(white: 0.63)).padding(.vertical, 20).background(.white, in: RoundedRectangle(cornerRadius: 22))
          }.padding(.horizontal, 15).padding(.top, 70).padding(.bottom, 30)
        }.frame(width: geometry.size.width - 60).background(QQStyle.background)
      }
    }.ignoresSafeArea().buttonStyle(.plain).task { info = (try? await store.api.request("member/getRoleSetting", method: "POST", parameters: ["role_id": role.id])) ?? .null }
  }
  private func row(_ title: String, value: String, placeholder: String, action: @escaping () -> Void) -> some View {
    Button(action: action) { HStack { Text(title).foregroundStyle(Color(white: 0.63)); Spacer(minLength: 5); Text(value.isEmpty ? placeholder : value).foregroundStyle(value.isEmpty ? Color(white: 0.63) : QQStyle.ink).lineLimit(1); QQArtwork(name: "ico_setting_next").frame(width: 18, height: 18) }.font(.system(size: 14, weight: .bold)).padding(.horizontal, 15).frame(height: 40) }
  }
  private func switchRow(_ title: String, isOn: Binding<Bool>) -> some View { Button { isOn.wrappedValue.toggle() } label: { HStack { Text(title); Spacer(); QQArtwork(name: isOn.wrappedValue ? "ico_on" : "ico_off").frame(width: 50, height: 30) }.padding(.horizontal, 15).frame(height: 40) }.accessibilityLabel(title).accessibilityValue(isOn.wrappedValue ? "开启" : "关闭") }
}

enum QQChatBackground {
  static func key(_ roleID: String) -> String { "qingqing.chat.background." + roleID }
  static func selection(_ roleID: String) -> String { UserDefaults.standard.string(forKey: key(roleID)) ?? "" }
}

struct QQChatBackgroundView: View {
  let role: QQRecord
  let selection: String
  var body: some View {
    Group {
      if selection == "solid_color" { Color(white: 28.0/255) }
      else if !selection.isEmpty, let image = UIImage(contentsOfFile: selection) { Image(uiImage: image).resizable().scaledToFill() }
      else { QQRemoteImage(address: role.image) }
    }.clipped()
  }
}

struct QQBackgroundSettingView: View {
  @Environment(\.dismiss) private var dismiss
  let role: QQRecord
  @State private var choice = ""
  @State private var photo: PhotosPickerItem?
  @State private var photoData: Data?
  @State private var imagePreview = false
  @State private var error: String?
  var body: some View {
    VStack(spacing: 20) {
      Text("对话背景").font(.system(size: 20, weight: .bold)).padding(.top, 20)
      HStack(alignment: .top, spacing: 7) {
        option("默认背景", value: "") { QQRemoteImage(address: role.image) }
        option("纯色背景", value: "solid_color") { QQArtwork(name: "chat_set_bg") }
        VStack(spacing: 9) {
          customCard
          Text("自定义背景").font(.system(size: 12)).foregroundStyle(.gray)
        }.frame(maxWidth: .infinity)
      }.padding(.horizontal, 20)
      if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
      QQPrimaryButton(title: "设为聊天背景") { save() }.padding(.horizontal, 20).padding(.bottom, 30)
    }.background(QQStyle.background).overlay(alignment: .topTrailing) { Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).foregroundStyle(.gray).frame(width: 32, height: 32).background(.white, in: Circle()) }.padding(20) }
      .fullScreenCover(isPresented: $imagePreview) { if let photoData, let image = UIImage(data: photoData) { QQImagePreview(image: image) } }
      .task { let current = QQChatBackground.selection(role.id); choice = current; if !current.isEmpty && current != "solid_color", let data = try? Data(contentsOf: URL(fileURLWithPath: current)) { photoData = data; choice = "custom" } }
      .task(id: photo) { guard let photo else { return }; do { guard let data = try await photo.loadTransferable(type: Data.self), data.count <= 8_000_000, UIImage(data: data) != nil else { error = "请选择小于 8MB 的图片"; return }; photoData = data; choice = "custom" } catch { self.error = error.localizedDescription } }
  }
  private var customCard: some View {
    Color(white: 0.92).aspectRatio(102.0/190, contentMode: .fit).overlay {
      if let photoData, let image = UIImage(data: photoData) {
        GeometryReader { geometry in
          Button { choice = "custom" } label: { Image(uiImage: image).resizable().scaledToFill().frame(width: geometry.size.width, height: geometry.size.height).clipped() }.buttonStyle(.plain).accessibilityLabel("选择自定义背景")
        }.overlay(alignment: .top) {
          HStack {
            PhotosPicker(selection: $photo, matching: .images) { QQArtwork(name: "bj_ico_gh").frame(width: 26, height: 26).padding(10) }.accessibilityLabel("更换自定义背景")
            Spacer(minLength: 0)
            Button { imagePreview = true } label: { QQArtwork(name: "bj_ico_dt").frame(width: 26, height: 26).padding(10) }.accessibilityLabel("查看自定义背景大图")
          }
        }
      } else {
        PhotosPicker(selection: $photo, matching: .images) {
          VStack(spacing: 4) { QQArtwork(name: "script_ico_upload").frame(width: 24, height: 24); Text("自定义上传\n仅本地保存").font(.system(size: 14)).lineSpacing(2).multilineTextAlignment(.center).foregroundStyle(Color(white: 195.0/255)) }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }.clipShape(RoundedRectangle(cornerRadius: 12)).overlay { RoundedRectangle(cornerRadius: 10).stroke(choice == "custom" ? .cyan : .clear, lineWidth: 3).allowsHitTesting(false) }
  }
  private func option<Content: View>(_ title: String, value: String, @ViewBuilder content: () -> Content) -> some View {
    Button { choice = value } label: { VStack(spacing: 9) { Color.clear.aspectRatio(102.0/190, contentMode: .fit).overlay { content() }.clipShape(RoundedRectangle(cornerRadius: 12)).overlay { RoundedRectangle(cornerRadius: 10).stroke(choice == value ? .cyan : .clear, lineWidth: 3) }; Text(title).font(.system(size: 12)).foregroundStyle(.gray) }.frame(maxWidth: .infinity) }.buttonStyle(.plain).accessibilityLabel(title).accessibilityValue(choice == value ? "已选择" : "未选择")
  }
  private func save() {
    do {
      var selection = choice
      if choice == "custom" {
        guard let photoData else { return }
        let directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("QingqingChatBackgrounds", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let file = directory.appendingPathComponent(UUID().uuidString + ".image")
        try photoData.write(to: file, options: .atomic); selection = file.path
      }
      let old = QQChatBackground.selection(role.id)
      UserDefaults.standard.set(selection, forKey: QQChatBackground.key(role.id))
      if old != selection && old.contains("/QingqingChatBackgrounds/") { try? FileManager.default.removeItem(atPath: old) }
      dismiss()
    } catch { self.error = error.localizedDescription }
  }
}
