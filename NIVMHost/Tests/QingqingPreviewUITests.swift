import XCTest

/// Runs only the separate preview bundle. No phone login, purchase, chat send,
/// memory save, room creation, gift or publication action is available here.
final class QingqingPreviewUITests: XCTestCase {
  override func setUpWithError() throws { continueAfterFailure = false }

  func testLiveAgentSearchClearAndScroll() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=agent-picker"]
    app.launch()
    let search = app.textFields["搜索角色"]
    XCTAssertTrue(search.waitForExistence(timeout: 45))
    let roles = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "qingqing.agent."))
    XCTAssertTrue(roles.firstMatch.waitForExistence(timeout: 30))
    capture(app, "live-agent-first-page")
    app.swipeUp()
    XCTAssertTrue(roles.firstMatch.exists)
    app.swipeDown()
    search.tap()
    search.typeText("qa-no-role-20261108")
    XCTAssertTrue(app.staticTexts["暂无角色～"].waitForExistence(timeout: 30))
    capture(app, "live-agent-empty-search")
    app.buttons["清除搜索"].tap()
    XCTAssertTrue(roles.firstMatch.waitForExistence(timeout: 30))
    capture(app, "live-agent-restored-search")
  }

  func testMemoryOfferLayoutsAreNonPurchasableFixtures() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    for mode in ["memory-capacity-fixture", "memory-unlock-fixture", "memory-owned-fixture"] {
      app.launchArguments = ["--qq=" + mode]
      app.launch()
      XCTAssertTrue(app.staticTexts["合成布局验收 · 未请求业务接口"].waitForExistence(timeout: 10))
      if mode == "memory-owned-fixture" { XCTAssertTrue(app.staticTexts["已解锁最高记忆条数"].exists) }
      else {
        let buy = app.buttons[mode == "memory-capacity-fixture" ? "立即购买" : "立即解锁"]
        XCTAssertTrue(buy.exists)
        XCTAssertFalse(buy.isEnabled)
      }
      capture(app, mode)
      app.terminate()
    }
  }

  func testBackgroundSelectionPersistsInPreviewContainer() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=background-sheet-fixture"]
    app.launch()
    let solid = app.buttons["纯色背景"]
    XCTAssertTrue(solid.waitForExistence(timeout: 10))
    XCTAssertTrue(app.staticTexts["自定义上传\n仅本地保存"].exists)
    solid.tap()
    XCTAssertEqual(solid.value as? String, "已选择")
    let save = app.buttons["设为聊天背景"]
    XCTAssertTrue(save.isHittable)
    capture(app, "background-selected-fixture")
    save.tap()
    let open = app.buttons["打开背景设置"]
    XCTAssertTrue(open.waitForExistence(timeout: 10))
    open.tap()
    XCTAssertTrue(solid.waitForExistence(timeout: 10))
    XCTAssertEqual(solid.value as? String, "已选择")
    app.buttons["默认背景"].tap()
    save.tap()
  }

  func testCustomBackgroundImagePreviewZoomAndReturn() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=background-custom-fixture"]
    app.launch()
    let open = app.buttons["查看自定义背景大图"]
    XCTAssertTrue(open.waitForExistence(timeout: 10))
    open.tap()
    let image = app.images["图片预览"]
    XCTAssertTrue(image.waitForExistence(timeout: 10))
    XCTAssertEqual(image.value as? String, "100%")
    image.doubleTap()
    let zoomed = NSPredicate(format: "value != %@", "100%")
    expectation(for: zoomed, evaluatedWith: image)
    waitForExpectations(timeout: 5)
    let doubleTapScale = image.value as? String
    image.pinch(withScale: 1.2, velocity: 1)
    XCTAssertNotEqual(image.value as? String, doubleTapScale)
    capture(app, "custom-image-zoom-fixture")
    image.tap()
    XCTAssertTrue(open.waitForExistence(timeout: 10))
  }

  private func capture(_ app: XCUIApplication, _ name: String) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name; attachment.lifetime = .keepAlways
    add(attachment)
  }
}
