import SwiftUI
import UIKit
import CoreImage

enum QQStyle {
  static let ink = Color(red: 0.055, green: 0.102, blue: 0.133)
  static let secondary = Color(red: 0.47, green: 0.49, blue: 0.50)
  static let background = Color(white: 245.0 / 255)
  static let gradient = LinearGradient(colors: [Color(red: 140.0/255, green: 242.0/255, blue: 227.0/255), Color(red: 105.0/255, green: 191.0/255, blue: 250.0/255), Color(red: 182.0/255, green: 145.0/255, blue: 253.0/255)], startPoint: .leading, endPoint: .trailing)
}

enum QQImagePalette {
  static func backdrop(_ address: String) async -> (Color, Bool)? {
    guard let url = URL(string: address), url.scheme == "https",
      let (data, _) = try? await URLSession.shared.data(from: url),
      let image = CIImage(data: data),
      let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: image, kCIInputExtentKey: CIVector(cgRect: image.extent)])?.outputImage else { return nil }
    var pixel = [UInt8](repeating: 0, count: 4)
    CIContext(options: [.workingColorSpace: NSNull()]).render(filter, toBitmap: &pixel, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
    let red = Double(pixel[0]) / 255, green = Double(pixel[1]) / 255, blue = Double(pixel[2]) / 255
    let dark = red * 0.299 + green * 0.587 + blue * 0.114 < 0.50
    return (Color(red: red, green: green, blue: blue), dark)
  }
}

struct QQArtwork: View {
  let name: String
  var body: some View {
    Image("qq_" + name).renderingMode(.original).resizable().scaledToFit()
  }
}

struct QQRemoteImage: View {
  let address: String
  var contentMode: ContentMode = .fill
  var body: some View {
    GeometryReader { geometry in
      AsyncImage(url: URL(string: address)) { phase in
        if let image = phase.image {
          image.resizable().aspectRatio(contentMode: contentMode)
            .frame(width: geometry.size.width, height: geometry.size.height).clipped()
        } else {
          ZStack {
            Color(white: 0.94)
            if phase.error != nil { Image(systemName: "photo").foregroundStyle(.gray.opacity(0.45)) }
            else if !address.isEmpty { ProgressView().tint(.gray) }
            else { QQArtwork(name: "wd_znt_pic_kong").frame(width: 88, height: 100) }
          }
        }
      }
    }.clipped().contentShape(Rectangle())
  }
}

struct QQPrimaryButton: View {
  @Environment(\.isEnabled) private var enabled
  let title: String
  var busy = false
  var icon: String? = nil
  let action: () -> Void
  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        if busy { ProgressView().tint(QQStyle.ink) }
        if let icon { QQArtwork(name: icon).frame(width: 14, height: 14) }
        Text(title).font(.system(size: 16, weight: .semibold))
      }.frame(maxWidth: .infinity).frame(height: 56)
        .foregroundStyle(enabled ? QQStyle.ink : QQStyle.ink.opacity(0.4)).background { if enabled { Capsule().fill(QQStyle.gradient) } else { Capsule().fill(Color(white: 230.0/255)) } }
    }.buttonStyle(QQPrimaryButtonStyle()).disabled(busy)
  }
}

private struct QQPrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View { configuration.label.opacity(configuration.isPressed ? 0.85 : 1) }
}

struct QQEmptyState: View {
  var text = "暂时没有内容～"
  var action: (() -> Void)?
  var body: some View {
    VStack(spacing: 16) {
      QQArtwork(name: "invite_pic_null").frame(width: 150, height: 150)
      Text(text).font(.system(size: 14)).foregroundStyle(QQStyle.secondary).multilineTextAlignment(.center)
      if let action { Button("重新加载", action: action).font(.system(size: 14)) }
    }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct QQTags: View {
  let tags: [String]
  var dark = false
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 6) {
        ForEach(Array(tags.prefix(6).enumerated()), id: \.offset) { _, tag in
          Text(tag).font(.system(size: 11)).foregroundStyle(dark ? .white : QQStyle.ink).padding(.horizontal, 9).padding(.vertical, 5)
            .background(dark ? .white.opacity(0.16) : .black.opacity(0.045), in: Capsule())
        }
      }
    }
  }
}

struct QQRoleTile: View {
  let role: QQRecord
  var compact = false
  var body: some View {
    Color.clear.aspectRatio(compact ? 108.0/169 : 170.0/264, contentMode: .fit).overlay {
      ZStack(alignment: .bottomLeading) {
        QQRemoteImage(address: compact ? role.first("img_url", "img_url_webp") : role.image)
        LinearGradient(colors: compact ? [.black.opacity(0.6), .clear] : [.clear, .black.opacity(0.88)], startPoint: .top, endPoint: .bottom).frame(height: compact ? 50 : 150)
        VStack(alignment: .leading, spacing: compact ? 2 : 12) {
          HStack(spacing: 4) {
            Text(role.name).font(.system(size: 14, weight: .bold)).lineLimit(1)
            Spacer(minLength: 0)
            if !compact && !role.first("msg_num", "chat_num", "hot", "heat").isEmpty {
              QQArtwork(name: "home_ico_comments").frame(width: 12, height: 12)
              Text(role.first("msg_num", "chat_num", "hot", "heat")).font(.system(size: 12)).lineLimit(1)
            }
          }
          Text(compact ? (role["tag"].isEmpty ? "" : "#" + role["tag"]) : role.intro).font(.system(size: compact ? 10 : 12)).foregroundStyle(Color(white: 211.0/255)).lineSpacing(2).lineLimit(compact ? 1 : 4).frame(maxWidth: .infinity, alignment: .leading)
        }.padding(10).foregroundStyle(.white)
      }.overlay(alignment: .topTrailing) {
        if ["男", "女"].contains(role["gender"]) { QQArtwork(name: role["gender"] == "男" ? "home_ico_male" : "home_ico_female").frame(width: 20, height: 20).padding(8) }
      }.clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}

// Original PAG artwork is rendered once during asset preparation, preserving
// alpha, timing and every frame. Playback uses ImageIO and adds no SDK network
// or analytics code to the app.
struct QQAnimatedAsset: UIViewRepresentable {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  let name: String
  func makeUIView(context: Context) -> UIImageView {
    let view = UIImageView(); view.contentMode = .scaleAspectFit; view.clipsToBounds = true
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    view.setContentHuggingPriority(.defaultLow, for: .vertical)
    return view
  }
  func updateUIView(_ view: UIImageView, context: Context) {
    guard let animation = QQAnimationCache.load(name) else { return }
    if context.coordinator.name != name || context.coordinator.reduceMotion != reduceMotion {
      view.stopAnimating(); view.animationImages = nil
      view.image = animation.frames.first
      if !reduceMotion && animation.frames.count > 1 {
        view.animationImages = animation.frames; view.animationDuration = animation.duration
        view.animationRepeatCount = 0; view.startAnimating()
      }
      context.coordinator.name = name; context.coordinator.reduceMotion = reduceMotion
    }
  }
  func makeCoordinator() -> Coordinator { Coordinator() }
  func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIImageView, context: Context) -> CGSize? {
    guard let width = proposal.width, let height = proposal.height else { return nil }
    return CGSize(width: width, height: height)
  }
  static func dismantleUIView(_ view: UIImageView, coordinator: Coordinator) { view.stopAnimating(); view.animationImages = nil; view.image = nil }
  final class Coordinator { var name = ""; var reduceMotion = false }
}

import ImageIO
private final class QQAnimationFrames {
  let frames: [UIImage]
  let duration: TimeInterval
  init(frames: [UIImage], duration: TimeInterval) { self.frames = frames; self.duration = duration }
}
@MainActor
private enum QQAnimationCache {
  static let cache: NSCache<NSString, QQAnimationFrames> = { let cache = NSCache<NSString, QQAnimationFrames>(); cache.totalCostLimit = 50_000_000; return cache }()
  static func load(_ name: String) -> QQAnimationFrames? {
    if let value = cache.object(forKey: name as NSString) { return value }
    guard let data = NSDataAsset(name: "qq_" + name)?.data, let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
    var frames: [UIImage] = []; var duration = 0.0; var cost = 0
    for index in 0..<CGImageSourceGetCount(source) {
      guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else { return nil }
      frames.append(UIImage(cgImage: image, scale: 3, orientation: .up)); cost += image.width * image.height * 4
      let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
      let png = properties?[kCGImagePropertyPNGDictionary] as? [CFString: Any]
      duration += (png?[kCGImagePropertyAPNGUnclampedDelayTime] as? Double) ?? (png?[kCGImagePropertyAPNGDelayTime] as? Double) ?? 0.04
    }
    let value = QQAnimationFrames(frames: frames, duration: duration)
    cache.setObject(value, forKey: name as NSString, cost: cost); return value
  }
}

struct QQRoleChatLink<Content: View>: View {
  @EnvironmentObject private var store: QingqingStore
  let role: QQRecord
  var kind: QQConversationKind = .single
  @ViewBuilder let label: () -> Content
  @State private var talking = false
  var body: some View {
    Button { store.requireLogin { talking = true } } label: { label() }.buttonStyle(.plain)
      .navigationDestination(isPresented: $talking) { QQChatView(role: role, kind: kind) }
  }
}

// Android's FlexboxLayout wraps author, activity and tag capsules naturally.
struct QQWrapLayout: Layout {
  var spacing: CGFloat = 6
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize { arrange(width: proposal.width ?? 350, subviews: subviews).size }
  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let layout = arrange(width: bounds.width, subviews: subviews)
    for (index, point) in layout.points.enumerated() { subviews[index].place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), anchor: .topLeading, proposal: .unspecified) }
  }
  private func arrange(width: CGFloat, subviews: Subviews) -> (size: CGSize, points: [CGPoint]) {
    var points: [CGPoint] = []; var x: CGFloat = 0; var y: CGFloat = 0; var rowHeight: CGFloat = 0
    for view in subviews { let size = view.sizeThatFits(.unspecified); if x > 0 && x + size.width > width { x = 0; y += rowHeight + spacing; rowHeight = 0 }; points.append(CGPoint(x: x, y: y)); x += size.width + spacing; rowHeight = max(rowHeight, size.height) }
    return (CGSize(width: width, height: y + rowHeight), points)
  }
}
