import XCTest

/// Runs only the separate preview bundle. No phone login, purchase, chat send,
/// memory save, room creation, gift or publication action is available here.
final class QingqingPreviewUITests: XCTestCase {
  override func setUpWithError() throws { continueAfterFailure = false }

  func testTheaterCanSwitchBackToRecommendation() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=theater"]
    app.launch()
    let more = app.buttons["更多剧场"]
    XCTAssertTrue(more.waitForExistence(timeout: 40))
    capture(app, "theater-before-category-tap")
    let tree = XCTAttachment(string: app.debugDescription)
    tree.name = "theater-hit-regions"; tree.lifetime = .keepAlways; add(tree)
    app.buttons["推荐"].tap()
    let leftTheater = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: more)
    XCTAssertEqual(XCTWaiter.wait(for: [leftTheater], timeout: 5), .completed)
    capture(app, "recommendation-after-theater")
  }

  func testAllHomeSectionsAndBottomBarRemainReachable() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    for mode in ["navigation-fixture", "compact-navigation-fixture"] {
      app.launchArguments = ["--qq=" + mode]
      app.launch()
      XCTAssertTrue(app.buttons["qingqing.home.section.0"].waitForExistence(timeout: 10))
      for index in [3, 0, 1, 2, 3, 1, 0, 3] {
        let tab = app.buttons["qingqing.home.section.\(index)"]
        XCTAssertTrue(tab.isHittable)
        tab.tap()
        XCTAssertTrue(tab.isSelected)
      }
      let more = app.buttons["qingqing.theater.slot.4"]
      XCTAssertTrue(more.waitForExistence(timeout: 10))
      more.tap()
      XCTAssertTrue(app.staticTexts["剧场验收剧情1"].exists)
      XCTAssertTrue(app.buttons["聊天"].isHittable)
      capture(app, mode + "-theater-bounds")
      for index in [1, 3, 2, 0] {
        let tab = app.buttons["qingqing.tab.\(index)"]
        // Exercise the bar cell's upper edge, outside the 24-point icon.
        tab.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08)).tap()
        XCTAssertTrue(tab.isSelected)
      }
      app.buttons["会员中心"].tap()
      let back = app.buttons["返回"]
      XCTAssertTrue(back.waitForExistence(timeout: 10))
      back.tap()
      XCTAssertTrue(app.buttons["qingqing.home.section.3"].isSelected)
      app.terminate()
    }
  }

  func testDiscoveryPaginationFailureRetryAndModeSwitching() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=discovery-fixture"]
    app.launch()
    XCTAssertTrue(app.buttons["qingqing.library.role.all-1"].waitForExistence(timeout: 10))
    app.buttons["qingqing.category.slow"].tap()
    app.buttons["qingqing.category.fast"].tap()
    XCTAssertTrue(app.buttons["qingqing.library.role.fast-1"].waitForExistence(timeout: 10))
    app.buttons["qingqing.category.all"].tap()
    XCTAssertTrue(app.buttons["qingqing.library.role.all-1"].waitForExistence(timeout: 10))
    let more = app.buttons["qingqing.library.load-more"]
    for _ in 0..<14 { if more.exists && more.isHittable { break }; app.swipeUp() }
    XCTAssertTrue(more.isHittable)
    more.tap()
    XCTAssertTrue(app.buttons["重试加载更多"].waitForExistence(timeout: 10))
    capture(app, "discovery-page-failure-preserves-results")
    more.tap()
    XCTAssertTrue(app.buttons["qingqing.library.role.all-21"].waitForExistence(timeout: 10))
    app.buttons["排行榜"].tap()
    XCTAssertTrue(app.staticTexts["排行验收角色"].waitForExistence(timeout: 10))
    app.buttons["热门标签"].tap()
    app.swipeDown()
    XCTAssertTrue(app.buttons["qingqing.library.role.all-1"].waitForExistence(timeout: 10))
  }

  func testFailedHomeSectionStillAllowsSwitching() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=section-error-fixture"]
    app.launch()
    let group = app.buttons["qingqing.home.section.1"]
    XCTAssertTrue(group.waitForExistence(timeout: 10))
    group.tap()
    XCTAssertTrue(app.buttons["重新加载"].waitForExistence(timeout: 10))
    app.buttons["qingqing.home.section.3"].tap()
    XCTAssertTrue(app.buttons["更多剧场"].waitForExistence(timeout: 10))
    app.buttons["qingqing.home.section.0"].tap()
    XCTAssertTrue(app.buttons["推荐验收角色"].waitForExistence(timeout: 10))
    XCTAssertFalse(app.buttons["重新加载"].exists)
  }

  func testSupportingSimulatorIdentityCannotBeAssignedToPlayer() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=cast-guards-fixture"]
    app.launch()
    let main = app.buttons["qingqing.cast.self.lead"]
    XCTAssertTrue(main.waitForExistence(timeout: 10))
    XCTAssertTrue(main.isEnabled)
    XCTAssertFalse(app.buttons["qingqing.cast.self.support"].isEnabled)
    capture(app, "simulator-playable-identity-guards")
  }

  func testFailedChatDoesNotOverwriteNewTyping() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=chat-draft-fixture"]
    app.launch()
    let input = app.descendants(matching: .any)["qingqing.chat.input"]
    XCTAssertTrue(input.waitForExistence(timeout: 10))
    input.tap(); input.typeText("first draft")
    app.buttons["发送消息"].tap()
    input.tap(); input.typeText("new draft")
    let recover = app.buttons["恢复未发送内容"]
    XCTAssertTrue(recover.waitForExistence(timeout: 12))
    XCTAssertEqual(input.value as? String, "new draft")
    recover.tap()
    XCTAssertTrue((input.value as? String ?? "").contains("first draft"))
    XCTAssertTrue((input.value as? String ?? "").contains("new draft"))
    capture(app, "failed-chat-keeps-both-drafts-fixture")
  }

  func testComposerInputExpansionBracketsAndDarkSendArtwork() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    for mode in ["chat-draft-fixture", "chat-input-dark-fixture"] {
      app.launchArguments = ["--qq=" + mode]; app.launch()
      let input = app.textViews["qingqing.chat.input"]
      XCTAssertTrue(input.waitForExistence(timeout: 10))
      XCTAssertFalse(app.buttons["发送消息"].exists)
      app.buttons["更多功能"].tap()
      XCTAssertTrue(app.buttons["重启会话"].exists)
      input.tap()
      XCTAssertFalse(app.buttons["重启会话"].exists)
      XCTAssertTrue(app.buttons["插入括号"].exists)
      input.typeText("hello")
      let send = app.buttons["发送消息"]
      XCTAssertTrue(send.isEnabled && send.isHittable)
      XCTAssertFalse(app.buttons["回复灵感"].exists)
      app.buttons["插入括号"].tap()
      input.typeText("inside")
      XCTAssertEqual(input.value as? String, "hello（inside）")
      input.typeText("\nsecond line\nthird line")
      XCTAssertGreaterThan(input.frame.height, 40)
      capture(app, mode + "-expanded-send")
      input.typeText("\n4\n5\n6")
      XCTAssertTrue((input.value as? String ?? "").contains("third line\n4\n5\n6"))
      XCTAssertLessThanOrEqual(input.frame.height, 85)
      XCTAssertTrue(send.isHittable)
      capture(app, mode + "-four-line-scroll-limit")
      app.terminate()
    }
    app.launchArguments = ["--qq=chat-draft-fixture"]; app.launch()
    let input = app.textViews["qingqing.chat.input"]
    XCTAssertTrue(input.waitForExistence(timeout: 10)); input.tap(); input.typeText("   ")
    XCTAssertFalse(app.buttons["发送消息"].isEnabled)
  }

  func testReplyIdeasAndMorePanelAreExclusive() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=chat-draft-fixture"]; app.launch()
    let input = app.textViews["qingqing.chat.input"]
    XCTAssertTrue(input.waitForExistence(timeout: 10))
    app.buttons["回复灵感"].tap()
    let idea = app.buttons["合成回复灵感一"]
    app.buttons["更多功能"].tap()
    let completed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: app.buttons["回复灵感"])
    XCTAssertEqual(XCTWaiter.wait(for: [completed], timeout: 6), .completed)
    XCTAssertFalse(idea.exists)
    XCTAssertTrue(app.buttons["重启会话"].exists)
    app.buttons["回复灵感"].tap()
    XCTAssertTrue(idea.waitForExistence(timeout: 10))
    app.buttons["更多功能"].tap()
    XCTAssertFalse(idea.exists)
    app.buttons["回复灵感"].tap()
    XCTAssertTrue(idea.waitForExistence(timeout: 10))
    XCTAssertFalse(app.buttons["重启会话"].exists)
    app.buttons["查看回复灵感1全文"].tap()
    XCTAssertTrue(app.buttons["关闭灵感全文"].waitForExistence(timeout: 5))
    app.buttons["关闭灵感全文"].tap()
    capture(app, "reply-ideas-original-card-panel")
    app.buttons["填入回复灵感1"].tap()
    XCTAssertEqual(input.value as? String, "合成回复灵感一")
    XCTAssertTrue(app.buttons["插入括号"].exists)
  }

  func testMemberSelectionIsPreservedAcrossVipAndDiamondTabs() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    for mode in ["member-purchase-fixture", "compact-member-purchase-fixture"] {
      app.launchArguments = ["--qq=" + mode]; app.launch()
      let vip = app.buttons["qingqing.member.package.qa-vip-long"]
      XCTAssertTrue(vip.waitForExistence(timeout: 10)); capture(app, mode + "-vip-default"); vip.tap()
      let ali = app.buttons["qingqing.member.way.qa-alipay"]
      if !ali.isHittable { app.swipeUp() }
      ali.tap(); XCTAssertTrue(ali.isSelected)
      app.buttons["qingqing.member.tab.1"].tap()
      let coin = app.buttons["qingqing.member.package.qa-coin-1"]
      XCTAssertTrue(coin.waitForExistence(timeout: 10)); capture(app, mode + "-diamond-default"); coin.tap()
      XCTAssertTrue(app.buttons["qingqing.member.way.qa-wechat"].isSelected)
      capture(app, mode + "-diamond-selected")
      app.buttons["qingqing.member.tab.0"].tap()
      XCTAssertTrue(vip.isSelected); XCTAssertTrue(ali.isSelected)
      let purchase = app.buttons["qingqing.member.purchase"]
      for _ in 0..<8 { if purchase.isHittable { break }; app.swipeUp() }
      XCTAssertTrue(purchase.isEnabled && purchase.isHittable)
      capture(app, mode + "-vip-selected")
      purchase.tap()
      XCTAssertTrue(app.buttons["确认支付 ¥500"].waitForExistence(timeout: 5))
      // Do not confirm: no order, payment or web checkout is executed.
      app.terminate()
    }
  }

  func testEmptyMemberCatalogCannotStartPurchase() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=member-empty-fixture"]; app.launch()
    XCTAssertTrue(app.staticTexts["当前暂无可购买的套餐"].waitForExistence(timeout: 10))
    let purchase = app.buttons["qingqing.member.purchase"]
    XCTAssertTrue(purchase.exists); XCTAssertFalse(purchase.isEnabled)
    app.buttons["qingqing.member.tab.1"].tap()
    XCTAssertFalse(purchase.isEnabled)
    capture(app, "empty-member-catalog-no-purchase")
  }

  func testExpiredMemberOfferCannotStartPurchase() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=member-expiring-fixture"]; app.launch()
    let offer = app.buttons["qingqing.member.package.qa-vip-trial"]
    XCTAssertTrue(offer.waitForExistence(timeout: 10))
    let purchase = app.buttons["qingqing.member.purchase"]
    XCTAssertTrue(purchase.isEnabled)
    let expired = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == false"), object: purchase)
    XCTAssertEqual(XCTWaiter.wait(for: [expired], timeout: 10), .completed)
    XCTAssertTrue(app.buttons["重新加载套餐"].exists)
    capture(app, "expired-member-offer-no-purchase")
  }

  func testLongPageTitleLeavesBackButtonReachable() {
    let app = XCUIApplication(bundleIdentifier: "com.tianyabox.qingqing.preview")
    app.launchArguments = ["--qq=long-header-fixture"]
    app.launch()
    let open = app.buttons["打开长标题页面"]
    XCTAssertTrue(open.waitForExistence(timeout: 10))
    open.tap()
    let back = app.buttons["返回"]
    XCTAssertTrue(back.waitForExistence(timeout: 10))
    let title = app.staticTexts[String(repeating: "很长的验收标题", count: 5)]
    XCTAssertTrue(title.exists)
    XCTAssertGreaterThanOrEqual(title.frame.minX, back.frame.maxX)
    XCTAssertTrue(back.isHittable)
    capture(app, "long-title-bounded-header-fixture")
    back.tap()
    XCTAssertTrue(open.waitForExistence(timeout: 10))
  }

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
