# Signal (macOS)

Signal is a macOS SwiftUI desktop app with a modern editorial landing page and collapsible left sidebar.

## Frontend features implemented

- macOS-native app target (`Signal`) for Xcode.
- Collapsible left sidebar.
- Full-bleed static background image.
- Large gradient typographic overlay.
- Top navigation bar with logo, links, and hamburger toggle.
- Bottom-left info block + rounded `CONTACT US` button.
- Bottom-right glassmorphism tag pills with wrapping layout.
- Google fonts bundled in app resources:
  - Anton SC
  - Inter
  - Manrope

## Run

```bash
xcodegen generate
open Signal.xcodeproj
```

Then build and run the `Signal` scheme.
