# Screenshot Capture Guide — iOS and Android

**App:** TrySomething v1.0.0
**Date:** 2026-03-22

This guide covers capturing all 4 required screenshots for both app stores, plus setting up the demo account for Apple Review.

---

## Screens to Capture

4 screenshots, same screens on both platforms:

| Order | Screen | What Should Be Visible | Key Elements |
|-------|--------|----------------------|--------------|
| 1 | Home | Active hobby dashboard | Warm greeting ("Good morning"), active hobby card with "Week 2 of Photography" overline, coral "Start session" CTA, floating glass dock |
| 2 | Discover | Hobby discovery feed | Full-width hero card at 55-60% screen height, cinematic dark background, glass search bar, coral accents, floating dock |
| 3 | Detail | Hobby detail page | Stage roadmap card, spec badge (CHF X / Xh/week / Easy), "Start Hobby" CTA in coral, kit items |
| 4 | Session | Immersive session timer | Particle formation timer mid-animation (particles converging toward category shape), session glow effect, full-screen immersive (no nav bar) |

---

## Pre-Capture Setup

### 1. Demo Account Setup (required for screenshots and Apple Review)

Create the demo account in **production** so Apple reviewers can use it:

```bash
# Step 1: Register the account
curl -X POST https://your-api-domain.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "support@trysomething.io", "password": "YOUR_SECURE_PASSWORD"}'
```

Then set up hobby data (via API or direct database):

```bash
# Step 2: Log in to get auth token
curl -X POST https://your-api-domain.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "support@trysomething.io", "password": "YOUR_SECURE_PASSWORD"}'
# Save the accessToken from the response

# Step 3: Start a hobby (Photography recommended)
# Use the accessToken to create an active UserHobby
curl -X POST https://your-api-domain.vercel.app/api/users/hobbies \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -d '{"hobbyId": "PHOTOGRAPHY_HOBBY_ID", "status": "active"}'

# Step 4: Complete 2-3 roadmap steps
# Mark steps as completed via UserCompletedStep
curl -X POST https://your-api-domain.vercel.app/api/users/hobbies-detail \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -d '{"hobbyId": "PHOTOGRAPHY_HOBBY_ID", "stepId": "STEP_ID", "action": "complete"}'

# Repeat for 1-2 more steps

# Step 5: Add 1-2 journal entries
curl -X POST https://your-api-domain.vercel.app/api/users/journal \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -d '{"hobbyId": "PHOTOGRAPHY_HOBBY_ID", "text": "Took my first landscape photo today. The composition tips from the roadmap really helped."}'
```

**Store the password securely offline** — you will need it for the App Review demo account field in App Store Connect and the App Access field in Google Play Console.

### 2. Build Configuration

**Critical:** Always use **release builds** for screenshots. Debug builds show a red "DEBUG" banner that will cause store rejection.

---

## iOS Screenshot Capture

### Requirements
- macOS with Xcode 16+ installed
- iPhone 16 Pro Max Simulator available
- Flutter 3.6.0

### Steps

```bash
# 1. Open Simulator with iPhone 16 Pro Max
open -a Simulator
# In Simulator menu: File -> Open Simulator -> iPhone 16 Pro Max

# 2. Run the app in release mode on the simulator
flutter run --release -d "iPhone 16 Pro Max"

# 3. Log in with the demo account (support@trysomething.io)
```

**Capture each screenshot:**

1. **Home Screen**
   - Navigate to Home tab (first icon in floating dock)
   - Ensure the active hobby card shows "Week 2 of Photography" with coral CTA
   - Press **Cmd+S** in the Simulator window (saves PNG to Desktop)

2. **Discover Screen**
   - Tap the compass icon (second in floating dock)
   - Wait for the hero card to load fully
   - Press **Cmd+S**

3. **Detail Screen**
   - Tap any hobby card (e.g., the hero card on Discover)
   - Scroll to show the stage roadmap and spec badge
   - Press **Cmd+S**

4. **Session Screen**
   - Go back to Home, tap "Start session"
   - Wait for the timer to start and particles to begin converging
   - Pause at a visually appealing moment (particles mid-formation)
   - Press **Cmd+S**

Alternative capture method:
```bash
# Capture via command line (while app is running in Simulator)
xcrun simctl io booted screenshot ~/Desktop/trysomething_home.png
xcrun simctl io booted screenshot ~/Desktop/trysomething_discover.png
xcrun simctl io booted screenshot ~/Desktop/trysomething_detail.png
xcrun simctl io booted screenshot ~/Desktop/trysomething_session.png
```

### Expected Dimensions

| Device | Resolution | App Store Slot |
|--------|-----------|----------------|
| iPhone 16 Pro Max | **1290 x 2796** px | 6.3" display |

If App Store Connect requires 6.9" screenshots separately, also capture using:

| Device | Resolution | App Store Slot |
|--------|-----------|----------------|
| iPhone 17 Pro Max | 1320 x 2868 px (or 1260 x 2736 — check Simulator) | 6.9" display |

### Upload

Navigate to: **App Store Connect -> Your App -> (Version) -> Screenshots**
- Select "iPhone 6.3" Display" (or "6.9" Display" if required)
- Drag and drop 4 PNG files in order: Home, Discover, Detail, Session
- Verify no red error appears (dimensions match)

---

## Android Screenshot Capture

### Requirements
- Nothing Phone 3a connected via USB
- USB debugging enabled on the device
- Flutter 3.6.0

### Steps

```bash
# 1. Connect Nothing Phone 3a via USB cable
# Verify device is recognized
adb devices

# 2. Run the app in release mode
flutter run --release -d "YOUR_DEVICE_ID"
# Or just:
flutter run --release
# (if only one device is connected)

# 3. Log in with the demo account (support@trysomething.io)
```

**Capture each screenshot:**

**Option A: Physical buttons**
- Navigate to each screen
- Press **Power + Volume Down** simultaneously
- Screenshots save to device gallery

**Option B: ADB command**
```bash
# Navigate to Home screen, then:
adb shell screencap -p /sdcard/trysomething_home.png
adb pull /sdcard/trysomething_home.png ~/Desktop/

# Repeat for each screen:
adb shell screencap -p /sdcard/trysomething_discover.png
adb pull /sdcard/trysomething_discover.png ~/Desktop/

adb shell screencap -p /sdcard/trysomething_detail.png
adb pull /sdcard/trysomething_detail.png ~/Desktop/

adb shell screencap -p /sdcard/trysomething_session.png
adb pull /sdcard/trysomething_session.png ~/Desktop/
```

### Expected Dimensions

Nothing Phone 3a native resolution (screenshots will match device display resolution). Google Play accepts any phone resolution — no specific pixel size required.

### Upload

Navigate to: **Google Play Console -> Your App -> Store Listing -> Graphics -> Phone screenshots**
- Upload 4 screenshots in order: Home, Discover, Detail, Session
- Minimum: 2 screenshots required; we provide 4

---

## Composition Tips

### General
- App should display the **warm cinematic dark theme** (dark backgrounds, warm cream text, coral accents)
- The **floating glass dock** should be visible in screenshots 1-3 (Home, Discover, Detail)
- Screenshot 4 (Session) is full-screen immersive — no dock or status bar overlays
- Ensure no notifications or system overlays are visible
- Set device to "Do Not Disturb" before capturing

### Per Screen
1. **Home:** The warm greeting should say something like "Good morning" or "Good evening" — time it accordingly. The active hobby card should prominently show the hobby name and week number.
2. **Discover:** The hero card should display a visually appealing hobby with a good Unsplash image. Scroll position should be at top (hero fully visible).
3. **Detail:** Choose a photogenic hobby (Photography, Pottery, or Cooking work well). The roadmap steps and spec badge should be visible without scrolling too far.
4. **Session:** The particle timer is most visually striking at about 30-50% progress when particles are actively converging but haven't fully formed the shape yet.

---

## Checklist Summary

- [ ] Demo account created (`support@trysomething.io`) with active hobby + progress
- [ ] Demo account password stored securely offline
- [ ] iOS screenshots captured at 1290 x 2796 px (release build, no debug banner)
- [ ] Android screenshots captured from Nothing Phone 3a (release build, no debug banner)
- [ ] 4 iOS screenshots uploaded to App Store Connect
- [ ] 4 Android screenshots uploaded to Google Play Console
- [ ] All screenshots show warm cinematic dark theme
- [ ] No debug banners, notifications, or system overlays visible

---

*Guide generated: 2026-03-22 | Phase 09, Plan 02*
