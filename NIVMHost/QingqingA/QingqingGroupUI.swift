import SwiftUI

struct QQGroupDetailView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  let role: QQRecord
  @State private var detail: QQRecord?
  @State private var followed = false
  @State private var talking = false
  @State private var gallery = false
  @State private var galleryIndex = 0
  @State private var backdrop = Color(white: 0.15)
  @State private var error: String?
  private var current: QQRecord { detail ?? role }
  private var cast: [QQRecord] { current.value["characters"].records }
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        VStack(spacing: 16) {
          Color.clear.frame(height: 380)
          HStack(spacing: 12) { Text("····◆").foregroundStyle(.white.opacity(0.3)); Text(current.name).font(.system(size: 18, weight: .bold)); Text("◆····").foregroundStyle(.white.opacity(0.3)) }.foregroundStyle(.white)
          Text(current.intro).font(.system(size: 12)).foregroundStyle(.white.opacity(0.6)).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
          HStack { metric(current["fans_num"], icon: "person.fill", tint: .mint); Spacer(); metric(current["chat_num"], icon: "bubble.left.fill", tint: .cyan); Spacer(); metric(current["msg_num"], icon: "flame.fill", tint: .orange) }.padding(.horizontal, 60)
          Divider().overlay(.white.opacity(0.15)).padding(.horizontal, 20)
          Text("角色列表").font(.system(size: 14)).foregroundStyle(.white).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) { ForEach(Array(cast.enumerated()), id: \.offset) { index, actor in Button { galleryIndex = index; gallery = true } label: {
              VStack(spacing: 5) {
                QQRemoteImage(address: actor.first("avatar", "avatarUrl")).frame(width: 80, height: 110).background(.white).clipShape(RoundedRectangle(cornerRadius: 15)).rotationEffect(.degrees(-3))
                Text(actor.name).font(.system(size: 14, weight: .bold)).lineLimit(1)
                Text(actor["tag"]).font(.system(size: 10)).foregroundStyle(.white.opacity(0.5)).lineLimit(1)
              }.padding(.top, 0).padding(.bottom, 8).frame(width: 100).foregroundStyle(.white).background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 15))
            } } }.padding(.horizontal, 20).padding(.top, 4).padding(.bottom, 20)
          }
        }.background { VStack(spacing: 0) { Color.clear.frame(height: 300); LinearGradient(colors: [.clear, backdrop], startPoint: .top, endPoint: .bottom).frame(height: 90); backdrop } }
        VStack(spacing: 14) {
          card("简介", text: current.intro)
          if !current["open_remark"].isEmpty { card("开场白", text: current["open_remark"]) }
          if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) }
          Spacer(minLength: 20)
        }.padding(16).padding(.top, 10).frame(maxWidth: .infinity).background(.white, in: UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22))
      }
    }.background(alignment: .top) { QQRemoteImage(address: current.image).frame(height: 730).ignoresSafeArea(edges: .top) }.background(backdrop).overlay(alignment: .top) {
      HStack {
        Button { dismiss() } label: { QQArtwork(name: "character_ico_close").frame(width: 20, height: 20).frame(width: 60, height: 50) }.accessibilityLabel("关闭")
        Spacer()
        Button { store.requireLogin { Task { await follow() } } } label: { QQArtwork(name: followed ? "character_ico_collect02" : "character_ico_collect01").frame(width: 24, height: 24).frame(width: 60, height: 50) }.accessibilityLabel(followed ? "取消关注" : "关注")
      }
    }.safeAreaInset(edge: .bottom) { QQPrimaryButton(title: "和TA聊天", icon: "character_ico_chat") { store.requireLogin { talking = true } }.padding(.horizontal, 20).padding(.vertical, 10).background(.white) }
      .toolbar(.hidden, for: .navigationBar).buttonStyle(.plain)
      .navigationDestination(isPresented: $talking) { QQChatView(role: current, kind: .multi) }
      .sheet(isPresented: $gallery) { QQGroupCastGallery(cast: cast, initialIndex: galleryIndex) }
      .task { do { detail = QQRecord(try await store.api.request("home/getGroupRoleDetail", method: "POST", parameters: ["id": role.id])); followed = current["follow"] == "1" } catch { self.error = error.localizedDescription } }
      .task(id: current.image) { if let palette = await QQImagePalette.backdrop(current.image), !Task.isCancelled { backdrop = palette.0 } }
  }
  private func metric(_ value: String, icon: String, tint: Color) -> some View { HStack(spacing: 4) { Image(systemName: icon).foregroundStyle(tint); Text(value) }.font(.system(size: 12, weight: .bold)).foregroundStyle(.white) }
  private func card(_ title: String, text: String) -> some View { VStack(alignment: .leading, spacing: 10) { Text(title).font(.system(size: 18, weight: .bold)); Text(text).font(.system(size: 14)).foregroundStyle(.gray).lineSpacing(8).frame(maxWidth: .infinity, alignment: .leading) }.padding(16).background(Color(red: 241.0/255, green: 248.0/255, blue: 1), in: RoundedRectangle(cornerRadius: 16)) }
  private func follow() async { do { _ = try await store.api.request("member/roleFollow", method: "POST", parameters: ["role_id": role.id, "status": followed ? "0" : "1"]); followed.toggle() } catch { self.error = error.localizedDescription } }
}

private struct QQGroupCastGallery: View {
  let cast: [QQRecord]
  let initialIndex: Int
  @State private var index = 0
  var body: some View {
    TabView(selection: $index) { ForEach(Array(cast.enumerated()), id: \.offset) { offset, actor in
      QQRemoteImage(address: actor.first("avatar", "avatarUrl")).overlay(alignment: .bottom) { VStack(alignment: .leading, spacing: 12) { Text(actor.name).font(.system(size: 18, weight: .bold)); Text(actor["intro"]).font(.system(size: 14)).lineSpacing(8) }.frame(maxWidth: .infinity, alignment: .leading).padding(20).foregroundStyle(.white).background(LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)) }.clipShape(RoundedRectangle(cornerRadius: 30)).padding(20).tag(offset)
    } }.tabViewStyle(.page(indexDisplayMode: .never)).onAppear { index = initialIndex }.presentationDetents([.height(680)]).presentationCornerRadius(30)
  }
}
