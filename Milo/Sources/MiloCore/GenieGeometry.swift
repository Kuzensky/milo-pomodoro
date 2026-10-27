import CoreGraphics

/// Horizontal sections of a panel flowing into an icon above it.
public enum GenieGeometry {
    public struct Section {
        public let left: CGFloat
        public let right: CGFloat
        public let y: CGFloat
        public var width: CGFloat { right - left }
    }

    /// Progress runs from the full panel (0) to the menu icon (1).
    public static func section(at fraction: CGFloat, progress: CGFloat, body: CGRect, anchor: CGPoint) -> Section {
        let fraction = min(1, max(0, fraction))
        let progress = min(1, max(0, progress))
        // The edge nearest the icon leads; the far edge follows after a delay.
        let delay = (1 - fraction) * 0.55
        let local = min(1, max(0, (progress - delay) / (1 - delay)))
        let neck = smoothstep(local / 0.48)
        let lift = smoothstep(local)
        let pinch = 1 - smoothstep((progress - 0.82) / 0.18)
        let width = (body.width * (1 - neck) + min(18, body.width) * neck) * pinch
        let center = body.midX + (anchor.x - body.midX) * neck
        let sourceY = body.minY + body.height * fraction
        return Section(left: center - width / 2, right: center + width / 2,
                       y: sourceY + (anchor.y - sourceY) * lift)
    }

    private static func smoothstep(_ value: CGFloat) -> CGFloat {
        let value = min(1, max(0, value))
        return value * value * (3 - 2 * value)
    }
}
