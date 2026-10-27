import SwiftUI

struct CatDrawing: View {
    let pose: CatPose
    var time: TimeInterval = 0
    var moving = false
    var scanlines = false

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 512
            context.translateBy(x: (size.width - 512 * scale) / 2, y: (size.height - 512 * scale) / 2)
            context.scaleBy(x: scale, y: scale)
            let cycle = pose == .focus ? 6.0 : (pose == .rest ? 5.2 : 4.8)
            let wave = moving ? sin(time * .pi * 2 / cycle) : 0
            let breath = wave * (pose == .focus ? 0.004 : 0.008)
            context.translateBy(x: 256, y: 460)
            context.scaleBy(x: 1 + breath * 0.5, y: 1 + breath)
            context.translateBy(x: -256, y: -460)

            let blinkPhase = time.truncatingRemainder(dividingBy: 6.7)
            let blink = moving && pose != .focus && blinkPhase > 4.6 && blinkPhase < 4.76
                ? max(0.07, abs(blinkPhase - 4.68) / 0.08) : 1.0
            func draw(_ part: VectorPart, in source: GraphicsContext) {
                var layer = source
                if moving, part.role == .tail {
                    let anchor = pose.tailAnchor
                    layer.translateBy(x: anchor.x, y: anchor.y)
                    layer.rotate(by: .degrees(wave * (pose == .focus ? 0.7 : 2)))
                    layer.translateBy(x: -anchor.x, y: -anchor.y)
                }
                if part.role == .eyes, blink < 1 {
                    let center = part.path.boundingRect.midY
                    layer.translateBy(x: 0, y: center)
                    layer.scaleBy(x: 1, y: blink)
                    layer.translateBy(x: 0, y: -center)
                }
                let ink = GraphicsContext.Shading.color(part.white ? .white : Color(white: 0.018))
                if part.stroke > 0 {
                    layer.stroke(part.path, with: ink, style: .init(lineWidth: part.stroke, lineCap: .round))
                } else {
                    layer.fill(part.path, with: ink)
                }
            }
            if scanlines {
                // Cut only the silhouette in an isolated layer. Destination-out
                // reveals the soft glow without erasing the panel behind it.
                context.drawLayer { silhouette in
                    for part in pose.parts where !part.white && part.role != .eyes {
                        draw(part, in: silhouette)
                    }
                    let spacing = 12.0
                    let offset = moving ? time.truncatingRemainder(dividingBy: 3.6) / 3.6 * spacing : 0
                    silhouette.blendMode = .destinationOut
                    for y in stride(from: -spacing, through: 512 + spacing, by: spacing) {
                        let band = Path(CGRect(x: -16, y: y + offset, width: 544, height: 4))
                        silhouette.fill(band, with: .color(.white.opacity(0.82)))
                    }
                }
                // Keep the eyes, pupils and ear details crisp at menu-panel size.
                for part in pose.parts where part.white || part.role == .eyes {
                    draw(part, in: context)
                }
            } else {
                for part in pose.parts { draw(part, in: context) }
            }
        }
        .accessibilityHidden(true)
    }
}

struct MiloCatView: View {
    @ObservedObject var store: MiloStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var petted = false
    private var animating: Bool { store.panelVisible && store.engine.settings.animationEnabled && !reduceMotion }

    var body: some View {
        Button(action: react) {
            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !animating)) { context in
                CatDrawing(pose: store.pose, time: context.date.timeIntervalSinceReferenceDate,
                           moving: animating, scanlines: store.scanlineCatEnabled)
                    .id(store.pose)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: reduceMotion ? 0.1 : 0.25), value: store.pose)
            }
            .background {
                GeometryReader { geometry in
                    let diameter = min(196, min(geometry.size.width, geometry.size.height) * 1.3)
                    RadialGradient(
                        stops: [
                            .init(color: .white.opacity(0.30), location: 0),
                            .init(color: .white.opacity(0.18), location: 0.30),
                            .init(color: .white.opacity(0.055), location: 0.65),
                            .init(color: .clear, location: 1),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: diameter / 2
                    )
                    .frame(width: diameter, height: diameter)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blur(radius: 8)
                    .allowsHitTesting(false)
                }
            }
            .scaleEffect(x: petted ? 1.055 : 1, y: petted ? 0.955 : 1, anchor: .bottom)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Pet Milo")
        .accessibilityValue(store.pose == .focus ? "Focusing" : (store.pose == .rest ? "Resting" : "Ready"))
        .help("A little company")
        .onChange(of: store.completionPulse) { _, _ in if store.panelVisible { react() } }
    }

    private func react() {
        guard !reduceMotion, store.engine.settings.animationEnabled else { return }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) { petted = true }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.spring(response: 0.45, dampingFraction: 0.45)) { petted = false }
        }
    }
}
