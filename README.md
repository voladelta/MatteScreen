# MatteScreen

MatteScreen is a native macOS menu-bar utility that places a subtle paper surface over each selected display. It uses AppKit for click-through overlay windows and Metal for texture compositing.

It does not capture the screen. It does not change color temperature. It can run with f.lux or Night Shift.

## Requirements

- macOS 14 or later
- Xcode 16 or later
- A Metal-capable Mac

## Build and test

```sh
swift build
swift test
```

Build a local application bundle:

```sh
make app
open build/MatteScreen.app
```

The build script creates an ad-hoc signed app at `build/MatteScreen.app`. The app appears in the menu bar and does not create a Dock icon.

## Controls

Use the menu-bar icon to:

- enable or disable the surface;
- select one of nine authored textures;
- select texture strength and grain size;
- enable or disable individual displays;
- quit the app.

Settings persist in `UserDefaults`.

## Architecture

`DisplayCoordinator` owns one `OverlayPanel` per active display. Each panel ignores mouse events and joins all Spaces. A paused `MTKView` renders one full-screen triangle when settings or display parameters change. There is no frame timer while the surface is static.

The renderer samples an authored grayscale paper scan with repeated Metal texture addressing. The fragment shader combines a neutral contrast veil with separate light and dark paper grain.

The shader produces premultiplied translucent color. Core Animation then composites the surface over other applications. Metal does not read pixels from other windows, so MatteScreen does not need Screen Recording or Accessibility permission.
