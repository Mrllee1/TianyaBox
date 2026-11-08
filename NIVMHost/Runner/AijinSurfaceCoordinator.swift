import SwiftUI
import UIKit

final class AijinSurfaceCoordinatorViewController: UIViewController {
  private let defaults: UserDefaults
  private var currentSurface: AijinSurface?
  private var currentController: UIViewController?

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    let initialSurface = AijinSurfaceRoute.initialSurface(defaults: defaults)
    show(
      initialSurface,
      animated: false,
      persist: false
    )
    print("AIJIN_SURFACE initial=\(initialSurface == .ai ? "ai" : "box")")
  }

  @discardableResult
  func handle(url: URL) -> Bool {
    guard let scheme = url.scheme?.lowercased(),
          AijinSurfaceRoute.supports(scheme: scheme) else {
      return false
    }
    guard let surface = AijinSurfaceRoute.surface(for: url) else {
      // The relaunch URL intentionally preserves the currently activated face.
      let host = url.host?.lowercased()
      return host == "sandbox.relaunch" || host == "playbox.guestapp.relaunch"
    }
    show(surface, animated: view.window != nil, persist: true)
    print("AIJIN_SURFACE url=\(url.absoluteString) selected=\(surface == .ai ? "ai" : "box")")
    return true
  }

  private func show(
    _ surface: AijinSurface,
    animated: Bool,
    persist: Bool
  ) {
    guard surface != currentSurface else {
      return
    }

    if persist {
      defaults.set(surface == .box, forKey: AijinSurfaceRoute.activatedKey)
      defaults.synchronize()
    }

    let nextController: UIViewController
    switch surface {
    case .ai:
      nextController = UIHostingController(rootView: QingqingRootView())
    case .box:
      nextController = AijinLauncherViewController()
    }

    addChild(nextController)
    nextController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(nextController.view)
    NSLayoutConstraint.activate([
      nextController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      nextController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      nextController.view.topAnchor.constraint(equalTo: view.topAnchor),
      nextController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    nextController.didMove(toParent: self)

    let previousController = currentController
    currentController = nextController
    currentSurface = surface

    let finishTransition = {
      previousController?.willMove(toParent: nil)
      previousController?.view.removeFromSuperview()
      previousController?.removeFromParent()
    }

    guard animated, let previousController else {
      finishTransition()
      return
    }

    nextController.view.alpha = 0
    UIView.animate(
      withDuration: 0.22,
      animations: {
        nextController.view.alpha = 1
        previousController.view.alpha = 0
      },
      completion: { _ in
        previousController.view.alpha = 1
        finishTransition()
      }
    )
  }
}
