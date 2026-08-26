import MetalKit

final class TransparentMetalView: MTKView {
    override var isOpaque: Bool { false }

    override func makeBackingLayer() -> CALayer {
        let layer = super.makeBackingLayer()
        layer.isOpaque = false
        return layer
    }
}
