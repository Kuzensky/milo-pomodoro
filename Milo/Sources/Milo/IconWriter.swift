import AppKit

enum IconWriter {
    static func write(to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for (name, size) in [
            ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
            ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
            ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
            ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
            ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024),
        ] {
            let bitmap = NSBitmapImageRep(
                bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
            )!
            let graphics = NSGraphicsContext(bitmapImageRep: bitmap)!
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = graphics
            let context = graphics.cgContext
            // Notifications use the app icon. Keep everything outside the cat transparent.
            context.clear(CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size)))
            context.translateBy(x: 0, y: CGFloat(size))
            context.scaleBy(x: CGFloat(size) / 1024, y: -CGFloat(size) / 1024)
            context.translateBy(x: 102, y: 102)
            context.scaleBy(x: 1.6, y: 1.6)
            for part in MiloVectors.icon {
                context.setFillColor((part.white ? NSColor.white : NSColor(calibratedWhite: 0.015, alpha: 1)).cgColor)
                context.setStrokeColor(NSColor.black.cgColor)
                context.addPath(part.path.cgPath)
                if part.stroke > 0 {
                    context.setLineWidth(part.stroke)
                    context.setLineCap(.round)
                    context.strokePath()
                } else {
                    context.fillPath()
                    if part.name == "head" {
                        context.addPath(part.path.cgPath)
                        context.setStrokeColor(NSColor.white.withAlphaComponent(0.07).cgColor)
                        context.setLineWidth(0.8)
                        context.strokePath()
                    }
                }
            }
            NSGraphicsContext.restoreGraphicsState()
            try bitmap.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent(name))
        }
    }
}
