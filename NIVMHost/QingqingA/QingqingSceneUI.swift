import SwiftUI

struct QQTheaterCarousel: View {
  @EnvironmentObject private var store: QingqingStore
  let items: [QQRecord]
  @Binding var selection: Int
  @State private var destination: QQRecord?
  @State private var initialized = false
  var body: some View {
    VStack(spacing: 10) {
      if items.indices.contains(selection) {
        let item = items[selection]
        ZStack(alignment: .bottomLeading) {
          QQRemoteImage(address: item.image)
          LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .center, endPoint: .bottom)
          VStack(alignment: .leading, spacing: 14) {
            Text(item.name).font(.system(size: 24, weight: .bold)).lineLimit(2)
            QQWrapLayout(spacing: 6) { ForEach(item.tags, id: \.self) { tag in Text(tag).font(.system(size: 12)).padding(.horizontal, 9).frame(height: 24).background(.white.opacity(0.25), in: Capsule()) } }
            Text(item.intro).font(.system(size: 14)).lineSpacing(7).lineLimit(4)
            Button { store.requireLogin { destination = item } } label: { Text("聊天").font(.system(size: 16, weight: .bold)).foregroundStyle(QQStyle.ink).frame(width: 180, height: 48).background(QQStyle.gradient, in: Capsule()) }.frame(maxWidth: .infinity).padding(.top, 8)
          }.foregroundStyle(.white).padding(20).padding(.bottom, 6)
        }.clipShape(QQTheaterCardShape()).padding(.horizontal, 10)
      }
      ZStack {
        QQArtwork(name: "home_theater_line").frame(height: 54).padding(.horizontal, 30)
        HStack(alignment: .center, spacing: 0) {
          ForEach(0..<5) { slot in
            let index = items.isEmpty ? 0 : (selection + slot - 2 + items.count) % items.count
            let size: CGFloat = [42, 50, 54, 50, 42][slot]
            if items.indices.contains(index) {
              Button { withAnimation(.easeInOut(duration: 0.25)) { selection = index } } label: {
                QQRemoteImage(address: items[index].image).frame(width: size, height: size).clipShape(Circle()).overlay {
                  if slot == 2 { QQArtwork(name: "home_theater_pointer").frame(width: 70, height: 80) }
                  if slot == 4 { QQArtwork(name: "home_theater_more").frame(width: 42, height: 42).allowsHitTesting(false) }
                }.frame(maxWidth: .infinity).offset(y: [0.0, 10, 18, 10, 0][slot])
              }.accessibilityLabel(slot == 4 ? "更多剧场" : items[index].name)
            }
          }
        }.padding(.horizontal, 25)
      }.frame(height: 100).contentShape(Rectangle()).gesture(DragGesture(minimumDistance: 20).onEnded { value in guard !items.isEmpty else { return }; withAnimation(.easeInOut(duration: 0.25)) { selection = (selection + (value.translation.width < 0 ? 1 : -1) + items.count) % items.count } })
    }.navigationDestination(item: $destination) { QQTheaterView(script: $0) }.onAppear { if !initialized { selection = min(2, max(0, items.count - 1)); initialized = true } }

  }
}

private struct QQTheaterCardShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path(); let radius: CGFloat = 28
    path.move(to: CGPoint(x: radius, y: 0)); path.addLine(to: CGPoint(x: rect.width-radius, y: 0)); path.addQuadCurve(to: CGPoint(x: rect.width, y: radius), control: CGPoint(x: rect.width, y: 0)); path.addLine(to: CGPoint(x: rect.width, y: rect.height-42)); path.addQuadCurve(to: CGPoint(x: 0, y: rect.height-42), control: CGPoint(x: rect.width/2, y: rect.height+42)); path.addLine(to: CGPoint(x: 0, y: radius)); path.addQuadCurve(to: CGPoint(x: radius, y: 0), control: .zero); path.closeSubpath(); return path
  }
}

struct QQSceneTile: View {
  let record: QQRecord
  var body: some View {
    ZStack(alignment: .bottom) {
      QQRemoteImage(address: record.image)
      if !record["titleImage"].isEmpty { VStack { QQRemoteImage(address: record["titleImage"], contentMode: .fit).aspectRatio(350.0/353, contentMode: .fit); Spacer(minLength: 0) } }
      LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
      VStack(alignment: .leading, spacing: 6) {
        HStack(spacing: 3) { Text(record.name).font(.system(size: 14, weight: .bold)).lineLimit(1); Spacer(minLength: 0); Image(systemName: "flame.fill"); Text(record.first("msg_num", "msgNum")).font(.system(size: 12)) }
        Text(record.intro).font(.system(size: 12)).foregroundStyle(Color(white: 211.0/255)).lineLimit(3).frame(maxWidth: .infinity, alignment: .leading)
      }.padding(10).foregroundStyle(.white)
    }.frame(height: 282).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(alignment: .topTrailing) { Image(systemName: "book.closed.fill").font(.system(size: 18)).foregroundStyle(.white).padding(6) }
  }
}

struct QQRoleGalleryView: View {
  let roles: [QQRecord]
  var initialIndex = 0
  @State private var index = 0
  var body: some View {
    TabView(selection: $index) {
      ForEach(Array(roles.enumerated()), id: \.offset) { offset, role in
        QQRemoteImage(address: role.first("avatar", "img_url", "roleImage")).overlay(alignment: .bottom) {
          VStack(alignment: .leading, spacing: 12) { HStack(spacing: 5) { Text(role.name).font(.system(size: 18, weight: .bold)); Text(role["playable"] == "1" ? "·主控身份·" : "·副控身份·").font(.system(size: 12)).padding(.horizontal, 8).padding(.vertical, 5).background(.white.opacity(0.3), in: Capsule()) }; Text(role.first("detailedIntro", "description", "intro")).font(.system(size: 14)).lineSpacing(8) }.padding(15).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.white).background(LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom))
        }.clipShape(RoundedRectangle(cornerRadius: 30)).padding(.horizontal, 20).padding(.top, 36).padding(.bottom, 14).tag(offset)
      }
    }.tabViewStyle(.page(indexDisplayMode: .never)).onAppear { index = initialIndex }.presentationDetents([.height(680)]).presentationCornerRadius(28).presentationDragIndicator(.visible)
  }
}

struct QQSimulatorCastView: View {
  @EnvironmentObject private var store: QingqingStore
  let title: String
  let scenarioID: String
  let roles: [QQRecord]
  @Binding var playerRoleID: String
  @Binding var agents: [String: QQRecord]
  let busy: Bool
  var submissionError: String? = nil
  let start: () -> Void
  @State private var target: QQRecord?
  @State private var error: String?
  var body: some View {
    VStack(spacing: 15) {
      Text(title).font(.system(size: 18, weight: .bold)).padding(.top, 20)
      HStack(spacing: 6) { Text("选择身份").font(.system(size: 14)); Text("空缺身份不会带入模拟器哦～").font(.system(size: 12)).foregroundStyle(.gray); Spacer() }.padding(.horizontal, 20)
      ScrollView {
        LazyVStack(spacing: 8) { ForEach(roles) { role in castRow(role) } }.padding(.horizontal, 10)
      }
      if let message = error ?? submissionError { Text(message).font(.system(size: 12)).foregroundStyle(.red) }
      HStack(spacing: 10) {
        Button("一键邀请") { inviteAll() }.font(.system(size: 16, weight: .bold)).foregroundStyle(.cyan).frame(maxWidth: .infinity).frame(height: 56).background(.cyan.opacity(0.08), in: Capsule()).disabled(busy)
        QQPrimaryButton(title: "开始游戏", busy: busy, action: start)
      }.padding(.horizontal, 20).padding(.bottom, 10)
    }.background(Color(white: 248.0/255)).sheet(item: $target) { role in NavigationStack { QQAgentPickerView(excludedIDs: Set(agents.filter { $0.key != role.id }.values.map(\.id))) { agent in if playerRoleID == role.id { playerRoleID = "" }; agents[role.id] = agent; target = nil } } }
  }
  private func castRow(_ role: QQRecord) -> some View {
    HStack(spacing: 8) {
      QQRemoteImage(address: role["avatar"]).frame(width: 66, height: 90).clipShape(RoundedRectangle(cornerRadius: 10))
      VStack(alignment: .leading, spacing: 5) { Text(role.name).font(.system(size: 14, weight: .bold)); Text(role["playable"] == "1" ? "·主控身份·" : "·副控身份·").font(.system(size: 11)).padding(.horizontal, 6).padding(.vertical, 3).background(Color(white: 0.96), in: Capsule()); Text(role["description"]).font(.system(size: 11)).foregroundStyle(.gray).lineLimit(2) }.frame(maxWidth: .infinity, alignment: .leading)
      VStack(spacing: 4) {
        Group { if playerRoleID == role.id { QQRemoteImage(address: store.user?["head_img"] ?? "") } else if let agent = agents[role.id] { QQRemoteImage(address: agent.image) } else { Image(systemName: "person.fill.badge.plus").resizable().scaledToFit().padding(6).foregroundStyle(Color(white: 0.8)).background(Color(white: 0.93)) } }.frame(width: 34, height: 34).clipShape(Circle())
        Text(playerRoleID == role.id ? store.user?["nick"] ?? "我" : agents[role.id]?.name ?? "空缺").font(.system(size: 11)).foregroundStyle(.gray).lineLimit(1)
        HStack(spacing: 4) { Button(agents[role.id] == nil ? "邀请角色" : "更换角色") { target = role }.padding(.horizontal, 5).frame(height: 22).overlay { Capsule().stroke(.cyan) }; Button(playerRoleID == role.id ? "✓ 我" : "我来扮演") { playerRoleID = role.id; agents.removeValue(forKey: role.id) }.padding(.horizontal, 5).frame(height: 22).background(.cyan.opacity(0.08), in: Capsule()) }.font(.system(size: 10)).foregroundStyle(.cyan)
      }.frame(width: 128)
    }.padding(5).frame(height: 100).background(.white, in: RoundedRectangle(cornerRadius: 20)).contextMenu { Button("移除此身份的扮演者", role: .destructive) { agents.removeValue(forKey: role.id); if playerRoleID == role.id { playerRoleID = "" } } }
  }
  private func inviteAll() {
    guard !playerRoleID.isEmpty else { error = "请选择自己要扮演的角色"; return }
    Task { do { let candidates = try await store.api.request("simulator/onekeyInvite", parameters: ["id": scenarioID]).records
      for (index, role) in roles.enumerated() where role.id != playerRoleID && candidates.indices.contains(index) { let candidate = candidates[index]; agents[role.id] = QQRecord(.object(["id": .string(candidate.id), "name": .string(candidate.name), "img_url": .string(candidate.first("img_url", "imgUrl"))])) }; error = nil
    } catch { self.error = error.localizedDescription } }
  }
}

private struct QQAgentPickerView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  let excludedIDs: Set<String>
  let select: (QQRecord) -> Void
  @State private var query = ""
  @State private var records: [QQRecord] = []
  @State private var error: String?
  var body: some View {
    QQPage(title: "搜索角色", color: .white) {
      TextField("搜索角色", text: $query).font(.system(size: 14)).padding(12).background(Color(white: 0.95), in: Capsule()).padding(.horizontal, 15)
      ScrollView { LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) { ForEach(records.filter { !excludedIDs.contains($0.id) }) { role in Button { select(role); dismiss() } label: { QQRoleTile(role: role, compact: true) }.buttonStyle(.plain) } }.padding(14); if let error { Text(error).font(.system(size: 13)).foregroundStyle(.red) } }
    }.task(id: query) {
      do { try await Task.sleep(for: .milliseconds(350)); let result = query.isEmpty ? try await store.api.request("home/getRole", parameters: ["page": "1", "pageSize": "30", "category": "all"]) : try await store.api.request("home/searchRole", method: "POST", parameters: ["keyword": query, "page": "1", "pageSize": "30"]); guard !Task.isCancelled else { return }; records = result.records; error = nil } catch is CancellationError {} catch { if !Task.isCancelled { self.error = error.localizedDescription } }
    }
  }
}
