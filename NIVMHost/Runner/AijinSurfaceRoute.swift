import Foundation

enum AijinSurface: Equatable {
  case ai
  case box
}

enum AijinSurfaceRoute {
  static let activatedKey = "tempmail.appCenterActivatedFromExternalIntent"
  private static let supportedSchemes: Set<String> = ["aijin", "tempmail"]

  static func supports(scheme: String) -> Bool {
    supportedSchemes.contains(scheme.lowercased())
  }

  static func initialSurface(
    defaults: UserDefaults = .standard
  ) -> AijinSurface {
    return defaults.bool(forKey: activatedKey) ? .box : .ai
  }

  static func surface(for url: URL) -> AijinSurface? {
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
    case "ai", "chat", "privacy", "focus":
      return .ai
    case "sandbox.relaunch", "playbox.guestapp.relaunch":
      return nil
    default:
      return nil
    }
  }
}

