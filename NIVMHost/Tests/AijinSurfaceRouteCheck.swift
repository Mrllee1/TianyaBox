import Foundation

@main
struct AijinSurfaceRouteCheck {
  static func main() {
    let suite = "AijinRouteCompatibility." + UUID().uuidString
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    precondition(AijinSurfaceRoute.initialSurface(defaults: defaults) == .ai)
    defaults.set(true, forKey: "tempmail.appCenterActivatedFromExternalIntent")
    precondition(AijinSurfaceRoute.initialSurface(defaults: defaults) == .box)
    var checked = 2
    for scheme in ["aijin", "tempmail", "AIJIN", "TEMPMAIL"] {
      for command in ["ai", "chat", "privacy", "focus"] {
        precondition(AijinSurfaceRoute.surface(for: URL(string: scheme + "://" + command)!) == .ai)
        checked += 1
      }
      for command in ["box", "open?id=tianya", "install", "native", "/box"] {
        precondition(AijinSurfaceRoute.surface(for: URL(string: scheme + "://" + command)!) == .box)
        checked += 1
      }
      for command in ["sandbox.relaunch", "playbox.guestapp.relaunch", "unknown"] {
        precondition(AijinSurfaceRoute.surface(for: URL(string: scheme + "://" + command)!) == nil)
        checked += 1
      }
    }
    precondition(!AijinSurfaceRoute.supports(scheme: "https"))
    precondition(AijinSurfaceRoute.surface(for: URL(string: "https://3601.help")!) == nil)
    print("AIJIN_ROUTE_COMPATIBILITY_OK checks=\(checked + 2)")
  }
}
