# SipNear

**Native SwiftUI iPhone app** — Vivino-inspired wine discovery with an Apple North Star bar: clarity, deference, depth, and a single unmistakable easy button.

> No account. One tap. Wineries around you.

Open in Xcode:

```text
SipNearApp/SipNear.xcodeproj
```

## Product principles (Apple HIG)

- **Clarity** — one primary action: *Find Wineries Near Me*
- **Deference** — content first; chrome stays quiet
- **Depth** — continuous corners, materials, spring motion (honors Reduce Motion)
- **Accessibility** — Dynamic Type–friendly type, VoiceOver labels, semantic contrast
- **Privacy** — location only for nearby search; saves stay on-device; privacy manifest included

## Run on your iMac

1. Clone / pull this repo  
2. Open `SipNearApp/SipNear.xcodeproj`  
3. Select an **iPhone 16** (or any iOS 17+) simulator  
4. Target → **Signing & Capabilities** → choose your Team  
5. Press **Run** (⌘R)  
6. In Simulator: **Features → Location → Custom Location** (or Apple)  
7. Tap **Find Wineries Near Me**

### Tests

```bash
xcodebuild test \
  -project SipNearApp/SipNear.xcodeproj \
  -scheme SipNear \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

```text
SipNear/
  App/                 # @main, RootView
  Core/
    DesignSystem/      # tokens, adaptive colors, motion
    Models/            # Wine, Winery, catalogs
    Services/          # @Observable AppModel, CoreLocation, Overpass
    Utilities/         # Geo, haptics
  Features/            # Welcome, Home, Nearby, Discover, Details, Saved
  Shared/Components/   # EasyButton, cards, chips
  Resources/           # Info.plist, Assets, PrivacyInfo
SipNearTests/          # Geo + Overpass mapping tests
```

Swift concurrency: `@MainActor` UI model, `Sendable` models, strict concurrency enabled.

## Features

| Surface | Behavior |
|---|---|
| Welcome | Hero easy button — no signup wall |
| Nearby | MapKit map + live OpenStreetMap Overpass results |
| Fallback | Curated Napa / Sonoma estates when live data is sparse |
| Discover | Style filters, ratings, tasting notes |
| Detail | Save locally, Directions via Apple Maps |
| Saved | On-device favorites via `UserDefaults` |

## Requirements

- Xcode 15+ (Xcode 16 recommended)
- iOS 17+ deployment target
- Apple ID for simulator signing

## When you’re back

Allow Cursor / this agent access to your Mac’s Xcode simulator and we can iterate with live builds, Instruments, and accessibility audits against Apple’s North Star bar.
