import Foundation
enum TempMailSurface: Equatable {
  case privacy
  case box
}

enum TempMailSurfaceRoute {
  static let activatedKey = "tempmail.appCenterActivatedFromExternalIntent"
  private static let supportedSchemes: Set<String> = ["tempmail"]

  static func supports(scheme: String) -> Bool {
    supportedSchemes.contains(scheme.lowercased())
  }

  static func initialSurface(
    defaults: UserDefaults = .standard
  ) -> TempMailSurface {
    return defaults.bool(forKey: activatedKey) ? .box : .privacy
  }

  static func surface(for url: URL) -> TempMailSurface? {
    guard let scheme = url.scheme?.lowercased(), supports(scheme: scheme) else {
      return nil
    }
    let host = (url.host ?? "").lowercased()
    let path = url.path
      .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
      .lowercased()
    let command = host.isEmpty ? path : host

    switch command {
    case "box", "open", "install", "native":
      return .box
    case "privacy", "focus":
      return .privacy
    case "sandbox.relaunch", "playbox.guestapp.relaunch":
      return nil
    default:
      return nil
    }
  }
}


let suite = "TianyaBox.RouteCheck.\(UUID().uuidString)"
let defaults = UserDefaults(suiteName: suite)!
defer { defaults.removePersistentDomain(forName: suite) }
precondition(TempMailSurfaceRoute.initialSurface(defaults: defaults) == .privacy)
defaults.set(true, forKey: TempMailSurfaceRoute.activatedKey)
precondition(TempMailSurfaceRoute.initialSurface(defaults: defaults) == .box)
precondition(TempMailSurfaceRoute.surface(for: URL(string: "tempmail://privacy")!) == .privacy)
precondition(TempMailSurfaceRoute.surface(for: URL(string: "tempmail://box")!) == .box)
precondition(TempMailSurfaceRoute.surface(for: URL(string: "tempmail://sandbox.relaunch")!) == nil)
precondition(!TempMailSurfaceRoute.supports(scheme: "https"))
print("PASS: fresh mailbox, remembered box, A/B links, preserved relaunch, rejected scheme")
