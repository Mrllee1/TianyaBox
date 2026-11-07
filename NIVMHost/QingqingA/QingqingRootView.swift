import SwiftUI

struct QingqingRootView: View {
  @StateObject private var store: QingqingStore
  init(initialTab: Int = 0, initialHomeSection: Int = 0) {
    let store = QingqingStore()
    store.selectedTab = initialTab
    store.homeSection = initialHomeSection
    _store = StateObject(wrappedValue: store)
  }
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Group {
          switch store.selectedTab {
          case 1: QQLibraryView()
          case 2: QQMessagesView()
          case 3: QQMineView()
          default: QQHomeView()
          }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        bottomBar
      }
      .background(QQStyle.background)
      .toolbar(.hidden, for: .navigationBar)
      .navigationDestination(for: QQRecord.self) { QQRoleDetailView(role: $0) }
      .sheet(isPresented: $store.loginPresented) { QQLoginView() }
      .sheet(isPresented: $store.creatorPresented) { NavigationStack { QQCreatorView() } }
      .task { await store.start() }
    }.environmentObject(store).tint(QQStyle.ink).preferredColorScheme(.light)
  }

  private var bottomBar: some View {
    HStack(spacing: 0) {
      tab(0, selected: "tab001", normal: "tab01", title: "首页")
      tab(1, selected: "tab002", normal: "tab02", title: "发现")
      Button { store.requireLogin { store.creatorPresented = true } } label: {
        QQArtwork(name: "tab_ico00").frame(width: 48, height: 40).frame(maxWidth: .infinity)
      }.accessibilityLabel("创建智能体")
      tab(2, selected: "tab004", normal: "tab04", title: "消息")
      tab(3, selected: "tab005", normal: "tab05", title: "我的")
    }.frame(height: 64).background(.white)
      .overlay(alignment: .top) { Color.black.opacity(0.04).frame(height: 0.5) }
      .buttonStyle(.plain)
  }
  private func tab(_ index: Int, selected: String, normal: String, title: String) -> some View {
    Button {
      if index == 2 { store.requireLogin { store.selectedTab = index } }
      else { store.selectedTab = index }
    } label: {
      QQArtwork(name: store.selectedTab == index ? selected : normal)
        .frame(width: 24, height: 24).frame(maxWidth: .infinity)
    }.accessibilityLabel(title).accessibilityAddTraits(store.selectedTab == index ? .isSelected : [])
  }
}

private struct QQHomeView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var focused = 0
  @State private var backdrop = Color(red: 0.89, green: 0.94, blue: 0.94)
  @State private var darkBackdrop = false
  var body: some View {
    VStack(spacing: 14) {
      HStack(spacing: 12) {
        ForEach(Array(["01", "06", "07", "08"].enumerated()), id: \.offset) { index, suffix in
          Button { focused = 0; store.homeSection = index } label: {
            VStack(spacing: 4) {
              QQArtwork(name: "home_tittle_" + (darkBackdrop ? "white" : "black") + suffix)
                .frame(width: [34.0, 34, 48, 64][index], height: 20)
                .opacity(store.homeSection == index ? 1 : 0.45)
              Capsule().fill(store.homeSection == index ? Color.cyan : .clear).frame(width: 12, height: 4)
            }
          }.accessibilityLabel(["推荐", "群聊", "模拟器", "剧场"][index])
        }
        Spacer(minLength: 0)
        NavigationLink { QQMemberView() } label: { QQArtwork(name: "home_ico_vip").frame(width: 34, height: 34) }
          .accessibilityLabel("会员中心")
      }.padding(.horizontal, 20).padding(.top, 8)
      ZStack {
        if let error = store.error, items.isEmpty {
          QQEmptyState(text: error) { Task { await store.loadSection(store.homeSection) } }
        } else if items.isEmpty && store.loading {
          ProgressView()
        } else if items.isEmpty {
          QQEmptyState()
        } else if store.homeSection < 2 {
          TabView(selection: $focused) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, role in
              QQHeroCard(role: role, kind: store.homeSection == 1 ? .multi : .single)
                .padding(.horizontal, 20).padding(.bottom, 14).tag(index)
            }
          }.tabViewStyle(.page(indexDisplayMode: .never))
        } else if store.homeSection == 3 {
          QQTheaterCarousel(items: items, selection: $focused)
        } else {
          ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
              ForEach(items) { record in
                if store.homeSection == 2 {
                  NavigationLink { QQSimulatorDetailView(scenario: record) } label: { sceneCard(record) }
                } else {
                  NavigationLink { QQTheaterView(script: record) } label: { sceneCard(record) }
                }
              }
            }.padding(.horizontal, 10).padding(.bottom, 18)
          }.refreshable { await store.loadSection(store.homeSection) }
        }
      }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .background(LinearGradient(colors: [backdrop, QQStyle.background], startPoint: .top, endPoint: .bottom))
    .task(id: store.homeSection) { await store.loadSection(store.homeSection) }
    .task(id: items.indices.contains(focused) ? items[focused].image : "") {
      guard items.indices.contains(focused), let palette = await QQImagePalette.backdrop(items[focused].image), !Task.isCancelled else { return }
      backdrop = palette.0; darkBackdrop = palette.1
    }
  }
  private var items: [QQRecord] {
    switch store.homeSection { case 1: return store.groups; case 2: return store.simulators; case 3: return store.theaters; default: return store.recommended }
  }
  private func sceneCard(_ record: QQRecord) -> some View { QQSceneTile(record: record) }

}

private struct QQHeroCard: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  let kind: QQConversationKind
  @State private var talking = false
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        QQRemoteImage(address: role.image)
        LinearGradient(stops: [.init(color: .clear, location: 0.25), .init(color: .black.opacity(0.15), location: 0.45), .init(color: .black.opacity(0.9), location: 1)], startPoint: .top, endPoint: .bottom)
        VStack(alignment: .leading, spacing: 12) {
          NavigationLink { QQRoleDetailView(role: role, kind: kind) } label: {
            Text(role.first("title", "name")).font(.system(size: 24, weight: .bold))
          }.foregroundStyle(.white)
          QQWrapLayout(spacing: 6) {
            if !role["uid"].isEmpty { NavigationLink { QQAuthorCenterView(authorID: role["uid"]) } label: { QQAuthorBadge(role: role) } }
            if !role["msg_num"].isEmpty { HStack(spacing: 3) { Image(systemName: "flame.fill"); Text(role["msg_num"]) }.font(.system(size: 12)).padding(.horizontal, 9).frame(height: 24).background(.white.opacity(0.25), in: Capsule()) }
            ForEach(role.tags, id: \.self) { tag in Text(tag).font(.system(size: 12)).padding(.horizontal, 9).frame(height: 24).background(.white.opacity(0.25), in: Capsule()) }
          }
          Text(role.intro).font(.system(size: 14)).lineSpacing(5).lineLimit(4).foregroundStyle(.white.opacity(0.9))
          QQPrimaryButton(title: "聊天") { store.requireLogin { talking = true } }.padding(.top, 8)
        }.padding(20)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }.navigationDestination(isPresented: $talking) { QQChatView(role: role, kind: kind) }
  }
}

struct QQLibraryView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var category = "all"
  @State private var ranking = false
  @State private var ranked: [QQRecord] = []
  @State private var rankLabels: [QQRecord] = []
  @State private var rankType = ""
  @State private var page = 1
  @State private var exhausted = false
  @State private var rankError: String?
  @State private var rankRequestID = UUID()
  init(initialRanking: Bool = false) { _ranking = State(initialValue: initialRanking) }
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 12) {
        QQArtwork(name: "list_ico_tittle").frame(width: 40, height: 24)
        Spacer()
        NavigationLink { QQSearchView() } label: { QQArtwork(name: "list_ico_search").frame(width: 24, height: 24) }.accessibilityLabel("搜索角色")
        NavigationLink { QQMemberView() } label: { QQArtwork(name: "home_ico_vip").frame(width: 30, height: 30) }.accessibilityLabel("会员中心")
      }.padding(.leading, 20).padding(.trailing, 10).frame(height: 54)
      HStack(spacing: 8) {
        segment("热门标签", active: !ranking) { ranking = false; refresh() }
        segment("排行榜", active: ranking) { ranking = true; refresh() }
        Spacer()
      }.padding(.horizontal, 10).padding(.top, 8)
      if ranking && !rankLabels.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 24) { ForEach(rankLabels) { label in Button { rankType = label["type"]; refresh() } label: { Text(label.name).font(.system(size: 14, weight: rankType == label["type"] ? .bold : .regular)).foregroundStyle(rankType == label["type"] ? QQStyle.ink : .gray) } } }.padding(.horizontal, 15) }.frame(height: 42)
      }
      if !ranking { ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 24) {
          ForEach(store.categories) { item in Button { category = item["code"]; refresh() } label: { Text(item.name).font(.system(size: 14, weight: category == item["code"] ? .bold : .regular)).foregroundStyle(category == item["code"] ? QQStyle.ink : .gray) } }
        }.padding(.horizontal, 15)
      }.frame(height: 45) }
      ScrollView {
        if ranking {
          LazyVStack(spacing: 0) { ForEach(Array(ranked.enumerated()), id: \.element.id) { index, role in QQRoleChatLink(role: role.conversationRole) { QQRankingRow(role: role, index: index) }.buttonStyle(.plain) } }
          if let rankError { QQEmptyState(text: rankError, action: refresh) }
        } else {
          if let error = store.error, store.roles.isEmpty { QQEmptyState(text: error, action: refresh) }
          LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) { ForEach(store.roles) { role in QQRoleChatLink(role: role) { QQRoleTile(role: role) }.buttonStyle(.plain) } }.padding(.horizontal, 10)
        }
        if store.loading { ProgressView().padding() }
        else if !ranking && !store.roles.isEmpty && !exhausted {
          Button("加载更多") { page += 1; Task { let count = store.roles.count; await store.loadRoles(category: category, page: page); exhausted = store.roles.count == count } }.padding(20).font(.system(size: 13))
        } else if (ranking ? ranked : store.roles).isEmpty && !store.loading { QQEmptyState() }
      }.refreshable { refresh() }
    }.background(.white).task { refresh() }
  }
  private func segment(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) { Text(title).font(.system(size: 14, weight: .bold)).foregroundStyle(active ? Color(red: 0, green: 0.65, blue: 0.85) : Color(white: 0.55)).padding(.horizontal, 15).frame(height: 32).background(active ? Color(red: 0.88, green: 0.98, blue: 1) : Color(white: 0.97), in: Capsule()) }
  }
  private func refresh() {
    page = 1; exhausted = false
    let requestID = UUID(); rankRequestID = requestID
    let requestedRanking = ranking, requestedCategory = category
    Task {
      if requestedRanking {
        rankError = nil
        do {
          if rankLabels.isEmpty {
            let labels = try await store.api.request("home/roleRankLabel").records
            guard rankRequestID == requestID else { return }
            rankLabels = labels; rankType = rankLabels.first?["type"] ?? ""
          }
          guard !rankType.isEmpty else { return }
          let result = try await store.api.request("home/roleRank", parameters: ["type": rankType, "category": requestedCategory]).records
          guard rankRequestID == requestID else { return }
          ranked = result
        } catch { if rankRequestID == requestID { rankError = error.localizedDescription } }
      } else { await store.loadRoles(category: requestedCategory) }
    }
  }
}

struct QQRankingRow: View {
  let role: QQRecord
  let index: Int
  var body: some View {
    HStack(spacing: 8) {
      Group { if index < 3 { QQArtwork(name: String(format: "list_ico_no%02d", index + 1)).frame(width: 24, height: 28) } else { Text(String(index + 1)).font(.system(size: 13, weight: .bold)).frame(width: 24) } }
      QQRemoteImage(address: role.image).frame(width: 60, height: 80).clipShape(RoundedRectangle(cornerRadius: 9))
      VStack(alignment: .leading, spacing: 7) {
        Text(role.name).font(.system(size: 18, weight: .bold)).lineLimit(1)
        Text("@" + role.first("member_name", "author", "member_nick", "nick")).font(.system(size: 12, weight: .bold)).foregroundStyle(.gray)
        HStack(spacing: 14) { stat(role.first("follow_num", "fans_num"), "role_ico_people"); stat(role["chat_num"], "role_ico_comment"); stat(role.first("hot", "hot_num"), "role_ico_hot") }.font(.system(size: 12, weight: .bold)).foregroundStyle(.gray)
      }
      Spacer(minLength: 0)
    }.padding(.horizontal, 15).padding(.vertical, 15).background { if index < 3 { Image(String(format: "qq_list_bg2_no%02d", index + 1)).resizable() } else { Color.white } }.overlay(alignment: .bottom) { if index >= 3 { Color.black.opacity(0.06).frame(height: 1).padding(.horizontal, 15) } }
  }
  private func stat(_ value: String, _ icon: String) -> some View { HStack(spacing: 1) { QQArtwork(name: icon).frame(width: 12, height: 12); Text(value.isEmpty ? "0" : value) } }
}

struct QQSearchView: View {
  @EnvironmentObject private var store: QingqingStore
  @Environment(\.dismiss) private var dismiss
  @State private var query = ""
  @State private var records: [QQRecord] = []
  @State private var loading = false
  @State private var error: String?
  @FocusState private var searchFocused: Bool
  var body: some View {
    VStack(spacing: 10) {
      HStack(spacing: 4) {
        HStack(spacing: 5) { QQArtwork(name: "list_ico_search").frame(width: 24, height: 24); TextField("在此处搜索", text: $query).focused($searchFocused).font(.system(size: 14)).submitLabel(.search).autocorrectionDisabled().onSubmit { searchFocused = false }; if !query.isEmpty { Button { query = "" } label: { Image(systemName: "xmark").foregroundStyle(.black) } } }.padding(.horizontal, 13).frame(height: 48).background(Color(white: 242.0/255), in: RoundedRectangle(cornerRadius: 18))
        Button("取消") { dismiss() }.font(.system(size: 15)).padding(.horizontal, 15).frame(height: 50)
      }.padding(.leading, 15).padding(.top, 10)
      ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) { ForEach(records) { role in QQRoleChatLink(role: role) { QQRoleTile(role: role, compact: true) } } }.padding(.horizontal, 4)
        if loading { ProgressView().padding(20) }
        else if let error { QQEmptyState(text: error) }
        else if !query.isEmpty && records.isEmpty { VStack(spacing: 10) { QQArtwork(name: "invite_pic_null").frame(width: 150, height: 150); Text("暂时没有内容～").font(.system(size: 14)) }.padding(.top, 175).frame(maxWidth: .infinity) }
      }
    }.background(.white).toolbar(.hidden, for: .navigationBar).onAppear { searchFocused = true }.task(id: query) {
      guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { records = []; error = nil; loading = false; return }
      do {
        try await Task.sleep(for: .milliseconds(350)); loading = true; error = nil
        let result = try await store.api.request("home/searchRole", method: "POST", parameters: ["keyword": query, "page": "1", "pageSize": "30"]).records
        guard !Task.isCancelled else { return }; records = result; loading = false
      } catch is CancellationError {} catch { if !Task.isCancelled { self.error = error.localizedDescription; loading = false } }
    }
  }
}
