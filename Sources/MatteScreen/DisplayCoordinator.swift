import AppKit
import CoreGraphics

@MainActor
final class DisplayCoordinator {
    private let metalContext: MetalContext
    private var configuration: OverlayConfiguration
    private var overlays: [CGDirectDisplayID: OverlayPanel] = [:]
    private var screenObserver: NSObjectProtocol?
    var onDisplaysChanged: (() -> Void)?

    init(metalContext: MetalContext, configuration: OverlayConfiguration) {
        self.metalContext = metalContext
        self.configuration = configuration
    }

    func start() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.reconcileDisplays()
                self?.onDisplaysChanged?()
            }
        }

        reconcileDisplays()
    }

    func apply(_ configuration: OverlayConfiguration) {
        self.configuration = configuration
        reconcileDisplays()
    }

    func availableDisplays() -> [(id: CGDirectDisplayID, name: String)] {
        NSScreen.screens.compactMap { screen in
            screen.displayID.map { ($0, screen.localizedName) }
        }
    }

    private func reconcileDisplays() {
        guard configuration.isEnabled else {
            removeAllOverlays()
            return
        }

        let screensByID = Dictionary(
            uniqueKeysWithValues: NSScreen.screens.compactMap { screen in
                screen.displayID.map { ($0, screen) }
            }
        )
        let desiredIDs = Set(screensByID.keys).subtracting(configuration.disabledDisplayIDs)

        for id in overlays.keys where !desiredIDs.contains(id) {
            overlays.removeValue(forKey: id)?.close()
        }

        for id in desiredIDs {
            guard let screen = screensByID[id] else { continue }

            if let overlay = overlays[id] {
                overlay.apply(configuration, screen: screen)
                overlay.show()
                continue
            }

            let overlay = OverlayPanel(
                screen: screen,
                displayID: id,
                metalContext: metalContext,
                configuration: configuration
            )
            overlays[id] = overlay
            overlay.show()
        }
    }

    private func removeAllOverlays() {
        for overlay in overlays.values {
            overlay.close()
        }
        overlays.removeAll()
    }
}
