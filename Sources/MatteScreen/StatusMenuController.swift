import AppKit
import CoreGraphics

@MainActor
final class StatusMenuController: NSObject {
    private let settingsStore: SettingsStore
    private let displayCoordinator: DisplayCoordinator
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    init(settingsStore: SettingsStore, displayCoordinator: DisplayCoordinator) {
        self.settingsStore = settingsStore
        self.displayCoordinator = displayCoordinator
    }

    func start() {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "circle.hexagongrid.fill",
                accessibilityDescription: "MatteScreen"
            )
            button.image?.isTemplate = true
        }
        refresh()
    }

    func refresh() {
        let configuration = settingsStore.configuration
        let menu = NSMenu()

        let enabledItem = NSMenuItem(
            title: "Enable matte surface",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        enabledItem.target = self
        enabledItem.state = configuration.isEnabled ? .on : .off
        menu.addItem(enabledItem)
        menu.addItem(.separator())

        menu.addItem(submenuItem(
            title: "Texture",
            items: TexturePreset.allCases.map { preset in
                actionItem(
                    title: preset.title,
                    action: #selector(selectPreset(_:)),
                    representedObject: preset.rawValue,
                    isSelected: preset == configuration.preset
                )
            }
        ))

        let strengths: [(String, Float)] = [
            ("Subtle — 8%", 0.08),
            ("Balanced — 10%", 0.10),
            ("Strong — 18%", 0.18),
            ("Maximum — 28%", 0.28)
        ]
        menu.addItem(submenuItem(
            title: "Strength",
            items: strengths.map { title, value in
                actionItem(
                    title: title,
                    action: #selector(selectStrength(_:)),
                    representedObject: NSNumber(value: value),
                    isSelected: abs(value - configuration.strength) < 0.001
                )
            }
        ))

        let scales: [(String, Float)] = [
            ("Fine", 1.5),
            ("Medium", 3),
            ("Coarse", 6)
        ]
        menu.addItem(submenuItem(
            title: "Grain size",
            items: scales.map { title, value in
                actionItem(
                    title: title,
                    action: #selector(selectScale(_:)),
                    representedObject: NSNumber(value: value),
                    isSelected: abs(value - configuration.scale) < 0.001
                )
            }
        ))

        let displayItems = displayCoordinator.availableDisplays().map { display in
            actionItem(
                title: display.name,
                action: #selector(toggleDisplay(_:)),
                representedObject: NSNumber(value: display.id),
                isSelected: !configuration.disabledDisplayIDs.contains(display.id)
            )
        }
        menu.addItem(submenuItem(title: "Displays", items: displayItems))

        menu.addItem(.separator())
        let quitItem = NSMenuItem(
            title: "Quit MatteScreen",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func submenuItem(title: String, items: [NSMenuItem]) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: title)
        for child in items {
            submenu.addItem(child)
        }
        item.submenu = submenu
        return item
    }

    private func actionItem(
        title: String,
        action: Selector,
        representedObject: Any,
        isSelected: Bool
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.representedObject = representedObject
        item.state = isSelected ? .on : .off
        return item
    }

    @objc private func toggleEnabled() {
        settingsStore.update { $0.isEnabled.toggle() }
    }

    @objc private func selectPreset(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let preset = TexturePreset(rawValue: rawValue)
        else { return }

        settingsStore.update { $0.preset = preset }
    }

    @objc private func selectStrength(_ sender: NSMenuItem) {
        guard let number = sender.representedObject as? NSNumber else { return }
        settingsStore.update { $0.strength = number.floatValue }
    }

    @objc private func selectScale(_ sender: NSMenuItem) {
        guard let number = sender.representedObject as? NSNumber else { return }
        settingsStore.update { $0.scale = number.floatValue }
    }

    @objc private func toggleDisplay(_ sender: NSMenuItem) {
        guard let number = sender.representedObject as? NSNumber else { return }
        let id = CGDirectDisplayID(number.uint32Value)

        settingsStore.update { configuration in
            if configuration.disabledDisplayIDs.contains(id) {
                configuration.disabledDisplayIDs.remove(id)
            } else {
                configuration.disabledDisplayIDs.insert(id)
            }
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
