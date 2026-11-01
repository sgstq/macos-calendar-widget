# Calendar Widget

Calendar Widget brings a fast, glanceable month calendar to macOS Notification Center and the desktop. It is made for the small moment when you need to check a date, move a few months ahead, or jump across the year without opening a full calendar app.

<p align="center">
  <img src=".github/assets/demo.gif" alt="Calendar Widget demo" width="420">
</p>

The widget stays quiet and lightweight. Today is clearly marked, adjacent-month days stay visible for context, and the controls are tuned for quick navigation: move by month, jump by year, or click the left and right sides of the calendar body to page through time.

## Highlights

- Interactive month calendar for Notification Center and desktop widgets
- Fast month navigation with arrows or broad left/right calendar zones
- Year jumps with compact double-arrow controls
- One-click return to the current month
- Native Liquid Glass look on macOS 26 and later, in Medium and Large sizes
- Locale-aware weekday order

## Get Calendar Widget

Download the latest DMG from [GitHub Releases](https://github.com/sgstq/macos-calendar-widget/releases/latest), open it, and drag Calendar Widget into Applications. After opening the app once, add Calendar from Notification Center's widget gallery.

> **First launch:** the app is self-signed, not notarized, so macOS flags it as coming from an unidentified developer. Open **System Settings → Privacy & Security**, find the Calendar Widget message near the bottom, and click **Open Anyway** (on older macOS, right-click the app → **Open**). You only need to do this once.

## Development

Built with SwiftUI + WidgetKit and generated from `project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen). Releases are built and packaged by [`.github/workflows/release.yml`](.github/workflows/release.yml); see [docs/ci-signing.md](docs/ci-signing.md) for the code-signing setup.

```sh
xcodegen generate
xcodebuild -project CalendarWidget.xcodeproj -scheme CalendarWidget -configuration Release \
  -derivedDataPath build/DerivedData CODE_SIGN_IDENTITY="-" \
  CURRENT_PROJECT_VERSION="$(date -u +%Y%m%d%H%M)" build
```

To try a build on your own Mac, copy `build/DerivedData/Build/Products/Release/Calendar Widget.app` to `/Applications`, open it once, then restart the widget host with `killall chronod NotificationCenter`.

Always pass a build number (`CURRENT_PROJECT_VERSION`) higher than the one already installed, as above. If it goes down, Notification Center keeps the stored timeline of the higher-numbered build and the widget's buttons appear to stop working. Releases use the same timestamp scheme.

The app icon is rendered by `scripts/generate-app-icon.swift` into `App/Assets.xcassets`; re-run it only when the icon design changes.
