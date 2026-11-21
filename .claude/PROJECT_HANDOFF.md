# Myanmar Alphabet — Project Handoff & Update Log

> **Status:** Reflects the code in `lib.zip` as of 18 Nov 2026 (after §3A ad/streak/cleanup, §3B liquid glass UI, §3C menu simplification, §3D flashcard fixes, §3E flashcard banner, §3F review fixes, §3G manifest/pubspec review, §3H privacy policy review, §3I duplicate class + deprecations, §3J analyzer clean-up + code-vs-handoff check, §3K–§3M website/icon/iOS release prep, §3N website phone mock-up, §3O documentation v2.0, §3P App Store header art, §3Q App Store text for the next version, UML review). Where this file and the code disagree, the code wins.
>
> **Purpose:** This document is written for any AI agent or developer continuing work on this project.
> It captures the full current state, what was recently changed and why, what still needs doing,
> and all technical context required to work safely on this codebase.

---

## 1. Project Overview

| Field | Value |
|---|---|
| **App name** | Learn Myanmar Alphabet |
| **Package** | `myanmar_alphabet` |
| **Version** | 1.0.3+4 |
| **Framework** | Flutter / Dart (Windows dev machine) |
| **Target platforms** | **iOS only** — live on the App Store. Android is used for local testing (emulator) only and is **not published** (confirmed by the developer, 18 Nov 2026). |
| **Audience** | Children age 4+, learning Myanmar consonants (33) and numbers (0–10) |
| **Developer** | Ru di pah (the privacy policy spells it "Ru Di Pah"; use one spelling consistently) — contact email **`learnmyanmaralphabet@gmail.com`** (confirmed by the developer 21 Nov 2026; use it on the privacy policy, website and App Store Connect) / GitHub: `rudipah` |
| **Project path (Windows)** | `C:\Users\dipah\Documents\myanmar_alphabet\` |
| **Developer website** | https://learn-myanmar-alphabet.web.app/ (Firebase Hosting; new app-information homepage prepared, deployment not yet confirmed — see §3K). The old GitHub Pages site is no longer the developer website. |

### App features
- **Letter tracing** — finger-draw each Myanmar character with stroke guidance
- **Flashcards** — tap to flip between letter and image/word; swipe to navigate
- **Quiz** — 10 questions; visual mode (see letter, pick name) and audio mode (hear sound, pick letter)
- **Matching game** — match letter cards to image cards (6 pairs, confetti on win)
- **Progress screen** — star-tier system (0 / 1 / 2 / 3 stars per letter based on practice count)
- **Letter of the Day** — shown on the menu screen, changes daily
- **Daily streak counter** — still recorded (counts days the child *finishes* a tracing, quiz round or matching round) but **not displayed anywhere since §3C**
- **Sound toggle** — Settings → "Sound Effects" only (the menu button was removed in §3C)

### Key packages (pubspec.yaml)
```
confetti: ^0.7.0
google_mobile_ads: ^5.1.0
just_audio: ^0.9.40
shared_preferences: ^2.2.3
unity_ads_plugin: ^0.3.20
```
Dev: `flutter_launcher_icons`, `flutter_native_splash`, `flutter_lints`, `flutter_test`, `integration_test`

Resolved versions on 18 Nov (from `pubspec.lock` via `flutter pub get`): `google_mobile_ads 5.3.1`, `unity_ads_plugin 0.3.30`, `just_audio 0.9.46`, `confetti 0.7.0`, `shared_preferences 2.5.5`. Newer major versions exist (e.g. `google_mobile_ads 9.2.0`, `unity_ads_plugin 0.6.0`), but they are **not** a drop-in upgrade — don't bump them without testing ads on a device.

### Assets
- `assets/audio/` — `.ogg` files for letters (`ka.ogg`, `ka_long.ogg`, etc.)
- `assets/images/` — images shown on flashcard backs
- `assets/data/` — JSON data files loaded by `DataLoader`
- `assets/fonts/` — `Pyidaungsu-2.5.3_Regular.ttf` + Bold (Myanmar Unicode font)

---

## 2. Architecture — File Map

```
lib/
├── main.dart                        Entry point; initialises app, loads data, sets portrait lock
├── data/
│   ├── data_loader.dart             Loads letters/numbers/flashcards from JSON assets
│   ├── letters_data.dart            Hardcoded fallback letter list (used if JSON fails)
│   ├── numbers_data.dart            Hardcoded fallback numbers list
│   └── stroke_data.dart             Centerline stroke paths for tracing (Pyidaungsu-derived)
├── models/
│   ├── letter.dart                  MyanmarLetter model
│   └── flashcard.dart               Flashcard model (letter, pronunciation, image, audio, word)
├── painters/
│   └── background_painter.dart      Custom painter for tracing screen background
├── screens/
│   ├── menu_screen.dart             Home menu — Letter of the Day, Start Learning, 2×2 grid, Settings (no streak badge / mute button, §3C)
│   ├── home_screen.dart             Letter/number grid — tapping opens TracingScreenWithNav
│   ├── tracing_screen.dart          Stroke-guided letter tracing
│   ├── flashcard_screen.dart        Flip cards with progress bar and swipe hint
│   ├── quiz_screen.dart             10-question quiz with haptic feedback
│   ├── matching_game_screen.dart    6-pair letter↔image matching game
│   ├── progress_screen.dart         Per-letter star progress grid
│   └── settings_screen.dart        Audio format, sound toggle, reset progress
├── services/
│   ├── app_initializer.dart         Single init point: child-directed ad config, then AdMob + Unity Ads (background) + SoundService
│   ├── ad_manager.dart              Singleton — rotates AdMob/Unity, 2-min cooldown (starts only after a REAL show)
│   ├── unity_ads_service.dart       Unity Ads wrapper (init, interstitial only)
│   ├── sound_service.dart           just_audio wrapper with caching and long/short audio support; respects the mute setting
│   ├── preferences_service.dart     SharedPreferences: audio format, sound toggle, progress, streak
│   └── tracing_validator.dart       Validates finger-tracing accuracy against stroke paths
├── utils/
│   ├── ad_helper.dart               AdMob banner + interstitial ad unit IDs and load/show logic
│   ├── app_colors.dart              Brand colour constants (primary: #6C5CE7) + glass palette (§3B)
│   └── navigator_util.dart          Thin Navigator.push wrapper
└── widgets/
    ├── menu_button.dart             Glass menu button (isPrimary = purple-tinted glass)
    ├── glass_container.dart         Core glass surface (blur + fill + border + specular)
    ├── glass_button.dart            Tinted glass button (disabled state = onPressed null)
    ├── glass_progress_bar.dart      Frosted track, lilac→pink animated fill
    ├── mesh_background.dart         Animated mesh background + GlassScaffold wrapper
    ├── tracing_board.dart           Tracing UI scaffold widget
    ├── tracing_canvas.dart          CustomPainter canvas for finger tracing
    ├── banner_ad_widget.dart        Self-contained adaptive AdMob banner (load/state/dispose)
    └── nav_icon_button.dart         Shared back/nav icon button (now a glass pill)
```

> **Unzipping over an existing `lib/` never deletes files.** Four unused legacy files keep coming back in zips (`lib/data/flashcard_data.dart`, `lib/services/progress_service.dart`, `lib/services/preferences_service.dart` + a trailing backtick, `lib/utils/ads_stub.dart`). They were still present in the zip reviewed on 18 Nov (§3J). Nothing references them — delete them by hand.

---

## 3. What Was Changed in This Session (November 2026)

### 3.1 Critical Bug Fixes — Ad Revenue & COPPA

#### Fix 1 · Unity Ads `testMode` hardcoded → `kDebugMode`
- **File:** `lib/services/unity_ads_service.dart`
- **Problem:** `testMode: true` was hardcoded. Unity Ads served test ads in production, earning $0.
- **Fix:** Changed to `testMode: kDebugMode`. Now automatically `true` in debug builds, `false` in release builds.

#### Fix 2 · AdMob `_isProduction` hardcoded → `kReleaseMode`
- **File:** `lib/utils/ad_helper.dart`
- **Problem:** `static const bool _isProduction = false` was hardcoded. AdMob also used test IDs in production.
- **Fix:** Changed to `static bool get _isProduction => kReleaseMode`.

#### Fix 3 · Placeholder interstitial Ad Unit IDs
- **File:** `lib/utils/ad_helper.dart`
- **Problem:** Production interstitial IDs were `1234567890` / `0987654321` (fake placeholders).
- **Status:** ⚠️ **STILL NEEDS MANUAL ACTION** — placeholders replaced with `REPLACE_ANDROID_INTERSTITIAL` / `REPLACE_IOS_INTERSTITIAL` as clear TODOs. Developer must log in to AdMob dashboard, create real Interstitial ad units, and paste the real IDs. Until then a release build retries and fails the AdMob load each time and only Unity interstitials show.
- **Banner IDs are correct:** `ca-app-pub-4129659429509766/3143061906` (Android) and `ca-app-pub-4129659429509766/7699563630` (iOS).

#### Fix 4 · COPPA violation — AdvertisingId collection removed
- **Files:** `lib/services/app_initializer.dart`, `pubspec.yaml`
- **Problem:** `AdvertisingId.id(true)` was being called and the device advertising ID was printed to logs. Collecting advertising IDs in a child-directed app is illegal under COPPA and violates Google Play Families Policy.
- **Fix:** Removed all `AdvertisingId` calls from `app_initializer.dart`. Removed `advertising_id: ^2.7.0` from `pubspec.yaml`.

#### Fix 5 · Duplicate `MobileAds.instance.initialize()` call
- **Files:** `lib/main.dart`, `lib/services/app_initializer.dart`
- **Problem:** AdMob was initialised twice — once in `main.dart` and once in `AppInitializer.init()`.
- **Fix:** Removed the block from `main.dart`. All SDK initialisation now lives exclusively in `AppInitializer.init()`.

#### Fix 6 · `print()` replaced with `debugPrint()` in Unity Ads
- **File:** `lib/services/unity_ads_service.dart`
- **Problem:** 10+ `print()` calls run in release builds, polluting logs and potentially leaking info.
- **Fix:** All `print()` replaced with `debugPrint()`.

---

### 3.2 New Shared Widgets

#### `lib/widgets/banner_ad_widget.dart` (NEW)
- Self-contained widget that handles its own `BannerAd` load, setState, and dispose.
- Use as `bottomNavigationBar: const BannerAdWidget()` on any `Scaffold`.
- Replaces ~30 lines of duplicated `_bannerAd` / `_loadBannerAd()` / `dispose()` code that existed in every screen.
- Now an adaptive anchored banner inside `SafeArea` (see §3F). It hides itself if the ad fails to load; the failure is logged as `Banner ad failed to load: <error>` (see §6 for how to read that).

#### `lib/widgets/nav_icon_button.dart` (NEW)
- Shared white-card icon button used for back navigation.
- Replaces the identical `_buildNavButton()` private method that was duplicated in `quiz_screen`, `flashcard_screen`, `progress_screen`, and `matching_game_screen`.

---

### 3.3 UI / UX Improvements

#### Letter of the Day — fixed weak daily index formula
- **File:** `lib/screens/menu_screen.dart`
- **Problem:** `(now.month + now.day) % flashcards.length` caused collisions — e.g. April 10 and March 11 both gave index 14.
- **Fix:** Uses day-of-year: `now.difference(DateTime(now.year, 1, 1)).inDays + 1`, giving a unique letter for every calendar day without any extra package dependency. (Later switched to UTC dates, §3A.3.)

#### Daily streak counter added
- **Files:** `lib/services/preferences_service.dart`, `lib/screens/menu_screen.dart`
- (Historical) a 🔥 streak badge was shown top-left on the menu; removed in §3C.
- Superseded by §3A.3: `PreferencesService.recordStudyActivity()` now updates the streak (see below).
- Streak is also reset when "Reset All Progress" is triggered in Settings.

#### Mute toggle
- (Historical) a 🔊/🔇 button on the menu screen; removed in §3C. Sound is now toggled in Settings only.
- Persisted via `PreferencesService.setSoundEnabled()` / `isSoundEnabled()`.
- `SoundService.playLetter()` and `playLetterAndWord()` return immediately when sound is off, and turning sound off in Settings also stops any clip already playing (`SoundService.stop()`). Before 18 Nov the setting was saved but `SoundService` never read it, so muting had no effect (see §3J).
- The Letter of the Day tap also respects this setting.

#### Flashcard screen — progress bar + swipe hint
- **File:** `lib/screens/flashcard_screen.dart`
- Added `X / 33` counter and `LinearProgressIndicator` below the header.
- Added a "Tap to flip • Swipe to navigate" hint text below the card.

#### Quiz screen — haptic feedback
- **File:** `lib/screens/quiz_screen.dart`
- Correct answer: `HapticFeedback.mediumImpact()`
- Wrong answer: `HapticFeedback.heavyImpact()`

#### Quiz screen — rewarded ad hint button — NOT PRESENT
- Earlier versions of this document described a "Get a Hint • Watch an Ad" button. **It is not in the current code** (no `showRewardedAd`, no `_hintActive`). Unity is used for interstitials only. The developer chose banners instead of a rewarded hint. If a hint feature is wanted it must be re-implemented — and a rewarded ad in a Families app needs a Families-certified network and a parent-friendly flow.

#### Settings screen — consistent header style
- **File:** `lib/screens/settings_screen.dart`
- Replaced the `AppBar` widget (which used gradient purple) with the same custom `Row` + `NavIconButton` header pattern used by all other screens.
- Added a **Sound Effects** `SwitchListTile` at the top of the settings list.
- Audio format radio buttons are disabled when sound is off.

---

### 3.4 `preferences_service.dart` — New Methods

```dart
// Sound toggle
static Future<void> setSoundEnabled(bool enabled)
static Future<bool> isSoundEnabled()

// Streak (see §3A.3)
static Future<int> recordStudyActivity()  // call when a tracing / quiz round / matching round is FINISHED
static Future<int> getCurrentStreak()     // read-only; returns 0 if the streak has lapsed
```

---

### 3.5 `pubspec.yaml` — Removed Package

```yaml
# REMOVED:
advertising_id: ^2.7.0
```

After pulling changes, run `flutter pub get` to sync.

---

## 3A. Session 2 (16 Nov 2026) — Ad reliability, streak, cleanup

> Code changes were made against `lib.zip`. They were **not compiled or run** in the authoring environment (no Flutter SDK) — run `flutter pub get && flutter analyze && flutter run` and play through each game once before release.

### 3A.1 Unity interstitial reports the real result
- **File:** `lib/services/unity_ads_service.dart`
- `showInterstitialAd()` used to return `true` immediately, even if the ad failed, so a failed show still started the 2-min cooldown and rotated provider.
- Now returns `true` only on `onStart` (or `onComplete`), `false` on `onFailed`, if nothing is loaded, or after an 8 s timeout.
- Added `isInterstitialReady`; `loadInterstitialAd()` returns `true` immediately if already loaded and shares an in-flight load instead of starting a second one. A loaded Unity ad is single-use, so the flag is cleared when shown.

### 3A.2 AdMob interstitial reuse + dispose
- **Files:** `lib/utils/ad_helper.dart`, `lib/services/ad_manager.dart`
- Old behaviour: every call re-loaded an ad, waited a fixed 500 ms, and never disposed the previous ad (leak).
- Now: one ad is loaded and reused until shown; no-op if already loaded/loading; ads are `dispose()`d after dismiss, on failed-to-show, and on error. The 500 ms delay is gone.
- `AdManager.showInterstitialAd()` no longer waits on loads (no UI stall when a child taps Back): it tries the current provider, falls back to the other, and only a real show starts the cooldown and rotates provider. It then calls `preloadAds()` so the next ad is ready.
- Trade-off: if neither provider has an ad ready at that moment, no ad is shown that time (instead of making the child wait).

### 3A.3 Streak rewritten
- **Files:** `lib/services/preferences_service.dart`, `lib/screens/menu_screen.dart`, `tracing_screen.dart`, `quiz_screen.dart`, `matching_game_screen.dart`
- Old: updated whenever the menu opened, and compared `DateTime.now().difference(lastDate).inDays`, which can wrongly break a streak on a daylight-saving change day.
- New: dates are compared as calendar dates (UTC date-only values). `getAndUpdateStreak()` was **removed**; `recordStudyActivity()` is called on: successful tracing (`_onDone`), quiz result dialog, matching win dialog. `getCurrentStreak()` returns 0 if the last study day was before yesterday.
- (Historical) the menu showed `getCurrentStreak()`; the badge was removed in §3C. `getCurrentStreak()` currently has no caller.
- Also fixed in `menu_screen.dart`: the Letter-of-the-Day day-of-year used local-time `difference`, which is off by one for the half of the year after the spring clock change (e.g. UK). Now uses UTC dates.

### 3A.4 Cleanup
- Deleted: `lib/services/progress_service.dart` (unused), `lib/data/flashcard_data.dart` (unused), `lib/services/preferences_service.dart` + backtick (stale older copy), `lib/utils/ads_stub.dart` (unused; nothing imported it).
- Removed unused imports (`google_mobile_ads`, `ad_helper`) from `tracing_screen.dart`.
- **Note:** these four files reappeared in later zips and must be deleted by hand each time (see the box under §2 and §3J).

### 3A.4b Menu screen background under the banner ad
- **File:** `lib/screens/menu_screen.dart`
- Problem: the purple gradient was only on the `body`, while `BannerAdWidget` sits in `bottomNavigationBar` (a separate Scaffold slot). That slot, including the banner's 8px top gap and the bottom safe area, showed the default white Scaffold background.
- Fix: the gradient `Container` now wraps the whole `Scaffold`, and the Scaffold uses `backgroundColor: Colors.transparent`, so the gradient also shows behind the banner area.
- Superseded by §3B: every screen now uses `GlassScaffold`, so the background always sits behind the banner slot.
- Any white *inside* the ad itself is the ad creative's own background and cannot be changed from the app.

### 3A.5 Corrections to earlier sections of this document
- Quiz hint / rewarded ad: **does not exist** in the code (see §3.3).
- Banners were on every screen except `FlashcardScreen` at that time — fixed in §3E.
- Unity is interstitial-only. Ad flow: interstitial after leaving Flashcards, after quiz completion, after matching completion.

---

## 3B. Liquid Glass UI (implemented from `liquid_glass_preview.html`)

> Not compiled/run in the authoring environment (no Flutter SDK; files were syntax-parsed only). Run `flutter analyze` and click through every screen. `lib_1.zip` was the pre-glass code plus the four legacy files from §3A.4 — those four are deleted again in the zip delivered with this change.

**New widgets**
- `GlassContainer` — `ClipRRect` → optional `BackdropFilter` → animated translucent fill + 1px border → top-half white specular gradient → transparent `Material` (so ink ripples and `ListTile`s paint above the glass). Params: `blur`, `fillOpacity`, `tint`, `borderColor`, `specularOpacity`, `onTap`, `darkMaterial`.
  - `darkMaterial: true` re-themes Material widgets inside (ListTile, Switch, Radio, Divider) to light-on-dark — used by the Settings cards.
  - **`blur: 0` skips the `BackdropFilter`.** Use it for grids of small tiles (Letters, Progress, Matching). The mesh behind is smooth so it looks the same, and it avoids 30+ backdrop blurs on low-end Android.
- `MeshBackground` / `GlassScaffold` — opaque dark base (`#150D2E`) + four radial colour blobs that drift slowly (≈15 fps, driven by one app-wide clock so it is continuous between screens, muted when the system "remove animations" setting is on). `GlassScaffold` = mesh + transparent `Scaffold`; **every screen now uses it instead of `Scaffold(backgroundColor: ...)`**. It also sets light status-bar icons and a dark navigation bar, and sits behind the banner ad area (this also replaces the §3A.4b fix on the menu).
- `GlassButton`, `GlassProgressBar` — see file map.
- `AppColors` gained: `meshBase`, `onGlass` (white 95%), `onGlassMuted` (55%), `glassCorrect`, `glassWrong`, glass alpha constants, and `AppColors.white(alpha)`.

**Screens changed:** menu, flashcard, quiz, letters (`home_screen`), progress, settings — as in the preview — plus **matching and tracing**, which were not in the preview but would otherwise be dark text on the new dark background.
- Letters: per-letter colours are kept as a tint on each glass tile and a glow behind a white character (dark/bright letter colours no longer have to be readable on their own).
- Progress: star tiers use glow colours (orange / silver / lilac).
- Quiz: correct/wrong options are green/red tinted glass; "Next Question" is a `GlassButton`.
- Tracing: the **drawing board stays cream** on purpose (stroke contrast + validation); only the header, Clear (neutral glass) and Done (tinted with the letter's colour) changed.
- `AlertDialog`s (quiz result, matching win, reset progress) and SnackBars are still the default light Material style.

**Rules for new screens**
- Wrap the screen in `GlassScaffold`; use white / `AppColors.onGlass` text; build cards with `GlassContainer`.
- Never put a `BackdropFilter` on every item of a long list/grid (`blur: 0`). Backdrop blur is currently disabled app-wide (§3D, `kGlassBackdropBlur`).

---

## 3C. Menu simplification (17 Nov 2026)

- **File:** `lib/screens/menu_screen.dart`
- Removed the top row: the 🔥 "N day(s)" streak badge and the mute/unmute button.
- Removed the code that only served them: the `_streak` field, the streak load, the `_toggleSound()` method, and the streak refresh after returning from a sub-screen. `_open()` is now a plain `Navigator.push`.
- **Unchanged:** the streak is still recorded by `PreferencesService.recordStudyActivity()` (tracing, quiz, matching) and cleared by "Reset All Progress", so it can be shown again later. Letter of the Day still respects the sound setting (`isSoundEnabled()`).
- Sound can now only be turned off in **Settings → Sound Effects**. Consider whether a parent-facing quick mute is still wanted.

---

## 3D. Flashcards responsiveness fixes (17 Nov 2026)

Triggered by a device log with `Skipped 38 frames` while using Flashcards and taps not responding. Not compiled/run — verify on device.

1. **Sound taps were being ignored (main cause)** — `lib/services/sound_service.dart`
   - `just_audio`'s `play()` Future completes only when the clip *finishes*. `playLetter()` awaited it while holding an `_isBusy` lock, so every speaker tap during playback (long audio / word clips are several seconds) was silently dropped.
   - Now: no lock; each request takes a token (`_playToken`) and **the newest tap wins** (interrupts the current clip). `play()` is not awaited by default.
   - `playLetter(file, {waitForCompletion: true})` keeps the old "returns when the clip ends" behaviour — used by `tracing_screen.dart` for its speaking animation. `playLetterAndWord` (matching) still plays letter then word in sequence, and is cancelled if a newer sound starts.
2. **Backdrop blur disabled globally** — `lib/widgets/glass_container.dart`
   - New `const bool kGlassBackdropBlur = false`. `BackdropFilter`s over the animated mesh cost a full re-blur per frame (and a `saveLayer` while the card fade/scale animates). The background is a smooth gradient, so the blur was invisible anyway; the glass look is unchanged. Set to `true` only if detailed content is ever placed *behind* glass. The `blur:` parameters stay in the API.
3. **Flashcard back-side image** is decoded at `cacheHeight: 300` (was full resolution).
4. **Crash guard**: `_nextCard()` / `_prevCard()` return early if the list hasn't loaded (previously `% 0` → exception on a fast tap).

**How to test performance:** debug builds are far slower than real use (and the first frame compiles shaders). Judge smoothness with `flutter run --profile` (or `--release`) on a real device, not `flutter run`. The `ConsumerBase ... abandoned` and `Dynamic lookup for intent failed` lines in the log are harmless Android / Google Mobile Ads noise.

---

## 3E. Banner added to Flashcards (17 Nov 2026)

- `lib/screens/flashcard_screen.dart` now shows `BannerAdWidget` in `bottomNavigationBar`, so **banners are on every screen**. This supersedes the "except Flashcards" notes in §3A.5 and the Ad Flow section.
- Flashcards also still shows an interstitial when leaving via the back button.
- The card area is inside an `Expanded`, so it simply gets a little less height while the banner is visible; check on a small phone that the card and the nav arrows still fit.

---

## 3F. Code review fixes (17 Nov 2026, on `lib_59b938.zip`)

> `lib_59b938.zip` = the previous delivery **plus the four legacy files again** (`progress_service.dart`, `flashcard_data.dart`, `preferences_service.dart` + backtick, `ads_stub.dart`). Unzipping over an existing `lib/` never deletes files — **delete those four by hand** (they are unused). Not compiled/run; verify on device.

**Bugs fixed**
- **Quiz — duplicate answers** (`quiz_screen.dart`): the same wrong letter could be picked twice, giving two identical option buttons. Now exactly 3 distinct wrong letters; also no `setState` after the screen is closed, and no infinite loop if fewer than 4 cards exist.
- **Matching — crash on leaving quickly** (`matching_game_screen.dart`): two `Future.delayed(... setState ...)` callbacks (600 ms / 1000 ms) and `_setupGame` ran `setState` after the screen was disposed. Added `mounted` guards.
- **Tracing** (`tracing_screen.dart`): `_celebrateController` was never disposed (leak); `_onDone` used `context` after an `await` without a `mounted` check; the success dialog's "Continue" button had purple-on-colour text (now white).

**Startup / ads**
- **Faster cold start** (`app_initializer.dart`): child-directed request config is still awaited first, but `MobileAds.initialize()`, `UnityAdsService.initialize()` and the first preload now run in the background (`AppInitializer.adsReady`). Previously `runApp` waited for both SDKs. `BannerAdWidget` awaits `adsReady` before requesting an ad.
- **No layout jump when the banner loads** (`banner_ad_widget.dart`): ~68 px is reserved while the ad loads and collapses if it fails. A layout that shifts under a child's finger risks accidental ad taps (Families policy concern).

**Reviewed, left as is / optional next steps**
- `TracingValidator` only checks that the guide is *covered*; scribbling extra lines still passes. Optionally also reject strokes that stray far from the guide.
- Every screen creates its own banner request (a new ad request per screen open). Fine for now; if fill rate drops, consider fewer/ cached banners.
- ~~`TracingScreenWithNav` defined twice~~ — fixed in §3I.
- ~~Deprecation lints~~ — fixed in §3I.
- Dialogs are still light Material style (can be restyled as glass).
- Still waiting on: `AndroidManifest.xml` (AD_ID permission, INTERNET, AdMob app ID) and `pubspec.yaml` for a dependency review (done in §3G).

---

## 3G. AndroidManifest.xml & pubspec.yaml review (17 Nov 2026)

> **Android-only parts below are not needed while the app is iOS-only** (confirmed 18 Nov 2026). Kept for reference if Android is ever published. The `pubspec.yaml` notes still apply.

**AndroidManifest.xml — one real policy issue, fixed (`AndroidManifest.xml` delivered alongside `lib.zip`)**
- The manifest itself does not declare `AD_ID`, but `google_mobile_ads` / Play Services **merge `com.google.android.gms.permission.AD_ID` into the final APK/AAB**. For a children's app targeting Android 13+ this must be explicitly removed. Added `xmlns:tools` and `<uses-permission android:name="com.google.android.gms.permission.AD_ID" tools:node="remove"/>`, plus the same for `android.permission.ACCESS_ADSERVICES_AD_ID` (precaution; harmless if no library adds it).
- **Verify after building** (the merged result is what Play sees): Android Studio → `AndroidManifest.xml` → *Merged Manifest* tab, or inspect `build/app/intermediates/merged_manifests/release/.../AndroidManifest.xml`, or run `aapt2 dump permissions app-release.apk`. Neither AD_ID permission should appear. Re-check after any dependency upgrade.
- `INTERNET` permission present ✓. AdMob app ID is present and its publisher (`ca-app-pub-4129659429509766`) matches the ad unit IDs in `ad_helper.dart` ✓ — it is a production ID (the old comment said "test"; corrected).
- No location / contacts / mic / camera permissions ✓. Cleartext traffic not enabled ✓.
- Play Console → *App content* → **Advertising ID** declaration: answer that the app does **not** use the advertising ID (it targets children and removes the permission).

**Unity Ads and Google's Families list**
- Google's *Families Self-Certified Ads SDK* list includes **Unity Ads (`com.unity3d.ads:unity-ads`, version 4.0.1 or later)**. Confirm the Unity Android SDK bundled by `unity_ads_plugin ^0.3.20` is ≥ 4.0.1 (`./gradlew :app:dependencies | grep unity-ads`) and re-check the list before each release, as certification is per-version: https://support.google.com/googleplay/android-developer/answer/9283445
- Still needed in the Unity dashboard: "targets children under 13" = yes for both projects (§4.1). The Flutter `unity_ads_plugin` only exposes `PrivacyConsentType` values (`gdpr`, `ccpa`, `pipl`, `ageGate`), none verified as a COPPA switch, so COPPA for Unity is set in the dashboard, not in code. I did not find Google Mobile Ads (AdMob) in the part of the list I retrieved — check the official page for its current status; AdMob is configured here with child-directed treatment, under-age-of-consent and max rating G (`app_initializer.dart`).

**pubspec.yaml (delivered updated)**
- `flutter_native_splash.color` `#6C5CE7` → `#150D2E` so the native splash matches the new dark mesh (no purple flash). **Run `dart run flutter_native_splash:create`** to regenerate.
- Dart SDK floor raised `>=3.0.0` → `>=3.8.0` because the code needs Flutter 3.32+ APIs. Revert if you build with an older Flutter (you shouldn't — it wouldn't compile).
- `version: 1.0.3+4` unchanged — **bump the build number before uploading** (e.g. `1.0.4+5`); Play rejects a reused versionCode.
- `advertising_id` is correctly removed. `integration_test` is declared but no tests were provided; harmless.

---

## 3H. Privacy policy review (18 Nov 2026)

The old `index.html` (dated 17 Apr 2026) was replaced with a rewritten page (delivered as `index.html`). Problems found in the old one:
- **Unity Ads not mentioned** — only AdMob, but the app uses both. Both must be disclosed.
- Said AdMob "may collect anonymized data such as device ID" — inaccurate (a device ID is not anonymous) and inconsistent with the app, which removes the advertising ID and runs child-directed, non-personalised ads.
- No mention of data stored on the device (progress, streak, sound settings) or how to clear it.
- Children's section was one sentence: no statement of no behavioural ads / no IAP / no social features, and no parent contact route.
- No developer/publisher name, no data-retention or rights section, no change-notification promise.
- Technical: no `lang`, charset or viewport meta (bad on phones), bare non-clickable URL, no `mailto:` link, stale date.

**Before publishing the new page**
1. Replace `[your name or business name]` in section 1.
2. The policy states ads are child-directed/non-personalised and the advertising ID is not requested. That is only true once the release items in §4.1 are done: Unity "directed to children" setting, AdMob child-directed setting, and the AD_ID removal (§3G) verified in the merged manifest.
3. Keep the **same URL** that is entered in App Store Connect when moving hosting (§6), or update it there.
4. Make the Play **Data safety** form and Apple **App Privacy** answers consistent with this page (ad SDKs can still process limited technical data such as IP address). This is not legal advice — have it checked if unsure.

---

## 3I. Duplicate class + deprecation clean-up (18 Nov 2026)

Not compiled/run — run `flutter analyze` to confirm it is clean.

- **`TracingScreenWithNav` was defined twice** (identical code in `home_screen.dart` and `tracing_screen.dart`). The `home_screen.dart` copy was the one actually used (it shadows the import), the other was dead. Kept the copy in `tracing_screen.dart` (next to `TracingScreen`), deleted the one in `home_screen.dart`; `home_screen.dart` already imports `tracing_screen.dart`.
- **`withOpacity` → `withValues(alpha: ...)`** — 11 places in `background_painter.dart`, `tracing_screen.dart`, `tracing_canvas.dart`. Same visual result, no precision loss.
- **Settings** (`settings_screen.dart`):
  - `SwitchListTile.activeColor` → `activeThumbColor` / `activeTrackColor` (+ inactive colours, same style as the Quiz switch).
  - `Radio<AudioFormat>(groupValue/onChanged)` is deprecated in newer Flutter (replaced by `RadioGroup`, which needs Flutter 3.35+). Replaced the two radios with `_buildFormatTile()`: a `ListTile` with a radio-style icon, `selected` state and `onTap`. It works on any Flutter version in the supported range and keeps the disabled look when sound is off.
- If `flutter analyze` still reports `deprecated_member_use` hits elsewhere, they come from packages/SDK upgrades and can be fixed the same way. The two `// ignore: deprecated_member_use` lines in `app_initializer.dart` are intentional (AdMob child-directed tags).

---

## 3J. Analyzer clean-up + code-vs-handoff check (18 Nov 2026)

### `flutter analyze` history
| Run | Result |
|---|---|
| 1 | `flutter_lints` not found (include in `analysis_options.yaml`) + unused import `../data/letters_data.dart` in `home_screen.dart` |
| 2 | Only the `flutter_lints` warning left (unused import removed) |
| 3 | `flutter_lints` added to `dev_dependencies`; 3 infos left (below) |
| 4 (after the fixes below) | **1 info left:** `test/tracing_test.dart:1` — `flutter_test` is not a declared dependency (`depend_on_referenced_packages`) |
| 5 | `flutter_test` added to `dev_dependencies` (`flutter pub get` reported it moved from a transitive to a dev dependency). **`No issues found!`** |

### Fixed in this pass (verified by run 4)
- `lib/screens/settings_screen.dart` (`use_build_context_synchronously`): in the Reset-progress dialog the `context` used after an `await` was the dialog's (already closed) context, so the `mounted` check did not cover it. The dialog builder parameter is now `dialogContext`, and the screen's `ScaffoldMessenger` is captured **before** the `await`. `_toggleSound()` and `_toggleAudioFormat()` also got `if (!mounted) return;` before `setState`.
- `lib/widgets/tracing_canvas.dart` (`curly_braces_in_flow_control_structures`): the `for` loop in `_drawUserStroke` now has a braced body.

### Result
- `flutter analyze` reports **No issues found** (18 Nov, run 5). The `flutter_test` dev dependency was added to `pubspec.yaml`:
  ```yaml
  dev_dependencies:
    flutter_test:
      sdk: flutter
  ```
- Analyzer-clean does **not** mean tested: the app has not been run in a release build, and the test in `test/tracing_test.dart` has not been reviewed or run by the authoring agent. Run `flutter test` once.

### Code checked against this handoff (the 18 Nov zip, read-through, not compiled)
Matches the handoff: interstitial real-result logic (§3A.1/§3A.2), adaptive banner in `SafeArea` with reserved space (§3F), child-directed config before any ad request (§3G), streak by calendar date (§3A.3), `TracingScreenWithNav` defined once (§3I), no rewarded-ad code left, no `print()` calls, banners on every screen.
Not as clean as the handoff says:
- The four legacy files (see the box under §2) were **still present** in the zip; delete by hand.
- `REPLACE_ANDROID_INTERSTITIAL` / `REPLACE_IOS_INTERSTITIAL` are still in `ad_helper.dart` (expected, §4.1).

### Earlier same-day work superseded by the above (do not re-apply)
Four partial fix zips (mute toggle, banners/rewarded removal, adaptive banner, child-directed config) were produced against the **older, pre-glass** code on 16 Nov. Their changes are already incorporated here; copying those zips over the current `lib/` would overwrite newer files.

---

## 3K. Developer Information Website + Firebase Hosting Preparation (19 Nov 2026)

### Website deliverable
- Created a responsive, child-friendly app-information website for **Learn Myanmar Alphabet**.
- Website source bundle: `learn_myanmar_alphabet_website_files.zip`.
- Bundle contents:
  - `public/index.html`
  - `public/assets/styles.css`
  - `public/assets/site.js`
  - `public/assets/app-icon.svg`
  - `README.txt`
- The homepage includes app information and feature descriptions, an App Store link, an Android “coming soon” state (because the Play Store listing is not yet confirmed — **but the app is iOS-only, §1, so remove this state unless an Android release is planned**), a parents section, and developer contact details.
- The website is intended for the existing Firebase Hosting domain: https://learn-myanmar-alphabet.web.app/
- The website bundle deliberately does **not** contain or replace the existing `privacy_policy.html` or `app-ads.txt`. Keep both existing files.

### New icon and logo added to the §3K website bundle (19 Nov 2026)
Delivered as `learn_myanmar_alphabet_website_new_icon.zip` (the §3K bundle with these changes; privacy policy and `app-ads.txt` still not included). Previewed over local HTTP only; **not deployed**.
- `public/assets/app-icon.svg` replaced with the new glass icon (self-contained paths, rounded corners; the old one drew the letter from a web font). The header and footer already use this file, so they pick it up; `.brand img` radius changed 14px → 10px in `styles.css`.
- New files: `public/favicon.ico` and `public/apple-touch-icon.png` (these two go in the public **root**), `assets/favicon-32.png`, `assets/icon-192.png`, `assets/app-icon.png` (512), `assets/og-image.png` (1200×630 share image, set in Inter, not the site's Nunito).
- `index.html` head: added favicon/apple-touch links, `og:image`/`og:url`/size and `twitter:card` tags; `theme-color` `#17132f` → `#150D2E`.
- **Still open:** the page's download section says "Android version coming soon" (`index.html` line ~131). The app is iOS-only, so it should be removed; offered to the developer, not yet done.
- Keep the website icon in step with the app icon (§3L) if the app icon changes again.

### Second website draft (19 Nov 2026, not delivered)
A separate draft built in this project's Claude session exists but was **never sent to the developer**; whether to use it is undecided. It is a lavender "practice-sheet" design with a hero that animates the letter ka being traced from the app's real `stroke_data.dart`, an alphabet strip of the 33 consonants, a screenshots gallery with placeholders, a parents section, a rewritten privacy policy (matches §3H) and an `app-ads.txt` with the AdMob line plus a Unity template line. The App Store link token is `APP_STORE_URL_HERE`. It only exists in the session workspace, so if wanted, ask for it to be sent again. The §3K bundle above remains the one the developer has.

### Local preview instructions
- Extract the ZIP on the Windows development PC.
- Preview `public/index.html` locally. A local HTTP server is preferred, for example:
  ```powershell
  cd C:\path\to\extracted\website\public
  python -m http.server 8000
  ```
  Then open `http://localhost:8000/` in a browser and stop the server with `Ctrl+C`.
- Confirm the homepage layout, Myanmar text rendering, mobile responsiveness, App Store link, email link, and privacy-policy link before deployment.

### Existing Firebase Hosting configuration checked
The developer supplied the contents of both existing Firebase configuration files. They are suitable for deploying to the existing project; no `firebase init` or new Firebase project is needed.

`firebase.json`:
```json
{
  "hosting": {
    "public": "public",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
```

`.firebaserc`:
```json
{
  "projects": {
    "default": "learn-myanmar-alphabet"
  }
}
```

- Existing Firebase project ID: `learn-myanmar-alphabet`.
- Existing Hosting URL: https://learn-myanmar-alphabet.web.app/
- Expected local project folder from the handoff: `C:\Users\dipah\Documents\myanmar_alphabet\`.
- The intended deployment command, run from that existing project folder, is:
  ```powershell
  firebase use
  firebase deploy --only hosting
  ```
- `firebase use` should show `learn-myanmar-alphabet` as the active project before deployment.
- If Firebase CLI is not installed: `npm install -g firebase-tools`; then authenticate with `firebase login`.
- Do not run `firebase init` for this existing Hosting project.

### Required file layout before deployment
Merge the new homepage and assets into the existing Firebase `public` folder. Do not delete or overwrite existing privacy or AdMob files.

```text
myanmar_alphabet/
├── firebase.json
├── .firebaserc
└── public/
    ├── index.html            # New app-information homepage
    ├── privacy_policy.html   # Preserve existing file
    ├── app-ads.txt           # Preserve existing file
    └── assets/
        ├── styles.css
        ├── site.js
        └── app-icon.svg
```

If `public/assets/` already exists, merge the new assets rather than deleting unrelated existing files.

### Deployment status and post-deploy checks
- **Status as of 19 Nov 2026: PREPARED, NOT YET CONFIRMED DEPLOYED.** The user has not reported running `firebase deploy --only hosting`.
- After deployment, verify all three URLs:
  - Homepage: https://learn-myanmar-alphabet.web.app/
  - Privacy policy: https://learn-myanmar-alphabet.web.app/privacy_policy.html
  - AdMob sellers file: https://learn-myanmar-alphabet.web.app/app-ads.txt
- Also verify that the new homepage links correctly to the existing privacy policy and that the `app-ads.txt` response contains the expected existing publisher declaration.
- After the Firebase site is live and verified, update the developer Website URL in both Google Play Console and App Store Connect to `https://learn-myanmar-alphabet.web.app/`.
- Do not claim the site or `app-ads.txt` has been verified by AdMob until the relevant dashboard/crawler confirms it.

### Checked on 18 Nov 2026 (live site, read-only)
- The **live `privacy_policy.html` is outdated** (dated 3 Aug 2026) and should **not** simply be preserved as §3K says: it does not mention Unity Ads, says the Advertising ID may be collected (the app removed it), refers to Google Play's Families Policy, and gives no developer or publisher name. Replace it with the rewritten policy (§3H) before relying on it, and keep the same URL (`/privacy_policy.html`).
- `app-ads.txt` could not be fetched by the reviewing agent, so its contents are unverified. It needs the AdMob line `google.com, pub-4129659429509766, DIRECT, f08c47fec0942fa0` and, because Unity Ads also serves ads, a Unity line copied from the Unity dashboard. Open `/app-ads.txt` in a browser to confirm it loads as plain text.
- For iOS, AdMob finds `app-ads.txt` through the developer website URL in the App Store listing (the Marketing URL is the usual place). Set it to `https://learn-myanmar-alphabet.web.app/`.
- The site's download section should show only the App Store with the real link (no Google Play button) and the page title should be the app's name.

---

## 3L. App icon and launch splash (19 Nov 2026)

### New icon designed to match the glass UI (19 Nov 2026) — delivered, not yet applied by the developer

- **Design:** the existing ka letter (vectorised from the old icon) as a glossy lilac-to-pink glass shape (`#F6F2FF` → `#CDBFFF` → `#FF8FC7`) over the app's mesh background (base `#150D2E`, blobs `#5C2FA8`, `#8B1A6B`, `#0D5C9A`, `#1B6E8F`), with a small gold/orange glass pencil whose tip touches the end of the letter's tail. The first version had a gold dot there; the developer asked for a pencil instead. The old icon's pencil line-art, purple flat background and the visible inner rectangle are gone. No dotted baseline (it collided with the pencil).
- **Files delivered** (`new_icon_set_pencil.zip`): `app_icon.png` (1024×1024, opaque RGB, no alpha, as iOS needs), `splash_logo.png` (transparent, letter + pencil only), `app_icon_foreground.png` (transparent, only for an Android adaptive icon, so unused while the app is iOS-only), `app_icon.svg` (editable source). Checked as a preview at 180/120/60/40 px with an iOS-style rounded mask; legible at 40 px. Not tested inside Flutter or on a device.
- **To apply:** copy `app_icon.png` and `splash_logo.png` into `assets/icon/`, then in `pubspec.yaml` set `flutter_native_splash.image: assets/icon/splash_logo.png` (keep `color: "#150D2E"`), keep `flutter_launcher_icons.image_path: "assets/icon/app_icon.png"`, run the commands in step 3 below, uninstall the old app, and rebuild. Also copy the icon to the website's `images/app_icon.png`.
- **Status:** the developer has not yet said the new icon is applied. The App Store icon only changes with a new submitted and approved version (so combine it with the version bump in §4.1).

### General instructions (how the settings work)

Where the settings live (as last seen in `pubspec.yaml`; open the file to confirm the current values):

```yaml
flutter_launcher_icons:        # home-screen / App Store icon
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon.png"

flutter_native_splash:         # launch screen shown before Flutter starts
  color: "#150D2E"             # was #6C5CE7 before the dark glass UI (§3G)
  image: assets/icon/app_icon.png
  android: true
  ios: true
```

To change the icon or splash:
1. Replace `assets/icon/app_icon.png` with the new artwork: square PNG, 1024 × 1024, no rounded corners (the OS applies the mask). iOS icons must have **no transparency**; add `remove_alpha_ios: true` under `flutter_launcher_icons` if the new file has any.
2. For a splash that looks right, use a separate logo PNG with a transparent background (not the full square icon) as `flutter_native_splash.image`, and set `color` to the background you want. Optional: `color_dark` / `image_dark` for dark mode.
3. Regenerate (from the project folder):
   ```
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   flutter clean
   flutter pub get
   ```
4. Check the generated files: iOS `ios/Runner/Assets.xcassets/AppIcon.appiconset/` and `LaunchImage.imageset/` (plus `Base.lproj/LaunchScreen.storyboard`); Android `android/app/src/main/res/mipmap-*/ic_launcher.png` and `drawable*/launch_background.xml`.
5. Uninstall the old app from the emulator or phone, then run again — launchers and the OS cache icons and splash screens, so an in-place update often keeps showing the old ones.
6. iOS builds need macOS/Xcode (or a CI/Mac build service). Commit the regenerated `ios/` files so that build picks them up. The App Store listing icon changes only after a new version with the new icon is uploaded and approved.
7. Keep the website icon in step: copy the same icon to the website's icon file (`images/app_icon.png` or `assets/app-icon.svg`, depending on which site bundle is used).

---

## 3M. Mac setup, iOS release prep and Unity hardening (20–21 Nov 2026)

**Dev machine:** the developer is now building on a **Mac** (MacBook Pro, user `rudipah`, project at `/Users/rudipah/Documents/myanmar_alphabet`), so iOS builds can be made locally. Windows was used earlier (§7). Not compiled/verified by the authoring agent.

**Setup problems solved**
- `flutter pub get` failed with "dubious ownership" for `/opt/homebrew/Caskroom/flutter/...`, and `brew upgrade` with "/opt/homebrew is not writable". Cause: Homebrew's folders were owned by another user. Fix: `sudo chown -R $(whoami) /opt/homebrew`.
- Flutter was **3.19.6 (Dart 3.3)**, too old for the project (needs Dart >=3.8). Fix: `brew upgrade --cask flutter` (offered 3.50.1), then `flutter pub get` and `flutter doctor -v`. If CocoaPods is flagged: `brew install cocoapods`. Not yet confirmed that the new Flutter builds the project cleanly.
- No iOS device was usable (iPad / iPhones "unpaired"). Use the iOS Simulator (`open -a Simulator`, `flutter run`), or pair a real iPhone (cable, Trust, Developer Mode on, Xcode > Window > Devices and Simulators).
- Release-mode build on the iPhone failed: **"PLA Update available… agree to the latest Program License Agreement"** and "provisioning profile doesn't include the selected device". Fix: the Account Holder accepts the new agreement at developer.apple.com/account; then in `ios/Runner.xcworkspace` > Signing & Capabilities keep "Automatically manage signing" with the team selected, build once in Xcode, or Xcode > Settings > Accounts > Download Manual Profiles. Bundle ID: `com.rudipah.learnmyanmaralphabet`. Status after this: not confirmed fixed.
- Release mode cannot run on the simulator. For device testing: `flutter run --release`.

**AdMob IDs (clarified)**
- App IDs contain `~` and go in native config, **not** in Dart: iOS `ca-app-pub-4129659429509766~7354280406` in `ios/Runner/Info.plist` as `GADApplicationIdentifier`; Android `ca-app-pub-4129659429509766~4839286959` in `AndroidManifest.xml` `com.google.android.gms.ads.APPLICATION_ID`. `Info.plist` has still not been seen by the authoring agent. The App ID must belong to the same AdMob iOS app that owns the iOS banner unit `…/7699563630`.
- Ad unit IDs contain `/` and go in `lib/utils/ad_helper.dart`. The two banner IDs there are correct. `ad_helper.dart` was reviewed on 21 Nov and is correct; **the iOS interstitial `REPLACE_IOS_INTERSTITIAL` (line ~39) is still a placeholder** until the developer creates the unit in AdMob (iOS app > Ad units > Interstitial) and pastes the real ID. New units can take hours to fill.
- Optional guard (not applied): in `AdHelper.loadInterstitialAd()` return false when `interstitialAdUnitId.contains('REPLACE_')`.

**Unity Ads — `lib/services/unity_ads_service.dart` rewritten (delivered as a full file, 21 Nov)**
- Config unchanged: iOS game ID `800111406`, placement `Interstitial_iOS` (must match the dashboard name exactly), `testMode: kDebugMode`.
- New: `_initDone` completer completed from `onComplete`/`onFailed`/catch in `initialize()`; `loadInterstitialAd()` waits up to 10 s for it before calling `UnityAds.load` (the plugin's `init` future likely returns before `onComplete`; not confirmed in plugin source). The load future now has a 20 s timeout that clears `_loadCompleter`, so one stuck load can't block later loads. Show logic unchanged.
- Not compiled; run `flutter analyze` after applying.
- Unity dashboard: iOS project must answer **yes** to "targets children under 13"; confirm placement name and Live status; copy Unity's `app-ads.txt` line into the website. COPPA for Unity is dashboard-only (the plugin's `ageGate` consent type was not verified as the COPPA switch).

**Apple Kids Category (checked 21 Nov 2026 against developer.apple.com guidelines; the page was truncated mid-5.1.4, so not read in full)**
- 1.3: Kids Category apps "should not include third-party analytics or third-party advertising"; narrow exceptions: contextual ads from services with publicly documented kids policies including human review of ad creatives; no links out of the app (ads open the App Store/web) unless behind a parental gate; no personal/device info sent to third parties.
- 5.1.4(a): "Apps intended primarily for kids should not include third-party analytics or third-party advertising" (worded by intent, not category; scope outside the Kids Category not confirmed). 2.5.18 prohibits targeted/behavioral ads based on data from kids.
- **Open:** the developer has not yet said whether the app is in the Kids Category (App Store Connect > App Information). The app has AdMob + Unity ads and no parental gate. Decide before the next release: remove third-party ads, or keep them only if the networks meet Apple's conditions and add a parental gate before anything that opens outside the app, or ask App Review via Resolution Center. Not legal advice.

**Unity COPPA dashboard setting (from Unity docs, not verified in the account):** Monetization dashboard > Monetization > Apps > the iOS app > Monetization tab > "Child-directed ad network settings" > "This app is directed to children"; "Is this a Mixed Audience app?" = No. Unity then serves contextual ads only. The `user.nonbehavioral` code option is only for mixed-audience apps (not needed).

**SKAdNetwork (Unity warning "add SKAdNetwork IDs", 21 Nov 2026)**
- Unity's dashboard (Project Settings > Missing SKAdNetwork IDs > Copy) gave 76 IDs, including Google's `cstr6suwn9.skadnetwork`. Delivered as `skadnetwork_block.xml` (a `SKAdNetworkItems` key + array) to paste into `ios/Runner/Info.plist` (one key only; merge into the array if it already exists; no duplicates). Not yet applied by the developer.
- Also compare against Google's AdMob iOS setup page for any missing AdMob IDs. SKAdNetwork is Apple's privacy-preserving attribution and does not use the advertising ID. Goes in with the next release build.

**`ios/Runner/Info.plist` reviewed and rewritten (21 Nov 2026, delivered as a full file; not yet applied or built by the developer)**
- `GADApplicationIdentifier` = `ca-app-pub-4129659429509766~7354280406` was already correct.
- `SKAdNetworkItems`: the developer's file **already contained all 76 IDs** from Unity's list (compared, same set, no duplicates, includes Google's `cstr6suwn9.skadnetwork`), so no IDs were added. The Unity "missing SKAdNetwork IDs" warning is probably about the build already on the store or a delay; it should clear after a release with these IDs. AdMob's own list should still be compared once against Google's AdMob iOS setup page.
- **Removed `NSUserTrackingUsageDescription`** ("…used to deliver personalized ads to you"): it contradicts the child-directed, non-personalised setup and the privacy policy, and the code never requests App Tracking Transparency (the handoff says never add the ATT prompt). In App Store Connect > App Privacy, "Tracking" should stay No.
- ~~Removed `NSMicrophoneUsageDescription`~~ **Wrong, reversed on 21 Nov 2026:** App Store Connect rejected the upload with **90683 "Missing purpose string… NSMicrophoneUsageDescription"** because a library bundled in the app (probably the audio stack) references microphone APIs, so the key is required even though the app's own code never records. Restored with an honest text ("This app does not record audio and never asks to use the microphone. This note is required because the app includes a standard audio library that refers to it."). The app still never prompts for the microphone, so the privacy policy statement (no microphone access) stays true. Needs a new build with a higher build number (e.g. `+6`), archive and upload again. Lesson: only remove permission strings after checking the *built* app, not just `lib/`.
- Left unchanged: everything else, including landscape being listed in `UISupportedInterfaceOrientations` (the app locks portrait in code, `main.dart`) and the Android App ID comment.
- Optional, not added: `ITSAppUsesNonExemptEncryption` = `false`, which skips the export-compliance question on each upload if the app uses only standard HTTPS encryption. It's a declaration to Apple, so the developer decides.

**Privacy policy file reviewed (21 Nov 2026) — `privacy_policy.html` corrected and delivered**
- The developer's own policy file (dated 18 Nov) matches how the app works. Corrections made: the Android-only advertising-ID bullet in section 2 replaced by "The app does not ask permission to track you and does not use the advertising ID to follow children across apps or websites"; "Last updated" set to 21 November 2026. Contact email stays `learnmyanmaralphabet@gmail.com`.
- **Contact email decision:** `learnmyanmaralphabet@gmail.com` is the correct address. Earlier drafts and the website bundle used `rudipah@gmail.com`; the website bundle (`learn_myanmar_alphabet_website_new_icon.zip`, `public/index.html` footer and `README.txt`) was re-delivered with the new address. My unsent second website draft (§3K) also used `rudipah@gmail.com` and would need the same change.
- Still true only after the dashboards are set: section 4's statement that the app is marked as directed to children in AdMob's and Unity's settings (Unity setting not yet confirmed done). The live site's `privacy_policy.html` is still the outdated one until this file is deployed at the same URL (`/privacy_policy.html`). Also keep the App Store Connect support contact consistent with this email.
- Left as is: developer name spelling ("Ru Di Pah" in the policy), the plain page style, and the parental-supervision note about ad links (not a substitute for a parental gate if the app is in the Kids Category).

**Building and uploading with Xcode (the developer uses Xcode for release builds; first upload done 21 Nov 2026)**
1. Raise the version in `pubspec.yaml`, then `flutter clean`, `flutter pub get`, `flutter build ios --release --no-codesign` (this writes the version/build into the iOS settings; `cd ios && pod install` if CocoaPods complains).
2. `open ios/Runner.xcworkspace` (the workspace, not the `.xcodeproj`). Runner target > General: check name, version, build. Signing & Capabilities: automatic signing, team, bundle ID `com.rudipah.learnmyanmaralphabet`.
3. Destination **Any iOS Device (arm64)** (Archive is greyed out with a simulator), then Product > Archive.
4. Organizer > Distribute App > App Store Connect > Distribute (Upload), defaults, Upload. Wait for the processing email (10–30 min), then add the version in App Store Connect, pick the build, fill in What's New/screenshots, check App Privacy, submit.
- If it fails: "build number already used" means raise the number after `+`; license errors mean accept the agreement at developer.apple.com/account.

**App Store Connect warnings after the first upload (21 Nov 2026)**
- "Built with iOS 26.4 SDK": from **April 2027** uploads need the iOS 27 SDK (Xcode 27 or later). Nothing to do now; update Xcode and rebuild for the next release after that.
- "Deployment target too low (iOS 13.0)": from **April 2027** apps must target **iOS 15.0 or later**. Not a blocker for the current upload. Fix prepared (not yet applied or built by the developer): in `ios/Podfile` set `platform :ios, '15.0'` (it was commented out as `'13.0'`) and add `config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'` for every pod target in `post_install` (keep `flutter_additional_ios_build_settings(target)`); in Xcode set **Minimum Deployments** to 15.0 on the Runner target (General) and the Runner project (Info); then `cd ios && pod install --repo-update`, `flutter clean`, `flutter pub get`, `flutter build ios --release --no-codesign`, a release test on the iPhone, archive again. This drops the few devices on iOS 13–14.
- `ios/Flutter/AppFrameworkInfo.plist` was checked: it has **no** `MinimumOSVersion` key (newer Flutter template), so nothing to change there (an earlier suggestion to edit it was wrong).
- "Upload Symbols Failed: objective_c.framework dSYM": ignorable. It only affects crash-report symbolication for that library; the app has no crash-reporting service and Apple still accepts the build.

**Firebase CLI on the Mac:** `zsh: command not found: firebase` fixed by `brew install firebase-cli` (or `brew install node` then `npm install -g firebase-tools`), then `firebase login`, `cd` to the folder with `firebase.json` and `public/`, `firebase use` (should say `learn-myanmar-alphabet`), `firebase deploy --only hosting`. Status of the website deploy: not confirmed.

**Upload error 90683 (21 Nov 2026):** missing `NSMicrophoneUsageDescription`; fixed by restoring the key (see the Info.plist note above). `NSUserTrackingUsageDescription` stays removed (no App Tracking Transparency use). Next: raise the build number in `pubspec.yaml`, `flutter clean`, `flutter pub get`, `flutter build ios --release --no-codesign`, archive and upload again, then pick the new build for the version in App Store Connect.

**App Store Connect submission questions (21 Nov 2026) — answers given to the developer**
- China mainland **Security Assessment** (end-to-end encrypted messaging / AIGC): **No** (no messaging, no AI features).
- China mainland **AI Generated or Synthetic Content**: **No** (all content is fixed and bundled).
- Age-rating questions about social feeds / user-generated content: **None / No** (no feed, posts, sharing or accounts).
- **"Social Media Disabled for Users Under 13"** (relies on the Declared Age Range API): leave **unchecked / not applicable**; the app has no social features and does not call that API, so ticking it would be untrue.
- If other China compliance questions (e.g. a filing number) appear, check Pricing and Availability to see whether China mainland is selected; not yet checked.
- Encryption/export-compliance question: answer honestly for the app (standard HTTPS only usually counts as exempt); `ITSAppUsesNonExemptEncryption` is not set in `Info.plist` (optional, developer's decision).
- Answers must stay consistent with the age rating, App Privacy and the privacy policy. Still open before submitting: whether **Made for Kids** is on (App Information > Edit > Age Categories and Override), the Unity "directed to children" setting, and deploying the corrected privacy policy.

**Release status (as of 21 Nov 2026):** build uploaded and processed once; a later upload failed validation with 90683 (microphone purpose string) and needs a new build with the restored key and a higher build number (see above). Warnings left are ignorable (iOS 27 SDK from April 2027; `objective_c.framework` dSYM); the iOS 15 deployment target change cleared its warning. Not yet submitted for review.

**Screenshots without banners (optional, not applied)**
Compile-time flag in `lib/widgets/banner_ad_widget.dart`: add `const bool _hideAds = bool.fromEnvironment('HIDE_ADS');` above the class, and add `|| _hideAds` to the early return in `didChangeDependencies` and to the `_failed || kIsWeb` check in `build`. Run with `flutter run --dart-define=HIDE_ADS=true`. Normal and release builds are unaffected.

**Release to the App Store (update of the live app)**
1. Code: real iOS interstitial ID; bump `pubspec.yaml` version (e.g. `1.0.4+5`, the build number above the live one); regenerate icon/splash if using the new icon (§3L); `flutter analyze`, `flutter test`; release test on an iPhone.
2. Signing: accept the Apple agreement; team selected in Xcode.
3. `flutter clean`, `flutter pub get`, `flutter build ipa --release` (output in `build/ios/ipa/`; `cd ios && pod install` if CocoaPods complains).
4. Upload with Transporter (drag the `.ipa`) or Xcode Organizer from `build/ios/archive/Runner.xcarchive` (Distribute App).
5. App Store Connect: add the new version, "What's New", screenshots, select the processed build, Marketing URL `https://learn-myanmar-alphabet.web.app/`, privacy policy URL `https://learn-myanmar-alphabet.web.app/privacy_policy.html` (the live policy is outdated, replace it first, §3H/§3K), review App Privacy and the Kids Category rules (§4.1), export-compliance question.
6. Submit for review; after approval install the live build and check banners, an interstitial and the icon; check `app-ads.txt` loads.

## 3N. Website: phone mock-up of the app's main screen (19–21 Nov 2026)

The developer approved a preview, then received `learn_myanmar_alphabet_website_phone_ui.zip`: only `public/index.html` and `public/assets/styles.css` differ from the website bundle of §3K.
- The hero's generic phone ("Hello, learner!") is replaced by a phone showing the app's main menu (`menu_screen.dart`, §3B/§3C): glass app icon with က, "Letter of the Day" pill (static ခ), title, "Tap start to begin learning", purple **Start Learning**, 2×2 grid (Flashcards, Quiz Time, Matching, Progress) and Settings (no streak badge / mute button, no banner). Built in HTML/CSS at the app's real 390 px width and scaled with `transform: scale(.6974)` into a 276×560 phone; mesh colours `#150D2E` base + `#5C2FA8`, `#8B1A6B`, `#0D5C9A`, `#1B6E8F`; slow drift animation off under `prefers-reduced-motion`. New CSS block is appended at the end of `styles.css`; `.hero-art` height 560 (600 under 850 px); `styles.css?v=2` cache-buster in `index.html`.
- **Status:** the `public.zip` the developer sent on 21 Nov does **not** contain this change (`phone-app` not found in `index.html` / `styles.css`, `styles.css` dated 19 Nov). Either it was not applied or the bundle predates it — check before deploying. Safari/real-phone testing was not done.
- Maintenance: it is a hand-built replica, not the live app; update it if the main menu changes.

## 3O. Documentation Word file rewritten — edition 2.0 (21 Nov 2026)

`learn_myanmar_alphabet_docs_v1_1.docx` (written for app v1.0.0: tracing only, MP3 audio, one banner, Android + iOS, placeholder bundle ID) was reviewed against the current app and rebuilt as **`learn_myanmar_alphabet_docs_v2_0.docx`** (22 pages, same look: purple headings, tables, dark diagram boxes; generated with docx-js, so edit via the generator or in Word).
- Updated: platform (iOS live; Android not released), 8 screens and their behaviour (Menu, Letters, Tracing with stroke validation, Flashcards, Quiz, Matching, Progress, Settings), OGG short/long audio, AdMob + Unity ads and the rules in `AdManager`, liquid-glass UI, services/widgets file tree, navigation and data-flow diagrams, store identity/description/keywords, privacy and ads disclosure table, content inventory, progress-star rules (1–3 = 1 star, 4–7 = 2, 8+ = 3), user guide, troubleshooting, an iOS-first release checklist (bundle ID `com.rudipah.learnmyanmaralphabet`, support email `learnmyanmaralphabet@gmail.com`, iOS 15.0 target, error 90683 / microphone string, SKAdNetwork, Kids Category), Google Play items kept separate "only if Android", future enhancements from §4.3, and **Appendix A "Items to Confirm"** (audio file count, app size, Kids Category status, Unity/AdMob dashboard settings, Flutter version on the Mac, live privacy page / app-ads.txt).
- Not verified (so listed in Appendix A rather than stated): installed app size, number of audio files, iOS subtitle currently in App Store Connect.
- Keep it in sync: any change to behaviour, ads or release steps should be reflected in sections 1.4, 4.1, 4.4 and 6.

## 3P. App Store header and search-result art (21 Nov 2026)

App Store Connect asked for a **header** image (5244×2950 or 3840×1646 px) and a **search-results** image (5244×2950, 3840×2560 or 1920×1280 px). Four PNGs were produced, in the website's theme (background `#fbfaff` with lavender/peach glows, Nunito 900 headline with the `#7965e9 → #e17caa` gradient word, DM Sans text, pastel letter chips, white pills, the new app icon, and a phone showing the app's main menu as in §3N):

| File | Size | Use |
|---|---|---|
| `appstore_header_5244x2950.png` | 5244×2950 | Header, and also valid for Search results |
| `appstore_header_3840x1646.png` | 3840×1646 | Header (wide banner crop, no feature pills) |
| `appstore_search_3840x2560.png` | 3840×2560 | Search results |
| `appstore_search_1920x1280.png` | 1920×1280 | Search results (same design at half size) |

- Text on the art: "A little learning goes a long way", **"Big adventures start with one letter."**, "Trace, listen, play and build confidence — one character at a time.", tags "33 consonants / Numbers 0–10 / Flashcards · Quiz · Matching". No App Store badge and no price/ads text, which keeps it within Apple's marketing-asset rules (not checked line by line against Apple's current guidelines).
- Files are RGB PNG (no alpha), sizes verified exactly; 0.8–3.9 MB each. The app icon used is `assets/app-icon.png` from the 21 Nov `public.zip` (new icon, §3L).
- Rendered from an HTML template with headless Chromium (stage drawn at 1920 px wide and scaled to the target size); the design reuses the §3N phone markup. To change wording or the phone, edit the template and re-render, or ask an agent to regenerate.
- Open: the art shows the main menu, so it assumes the current glass UI ships in the version being submitted. Apple may crop the search-result image to different aspect ratios in places; the key content sits in the central area.

---

## 3Q. App Store text for the next version + UML review (21 Nov 2026)

Text only — **no app code, `pubspec.yaml` or website files changed.** All wording below is a draft for the developer to paste into App Store Connect.

### What's New in This Version (final, as edited by the developer)
```
• New liquid glass UI design
• Added banner ads
• New app icon
• Improved performance
• Smoother, more reliable experience and many small fixes
```
- The developer supplied these points; "improve the performance" and "smoother, more reliable performance" were merged into two lines. A longer first draft (Flashcards, Quiz, Matching, Progress, Letter of the Day, Settings) was dropped by the developer.
- Assumption to check: the live version already has the activities (the developer's current description lists Quiz, Matching, Progress and short/long audio). Banner ads are mentioned, but the app also shows **interstitial** ads (§5).

### App Store description (updated from the developer's current text)
Changes only: the interface paragraph now says "a fresh liquid glass design with a colourful animated background"; added features "Letter of the Day", "New liquid glass design with a new app icon", "Smoother, faster and more reliable performance"; added a last line "The app is free and contains banner and interstitial ads." (ad disclosure; delete "and interstitial" only if the developer prefers). Everything else is the developer's existing wording.
- **Check before submitting:** "guided stroke order" is the developer's wording; the code has a stroke guide that follows each letter's shape and validates coverage (§3F), not necessarily an animated stroke *order*. "Guided letter tracing" is the safer claim.
- Not claimed on purpose: "child-friendly/non-personalised ads" — true only after the AdMob and Unity child-directed dashboard settings are done and the Kids Category question (§3M, §4.1) is settled.

### Promotional text (170 characters max; can be changed without a new version)
Current: *Learn Myanmar alphabet with fun tracing, clear audio, and interactive practice for kids.* Three drafts were offered (the developer has not chosen yet):
1. (160 chars, recommended, closest to the current text) `Learn the Myanmar alphabet with fun tracing, clear audio, quizzes and matching games for kids. Now with a fresh liquid glass design and a new Letter of the Day.`
2. (141 chars) `Trace, listen, play and learn Myanmar letters! Flashcards, quizzes, matching games and a Letter of the Day, now in a new liquid glass design.`
3. (124 chars) `Fun Myanmar alphabet tracing, clear audio, quizzes and matching games for kids. Now with a new liquid glass design and icon!`

### Documentation files
An interim `learn_myanmar_alphabet_docs_v1_2.docx` (rebuilt from the handoff before §3O) was delivered earlier the same day. It is **superseded by `learn_myanmar_alphabet_docs_v2_0.docx` (§3O)**: v1.2 still lists contact `rudipah@gmail.com`, uses a placeholder for the iOS bundle ID and says "iOS minimum: confirm", so do not use it.

### UML class diagram
- A class diagram of the current structure was drawn in chat (Mermaid; **not saved as a file**): menu and activity screens, `SoundService`, `PreferencesService`, `TracingValidator`, `AdManager`, `UnityAdsService`, `AdHelper`, `AppInitializer`, `DataLoader`, `MyanmarLetter`, `Flashcard`, `BannerAdWidget`, `TracingCanvas`.
- The developer's `UML_Diagram.png` (a tracing-only slice from the v1.0.0 design) is **out of date — do not reuse as-is**: `HomeScreen` opens `TracingScreenWithNav` (wrapping `TracingScreen`), not `TracingScreen` directly; `SoundService` now has `playLetter(file, {waitForCompletion})`, `playLetterAndWord()`, `stop()` and is mute-aware; `TracingScreen._onDone` validates with `TracingValidator` and calls `PreferencesService.recordStudyActivity()`; `BannerAd` should be `BannerAdWidget`; Dart `_`-prefixed members are private (`-`), `TracingCanvas` is composition, "uses"/"navigates" are dependencies (dashed); `MenuScreen`, Flashcards, Quiz, Matching, Progress, Settings, `PreferencesService`, `AdManager`, `UnityAdsService`, `DataLoader`, `Flashcard` are missing.
- **Open:** an updated PlantUML version was offered (full diagram or tracing slice + overview); not chosen yet. Check private field names and the `colorValue` type against the code first.

---

## 4. What Still Needs Doing

### 4.1 ⚠️ Before the next iOS release — manual actions only the developer can do

The app is **iOS-only and already live**, so the Android-only items (Play Console forms, `AD_ID` manifest check, Google Families SDK list, Android interstitial ID) are **not needed** unless an Android release is ever planned. They are kept in §3G for reference.

| Task | Where | Detail |
|---|---|---|
| Check Kids Category / kids-app rules | App Store Connect + Apple's App Review Guidelines (1.3 Kids Category, 5.1.4 apps intended for kids) | Confirm whether the app is in the Kids Category. The only source retrieved was a 2019 Apple forum thread quoting the older, stricter rule ("may not include third-party advertising or analytics"); the current text may allow narrow exceptions. Read the current guidelines on developer.apple.com or ask App Review before the next submission. Not legal advice. |
| Real iOS AdMob interstitial ID | `lib/utils/ad_helper.dart` | Replace `REPLACE_IOS_INTERSTITIAL` (admob.google.com → Apps → myanmar_alphabet (iOS) → Ad units → Create interstitial). Until then release builds retry and fail the AdMob interstitial load and only Unity shows. The Android placeholder can stay. |
| Unity: children under 13 | Unity dashboard, iOS project (game ID `800111406`) | Answer **yes** to "targets children under 13". |
| AdMob: child-directed | AdMob app settings, iOS app | Set the app to child-directed. |
| App Privacy answers ("nutrition label") | App Store Connect | Must match what AdMob and Unity process (ad SDKs can still handle limited technical data such as IP address) and must match the privacy policy page. |
| Privacy policy URL | App Store Connect | Use the rewritten page (§3H); fill in `[your name or business name]` first. Keep the same URL if hosting moves. |
| `Info.plist` | `ios/Runner/Info.plist` | Needs the AdMob app ID (`GADApplicationIdentifier`). Not reviewed yet (file not seen). Do **not** add an App Tracking Transparency prompt — the app must not track children. |
| Version bump | `pubspec.yaml` | `1.0.3+4` → e.g. `1.0.4+5`; the build number must be higher than the one already live. |
| Upload header and search-result art | App Store Connect | Use the files from §3P (header 5244×2950 or 3840×1646; search results 5244×2950, 3840×2560 or 1920×1280). |
| Release smoke test | Real iPhone | Run a release build and play through every screen; confirm banners and an interstitial appear. Also run `flutter test` once. |
| app-ads.txt | Firebase Hosting | Migrate site from GitHub Pages subfolder (see §6) so AdMob can verify the app. |

### 4.2 Code cleanup
- Done once (§3A.4), but the four legacy files keep returning in zips — delete by hand (box under §2).

### 4.3 Feature Backlog

| Feature | Priority | Notes |
|---|---|---|
| Local notifications (daily reminder) | High | Add `flutter_local_notifications`. Schedule a daily 7PM reminder "🌟 Time to learn your Myanmar letters!". Improves DAU → more ad impressions. |
| Tracing screen stroke animation | Medium | Auto-play the stroke path as an animation before the child traces. Already have stroke data in `stroke_data.dart`. |
| Parent mode / PIN lock | Medium | PIN gate around Settings and Progress Reset to prevent children from accidentally clearing data. |
| Onboarding screen | Medium | First-launch walkthrough showing the 4 game modes. |
| Difficulty levels | Low | Easy (numbers only) / Normal (all) / Hard (quiz with timer). |

---

## 5. Ad Monetisation — Current Setup

### Ad Networks
| Network | Type | Status |
|---|---|---|
| AdMob (Google) | Banner + Interstitial | ✅ Integrated. Banner IDs correct. Interstitial IDs need replacing (see §4.1). |
| Unity Ads | Interstitial only | ✅ Integrated. Game IDs: Android `800111456`, iOS `800111406`. |

### Ad Flow
- **Banner:** Shown at the bottom of every screen (including Flashcards since §3E) via `BannerAdWidget` (adaptive anchored size).
- **Interstitial:** Shown when leaving Flashcards (back button), after Quiz completion, and after Matching Game completion. `AdManager` rotates between AdMob and Unity with a 2-minute cooldown that starts only after an ad actually shows; falls back to the other provider if the first has nothing ready.
- **Rewarded:** none (feature not present).

### Child-Directed Compliance
- All ad requests use `nonPersonalizedAds: true` in `AdRequest`.
- `RequestConfiguration` sets child-directed treatment, under-age-of-consent and max content rating G before any ad request (`app_initializer.dart`). Those two tag fields are deprecated in newer `google_mobile_ads` (replaced by `ageRestrictedTreatment`) but work in `^5.1.0`.
- Unity `testMode` follows `kDebugMode` (no personal data in debug).
- `AdvertisingId` package has been removed (COPPA).
- AdMob child-directed setting must also be confirmed ON in the AdMob dashboard under app settings.

### AdMob Publisher ID
`ca-app-pub-4129659429509766`

---

## 6. Technical Learnings (Hard-Won — Read Before Revisiting These Areas)

### Myanmar Font Stroke Paths
- Stroke guide paths in `lib/data/stroke_data.dart` were derived by extracting centerline data from the Pyidaungsu font using Python's `fonttools` library.
- Coordinates are normalised `Offset(x, y)` values in the 0.0–1.0 range with 0.1 padding.
- The Y-axis is **flipped** (font coordinate system is bottom-up; Flutter canvas is top-down).

### GitHub Pages + app-ads.txt Incompatibility
- GitHub Pages serves the developer site from `/myanmar_alphabet/` (a subfolder), not from the root domain.
- AdMob's crawler looks for `app-ads.txt` at the root of the domain and cannot find it at the subfolder path.
- **Fix:** Migrate to Firebase Hosting, which serves from the true root. The `public/` folder should contain `index.html`, `privacy_policy.html`, and `app-ads.txt`.
- After deployment, update the Website / Support / Privacy Policy URLs in App Store Connect to the new Firebase URL.

### Web Platform Guard
- `google_mobile_ads` does not support Flutter Web. Ad code is guarded with `if (kIsWeb) return;`. (`ads_stub.dart` was removed because nothing used it — web is not a supported target.)

### Audio — Long vs Short Format
- Each letter has two audio files: `ka.ogg` (short) and `ka_long.ogg` (long/expanded pronunciation).
- The user selects their preference in Settings. `SoundService` automatically appends `_long` when the long format is active, with fallback to the short file if not found.
- `_word` audio files (e.g. from `descriptionAudio`) are never modified with the `_long` suffix.

### Data Loading
- Letters, numbers, and flashcards are loaded from JSON files in `assets/data/` via `DataLoader`.
- `DataLoader.init()` is called once at app startup in `main.dart`.
- Screens fall back to hardcoded lists if JSON loading fails.

### Build environment: Gradle fails on JDK 25 (Windows)
- Symptom: `flutter run` fails with `FAILURE: Build failed ... What went wrong: 25.0.4` (the Java version number as the message, no other detail).
- Cause: the project uses Gradle 8.14, which does not support Java 25. `flutter doctor -v` showed no Java line, so Flutter had no JDK of its own and Gradle used the Java 25 on `PATH`.
- Fix: use a JDK 17 or 21 — Android Studio's bundled `jbr` folder, or install Temurin 21 (`winget install EclipseAdoptium.Temurin.21.JDK`) — then `flutter config --jdk-dir "<jdk folder>"`. If `JAVA_HOME` points at Java 25, change or remove it. Then `cd android; ./gradlew --stop; cd ..; flutter clean; flutter run`.
- Also needed: install **Android SDK Command-line Tools (latest)** in Android Studio → SDK Manager → SDK Tools, then `flutter doctor --android-licenses`. Without them that command says `Android sdkmanager not found`.
- The Visual Studio warnings in `flutter doctor` only affect Windows desktop builds; ignore them.

### Reading banner-ad problems
- `BannerAdWidget` hides itself when the ad fails, so a failure looks like "no banner". Run `flutter run` and look in the console for `Banner ad loaded (WxH)` or `Banner ad failed to load: <error>`.
- Error codes: 0 / "app ID missing" → AdMob app ID missing from `AndroidManifest.xml` / `Info.plist`; 1 → invalid request (wrong ad unit ID for the platform); 2 → network error (emulator offline or no `INTERNET` permission); 3 → no fill (common with new production ad units).
- In debug builds the Google test banner ID is used and nearly always fills, so a failure in debug points at the app ID or the network. The banner has been confirmed visible on an Android emulator.

---

## 7. Environment & Tooling

| Tool | Detail |
|---|---|
| OS | macOS (MacBook Pro, from 20 Nov 2026, §3M); earlier work was on Windows |
| IDE | Android Studio + VS Code; Xcode for iOS archive/upload (Mac) |
| Flutter | 3.41.6 stable (Dart 3.11.4); `pubspec.yaml` SDK constraint `>=3.8.0 <4.0.0` (raised in §3G) |
| Java for Gradle | JDK 17 or 21 only (see §6) |
| Test device | Android emulator (`sdk gphone64 x86 64`, Android 17 / API 37) |
| Version control | Git / GitHub (`rudipah/myanmar_alphabet`) |
| Distribution | Apple App Store (live). No Google Play release planned. |
| Ad dashboard | admob.google.com (publisher ID: `ca-app-pub-4129659429509766`) |
| Unity Ads dashboard | dashboard.unity3d.com (Android game ID: `800111456`, iOS: `800111406`) |

---

## 8. How to Run

```bash
# 1. Install dependencies (run after any pubspec.yaml change)
flutter pub get

# 2. Run on a connected device or emulator
flutter run

# 3. Build release APK (Android)
flutter build apk --release

# 4. Build release IPA (iOS — requires macOS + Xcode)
flutter build ipa --release
```

> **Note:** In debug mode, all ads show Google/Unity test creatives automatically (no revenue, no policy risk). In release mode, real ads are served.

---

*Last updated: 21 November 2026 — includes §3A–§3J (app implementation and review history), §3K (developer information website, Firebase Hosting preparation and new icon/logo; deployment still pending), §3L (app icon and splash), §3M (Mac setup, iOS release preparation, AdMob ID clarification and Unity service hardening), §3N (website phone mock-up), §3O (documentation v2.0) §3P (App Store header and search-result art) and §3Q (App Store What's New, description and promotional text drafts; UML review). iOS-only release checklist in §4.1.*
