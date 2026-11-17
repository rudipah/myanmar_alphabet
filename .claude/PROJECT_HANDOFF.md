# Myanmar Alphabet — Project Handoff & Update Log

> **Status:** Reflects the code in `lib.zip` as of 16 Nov 2026 (after §3A ad/streak/cleanup, §3B liquid glass UI, §3C menu simplification). Where this file and the code disagree, the code wins.
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
| **Target platforms** | iOS (live on App Store) · Android (Play Store submission in progress) |
| **Audience** | Children age 4+, learning Myanmar consonants (33) and numbers (0–10) |
| **Developer** | Ru di pah — `rudipah@gmail.com` / GitHub: `rudipah` |
| **Project path (Windows)** | `C:\Users\dipah\Documents\myanmar_alphabet\` |
| **Developer website** | https://rudipah.github.io/myanmar_alphabet/ |

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
Dev: `flutter_launcher_icons`, `flutter_native_splash`

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
│   ├── app_initializer.dart         Single init point: AdMob + Unity Ads + SoundService
│   ├── ad_manager.dart              Singleton — rotates AdMob/Unity, 2-min cooldown (starts only after a REAL show)
│   ├── unity_ads_service.dart       Unity Ads wrapper (init, interstitial only)
│   ├── sound_service.dart           just_audio wrapper with caching and long/short audio support
│   ├── preferences_service.dart     SharedPreferences: audio format, sound toggle, progress, streak
│   └── tracing_validator.dart       Validates finger-tracing accuracy against stroke paths
├── utils/
│   ├── ad_helper.dart               AdMob banner + interstitial ad unit IDs and load/show logic
│   ├── app_colors.dart              Brand colour constants (primary: #6C5CE7) + glass palette (§3B)
│   └── navigator_util.dart          Thin Navigator.push wrapper
└── widgets/
    ├── menu_button.dart             Glass menu button (isPrimary = purple-tinted glass)
    ├── glass_container.dart         ★ NEW — core glass surface (blur + fill + border + specular)
    ├── glass_button.dart            ★ NEW — tinted glass button (disabled state = onPressed null)
    ├── glass_progress_bar.dart      ★ NEW — frosted track, lilac→pink animated fill
    ├── mesh_background.dart         ★ NEW — animated mesh background + GlassScaffold wrapper
    ├── tracing_board.dart           Tracing UI scaffold widget
    ├── tracing_canvas.dart          CustomPainter canvas for finger tracing
    ├── banner_ad_widget.dart        ★ NEW — self-contained AdMob banner (load/state/dispose)
    └── nav_icon_button.dart         Shared back/nav icon button (now a glass pill)
```

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
- **Status:** ⚠️ **STILL NEEDS MANUAL ACTION** — placeholders replaced with `REPLACE_ANDROID_INTERSTITIAL` / `REPLACE_IOS_INTERSTITIAL` as clear TODOs. Developer must log in to AdMob dashboard, create real Interstitial ad units, and paste the real IDs.
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
- Screens updated to use it: `menu_screen`, `home_screen`, `flashcard_screen`, `quiz_screen`, `progress_screen`, `settings_screen`.

#### `lib/widgets/nav_icon_button.dart` (NEW)
- Shared white-card icon button used for back navigation.
- Replaces the identical `_buildNavButton()` private method that was duplicated in `quiz_screen`, `flashcard_screen`, `progress_screen`, and `matching_game_screen`.

---

### 3.3 UI / UX Improvements

#### Letter of the Day — fixed weak daily index formula
- **File:** `lib/screens/menu_screen.dart`
- **Problem:** `(now.month + now.day) % flashcards.length` caused collisions — e.g. April 10 and March 11 both gave index 14.
- **Fix:** Uses day-of-year: `now.difference(DateTime(now.year, 1, 1)).inDays + 1`, giving a unique letter for every calendar day without any extra package dependency.

#### Daily streak counter added
- **Files:** `lib/services/preferences_service.dart`, `lib/screens/menu_screen.dart`
- (Historical) a 🔥 streak badge was shown top-left on the menu; removed in §3C.
- Superseded by §3A.3: `PreferencesService.recordStudyActivity()` now updates the streak (see below).
- Streak is also reset when "Reset All Progress" is triggered in Settings.

#### Mute toggle added to menu screen
- **Files:** `lib/screens/menu_screen.dart`, `lib/services/preferences_service.dart`
- A 🔊/🔇 icon button in the top-right of the menu screen.
- Persisted via `PreferencesService.setSoundEnabled()` / `isSoundEnabled()`.
- The Letter of the Day tap also respects this toggle.

#### Flashcard screen — progress bar + swipe hint
- **File:** `lib/screens/flashcard_screen.dart`
- Added `X / 33` counter and `LinearProgressIndicator` below the header.
- Added a "Tap to flip • Swipe to navigate" hint text below the card.

#### Quiz screen — haptic feedback
- **File:** `lib/screens/quiz_screen.dart`
- Correct answer: `HapticFeedback.mediumImpact()`
- Wrong answer: `HapticFeedback.heavyImpact()`

#### Quiz screen — rewarded ad hint button — NOT PRESENT
- Earlier versions of this document described a "Get a Hint • Watch an Ad" button. **It is not in the current code** (no `showRewardedAd`, no `_hintActive`). Unity is used for interstitials only. If a hint feature is wanted it must be re-implemented — and a rewarded ad in a Families app needs a Families-certified network and a parent-friendly flow.

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

### 3A.4b Menu screen background under the banner ad
- **File:** `lib/screens/menu_screen.dart`
- Problem: the purple gradient was only on the `body`, while `BannerAdWidget` sits in `bottomNavigationBar` (a separate Scaffold slot). That slot, including the banner's 8px top gap and the bottom safe area, showed the default white Scaffold background.
- Fix: the gradient `Container` now wraps the whole `Scaffold`, and the Scaffold uses `backgroundColor: Colors.transparent`, so the gradient also shows behind the banner area.
- Superseded by §3B: every screen now uses `GlassScaffold`, so the background always sits behind the banner slot.
- Any white *inside* the ad itself is the ad creative's own background and cannot be changed from the app.

### 3A.5 Corrections to earlier sections of this document
- Quiz hint / rewarded ad: **does not exist** in the code (see §3.3).
- Banners are on every screen **except `FlashcardScreen`** (it has no `BannerAdWidget`). Add one if wanted.
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
- Never put a `BackdropFilter` on every item of a long list/grid (`blur: 0`).

---

## 3C. Menu simplification (17 Nov 2026)

- **File:** `lib/screens/menu_screen.dart`
- Removed the top row: the 🔥 "N day(s)" streak badge and the mute/unmute button.
- Removed the code that only served them: the `_streak` field, the streak load, the `_toggleSound()` method, and the streak refresh after returning from a sub-screen. `_open()` is now a plain `Navigator.push`.
- **Unchanged:** the streak is still recorded by `PreferencesService.recordStudyActivity()` (tracing, quiz, matching) and cleared by "Reset All Progress", so it can be shown again later. Letter of the Day still respects the sound setting (`isSoundEnabled()`).
- Sound can now only be turned off in **Settings → Sound Effects**. Consider whether a parent-facing quick mute is still wanted.

---

## 4. What Still Needs Doing

### 4.1 ⚠️ Release blockers — manual actions only the developer can do

| Task | Where | Detail |
|---|---|---|
| Real AdMob interstitial IDs | `lib/utils/ad_helper.dart` | Replace `REPLACE_ANDROID_INTERSTITIAL` / `REPLACE_IOS_INTERSTITIAL` (admob.google.com → Apps → myanmar_alphabet → Ad units → Create interstitial, once per platform). Release builds will not serve AdMob interstitials until done. |
| Unity: children under 13 | Unity dashboard, both projects (Android `800111456`, iOS `800111406`) | Answer **yes** to "targets children under 13". |
| AdMob: child-directed | AdMob app settings | Set the app to child-directed. |
| Unity Families check | Google Play Families policy | Confirm Unity Ads is on Google's Families-certified ad SDK list; if not, drop Unity for the Android build. |
| `AndroidManifest.xml` review | `android/app/src/main/AndroidManifest.xml` | Not in `lib.zip`. Needs: `AD_ID` permission removed (kids' app), INTERNET permission present, correct AdMob app ID meta-data. |
| Play Console forms | Play Console | Data safety form + Families declarations. Privacy policy must say ads are shown and are non-personalised. |
| app-ads.txt | Firebase Hosting | Migrate site from GitHub Pages subfolder (see §6). |
| Finish Google Play submission | Play Console | iOS is live; Android in progress. |

### 4.2 Code cleanup — DONE (see §3A.4)

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
- **Banner:** Shown at the bottom of every screen except Flashcards via `BannerAdWidget` (adaptive anchored size).
- **Interstitial:** Shown when leaving Flashcards (back button), after Quiz completion, and after Matching Game completion. `AdManager` rotates between AdMob and Unity with a 2-minute cooldown that starts only after an ad actually shows; falls back to the other provider if the first has nothing ready.
- **Rewarded:** none (feature not present).

### Child-Directed Compliance
- All ad requests use `nonPersonalizedAds: true` in `AdRequest`.
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
- After deployment, update the Website field in both Play Console and App Store Connect to the new Firebase URL.

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

---

## 7. Environment & Tooling

| Tool | Detail |
|---|---|
| OS | Windows (developer machine) |
| IDE | Android Studio + VS Code |
| Flutter | SDK `>=3.0.0 <4.0.0` |
| Version control | Git / GitHub (`rudipah/myanmar_alphabet`) |
| Distribution | Apple App Store (live) · Google Play Store (pending) |
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

*Last updated: 17 November 2026 — includes §3A (ad reliability, streak, cleanup), §3B (liquid glass UI) and §3C (menu simplification).*
