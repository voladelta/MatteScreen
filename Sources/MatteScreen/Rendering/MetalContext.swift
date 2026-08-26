import Foundation
import Metal
import MetalKit

enum MetalContextError: LocalizedError {
    case commandQueueUnavailable
    case shaderFunctionUnavailable(String)
    case textureUnavailable(String)
    case samplerUnavailable

    var errorDescription: String? {
        switch self {
        case .commandQueueUnavailable:
            "Metal did not create a command queue."
        case let .shaderFunctionUnavailable(name):
            "The Metal shader function \(name) is unavailable."
        case let .textureUnavailable(name):
            "The texture resource \(name).png is unavailable."
        case .samplerUnavailable:
            "Metal did not create the paper texture sampler."
        }
    }
}

enum PaperTextureResource {
    static func locate(_ preset: TexturePreset) -> URL? {
        Bundle.main.url(forResource: preset.resourceName, withExtension: "png")
            ?? Bundle.module.url(forResource: preset.resourceName, withExtension: "png")
    }
}

@MainActor
final class MetalContext {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    private let paperTextures: [TexturePreset: MTLTexture]
    let paperSampler: MTLSamplerState

    init(device: MTLDevice) throws {
        guard let commandQueue = device.makeCommandQueue() else {
            throw MetalContextError.commandQueueUnavailable
        }

        let library = try device.makeLibrary(source: ShaderSource.paper, options: nil)
        guard let vertexFunction = library.makeFunction(name: "paperVertex") else {
            throw MetalContextError.shaderFunctionUnavailable("paperVertex")
        }
        guard let fragmentFunction = library.makeFunction(name: "paperFragment") else {
            throw MetalContextError.shaderFunctionUnavailable("paperFragment")
        }
        let textureLoader = MTKTextureLoader(device: device)
        var paperTextures: [TexturePreset: MTLTexture] = [:]
        for preset in TexturePreset.allCases {
            guard let textureURL = PaperTextureResource.locate(preset) else {
                throw MetalContextError.textureUnavailable(preset.resourceName)
            }

            paperTextures[preset] = try textureLoader.newTexture(
                URL: textureURL,
                options: [
                    .SRGB: false,
                    .generateMipmaps: true,
                    .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
                    .textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
                ]
            )
        }

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.label = "MatteScreen paper sampler"
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 4

        guard let paperSampler = device.makeSamplerState(descriptor: samplerDescriptor) else {
            throw MetalContextError.samplerUnavailable
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "MatteScreen paper pipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        self.device = device
        self.commandQueue = commandQueue
        self.paperTextures = paperTextures
        self.paperSampler = paperSampler
        pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    func paperTexture(for preset: TexturePreset) -> MTLTexture {
        guard let texture = paperTextures[preset] else {
            preconditionFailure("MetalContext did not load \(preset.resourceName).png")
        }
        return texture
    }
}
