#!/usr/bin/env swift

// Re-export the approved imagegen masters; never redraw the mascot in code.
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let masters = root.appendingPathComponent("Design/Branding/Aijin", isDirectory: true)
let catalog = root.appendingPathComponent("Runner/Assets.xcassets", isDirectory: true)

func export(_ sourceName: String, to destination: URL, width: Int, height: Int, opaque: Bool) throws {
  let sourceURL = masters.appendingPathComponent(sourceName)
  guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
        let context = CGContext(data: nil, width: width, height: height,
          bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
          bitmapInfo: (opaque ? CGImageAlphaInfo.noneSkipLast : .premultipliedLast).rawValue)
  else { throw CocoaError(.fileReadCorruptFile) }
  context.interpolationQuality = .high
  if opaque {
    context.setFillColor(CGColor(red: 0.88, green: 0.97, blue: 0.93, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
  }
  context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
  try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
  guard let result = context.makeImage(),
        let output = CGImageDestinationCreateWithURL(destination as CFURL, UTType.png.identifier as CFString, 1, nil)
  else { throw CocoaError(.fileWriteUnknown) }
  CGImageDestinationAddImage(output, result, nil)
  guard CGImageDestinationFinalize(output) else { throw CocoaError(.fileWriteUnknown) }
}

func imageSet(_ name: String, source: String, width: Int, height: Int, opaque: Bool) throws {
  let directory = catalog.appendingPathComponent(name + ".imageset", isDirectory: true)
  try export(source, to: directory.appendingPathComponent(name + ".png"), width: width, height: height, opaque: opaque)
  let contents: [String: Any] = [
    "images": [["filename": name + ".png", "idiom": "universal", "scale": "3x"]],
    "info": ["author": "xcode", "version": 1]
  ]
  try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    .write(to: directory.appendingPathComponent("Contents.json"), options: .atomic)
}

let iconSet = catalog.appendingPathComponent("AijinAppIcon.appiconset", isDirectory: true)
let contents = try JSONSerialization.jsonObject(with: Data(contentsOf: iconSet.appendingPathComponent("Contents.json"))) as! [String: Any]
let icons = contents["images"] as! [[String: String]]
var exported = Set<String>()
for spec in icons {
  guard let filename = spec["filename"], exported.insert(filename).inserted,
        let size = spec["size"]?.split(separator: "x").first,
        let points = Double(size), let scale = spec["scale"],
        let multiplier = Double(scale.replacingOccurrences(of: "x", with: ""))
  else { continue }
  let pixels = Int(points * multiplier)
  try export("Aijin-AppIcon-Master.png", to: iconSet.appendingPathComponent(filename), width: pixels, height: pixels, opaque: true)
}
try imageSet("AijinLogo", source: "Aijin-AppIcon-Master.png", width: 512, height: 512, opaque: true)
try imageSet("AijinMascot", source: "Aijin-Mascot-Master.png", width: 900, height: 900, opaque: false)
try imageSet("AijinInviteBackground", source: "Aijin-Invite-Master.png", width: 1080, height: 900, opaque: false)
print("AIJIN_BRAND_ASSETS_GENERATED icons=\(exported.count) imagesets=3")
