import SwiftUI
import UIKit
import CoreImage

enum QQStyle {
  static let ink = Color(red: 0.055, green: 0.102, blue: 0.133)
  static let secondary = Color(red: 0.47, green: 0.49, blue: 0.50)
  static let background = Color(white: 0.975)
  static let gradient = LinearGradient(colors: [Color(red: 0.55, green: 0.95, blue: 0.89), Color(red: 0.41, green: 0.75, blue: 0.98), Color(red: 0.71, green: 0.57, blue: 0.99)], startPoint: .leading, endPoint: .trailing)
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
    }.clipped()
  }
}

struct QQPrimaryButton: View {
  let title: String
  var busy = false
  let action: () -> Void
  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        if busy { ProgressView().tint(QQStyle.ink) }
        Text(title).font(.system(size: 16, weight: .semibold))
      }.frame(maxWidth: .infinity).frame(height: 56)
        .foregroundStyle(QQStyle.ink).background(QQStyle.gradient, in: Capsule())
    }.buttonStyle(.plain).disabled(busy)
  }
}

struct QQEmptyState: View {
  var text = "暂时没有内容～"
  var action: (() -> Void)?
  var body: some View {
    VStack(spacing: 16) {
      QQArtwork(name: "wd_znt_pic_kong").frame(width: 104, height: 110)
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
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      QQRemoteImage(address: role.image).frame(height: 224).clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomTrailing) {
          if !role["chat_num"].isEmpty {
            Label(role["chat_num"], systemImage: "bubble.left.fill").font(.system(size: 10))
              .padding(6).foregroundStyle(.white).background(.black.opacity(0.4), in: Capsule()).padding(8)
          }
        }
      Text(role.name).font(.system(size: 16, weight: .semibold)).lineLimit(1)
      Text(role.intro).font(.system(size: 12)).foregroundStyle(QQStyle.secondary).lineLimit(2)
    }.foregroundStyle(QQStyle.ink).frame(maxWidth: .infinity, alignment: .leading)
  }
}
