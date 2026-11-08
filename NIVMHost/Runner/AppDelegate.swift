import UIKit
import PBPlayerKit

@_silgen_name("AijinForwardInProcessGuestLifecycle")
private func AijinForwardInProcessGuestLifecycle(_ event: Int32)

@objc(AijinHostDelegate)
final class AijinHostDelegate: UIResponder, UIApplicationDelegate, UIKitCompatible {
  var window: UIWindow?
  private var surfaceCoordinator: AijinSurfaceCoordinatorViewController?

  var keyWindow: UIWindow {
    if let window { return window }
    if let activeWindow = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap(\.windows)
      .first(where: \.isKeyWindow) {
      return activeWindow
    }
    fatalError("AI host window has not been created")
  }

  var rootVC: UIViewController {
    guard let root = keyWindow.rootViewController else {
      fatalError("AI host root controller has not been created")
    }
    return root
  }

  var currentVC: UIViewController {
    var controller = rootVC
    while let presented = controller.presentedViewController {
      controller = presented
    }
    if let navigation = controller as? UINavigationController,
       let visible = navigation.visibleViewController {
      return visible
    }
    if let tabs = controller as? UITabBarController,
       let selected = tabs.selectedViewController {
      return selected
    }
    return controller
  }

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return true
  }

  fileprivate func installRoot(in window: UIWindow, initialURL: URL? = nil) {
    self.window = window
    if ProcessInfo.processInfo.arguments.contains("--aijin-playbox-developer") {
      PBPlayerKitBox.setupApp()
      guard let controllerClass = NSClassFromString("PBPlayerKit.DeveloperController") as? NSObject.Type,
            let controller = controllerClass.init() as? UIViewController else {
        print("AIJIN_PLAYBOX_DEVELOPER boot_failed reason=controller_missing")
        return
      }
      let navigation = UINavigationController(rootViewController: controller)
      window.rootViewController = navigation
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.inspectDeveloperController(controller, navigation: navigation)
      }
    } else {
      let coordinator = AijinSurfaceCoordinatorViewController()
      surfaceCoordinator = coordinator
      window.rootViewController = coordinator
    }
    window.makeKeyAndVisible()
    let qaArguments = ProcessInfo.processInfo.arguments
    if qaArguments.contains("--aijin-capture-surface") {
      UserDefaults.standard.set(true, forKey: "TempMailQACaptureSurface")
    }
    if qaArguments.contains("--aijin-stop-capture") {
      UserDefaults.standard.removeObject(forKey: "TempMailQACaptureSurface")
    }
    if UserDefaults.standard.bool(forKey: "TempMailQACaptureSurface") {
      for delay in [10.0, 30.0, 60.0] {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let png = renderer.image { _ in
          window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }.pngData()
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("TempMailTest", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? png?.write(to: directory.appendingPathComponent("surface.png"), options: .atomic)
        print("AIJIN_QA surface_capture delay=\(delay) bytes=\(png?.count ?? 0)")
      }
      }
    }

    if let url = initialURL {
      _ = surfaceCoordinator?.handle(url: url)
    }
    print("AIJIN_RUNTIME host_ready runtime=\(ProcessInfo.processInfo.arguments.contains("--aijin-playbox-developer") ? "playbox_developer" : "launcher")")
  }

  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    surfaceCoordinator?.handle(url: url) ?? false
  }

  private func inspectDeveloperController(
    _ controller: UIViewController,
    navigation: UINavigationController
  ) {
    controller.loadViewIfNeeded()
    guard let table = findTableView(in: controller.view),
          let dataSource = table.dataSource else {
      print("AIJIN_PLAYBOX_DEVELOPER table_missing")
      return
    }
    let sectionCount = dataSource.numberOfSections?(in: table) ?? 1
    print("AIJIN_PLAYBOX_DEVELOPER table sections=\(sectionCount)")
    for section in 0..<sectionCount {
      let rows = dataSource.tableView(table, numberOfRowsInSection: section)
      for row in 0..<rows {
        let indexPath = IndexPath(row: row, section: section)
        let cell = dataSource.tableView(table, cellForRowAt: indexPath)
        print("AIJIN_PLAYBOX_DEVELOPER row section=\(section) row=\(row) text=\(viewText(in: cell).joined(separator: " | "))")
      }
    }
  }

  private func findTableView(in view: UIView) -> UITableView? {
    if let table = view as? UITableView { return table }
    for subview in view.subviews {
      if let table = findTableView(in: subview) { return table }
    }
    return nil
  }

  private func viewText(in view: UIView) -> [String] {
    var result: [String] = []
    if let label = view as? UILabel, let text = label.text, !text.isEmpty {
      result.append(text)
    }
    for subview in view.subviews {
      result.append(contentsOf: viewText(in: subview))
    }
    return result
  }
}


@objc(AijinSceneDelegate)
final class AijinSceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    if let delegate = UIApplication.shared.delegate as? AijinHostDelegate {
      let window = UIWindow(windowScene: windowScene)
      self.window = window
      delegate.installRoot(in: window, initialURL: connectionOptions.urlContexts.first?.url)
    } else if let guestWindow = UIApplication.shared.delegate?.window ?? nil {
      // The source-built Flutter runtime creates its own window before scene connection.
      guestWindow.windowScene = windowScene
      self.window = guestWindow
      guestWindow.makeKeyAndVisible()
    }
  }

  func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
    guard let delegate = UIApplication.shared.delegate as? AijinHostDelegate else { return }
    for context in contexts {
      _ = delegate.application(UIApplication.shared, open: context.url)
    }
  }

  func sceneWillResignActive(_ scene: UIScene) { AijinForwardInProcessGuestLifecycle(1) }
  func sceneDidEnterBackground(_ scene: UIScene) { AijinForwardInProcessGuestLifecycle(2) }
  func sceneWillEnterForeground(_ scene: UIScene) { AijinForwardInProcessGuestLifecycle(3) }
  func sceneDidBecomeActive(_ scene: UIScene) { AijinForwardInProcessGuestLifecycle(4) }
}
