// Compile with Models, API, Store and InteractionFixtures. No live networking.
import Foundation

@main struct QingqingStoreCheck {
  @MainActor static func main() async {
    var store = QQInteractionFixtures.store(mode: "navigation")
    let initialStore = store
    async let startup: Void = initialStore.start()
    async let visibleHome: Void = initialStore.loadSection(0)
    _ = await (startup, visibleHome)
    precondition(QQInteractionProtocol.count("home/getRecommend") == 1 && store.loggedIn)
    await store.loadSection(0)
    precondition(QQInteractionProtocol.count("home/getRecommend") == 1)
    await store.loadSection(0, force: true)
    precondition(QQInteractionProtocol.count("home/getRecommend") == 2)
    print("PASS startup/home deduplication, cached tab return and explicit refresh")

    store = QQInteractionFixtures.store(mode: "section-error")
    let sectionStore = store
    async let group: Void = sectionStore.loadSection(1)
    async let theater: Void = sectionStore.loadSection(3)
    try? await Task.sleep(for: .milliseconds(450))
    precondition(store.sectionErrors[1] != nil && store.sectionErrors[3] == nil && store.loadingSections.contains(3))
    _ = await (group, theater)
    precondition(store.theaters.count == 3 && store.loadingSections.isEmpty)
    print("PASS late section failure cannot hide another section's loading or replace its error")

    store = QQInteractionFixtures.store(mode: "navigation")
    let slowStore = store
    async let slow: Int? = slowStore.loadRoles(category: "slow")
    try? await Task.sleep(for: .milliseconds(20))
    let fast = await store.loadRoles(category: "fast")
    _ = await slow
    precondition(fast == 20 && store.roles.count == 20 && store.roles.allSatisfy { $0.id.hasPrefix("fast-") } && !store.rolesLoading)
    print("PASS category response ordering discards stale results")

    store = QQInteractionFixtures.store(mode: "paging")
    await store.loadRoles()
    let failure = await store.loadRoles(page: 2)
    precondition(failure == nil && store.roles.count == 20 && store.rolesError != nil)
    let retry = await store.loadRoles(page: 2)
    precondition(retry == 20 && store.roles.count == 40 && store.rolesError == nil && QQInteractionProtocol.count("roles.all.2") == 2)
    print("PASS failed page can retry the same page without losing records or skipping ahead")

    store = QQInteractionFixtures.store(mode: "navigation")
    await store.loadRoles()
    let pagingStore = store
    async let first: Int? = pagingStore.loadRoles(page: 2)
    async let duplicate: Int? = pagingStore.loadRoles(page: 2)
    _ = await (first, duplicate)
    precondition(store.roles.count == 40 && QQInteractionProtocol.count("roles.all.2") == 1)
    print("PASS duplicate pagination clicks share one effective page request")

    let skipped = await store.loadRoles(page: 4)
    let mixed = await store.loadRoles(category: "fast", page: 2)
    precondition(skipped == nil && mixed == nil && QQInteractionProtocol.count("roles.all.4") == 0 && QQInteractionProtocol.count("roles.fast.2") == 0)
    print("PASS out-of-sequence and mixed-category pagination are rejected before networking")

    store = QQInteractionFixtures.store(mode: "refresh-failure")
    await store.loadRoles(); await store.loadRoles(page: 2)
    let refreshFailure = await store.loadRoles()
    precondition(refreshFailure == nil && store.roles.count == 40 && store.lastLoadedRolePage == 2)
    await store.loadRoles(page: 3)
    precondition(QQInteractionProtocol.count("roles.all.3") == 1)
    print("PASS failed pull-to-refresh preserves the last successful pagination cursor")

    store = QQInteractionFixtures.store(mode: "navigation")
    let cancelStore = store
    let request = Task { @MainActor in await cancelStore.loadRoles(category: "slow") }
    try? await Task.sleep(for: .milliseconds(20)); request.cancel()
    _ = await request.value
    precondition(store.rolesError == nil && !store.rolesLoading)
    await store.loadRoles(category: "fast")
    precondition(store.roles.count == 20 && store.roles.first?.id == "fast-1")
    print("PASS cancellation leaves no false network error and the next filter remains usable")
  }
}
