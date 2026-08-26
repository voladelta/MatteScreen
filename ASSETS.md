# Texture assets

## ClassicMatte.png

`Sources/MatteScreen/Resources/ClassicMatte.png` was generated with the built-in OpenAI image-generation tool, then converted to a neutral 1024 × 1024 grayscale texture for Metal sampling.

Prompt:

```text
Use case: stylized-concept
Asset type: seamless material texture for a native macOS Metal screen overlay
Primary request: Create a premium classic matte paper surface texture, suitable for subtle full-screen compositing.
Scene/backdrop: a completely flat, edge-to-edge material scan with no scene and no objects
Style/medium: highly realistic uncoated cotton paper scan, fine dense micrograin, delicate short natural fibers, restrained low-frequency formation variation
Composition/framing: square 1:1 orthographic surface, uniform detail density across the full canvas, designed to tile seamlessly on all four edges
Color palette: strictly neutral grayscale centered around middle gray; no warm or cool color cast
Materials/textures: soft matte paper tooth, very fine random grain, sparse subtle fibers; no coarse canvas weave
Constraints: genuinely seamless and tileable; even illumination; no directional lighting; no shadows; no highlights; no vignette; no border; no corners; no folds; no creases; no stains; no speckles larger than fine paper fibers; no text; no watermark
Avoid: cloudy blobs, obvious repetition, large features, embossing, fabric weave, photography perspective, paper sheet edges
```

Processing normalizes the image to neutral grayscale with a mean near 50%. Metal samples it as a large repeating surface so any boundary remains below the visible contrast of the paper grain.

## Additional paper textures

The eight additional PNG files in `Sources/MatteScreen/Resources` were generated one at a time with the built-in OpenAI image-generation tool. Each source was converted to a neutral 1024 × 1024 grayscale map and centered near 50% mean luminance. Metal supplies the preset color at runtime.

### WhisperWeave.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Whisper Weave, a very fine, soft fabric weave with delicate irregular threads and subtle tactile depth. Square 1:1 orthographic flat scan, uniform density from edge to edge, neutral mid-gray overall, low-to-medium contrast. Even illumination. No baked color, no directional light, no cast shadows, no highlights, no vignette, no borders, no objects, no text, no watermark, no large stains or dominant features. Avoid coarse canvas, regular synthetic grids, and moire. The result must remain legible at low opacity and tile cleanly.
```

### SunbakedParchment.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Sunbaked Parchment, with rich heavy irregular parchment grain, dense varied natural fibers, and restrained broad mottling. Square 1:1 orthographic flat scan, uniform density from edge to edge, neutral mid-gray overall, medium contrast. Even illumination. No baked amber or other color; runtime shader supplies color. No directional light, cast shadows, highlights, vignette, borders, objects, writing, text, watermark, tears, burned edges, stains, or dominant features. The result must feel substantial and aged but remain calm at low opacity and tile cleanly.
```

### SaddleLinen.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Saddle Linen, a coarse natural linen crossweave with irregular yarn thickness, small slubs, rugged loose fibers, and earthy handmade character. Square 1:1 orthographic flat scan, uniform density edge to edge, neutral mid-gray overall, medium contrast. Even illumination. No baked color; runtime shader supplies warm tone. No directional light, cast shadows, highlights, vignette, borders, objects, text, watermark, stains, folds, or seams. Avoid a perfectly regular synthetic grid and avoid moire. The pattern must remain tactile at low opacity and tile cleanly.
```

### PaintersPress.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Painter's Press, a cold-press watercolor paper surface with subtle irregular pebbled tooth, random shallow pits, compressed fibers, and natural depth. Square 1:1 orthographic flat scan, uniform density edge to edge, neutral mid-gray overall, medium contrast. Even illumination with depth conveyed only by local tonal grain, not directional shading. No baked color, cast shadows, highlights, vignette, borders, deckled edges, objects, paint, text, watermark, stains, or dominant features. It must look freshly pressed, remain nuanced at low opacity, and tile cleanly.
```

### MulberryVeil.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Mulberry Veil, a sheer handmade mulberry-paper surface with delicate long organic fibers, wispy fiber crossings, and restrained translucent-looking formation. Square 1:1 orthographic flat scan, uniform density edge to edge, neutral mid-gray overall, low contrast. Even illumination. No baked plum or other color; runtime shader supplies color. No directional light, shadows, highlights, vignette, borders, objects, flowers, writing, text, watermark, stains, holes, or large dominant fibers. Soft and atmospheric at low opacity, with clean tiling.
```

### VellumMist.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Vellum Mist, a soft frosted-vellum surface with very low-contrast diffuse haze, quiet cloudlike paper formation, and sparse fine fibers. Square 1:1 orthographic flat scan, uniform density edge to edge, neutral mid-gray overall, low contrast. Even illumination. No baked color, directional light, shadows, highlights, vignette, borders, objects, text, watermark, stains, creases, or dominant features. The texture must be calm and minimal for long reading sessions, visibly tactile only at low opacity, and tile cleanly.
```

### MonasticFelt.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Monastic Felt, a dense close-cropped fiber surface with a quiet fine nap, random short fibers, compact soft fuzz, and muted tactile warmth. Square 1:1 orthographic flat scan, uniform density edge to edge, neutral mid-gray overall, low-to-medium contrast. Even illumination. No baked color, directional light, shadows, highlights, vignette, borders, objects, leather grain, woven pattern, text, watermark, stains, seams, or dominant strands. It must feel meditative and worn-in at low opacity and tile cleanly.
```

### CarbonLedger.png

```text
Create a seamless grayscale material map for a native macOS Metal screen overlay. Asset: Carbon Ledger, a precise cool graphite-paper surface with very fine restrained horizontal ruling, subtle mechanical regularity, and crisp micro-grain. Square 1:1 orthographic flat scan, uniform density edge to edge, neutral mid-gray overall, low-to-medium contrast. Lines must be thin, straight, evenly spaced, and understated, with enough organic graphite grain to prevent a sterile digital look. Even illumination. No baked blue or other color; runtime shader supplies color. No vertical grid, writing, numbers, objects, shadows, highlights, vignette, borders, watermark, stains, or moire. It must support code and analytical work at low opacity and tile cleanly.
```
