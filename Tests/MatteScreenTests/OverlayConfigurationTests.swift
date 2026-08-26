import Foundation
import Testing
@testable import MatteScreen

@Suite("Overlay configuration")
struct OverlayConfigurationTests {
    @Test("Normalization clamps user-controlled values")
    func normalizationClampsValues() {
        let configuration = OverlayConfiguration(
            isEnabled: true,
            preset: .saddleLinen,
            strength: 3,
            scale: -4,
            disabledDisplayIDs: [7]
        ).normalized()

        #expect(configuration.strength == OverlayConfiguration.strengthRange.upperBound)
        #expect(configuration.scale == OverlayConfiguration.scaleRange.lowerBound)
        #expect(configuration.disabledDisplayIDs == [7])
    }

    @Test("Every texture uses normalized noise weights")
    func textureWeightsAreNormalized() {
        for preset in TexturePreset.allCases {
            let parameters = preset.parameters
            let total = parameters.broadWeight + parameters.mediumWeight + parameters.fineWeight

            #expect(abs(total - 1) < 0.0001)
            #expect(parameters.grainAmount > 0)
            #expect(parameters.tint.x >= 0 && parameters.tint.x <= 1)
            #expect(parameters.tint.y >= 0 && parameters.tint.y <= 1)
            #expect(parameters.tint.z >= 0 && parameters.tint.z <= 1)
        }
    }

    @Test("Swift parameters match the Metal buffer stride")
    func metalParameterStride() {
        #expect(MemoryLayout<GPUParameters>.stride == 64)
    }

    @Test("All authored paper textures are packaged")
    func paperTexturesArePackaged() {
        #expect(TexturePreset.allCases.count == 9)
        for preset in TexturePreset.allCases {
            #expect(PaperTextureResource.locate(preset) != nil)
        }
    }

    @MainActor
    @Test("Settings persist through the production store")
    func settingsRoundTrip() throws {
        let suiteName = "MatteScreenTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(defaults: defaults)
        store.update {
            $0.isEnabled = false
            $0.preset = .paintersPress
            $0.strength = 0.07
            $0.scale = 6
            $0.disabledDisplayIDs = [42]
        }

        let restored = SettingsStore(defaults: defaults).configuration

        #expect(restored.isEnabled == false)
        #expect(restored.preset == .paintersPress)
        #expect(restored.strength == 0.07)
        #expect(restored.scale == 6)
        #expect(restored.disabledDisplayIDs == [42])
    }

    @MainActor
    @Test("The old strongest setting migrates to the new maximum")
    func legacyStrengthMigration() throws {
        let suiteName = "MatteScreenTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let legacy = LegacyTestConfiguration(
            isEnabled: true,
            preset: "classicMatte",
            strength: 0.10,
            scale: 3,
            disabledDisplayIDs: []
        )
        defaults.set(
            try JSONEncoder().encode(legacy),
            forKey: "overlayConfiguration.v1"
        )

        let migrated = SettingsStore(defaults: defaults).configuration
        let restored = SettingsStore(defaults: defaults).configuration

        #expect(migrated.strength == 0.28)
        #expect(restored.strength == 0.28)
    }

    @MainActor
    @Test("Version two texture names migrate and persist")
    func legacyTextureMigration() throws {
        let suiteName = "MatteScreenTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let legacy = LegacyTestConfiguration(
            isEnabled: false,
            preset: "linen",
            strength: 0.18,
            scale: 6,
            disabledDisplayIDs: [42]
        )
        defaults.set(
            try JSONEncoder().encode(legacy),
            forKey: "overlayConfiguration.v2"
        )

        let migrated = SettingsStore(defaults: defaults).configuration
        defaults.removeObject(forKey: "overlayConfiguration.v2")
        let restored = SettingsStore(defaults: defaults).configuration

        #expect(migrated.preset == .saddleLinen)
        #expect(migrated.strength == 0.18)
        #expect(restored == migrated)
    }
}

private struct LegacyTestConfiguration: Codable {
    var isEnabled: Bool
    var preset: String
    var strength: Float
    var scale: Float
    var disabledDisplayIDs: Set<UInt32>
}
