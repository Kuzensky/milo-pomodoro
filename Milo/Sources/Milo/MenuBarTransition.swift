import AppKit
import MiloCore
import QuartzCore

/// A snapshot mesh bends into the menu icon, then hands back to live native glass.
/// Only this app's own view is cached; no desktop capture or private APIs are used.
@MainActor
final class MenuBarTransition {
    private struct Strip {
        let layer: CALayer
        let lower: CGFloat
        let upper: CGFloat
    }

    private let layer: CALayer
    private let surface: NSView
    private let progressLayer = CALayer()
    private var mesh: CALayer?
    private var strips: [Strip] = []
    private var generation = UUID()
    private(set) var isAnimating = false
    var hasGenieMesh: Bool { mesh != nil && !strips.isEmpty }
    var collapseProgress: CGFloat {
        CGFloat(progressLayer.presentation()?.opacity ?? progressLayer.opacity)
    }

    init(layer: CALayer, surface: NSView) {
        self.layer = layer
        self.surface = surface
        progressLayer.opacity = 0
        layer.addSublayer(progressLayer)
    }

    func animate(opening: Bool, anchor: CGPoint, reduceMotion: Bool, completion: @escaping () -> Void) {
        let token = UUID()
        generation = token
        let start = isAnimating ? collapseProgress : (opening ? 1 : 0)
        let target: CGFloat = opening ? 0 : 1
        let currentOpacity = layer.presentation()?.opacity ?? layer.opacity
        isAnimating = true

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if !reduceMotion && mesh == nil, let image = snapshot() {
            let mesh = CALayer()
            mesh.frame = layer.bounds
            strips = makeStrips(image: image, in: mesh)
            layer.addSublayer(mesh)
            self.mesh = mesh
            surface.isHidden = true
        }
        CATransaction.commit()

        let useMesh = !reduceMotion && hasGenieMesh
        let duration = useMesh ? max(0.12, (opening ? 0.58 : 0.52) * Double(abs(target - start))) : 0.12
        let count = max(2, Int(ceil(duration * 60)))
        let times = (0...count).map { CGFloat($0) / CGFloat(count) }
        let progress = times.map { time -> CGFloat in
            let eased = time * time * (3 - 2 * time)
            return start + (target - start) * eased
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock { [weak self] in
            Task { @MainActor in
                guard let self, self.generation == token else { return }
                self.isAnimating = false
                completion()
            }
        }
        let tracker = keyframes("opacity", values: progress.map { NSNumber(value: Double($0)) }, duration: duration)
        progressLayer.opacity = Float(target)
        progressLayer.add(tracker, forKey: "milo.genie.progress")

        layer.removeAnimation(forKey: "milo.visibility")
        layer.opacity = 1
        if useMesh {
            for strip in strips {
                let values = progress.map { NSValue(caTransform3D: transform(strip, progress: $0, anchor: anchor)) }
                strip.layer.transform = transform(strip, progress: target, anchor: anchor)
                strip.layer.add(keyframes("transform", values: values, duration: duration), forKey: "milo.genie")
            }
            // Keep the funnel visible until the final few pixels reach the icon.
            let opacity = progress.map { NSNumber(value: Double(min(1, (1 - $0) / 0.06))) }
            mesh?.opacity = opening ? 1 : 0
            mesh?.add(keyframes("opacity", values: opacity, duration: duration), forKey: "milo.genie.visibility")
        } else {
            removeMesh()
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = opening && start == 1 ? 0 : currentOpacity
            fade.toValue = opening ? 1 : 0
            fade.duration = duration
            fade.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.opacity = opening ? 1 : 0
            layer.add(fade, forKey: "milo.visibility")
        }
        CATransaction.commit()
    }

    func reset() {
        generation = UUID()
        isAnimating = false
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        removeMesh()
        progressLayer.removeAllAnimations()
        progressLayer.opacity = 0
        layer.removeAnimation(forKey: "milo.visibility")
        layer.sublayerTransform = CATransform3DIdentity
        layer.opacity = 1
        CATransaction.commit()
    }

    private func removeMesh() {
        mesh?.removeFromSuperlayer()
        mesh = nil
        strips.removeAll()
        surface.isHidden = false
    }

    private func snapshot() -> CGImage? {
        surface.layoutSubtreeIfNeeded()
        surface.displayIfNeeded()
        guard let bitmap = surface.bitmapImageRepForCachingDisplay(in: surface.bounds) else { return nil }
        surface.cacheDisplay(in: surface.bounds, to: bitmap)
        return bitmap.cgImage
    }

    private func makeStrips(image: CGImage, in mesh: CALayer) -> [Strip] {
        let count = min(512, max(128, image.height / 2))
        // A fraction of a pixel overlaps adjacent strips to prevent hairline seams.
        let overlap = 0.25 / CGFloat(image.height)
        return (0..<count).map { index in
            let lower = max(0, CGFloat(index) / CGFloat(count) - overlap)
            let upper = min(1, CGFloat(index + 1) / CGFloat(count) + overlap)
            let strip = CALayer()
            strip.anchorPoint = .zero
            strip.position = .zero
            strip.bounds = CGRect(x: 0, y: 0, width: surface.bounds.width, height: surface.bounds.height * (upper - lower))
            strip.contents = image
            strip.contentsRect = CGRect(x: 0, y: lower, width: 1, height: upper - lower)
            strip.contentsGravity = .resize
            strip.minificationFilter = .linear
            strip.magnificationFilter = .linear
            strip.isDoubleSided = false
            mesh.addSublayer(strip)
            return Strip(layer: strip, lower: lower, upper: upper)
        }
    }

    private func transform(_ strip: Strip, progress: CGFloat, anchor: CGPoint) -> CATransform3D {
        let bottom = GenieGeometry.section(at: strip.lower, progress: progress, body: surface.frame, anchor: anchor)
        let top = GenieGeometry.section(at: strip.upper, progress: progress, body: surface.frame, anchor: anchor)
        let height = strip.layer.bounds.height
        // Subpixel-overlapped affine strips keep the texture continuous and avoid
        // perspective singularities as the sheet collapses to a single point.
        let width = max(0.001, (bottom.width + top.width) / 2)
        let bottomCenter = (bottom.left + bottom.right) / 2
        let topCenter = (top.left + top.right) / 2
        var transform = CATransform3DIdentity
        transform.m11 = width / strip.layer.bounds.width
        transform.m21 = (topCenter - bottomCenter) / height
        transform.m22 = max(0.001, top.y - bottom.y) / height
        transform.m41 = bottomCenter - width / 2
        transform.m42 = bottom.y
        return transform
    }

    private func keyframes(_ key: String, values: [Any], duration: TimeInterval) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: key)
        animation.values = values
        animation.duration = duration
        animation.calculationMode = .linear
        return animation
    }

    /// Deterministic snapshots of the same mesh used by the running animation.
    func exportDiagnosticFrames(to path: String, anchor: CGPoint) {
        guard let image = snapshot() else { return }
        let size = CGSize(width: layer.bounds.width, height: max(layer.bounds.height, anchor.y + 12))
        for progress: CGFloat in [0, 0.35, 0.60, 0.82] {
            let root = CALayer()
            root.frame = CGRect(origin: .zero, size: size)
            let previewStrips = makeStrips(image: image, in: root)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            for strip in previewStrips { strip.layer.transform = transform(strip, progress: progress, anchor: anchor) }
            CATransaction.commit()
            guard let context = CGContext(data: nil, width: Int(size.width * 2), height: Int(size.height * 2), bitsPerComponent: 8, bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { continue }
            context.scaleBy(x: 2, y: 2)
            root.render(in: context)
            guard let output = context.makeImage(), let data = NSBitmapImageRep(cgImage: output).representation(using: .png, properties: [:]) else { continue }
            try? data.write(to: URL(fileURLWithPath: path + ".genie-\(Int(progress * 100)).png"))
        }
    }
}
