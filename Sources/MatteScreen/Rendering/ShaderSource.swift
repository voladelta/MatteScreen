enum ShaderSource {
    static let paper = #"""
    #include <metal_stdlib>
    using namespace metal;

    struct VertexOut {
        float4 position [[position]];
    };

    struct PaperParameters {
        float2 screenOriginPixels;
        float scale;
        float strength;

        float grainAmount;
        float broadWeight;
        float mediumWeight;
        float fineWeight;

        float4 tintAndWeave;

        float fiberScale;
        uint seed;
        float2 padding;
    };

    vertex VertexOut paperVertex(uint vertexID [[vertex_id]]) {
        const float2 positions[3] = {
            float2(-1.0, -1.0),
            float2( 3.0, -1.0),
            float2(-1.0,  3.0)
        };

        VertexOut out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        return out;
    }

    uint hashCell(int2 cell, uint seed) {
        uint hash = as_type<uint>(cell.x) * 0x9E3779B9u;
        hash ^= as_type<uint>(cell.y) * 0x85EBCA6Bu;
        hash ^= seed * 0xC2B2AE35u;
        hash ^= hash >> 16;
        hash *= 0x7FEB352Du;
        hash ^= hash >> 15;
        hash *= 0x846CA68Bu;
        hash ^= hash >> 16;
        return hash;
    }

    float randomValue(int2 cell, uint seed) {
        return float(hashCell(cell, seed)) / 4294967295.0;
    }

    float valueNoise(float2 point, uint seed) {
        int2 cell = int2(floor(point));
        float2 local = fract(point);
        local = local * local * (3.0 - 2.0 * local);

        float a = randomValue(cell, seed);
        float b = randomValue(cell + int2(1, 0), seed);
        float c = randomValue(cell + int2(0, 1), seed);
        float d = randomValue(cell + int2(1, 1), seed);

        return mix(
            mix(a, b, local.x),
            mix(c, d, local.x),
            local.y
        );
    }

    fragment float4 paperFragment(
        VertexOut in [[stage_in]],
        constant PaperParameters& parameters [[buffer(0)]],
        texture2d<float> paperTexture [[texture(0)]],
        sampler paperSampler [[sampler(0)]]
    ) {
        float2 pixel = in.position.xy + parameters.screenOriginPixels;
        float2 point = pixel / max(parameters.scale, 0.5);

        float tileSize = 384.0 * max(parameters.scale, 0.5);
        float paper = paperTexture.sample(
            paperSampler,
            pixel / tileSize
        ).r;

        float broad = valueNoise(point * 0.015, parameters.seed);
        float medium = valueNoise(point * 0.075, parameters.seed + 17);
        float fine = valueNoise(point * 0.45, parameters.seed + 41);

        float formation =
            broad * parameters.broadWeight +
            medium * parameters.mediumWeight +
            fine * parameters.fineWeight;

        float detail = (paper - 0.5) * 2.0;
        detail += (formation - 0.5) * parameters.broadWeight * 0.18;

        float weaveAmount = parameters.tintAndWeave.w;
        if (weaveAmount > 0.0) {
            float horizontal = sin(pixel.y * parameters.fiberScale);
            float vertical = sin(pixel.x * parameters.fiberScale * 0.92);
            detail += horizontal * vertical * weaveAmount;
        }

        detail = clamp(detail, -1.0, 1.0);

        float baseAlpha = clamp(
            parameters.strength * 0.35,
            0.0,
            0.14
        );
        float grainGain = 0.8 + parameters.grainAmount * 8.0;
        float grainAlpha = clamp(
            parameters.strength * abs(detail) * grainGain,
            0.0,
            0.18
        );

        float3 paperTint = parameters.tintAndWeave.xyz;
        float3 lightTone = mix(paperTint, float3(0.94), 0.68);
        float3 darkTone = mix(paperTint, float3(0.06), 0.55);
        float3 grainTone = detail >= 0.0 ? lightTone : darkTone;

        float alpha = grainAlpha + (1.0 - grainAlpha) * baseAlpha;
        float3 premultipliedColor =
            grainTone * grainAlpha +
            paperTint * baseAlpha * (1.0 - grainAlpha);

        return float4(premultipliedColor, alpha);
    }
    """#
}
