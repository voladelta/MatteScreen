import AppKit
import Metal

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var settingsStore: SettingsStore?
    private var displayCoordinator: DisplayCoordinator?
    private var statusMenuController: StatusMenuController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            let alert = NSAlert()
            alert.messageText = "MatteScreen requires Metal"
            alert.informativeText = "This Mac did not provide a Metal device."
            alert.runModal()
            NSApplication.shared.terminate(nil)
            return
        }

        do {
            let metalContext = try MetalContext(device: device)
            let store = SettingsStore()
            let coordinator = DisplayCoordinator(
                metalContext: metalContext,
                configuration: store.configuration
            )
            let menuController = StatusMenuController(
                settingsStore: store,
                displayCoordinator: coordinator
            )

            store.onChange = { [weak coordinator, weak menuController] configuration in
                coordinator?.apply(configuration)
                menuController?.refresh()
            }
            coordinator.onDisplaysChanged = { [weak menuController] in
                menuController?.refresh()
            }

            settingsStore = store
            displayCoordinator = coordinator
            statusMenuController = menuController

            coordinator.start()
            menuController.start()
        } catch {
            let alert = NSAlert()
            alert.messageText = "MatteScreen could not start Metal"
            alert.informativeText = error.localizedDescription
            alert.runModal()
            NSApplication.shared.terminate(nil)
        }
    }
}
