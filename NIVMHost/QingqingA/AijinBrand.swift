import Foundation

/// A-side identity. Keep bundle IDs, URL callbacks and stored account keys stable.
enum AijinBrand {
  static let displayName = "爱锦"

  /// Existing layouts use reference-artwork names. Resolve only brand artwork
  /// here so role content, payment illustrations and B-side assets stay intact.
  static func assetName(for artwork: String) -> String {
    switch artwork {
    case "res_logo", "wd_tx": return "AijinLogo"
    case "invite_pic_null", "memory_ico_null": return "AijinMascot"
    case "invite_pic_banner2": return "AijinInviteBackground"
    default: return "qq_" + artwork
    }
  }
}
