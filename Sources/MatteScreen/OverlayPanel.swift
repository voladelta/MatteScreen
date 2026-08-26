import AppKit
import CoreGraphics

@MainActor
final class OverlayPanel: NSPanel {
    private let metalView: TransparentMetalView
    private let renderer: MetalRenderer

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(
        screen: NSScreen,
        metalContext: MetalContext,
        configuration: OverlayConfiguration
    ) {
        metalView = TransparentMetalView(
            frame: NSRect(origin: .zero, size: screen.frame.size),
            device: metalContext.device
        )
        renderer = MetalRenderer(
            metalContext: metalContext,
            view: metalView,
            configuration: configuration,
            screen: screen
        )
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.overlayWindow)))
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        animationBehavior = .none
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        metalView.autoresizingMask = [.width, .height]
        contentView = metalView
        renderer.requestDraw()
    }

    func apply(_ configuration: OverlayConfiguration, screen: NSScreen) {
        setFrame(screen.frame, display: false)
        renderer.apply(configuration, screen: screen)
    }

    func show() {
        orderFrontRegardless()
        renderer.requestDraw()
    }
}
