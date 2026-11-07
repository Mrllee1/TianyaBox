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

struct QQAgentPickerView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  let excludedIDs: Set<String>
  let select: (QQRecord) -> Void
  @State private var query = ""
  @State private var records: [QQRecord] = []
  @State private var error: String?
  @State private var toast: String?
  @State private var page = 1
  @State private var hasMore = true
  @State private var loading = false
  @State private var generation = UUID()
  @State private var firstPageCache: [String: [QQRecord]] = [:]
  @State private var loadedQuery = ""
  @FocusState private var searchFocused: Bool
  var body: some View {
    VStack(spacing: 17) {
      HStack(spacing: 0) {
        Button { dismiss() } label: { QQArtwork(name: "ico_back").frame(width: 18, height: 18).frame(width: 45, height: 42) }.accessibilityLabel("返回")
        HStack(spacing: 8) {
          QQArtwork(name: "list_ico_role_search").frame(width: 18, height: 18)
          TextField("搜索角色", text: $query).font(.system(size: 14)).focused($searchFocused).submitLabel(.search).autocorrectionDisabled().onSubmit { searchFocused = false }
          if !query.isEmpty { Button { query = "" } label: { Image(systemName: "xmark").foregroundStyle(.gray) }.accessibilityLabel("清除搜索") }
        }.padding(.horizontal, 10).frame(height: 42).background(Color(white: 242.0/255), in: Capsule()).padding(.trailing, 15)
      }.padding(.top, 7)
      ScrollView {
        VStack(spacing: 0) {
        if !records.isEmpty {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
          ForEach(records) { role in
            Button {
              guard !excludedIDs.contains(role.id) else { toast = "该角色已参与身份扮演"; return }
              select(role); dismiss()
            } label: { QQRoleTile(role: role, compact: true) }.buttonStyle(.plain).accessibilityIdentifier("qingqing.agent." + role.id)
              .onAppear { if records.last?.id == role.id && hasMore && !loading { Task { await load(reset: false) } } }
          }
        }.padding(.horizontal, 14).padding(.bottom, 15)
        }
        if loading { ProgressView().padding(15) }
        if let error { QQEmptyState(text: error) { Task { await load(reset: true) } } }
        else if records.isEmpty && !loading { VStack(spacing: 10) { QQArtwork(name: "invite_pic_null").frame(width: 162, height: 133); Text("暂无角色～").font(.system(size: 14)) }.padding(.top, 168).frame(maxWidth: .infinity) }
        }
      }.refreshable { firstPageCache.removeValue(forKey: query); await load(reset: true) }
    }.background(Color(white: 249.0/255)).foregroundStyle(QQStyle.ink).toolbar(.hidden, for: .navigationBar)
      .overlay(alignment: .bottom) { if let toast { Text(toast).font(.system(size: 14)).foregroundStyle(.white).padding(12).background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 8)).padding(.bottom, 80) } }
      .task(id: toast) { guard toast != nil else { return }; try? await Task.sleep(for: .seconds(2)); guard !Task.isCancelled else { return }; toast = nil }
      .task(id: query) { do { try await Task.sleep(for: .milliseconds(350)); await load(reset: true) } catch {} }
  }
  private func load(reset: Bool) async {
    // Do not append page N of a newly typed query to the preceding query's
    // results during the debounce interval.
    if !reset && (loading || !hasMore || query != loadedQuery) { return }
    let key = query
    if reset {
      generation = UUID(); page = 1; error = nil; loadedQuery = key
      if let cached = firstPageCache[key] { records = cached; hasMore = cached.count == QingqingAPI.agentSearchPageSize; loading = false; return }
      records = []
    }
    let ticket = generation
    let requestedPage = reset ? 1 : page + 1
    loading = true
    defer { if ticket == generation { loading = false } }
    do {
      let fetched = try await store.api.searchAgents(keyword: key, page: requestedPage)
      guard ticket == generation, key == query, !Task.isCancelled else { return }
      if reset { records = fetched; firstPageCache[key] = fetched } else { records += fetched.filter { record in !records.contains(where: { $0.id == record.id }) } }
      page = requestedPage; hasMore = fetched.count == QingqingAPI.agentSearchPageSize; error = nil
    } catch is CancellationError {} catch { if ticket == generation && key == query { self.error = error.localizedDescription } }
  }
}
