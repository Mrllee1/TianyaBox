import XCTest
@testable import AijinAI

final class RunnerTests: XCTestCase {
  func testFreshLaunchUsesAISurface() {
    let suiteName = "AijinSurfaceTests.fresh.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }

    XCTAssertEqual(AijinSurfaceRoute.initialSurface(defaults: defaults), .ai)
  }

  func testLaunchRestoresSurfaceSelectedByAnEarlierDeepLink() {
    let suiteName = "AijinSurfaceTests.persisted.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer { defaults.removePersistentDomain(forName: suiteName) }
    defaults.set(true, forKey: AijinSurfaceRoute.activatedKey)

    XCTAssertEqual(AijinSurfaceRoute.initialSurface(defaults: defaults), .box)
  }

  func testDeepLinksSelectSupportedSurfaces() {
    XCTAssertEqual(AijinSurfaceRoute.surface(for: URL(string: "aijin://box")!), .box)
    XCTAssertEqual(AijinSurfaceRoute.surface(for: URL(string: "aijin://open?id=tianya")!), .box)
    XCTAssertEqual(AijinSurfaceRoute.surface(for: URL(string: "aijin://install")!), .box)
    XCTAssertEqual(AijinSurfaceRoute.surface(for: URL(string: "aijin://native")!), .box)
    XCTAssertEqual(AijinSurfaceRoute.surface(for: URL(string: "aijin://ai")!), .ai)
    XCTAssertEqual(AijinSurfaceRoute.surface(for: URL(string: "aijin://focus")!), .ai)
  }

  func testGuestRelaunchPreservesCurrentSurface() {
    XCTAssertNil(AijinSurfaceRoute.surface(for: URL(string: "tempmail://sandbox.relaunch")!))
    XCTAssertNil(AijinSurfaceRoute.surface(for: URL(string: "aijin://playbox.guestapp.relaunch")!))
  }

  func testUnsupportedURLsAreIgnored() {
    XCTAssertFalse(AijinSurfaceRoute.supports(scheme: "https"))
    XCTAssertNil(AijinSurfaceRoute.surface(for: URL(string: "https://3601.help")!))
    XCTAssertNil(AijinSurfaceRoute.surface(for: URL(string: "aijin://unknown")!))
  }
}
