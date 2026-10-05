# Repository Guidelines

## Project Structure & Module Organization

Vidrado is a native macOS 14+ menu bar app built with Swift, SwiftUI, and AppKit.

- `Sources/Vidrado/`: app lifecycle, views, focus engine, WindowServer integration, global shortcuts, and native checks.
- `Sources/VidradoCore/`: preferences, geometry, focus policies, shake detection, and localization.
- `Sources/VidradoCore/Resources/`: language catalogs, fonts, and design assets.
- `Tests/VidradoCoreTests/`: XCTest coverage for core behavior.
- `Resources/`: application metadata and icon. `scripts/`: build, test, and packaging utilities.
- `design.pen`: interface reference; inspect it through the Pencil MCP, never by reading its encrypted contents directly.
- `.build/` and `dist/`: generated outputs excluded from Git.

## Build, Test, and Development Commands

Use macOS with Xcode or Command Line Tools and Swift 5.9+.

- `swift build`: compile the development executable.
- `swift run Vidrado --settings`: run locally and open settings; quit an existing instance first.
- `./scripts/build.sh`: create and verify the ad hoc signed `dist/Vidrado.app`.
- `swift test`: run core XCTest tests.
- `./scripts/test.sh`: run core tests, native checks in debug and release, and bundle validation.
- `./scripts/package.sh`: build and verify the DMG and generate its SHA-256 checksum.

## Coding Style & Naming Conventions

Use four spaces, `UpperCamelCase` types, and `lowerCamelCase` methods and properties. Follow existing Swift conventions; no formatter or linter is configured. Keep deterministic logic in `VidradoCore` and AppKit integration in `Vidrado`. Use `@MainActor` for UI state and sanitize persisted preferences.

## Testing Guidelines

Name XCTest methods `test` followed by the expected behavior. Add focused regression coverage for changed geometry, policies, persistence, or input handling; no percentage threshold is configured. Native checks require an unlocked graphical session, a normal foreground window, and Vidrado stopped. See `TESTING.md` for environment limits.

## Design & Localization

Match Pencil positions, spacing, and control dimensions in both themes. Use actual installed apps and their grayscale icons. Route UI text through `L10n`; maintain all 13 catalogs, English fallback, and Arabic/Urdu layout direction.

## Commit & Pull Request Guidelines

There are no commits yet, so no established message convention exists. Use concise imperative subjects, such as `Fix focus overlay ordering`. PRs should explain behavior changes, relevant issues, validation performed, and limitations. Include screenshots for UI changes. Preserve offline operation; handle unavailable SkyLight functions gracefully.
