import AppKit
import MetalKit
import Testing
@testable import MatteScreen

@Suite("Render invalidation", .serialized)
@MainActor
struct RenderingTests {
    @Test("Unchanged appearance does not request another frame")
    func unchangedAppearance() throws {
        let screen = try #require(NSScreen.screens.first)
        let device = try #require(MTLCreateSystemDefaultDevice())
        let context = try MetalContext(device: device)
        let view = DrawTrackingView(frame: .zero, device: device)
        let renderer = MetalRenderer(
            metalContext: context,
            view: view,
            configuration: .default,
            screen: screen
        )
        view.drawRequests = 0

        for _ in 0 ..< 1_000 {
            renderer.apply(.default, screen: screen)
        }

        #expect(view.drawRequests == 0)
        #expect(view.isPaused)
        #expect(view.enableSetNeedsDisplay)

        var configuration = OverlayConfiguration.default
        configuration.disabledDisplayIDs = [UInt32.max]
        renderer.apply(configuration, screen: screen)

        #expect(view.drawRequests == 0)

        configuration.strength = 0.18
        renderer.apply(configuration, screen: screen)

        #expect(view.drawRequests == 1)

        configuration.scale = 6
        renderer.apply(configuration, screen: screen)

        #expect(view.drawRequests == 2)

        configuration.preset = .carbonLedger
        renderer.apply(configuration, screen: screen)

        #expect(view.drawRequests == 3)

        renderer.mtkView(view, drawableSizeWillChange: CGSize(width: 200, height: 100))

        #expect(view.drawRequests == 4)
    }

    @Test("Reapplying a visible panel does not invalidate its surface")
    func visiblePanel() async throws {
        _ = NSApplication.shared
        let screen = try #require(NSScreen.screens.first)
        let device = try #require(MTLCreateSystemDefaultDevice())
        let context = try MetalContext(device: device)
        let panel = OverlayPanel(screen: screen, metalContext: context, configuration: .default)
        defer { panel.close() }
        let view = try #require(panel.contentView as? MTKView)
        let delegate = FrameTrackingDelegate(wrapping: try #require(view.delegate))
        view.delegate = delegate
        panel.show()
        try await Task.sleep(for: .milliseconds(100))

        #expect(delegate.frames > 0)

        delegate.frames = 0

        panel.apply(.default, screen: screen)
        panel.show()
        try await Task.sleep(for: .milliseconds(100))

        #expect(delegate.frames == 0)
        #expect(panel.frame == screen.frame)

        var configuration = OverlayConfiguration.default
        configuration.strength = 0.18
        panel.apply(configuration, screen: screen)
        try await Task.sleep(for: .milliseconds(100))

        #expect(delegate.frames > 0)

        panel.orderOut(nil)
        delegate.frames = 0
        panel.show()
        try await Task.sleep(for: .milliseconds(100))

        #expect(panel.isVisible)
        #expect(delegate.frames > 0)
    }

    @Test("Zero strength removes windows and positive strength restores them")
    func zeroStrength() throws {
        let app = NSApplication.shared
        let screen = try #require(NSScreen.screens.first)
        let displayID = try #require(screen.displayID)
        let device = try #require(MTLCreateSystemDefaultDevice())
        let context = try MetalContext(device: device)
        var configuration = OverlayConfiguration.default
        configuration.disabledDisplayIDs = Set(NSScreen.screens.compactMap(\.displayID))
            .subtracting([displayID])
        let coordinator = DisplayCoordinator(metalContext: context, configuration: configuration)
        defer {
            configuration.isEnabled = false
            coordinator.apply(configuration)
        }

        coordinator.apply(configuration)

        #expect(app.windows.contains { $0 is OverlayPanel && $0.isVisible })

        configuration.strength = 0
        coordinator.apply(configuration)

        #expect(!app.windows.contains { $0 is OverlayPanel && $0.isVisible })

        configuration.strength = 0.10
        coordinator.apply(configuration)

        #expect(app.windows.contains { $0 is OverlayPanel && $0.isVisible })
    }
}

@MainActor
private final class DrawTrackingView: MTKView {
    var drawRequests = 0

    override func setNeedsDisplay(_ invalidRect: NSRect) {
        drawRequests += 1
        super.setNeedsDisplay(invalidRect)
    }
}

@MainActor
private final class FrameTrackingDelegate: NSObject, MTKViewDelegate {
    let wrapped: MTKViewDelegate
    var frames = 0

    init(wrapping wrapped: MTKViewDelegate) {
        self.wrapped = wrapped
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        wrapped.mtkView(view, drawableSizeWillChange: size)
    }

    func draw(in view: MTKView) {
        frames += 1
        wrapped.draw(in: view)
    }
}
