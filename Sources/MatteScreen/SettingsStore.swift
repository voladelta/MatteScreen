import Foundation

@MainActor
final class SettingsStore {
    private static let configurationKey = "overlayConfiguration.v4"
    private static let legacyV3ConfigurationKey = "overlayConfiguration.v3"
    private static let legacyV2ConfigurationKey = "overlayConfiguration.v2"
    private static let legacyV1ConfigurationKey = "overlayConfiguration.v1"

    private let defaults: UserDefaults
    private(set) var configuration: OverlayConfiguration
    var onChange: ((OverlayConfiguration) -> Void)?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let loaded = Self.load(from: defaults)
        configuration = loaded.configuration

        if loaded.wasMigrated {
            persist(loaded.configuration)
        }
    }

    func update(_ change: (inout OverlayConfiguration) -> Void) {
        var next = configuration
        change(&next)
        next = next.normalized()

        guard next != configuration else { return }

        configuration = next
        persist(next)
        onChange?(next)
    }

    private static func load(
        from defaults: UserDefaults
    ) -> (configuration: OverlayConfiguration, wasMigrated: Bool) {
        if
            let data = defaults.data(forKey: configurationKey),
            let stored = try? JSONDecoder().decode(OverlayConfiguration.self, from: data)
        {
            return (stored.normalized(), false)
        }

        if
            let data = defaults.data(forKey: legacyV3ConfigurationKey),
            let legacy = try? JSONDecoder().decode(OverlayConfiguration.self, from: data)
        {
            return (replacingLegacySubtle(in: legacy).normalized(), true)
        }

        if
            let data = defaults.data(forKey: legacyV2ConfigurationKey),
            let legacy = try? JSONDecoder().decode(LegacyOverlayConfiguration.self, from: data)
        {
            let migrated = legacy.migrated()
            return (replacingLegacySubtle(in: migrated).normalized(), true)
        }

        if
            let data = defaults.data(forKey: legacyV1ConfigurationKey),
            let legacy = try? JSONDecoder().decode(LegacyOverlayConfiguration.self, from: data)
        {
            var migrated = legacy.migrated()
            migrated.strength = migratedStrength(migrated.strength)
            return (migrated.normalized(), true)
        }

        return (.default, false)
    }

    private static func migratedStrength(_ legacyStrength: Float) -> Float {
        let legacyLevels: [(old: Float, new: Float)] = [
            (0.025, 0.08),
            (0.045, 0.10),
            (0.07, 0.18),
            (0.10, 0.28)
        ]

        return legacyLevels.first {
            abs($0.old - legacyStrength) < 0.001
        }?.new ?? legacyStrength
    }

    private static func replacingLegacySubtle(
        in configuration: OverlayConfiguration
    ) -> OverlayConfiguration {
        guard abs(configuration.strength - 0.05) < 0.001 else {
            return configuration
        }

        var migrated = configuration
        migrated.strength = 0.08
        return migrated
    }

    private func persist(_ configuration: OverlayConfiguration) {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        defaults.set(data, forKey: Self.configurationKey)
    }
}

private struct LegacyOverlayConfiguration: Codable {
    enum Preset: String, Codable {
        case classicMatte
        case finePaper
        case linen
        case coldPress
        case vellum

        var migrated: TexturePreset {
            switch self {
            case .classicMatte: .classicMatte
            case .finePaper: .whisperWeave
            case .linen: .saddleLinen
            case .coldPress: .paintersPress
            case .vellum: .vellumMist
            }
        }
    }

    var isEnabled: Bool
    var preset: Preset
    var strength: Float
    var scale: Float
    var disabledDisplayIDs: Set<UInt32>

    func migrated() -> OverlayConfiguration {
        OverlayConfiguration(
            isEnabled: isEnabled,
            preset: preset.migrated,
            strength: strength,
            scale: scale,
            disabledDisplayIDs: disabledDisplayIDs
        )
    }
}
