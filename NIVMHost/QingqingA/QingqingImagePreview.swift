import SwiftUI
import UIKit

/// Original ImageDetailActivity: black canvas, fitted image, pinch/double-tap
/// zoom, and single tap to return. The image remains on this device.
struct QQImagePreview: View {
  @Environment(\.dismiss) private var dismiss
  let image: UIImage
  var body: some View {
    QQZoomingImage(image: image, close: { dismiss() }).ignoresSafeArea()
      .statusBarHidden().accessibilityAction(.escape) { dismiss() }
  }
}

private struct QQZoomingImage: UIViewRepresentable {
  let image: UIImage
  let close: () -> Void
  func makeCoordinator() -> Coordinator { Coordinator(close: close) }
  func makeUIView(context: Context) -> QQImageScrollView {
    let scroll = QQImageScrollView()
    scroll.delegate = context.coordinator
    scroll.picture.image = image
    scroll.picture.isAccessibilityElement = true
    scroll.picture.accessibilityLabel = "图片预览"
    scroll.picture.accessibilityValue = "100%"
    let single = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.singleTap))
    let double = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTap(_:)))
    double.numberOfTapsRequired = 2; single.require(toFail: double)
    scroll.addGestureRecognizer(single); scroll.addGestureRecognizer(double)
    return scroll
  }
  func updateUIView(_ view: QQImageScrollView, context: Context) {}
  final class Coordinator: NSObject, UIScrollViewDelegate {
    let close: () -> Void
    init(close: @escaping () -> Void) { self.close = close }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { (scrollView as? QQImageScrollView)?.picture }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
      guard let scroll = scrollView as? QQImageScrollView else { return }
      scroll.centerPicture()
      scroll.picture.accessibilityValue = "\(Int((scroll.zoomScale * 100).rounded()))%"
    }
    @objc func singleTap() { close() }
    @objc func doubleTap(_ gesture: UITapGestureRecognizer) {
      guard let scroll = gesture.view as? QQImageScrollView else { return }
      let scale: CGFloat = scroll.zoomScale < 1.75 ? 1.75 : scroll.zoomScale < 3 ? 3 : 1
      if scale == 1 { scroll.setZoomScale(1, animated: true); return }
      let point = gesture.location(in: scroll.picture)
      let size = CGSize(width: scroll.bounds.width / scale, height: scroll.bounds.height / scale)
      scroll.zoom(to: CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2, width: size.width, height: size.height), animated: true)
    }
  }
}

private final class QQImageScrollView: UIScrollView {
  let picture = UIImageView()
  private var fittedBounds = CGSize.zero
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .black; minimumZoomScale = 1; maximumZoomScale = 3
    contentInsetAdjustmentBehavior = .never; showsVerticalScrollIndicator = false; showsHorizontalScrollIndicator = false
    picture.contentMode = .scaleAspectFit; addSubview(picture)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  override func layoutSubviews() {
    super.layoutSubviews()
    guard bounds.size != fittedBounds, bounds.width > 0, bounds.height > 0, let image = picture.image, image.size.width > 0, image.size.height > 0 else { return }
    fittedBounds = bounds.size; setZoomScale(1, animated: false)
    let scale = min(bounds.width / image.size.width, bounds.height / image.size.height)
    let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    picture.frame = CGRect(origin: .zero, size: size); contentSize = size; centerPicture()
  }
  func centerPicture() {
    contentInset = UIEdgeInsets(top: max(0, (bounds.height - contentSize.height) / 2), left: max(0, (bounds.width - contentSize.width) / 2), bottom: 0, right: 0)
  }
}
