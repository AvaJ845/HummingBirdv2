# SipNear

A polished, Vivino-inspired wine app with an **easy-button** experience:

- **No account required**
- **One tap** to pull wineries around you
- Browse top-rated bottles with tasting notes
- Save favorites on-device
- Native map on iOS / Android

Built with **Expo + React Native + TypeScript**.

## Easy-button concept

1. Open the app  
2. Tap **Find Wineries Near Me**  
3. Instantly see nearby wineries, tasting rooms, and wine shops  
4. Browse wines like Vivino — ratings, notes, price estimates — without signing up

## Features

| Feature | Details |
|---|---|
| Nearby wineries | Live OpenStreetMap / Overpass lookup around your GPS |
| Fallback picks | Curated Napa / Sonoma estates if live data is sparse |
| Discover | Red / white / rosé / sparkling / dessert filters |
| Wine detail | Ratings, tasting notes, grapes, ABV, save button |
| Winery detail | Directions, website, call — one tap |
| Saved | Local-only favorites via AsyncStorage |

## Run it

```bash
cd SipNear
npm install
npm run ios      # macOS + Xcode / Expo Go
npm run android  # Android Studio / Expo Go
npm run web      # quick browser preview
```

### iOS via Expo Go

1. Install **Expo Go** on your iPhone  
2. `npm start` in this folder  
3. Scan the QR code  
4. Tap **Find Wineries Near Me** and allow location

## Why Expo (not pure SwiftUI here)

This environment can’t compile native Xcode projects, so SipNear ships as an Expo app that builds to a real iOS binary (`eas build` / Xcode prebuild) while staying demoable on web.

## Project layout

```
SipNear/
  App.tsx
  src/
    components/   # EasyButton, WineCard, WineryCard…
    context/      # location + saved wines state
    data/         # sample wines + curated fallbacks
    navigation/   # tabs + stack
    screens/      # Welcome, Home, Nearby, Discover, Details
    services/     # GPS + Overpass winery fetch
    theme/        # burgundy / cream polish
```

## Privacy

- Location is used **only** to query nearby wine places
- No accounts, no passwords, no cloud profile
- Saved wines stay on the device
