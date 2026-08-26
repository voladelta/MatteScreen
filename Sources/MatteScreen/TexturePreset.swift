import simd

enum TexturePreset: String, CaseIterable, Codable, Sendable {
    case classicMatte
    case whisperWeave
    case sunbakedParchment
    case saddleLinen
    case paintersPress
    case mulberryVeil
    case vellumMist
    case monasticFelt
    case carbonLedger

    var title: String {
        switch self {
        case .classicMatte: "Classic Matte"
        case .whisperWeave: "Whisper Weave™"
        case .sunbakedParchment: "Sunbaked Parchment"
        case .saddleLinen: "Saddle Linen"
        case .paintersPress: "Painter's Press"
        case .mulberryVeil: "Mulberry Veil"
        case .vellumMist: "Vellum Mist"
        case .monasticFelt: "Monastic Felt"
        case .carbonLedger: "Carbon Ledger"
        }
    }

    var resourceName: String {
        switch self {
        case .classicMatte: "ClassicMatte"
        case .whisperWeave: "WhisperWeave"
        case .sunbakedParchment: "SunbakedParchment"
        case .saddleLinen: "SaddleLinen"
        case .paintersPress: "PaintersPress"
        case .mulberryVeil: "MulberryVeil"
        case .vellumMist: "VellumMist"
        case .monasticFelt: "MonasticFelt"
        case .carbonLedger: "CarbonLedger"
        }
    }

    var parameters: PresetParameters {
        switch self {
        case .classicMatte:
            PresetParameters(
                tint: SIMD3(0.52, 0.51, 0.47),
                grainAmount: 0.18,
                broadWeight: 0.20,
                mediumWeight: 0.35,
                fineWeight: 0.45,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .whisperWeave:
            PresetParameters(
                tint: SIMD3(0.54, 0.51, 0.46),
                grainAmount: 0.12,
                broadWeight: 0.10,
                mediumWeight: 0.30,
                fineWeight: 0.60,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .sunbakedParchment:
            PresetParameters(
                tint: SIMD3(0.65, 0.49, 0.25),
                grainAmount: 0.23,
                broadWeight: 0.45,
                mediumWeight: 0.35,
                fineWeight: 0.20,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .saddleLinen:
            PresetParameters(
                tint: SIMD3(0.49, 0.40, 0.28),
                grainAmount: 0.14,
                broadWeight: 0.20,
                mediumWeight: 0.40,
                fineWeight: 0.40,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .paintersPress:
            PresetParameters(
                tint: SIMD3(0.57, 0.55, 0.50),
                grainAmount: 0.22,
                broadWeight: 0.35,
                mediumWeight: 0.40,
                fineWeight: 0.25,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .mulberryVeil:
            PresetParameters(
                tint: SIMD3(0.40, 0.27, 0.36),
                grainAmount: 0.18,
                broadWeight: 0.35,
                mediumWeight: 0.35,
                fineWeight: 0.30,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .vellumMist:
            PresetParameters(
                tint: SIMD3(0.59, 0.57, 0.51),
                grainAmount: 0.17,
                broadWeight: 0.62,
                mediumWeight: 0.28,
                fineWeight: 0.10,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .monasticFelt:
            PresetParameters(
                tint: SIMD3(0.44, 0.39, 0.32),
                grainAmount: 0.18,
                broadWeight: 0.25,
                mediumWeight: 0.45,
                fineWeight: 0.30,
                weaveAmount: 0,
                fiberScale: 1
            )
        case .carbonLedger:
            PresetParameters(
                tint: SIMD3(0.37, 0.41, 0.45),
                grainAmount: 0.18,
                broadWeight: 0.10,
                mediumWeight: 0.25,
                fineWeight: 0.65,
                weaveAmount: 0,
                fiberScale: 1
            )
        }
    }
}

struct PresetParameters: Equatable, Sendable {
    let tint: SIMD3<Float>
    let grainAmount: Float
    let broadWeight: Float
    let mediumWeight: Float
    let fineWeight: Float
    let weaveAmount: Float
    let fiberScale: Float
}
