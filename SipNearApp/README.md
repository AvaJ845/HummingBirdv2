# SipNear (Native iOS)

Polished, Vivino-inspired wine discovery for iPhone — **no account**, **one easy button**, wineries around you.

Open this project in **Xcode** to build & run on a simulator or device.

## Open in Xcode

1. On a Mac, open:

```text
SipNearApp/SipNear.xcodeproj
```

2. Select an iPhone simulator (or your device)
3. Set your **Signing Team** under:
   `SipNear` target → **Signing & Capabilities**
4. Press **Run** (⌘R)

**Requirements:** Xcode 15+, iOS 17+ deployment target

## Easy-button flow

1. Launch SipNear  
2. Tap **Find Wineries Near Me**  
3. Allow location once  
4. Instantly see nearby wineries / tasting rooms / wine shops  
5. Browse top-rated bottles — save favorites on-device, no signup

## What’s included

| Area | Details |
|---|---|
| Nearby | Live OpenStreetMap Overpass lookup + MapKit map |
| Fallback | Curated Napa / Sonoma estates if live data is sparse |
| Discover | Red / white / rosé / sparkling / dessert filters |
| Wine detail | Ratings, tasting notes, grapes, ABV, one-tap save |
| Winery detail | Apple Maps directions, website, call |
| Saved | Local `UserDefaults` favorites — no account |

## Project structure

```text
SipNearApp/
  SipNear.xcodeproj
  SipNear/
    SipNearApp.swift
    Info.plist
    Assets.xcassets
    Theme/
    Models/
    Services/          # CoreLocation + Overpass
    Views/
      Components/      # EasyButton, cards, badges
      Screens/         # Welcome, Home, Nearby, Discover, Details
```

## Privacy

- Location is used only to query nearby wine places
- No accounts, passwords, or cloud profiles
- Saved wines stay on the device

## Notes for first Xcode run

- If location is denied, SipNear falls back to a **Napa Valley demo area** so you can still explore the UI
- App Transport Security allows the HTTPS Overpass endpoints used for winery search
- Add a 1024×1024 App Icon in `Assets.xcassets/AppIcon` before App Store submission
