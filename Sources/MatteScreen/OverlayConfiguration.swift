import Foundation

struct OverlayConfiguration: Codable, Equatable, Sendable {
    static let strengthRange: ClosedRange<Float> = 0 ... 0.35
    static let scaleRange: ClosedRange<Float> = 0.5 ... 12

    var isEnabled: Bool
    var preset: TexturePreset
    var strength: Float
    var scale: Float
    var disabledDisplayIDs: Set<UInt32>

    static let `default` = OverlayConfiguration(
        isEnabled: true,
        preset: .classicMatte,
        strength: 0.10,
        scale: 3,
        disabledDisplayIDs: []
    )

    func normalized() -> OverlayConfiguration {
        var result = self
        result.strength = min(max(strength, Self.strengthRange.lowerBound), Self.strengthRange.upperBound)
        result.scale = min(max(scale, Self.scaleRange.lowerBound), Self.scaleRange.upperBound)
        return result
    }
}
