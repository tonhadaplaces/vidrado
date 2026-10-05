# Vidrado

**A quieter desktop. A clearer mind.**

Vidrado is a native macOS menu bar app that blurs and dims background windows while keeping your active window clear. It works entirely on your Mac, with no account, subscription, tracking, or screen recordings.

[Download](https://github.com/tonhadaplaces/vidrado/releases) · [Report a bug](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [Contribute](AGENTS.md)

**Languages:** English · [中文](docs/i18n/zh/README.md) · [हिन्दी](docs/i18n/hi/README.md) · [Español](docs/i18n/es/README.md) · [العربية](docs/i18n/ar/README.md) · [Français](docs/i18n/fr/README.md) · [বাংলা](docs/i18n/bn/README.md) · [Português](docs/i18n/pt/README.md) · [Bahasa Indonesia](docs/i18n/id/README.md) · [اردو](docs/i18n/ur/README.md) · [日本語](docs/i18n/ja/README.md) · [한국어](docs/i18n/ko/README.md) · [Русский](docs/i18n/ru/README.md)

## See it in action

![Vidrado focus controls](docs/screenshots/focus.png)

| App rules | Preferences |
| --- | --- |
| ![Application rules with real grayscale icons](docs/screenshots/apps.png) | ![Preferences and automatic behavior](docs/screenshots/preferences.png) |

## Features

- Live background blur, dimming, or both, with a quick intensity slider and Light, Balanced, and Deep levels.
- Your active window stays clear as you switch between apps and Spaces.
- Per-app rules: automatically soften background windows, keep an app clear, or pause focus while it is active. Real app icons appear in grayscale.
- Focus across all displays or just the active display; preserve aligned windows and Split View.
- Optional pauses during full screen, screen sharing, continuous capture, or display mirroring.
- A customizable global shortcut, optional cursor shake gesture, and launch at login.
- Saved presets and local preferences.
- Thirteen interface languages. Vidrado follows your primary system language and falls back to English for unsupported languages. Arabic and Urdu use a right-to-left layout.

## Install

Requires **macOS 14 or later**. Download the DMG from [Releases](https://github.com/tonhadaplaces/vidrado/releases), open it, and drag **Vidrado** to **Applications**.

The current distribution uses an **ad hoc signature** and is **not notarized by Apple**. For the Vidrado app you downloaded from this repository, if macOS blocks opening it, remove the quarantine attribute from that app only:

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

Then open Vidrado again. This command does not notarize the app or change system-wide Gatekeeper settings. Build locally if you prefer. Automated release DMGs support **Apple silicon and Intel**.

## Use

Click the overlapping-window icon in the menu bar to open the focus controls. **⌥⌘B** toggles focus anywhere. Right-click or Option-click the menu bar icon also toggles it.

Open preferences with the sliders button or **⌘,**. Choose apps under **Keep some apps clear**. Additional effect sliders, presets, and the cursor gesture are under **More options**. Close the settings window with **⌘W**; Vidrado keeps running in the menu bar. **⌘Q** quits the app.

## Build and test

Use Xcode or Command Line Tools with Swift 5.9 or newer:

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh` builds and signs `dist/Vidrado.app`. `package.sh` produces `dist/Vidrado.dmg` and its SHA-256 checksum. The default build targets the Mac's architecture. Use `VIDRADO_UNIVERSAL=1 ./scripts/package.sh` to build for Apple silicon and Intel.

`swift test` runs core XCTest tests. The full test script also runs native checks in debug and release. Those checks require an unlocked graphical session, a normal foreground window, and Vidrado stopped. GitHub CI runs core tests and verifies the app build; graphical checks run locally.

Read [Repository Guidelines](AGENTS.md) and [Validation notes](TESTING.md) before contributing. Use a pull request: `main` requires at least one approval, passing CI, and resolved review conversations.

## Automatic releases

Include the version changes (`CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`) in a pull request. After approval and merge into `main`, tag that commit:

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

Replace `1.0.0` with the version being released. GitHub Actions tests the code, builds a universal app, verifies the signed bundle and DMG, and publishes the DMG plus its SHA-256 checksum. The workflow checks that the tag is on `main` and matches the app version. No paid Apple Developer credentials are needed; releases retain the ad hoc signing limitations above.

## Privacy and technical limits

Vidrado reads window metadata and places non-interactive overlays beneath the active window. The macOS compositor applies the effect to live background content. It does not read your documents, capture screen frames, or send data over the network, and it does not require Accessibility permission.

Blur, clipping, sharing detection, and Spaces metadata use private SkyLight functions resolved at runtime. Availability may change with macOS updates, and this implementation is unsuitable for the Mac App Store. Tiled-window detection uses geometry. The effect is visual and is not a way to conceal sensitive content in recordings.

## License and credits

[GNU AGPL-3.0](LICENSE). Built with Swift, SwiftUI, and AppKit; no external runtime dependencies. Inter is distributed under the [SIL Open Font License](Sources/VidradoCore/Resources/Brand/Inter-OFL.txt). Lucide design icons use the ISC license; see [Third-party notices](THIRD_PARTY_NOTICES.md).

Inspired by [Defocus](https://defocus.me/). Vidrado is an independent implementation and does not use Defocus source code. The interface source is committed as [`design.pen`](design.pen).
