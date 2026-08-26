import AppKit
import Metal
import MetalKit
import simd

struct GPUParameters {
    var screenOriginPixels: SIMD2<Float>
    var scale: Float
    var strength: Float

    var grainAmount: Float
    var broadWeight: Float
    var mediumWeight: Float
    var fineWeight: Float

    var tintAndWeave: SIMD4<Float>

    var fiberScale: Float
    var seed: UInt32
    var padding: SIMD2<Float> = .zero
}

@MainActor
final class MetalRenderer: NSObject, MTKViewDelegate {
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let metalContext: MetalContext
    private var paperTexture: MTLTexture
    private let paperSampler: MTLSamplerState
    private weak var view: MTKView?
    private var parameters: GPUParameters

    init(
        metalContext: MetalContext,
        view: MTKView,
        configuration: OverlayConfiguration,
        screen: NSScreen
    ) {
        commandQueue = metalContext.commandQueue
        pipelineState = metalContext.pipelineState
        self.metalContext = metalContext
        paperTexture = metalContext.paperTexture(for: configuration.preset)
        paperSampler = metalContext.paperSampler
        self.view = view
        parameters = Self.makeParameters(configuration: configuration, screen: screen)

        super.init()

        view.device = metalContext.device
        view.delegate = self
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.framebufferOnly = true
        view.isPaused = true
        view.enableSetNeedsDisplay = true
        view.wantsLayer = true
        view.layer?.isOpaque = false
        view.colorspace = CGColorSpace(name: CGColorSpace.sRGB)
    }

    func apply(_ configuration: OverlayConfiguration, screen: NSScreen) {
        paperTexture = metalContext.paperTexture(for: configuration.preset)
        parameters = Self.makeParameters(configuration: configuration, screen: screen)
        requestDraw()
    }

    func requestDraw() {
        guard let view else { return }
        view.setNeedsDisplay(view.bounds)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        requestDraw()
    }

    func draw(in view: MTKView) {
        guard
            let renderPass = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass)
        else { return }

        commandBuffer.label = "MatteScreen paper frame"
        encoder.label = "MatteScreen paper encoder"
        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentBytes(
            &parameters,
            length: MemoryLayout<GPUParameters>.stride,
            index: 0
        )
        encoder.setFragmentTexture(paperTexture, index: 0)
        encoder.setFragmentSamplerState(paperSampler, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private static func makeParameters(
        configuration: OverlayConfiguration,
        screen: NSScreen
    ) -> GPUParameters {
        let preset = configuration.preset.parameters
        let backingScale = Float(screen.backingScaleFactor)

        return GPUParameters(
            screenOriginPixels: SIMD2(
                Float(screen.frame.origin.x) * backingScale,
                Float(screen.frame.origin.y) * backingScale
            ),
            scale: configuration.scale * backingScale,
            strength: configuration.strength,
            grainAmount: preset.grainAmount,
            broadWeight: preset.broadWeight,
            mediumWeight: preset.mediumWeight,
            fineWeight: preset.fineWeight,
            tintAndWeave: SIMD4(
                preset.tint.x,
                preset.tint.y,
                preset.tint.z,
                preset.weaveAmount
            ),
            fiberScale: preset.fiberScale,
            seed: 0x5EED_CAFE
        )
    }
}
