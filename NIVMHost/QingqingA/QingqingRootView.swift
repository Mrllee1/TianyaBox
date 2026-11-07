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
        QQArtwork(name: "tab_ico00").frame(width: 52, height: 48).frame(maxWidth: .infinity)
      }.accessibilityLabel("创建智能体")
      tab(2, selected: "tab004", normal: "tab04", title: "消息")
      tab(3, selected: "tab005", normal: "tab05", title: "我的")
    }.frame(height: 56).background(.white)
      .overlay(alignment: .top) { Color.black.opacity(0.04).frame(height: 0.5) }
      .buttonStyle(.plain)
  }
  private func tab(_ index: Int, selected: String, normal: String, title: String) -> some View {
    Button {
      if index == 2 { store.requireLogin { store.selectedTab = index } }
      else { store.selectedTab = index }
    } label: {
      QQArtwork(name: store.selectedTab == index ? selected : normal)
        .frame(width: 38, height: 44).frame(maxWidth: .infinity)
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
                .frame(width: index > 1 ? 58 : 40, height: 24)
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
        } else {
          ScrollView {
            LazyVStack(spacing: 12) {
              ForEach(items) { record in
                if store.homeSection == 2 {
                  NavigationLink { QQSimulatorDetailView(scenario: record) } label: { sceneCard(record) }
                } else {
                  NavigationLink { QQTheaterView(script: record) } label: { sceneCard(record) }
                }
              }
            }.padding(.horizontal, 16).padding(.bottom, 18)
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
  private func sceneCard(_ record: QQRecord) -> some View {
    QQRemoteImage(address: record.image).frame(height: 280)
      .overlay(alignment: .bottomLeading) {
        VStack(alignment: .leading, spacing: 10) {
          Text(record.name).font(.system(size: 23, weight: .bold))
          QQTags(tags: record.tags, dark: true)
          Text(record.intro).font(.system(size: 12)).lineLimit(2)
        }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
          .background(LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom))
      }.foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 16))
  }
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
          NavigationLink(value: role) {
            HStack { Text(role.name).font(.system(size: 26, weight: .bold)); Spacer(); Image(systemName: "chevron.right").font(.system(size: 14)) }
          }.foregroundStyle(.white)
          QQTags(tags: role.tags, dark: true)
          Text(role.intro).font(.system(size: 14)).lineSpacing(5).lineLimit(4).foregroundStyle(.white.opacity(0.9))
          QQPrimaryButton(title: "聊天") { store.requireLogin { talking = true } }.padding(.top, 8)
        }.padding(20)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }.navigationDestination(isPresented: $talking) { QQChatView(role: role, kind: kind) }
  }
}

private struct QQLibraryView: View {
  @EnvironmentObject private var store: QingqingStore
  @State private var query = ""
  @State private var category = "all"
  @State private var ranking = false
  @State private var ranked: [QQRecord] = []
  @State private var page = 1
  @State private var exhausted = false
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "magnifyingglass").foregroundStyle(QQStyle.secondary)
        TextField("搜索你喜欢的角色", text: $query).font(.system(size: 14)).submitLabel(.search)
          .onSubmit { refresh() }
        if !query.isEmpty { Button { query = ""; refresh() } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.gray) } }
      }.padding(12).background(Color.black.opacity(0.035), in: Capsule()).padding(.horizontal, 16).padding(.top, 8)
      HStack(spacing: 0) {
        segment("热门标签", active: !ranking) { ranking = false }
        segment("排行榜", active: ranking) { ranking = true; refresh() }
      }.padding(4).background(Color.black.opacity(0.04), in: Capsule()).padding(.horizontal, 50)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(store.categories) { item in
            Button { category = item["code"]; refresh() } label: {
              Text(item.name).font(.system(size: 13, weight: category == item["code"] ? .semibold : .regular))
                .padding(.horizontal, 15).padding(.vertical, 9)
                .background(category == item["code"] ? Color.black : Color.black.opacity(0.04), in: Capsule())
                .foregroundStyle(category == item["code"] ? .white : QQStyle.ink)
            }
          }
        }.padding(.horizontal, 16)
      }
      ScrollView {
        if let error = store.error, store.roles.isEmpty { QQEmptyState(text: error, action: refresh) }
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
          ForEach(ranking ? ranked : store.roles) { role in NavigationLink(value: role) { QQRoleTile(role: role) }.buttonStyle(.plain) }
        }.padding(.horizontal, 16)
        if store.loading { ProgressView().padding() }
        else if !ranking && !store.roles.isEmpty && !exhausted {
          Button("加载更多") {
            page += 1
            Task { let count = store.roles.count; await store.loadRoles(category: category, keyword: query, page: page); exhausted = store.roles.count == count }
          }.padding(20).font(.system(size: 13))
        } else if (ranking ? ranked : store.roles).isEmpty && !store.loading { QQEmptyState() }
      }.refreshable { await store.loadRoles(category: category, keyword: query) }
    }.background(.white).task { if store.roles.isEmpty { refresh() } }
  }
  private func segment(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) { Text(title).font(.system(size: 14, weight: active ? .semibold : .regular)).frame(maxWidth: .infinity).padding(.vertical, 10).background(active ? .white : .clear, in: Capsule()) }
  }
  private func refresh() {
    page = 1; exhausted = false
    Task {
      if ranking {
        do { ranked = try await store.api.request("home/roleRank", parameters: ["type": "1", "category": category]).records }
        catch { store.error = error.localizedDescription }
      } else { await store.loadRoles(category: category, keyword: query) }
    }
  }
}
