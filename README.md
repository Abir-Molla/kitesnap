<div align="center">
  <img src="./banner.png" width="200" height="200" alt="KiteSnap banner" />

  <h1>KiteSnap</h1>
  <p><strong>Native macOS screenshots, screen recording, and annotation from the menu bar — privacy-first, zero-cloud, one-time purchase.</strong></p>

  <p>
    Built with <a href="https://developer.apple.com/xcode/swiftui/">SwiftUI</a>,
    <a href="https://developer.apple.com/documentation/appkit">AppKit</a>,
    <a href="https://developer.apple.com/documentation/screencapturekit">ScreenCaptureKit</a>,
    <a href="https://developer.apple.com/documentation/vision">Vision</a>, and
    <a href="https://sparkle-project.org/">Sparkle</a>.
  </p>

  <p>
    <a href="#features">Features</a> •
    <a href="#install">Install</a> •
    <a href="#shortcuts">Shortcuts</a> •
    <a href="#automation">Automation</a> •
    <a href="#privacy--security">Privacy &amp; Security</a> •
    <a href="#development">Development</a>
  </p>
</div>

## Why KiteSnap

KiteSnap is a CleanShot X-style screenshot, recording, and annotation tool for macOS, built around one
constraint: **zero cloud**. There is no upload provider, no remote OCR endpoint, and no telemetry —
every feature (including OCR) runs entirely on-device using Apple's own frameworks. It's a one-time
purchase, not a subscription.

For the full, verified-against-source feature list, see [KITESNAP_FEATURES.md](KITESNAP_FEATURES.md).

## Features

- **Screenshot capture** — fullscreen, area (drag or app-window snap), active window, application
  window, scrolling capture with live stitched preview, delayed capture, repeat-last-area, object/subject
  cutout, Smart Element (AX-tree aware) capture, and on-device OCR text capture (Apple Vision)
- **Screen recording** — full screen or region, application recording, video or GIF output, system audio
  + microphone capture with a live level meter, camera overlay, mouse-click highlights, keystroke
  overlay, and live on-screen annotation while recording
- **Annotation editor** — 15 tools (crop, shapes, arrow, line, text, highlighter, blur/pixelate, spotlight,
  counter, watermark, pencil, mockup backgrounds with a 3D renderer), automatic local sensitive-data
  redaction, image combine, per-session persistence so edits survive reopening a capture
- **Quick Access** — a CleanShot-style floating panel after every capture: copy, save, annotate, pin to
  screen, swipe to dismiss, drag straight into another app
- **Capture history** — local SQLite (GRDB) database, filterable grid, reopen any past capture back into
  Annotate with its edits intact
- **Fully configurable global shortcuts** and a `kitesnap://` URL scheme for automation
- **Zero cloud** — no upload providers, no remote OCR, no telemetry; everything runs on-device

See [KITESNAP_FEATURES.md](KITESNAP_FEATURES.md) for the complete, itemized list.

## Install

> Requires **macOS 14.0** or later.

1. Go to [Releases](https://github.com/Abir-Molla/kitesnap/releases) and download the latest
   `KiteSnap-<version>.zip`
2. Unzip it and move `Snapzy.app` (KiteSnap's app bundle) to `/Applications`
3. **Gatekeeper note:** this build isn't Apple-notarized yet, so macOS will say the app "cannot be
   opened" the first time. Right-click (or Control-click) the app → **Open** → **Open** again in the
   confirmation dialog. You only need to do this once.
4. Launch KiteSnap and grant Screen Recording permission when prompted in System Settings
5. Re-launch KiteSnap after granting Screen Recording if macOS asks for it
6. Grant Microphone and Camera permission too if you want voice or camera input in recordings

### Build from source

```bash
git clone https://github.com/Abir-Molla/kitesnap.git
cd kitesnap
open Snapzy.xcodeproj
```

Build and run the `Snapzy` scheme from Xcode (Release configuration for a distributable build).

## Shortcuts

| Action                                                  | Shortcut |
| -------------------------------------------------------- | -------- |
| Fullscreen screenshot                                   | `⇧⌘3`    |
| Area screenshot                                         | `⇧⌘4`    |
| ↳ Toggle manual/app window mode (`Application Capture`) | `A`      |
| Repeat last area screenshot                             | `⌃⌘⇧4`   |
| Area screenshot + inline annotate                       | `⇧⌘7`    |
| Scrolling screenshot                                    | `⇧⌘6`    |
| Screen recording (start/stop toggle)                    | `⇧⌘5`    |
| OCR text capture                                        | `⇧⌘2`    |
| Object cutout capture                                   | `⇧⌘1`    |
| Smart element capture                                   | `⌥⇧4`    |
| Open Annotate                                           | `⇧⌘A`    |
| Show shortcuts list                                     | `⇧⌘K`    |

All shortcuts are reconfigurable under **Settings → Shortcuts**.

### Quick Access card actions

Hover a Quick Access card, then press the key — active only while the pointer is over that card.

| Action      | Shortcut |
| ----------- | -------- |
| Copy        | `⌘C`     |
| Save / Open | `⌘S`     |
| Edit        | `⌘E`     |
| Pin to screen | `⌘P`   |
| Delete      | `⌘⌫`     |
| Close       | `⌘W`     |

## Automation

KiteSnap registers the `kitesnap://` URL scheme (with `snapzy://` kept for backward compatibility) so
launchers and automation tools can trigger capture actions. Toggle this under **Settings → Advanced →
URL Scheme integration**.

| Action                 | URL                                |
| ----------------------- | ----------------------------------- |
| Fullscreen screenshot  | `kitesnap://capture/fullscreen`    |
| Area screenshot        | `kitesnap://capture/area`          |
| Repeat area screenshot | `kitesnap://capture/repeat-area`   |
| Delayed area screenshot| `kitesnap://capture/delayed`       |
| Application window     | `kitesnap://capture/application`   |
| Active window          | `kitesnap://capture/active-window` |
| Area annotate          | `kitesnap://capture/area-annotate` |
| Scrolling screenshot   | `kitesnap://capture/scrolling`     |
| OCR text capture       | `kitesnap://capture/ocr`           |
| Smart element capture  | `kitesnap://capture/smart-element` |
| Object cutout capture  | `kitesnap://capture/object-cutout` |
| Screen recording       | `kitesnap://record/screen`         |
| Application recording  | `kitesnap://record/application`    |
| Open Annotate          | `kitesnap://open/annotate`         |
| Combine images         | `kitesnap://open/combine`          |
| Open Capture History   | `kitesnap://open/history`          |
| Show shortcuts list    | `kitesnap://show/shortcuts`        |
| Open Settings          | `kitesnap://settings`              |
| Open Settings tab      | `kitesnap://settings?tab=annotate` |

`kitesnap://open/combine` opens the image picker. Skip the picker by passing two or more URL-encoded
local paths as repeated `file` parameters:

```bash
open 'kitesnap://open/combine?file=/tmp/first.png&file=/tmp/second.png'
```

## Privacy & Security

KiteSnap is **not sandboxed** — it runs with your user account's privileges, with the macOS Hardened
Runtime enabled. There are no upload providers, no remote OCR endpoint, and no telemetry: the only
network call it ever makes is the Sparkle update check. OCR runs entirely on-device via Apple Vision.
Capture history is stored locally in SQLite (GRDB); security-scoped bookmarks are used for
user-selected folders. This build is signed with an Apple Development certificate but is **not yet
notarized** — see the Gatekeeper note in [Install](#install).

To report a vulnerability, see [SECURITY.md](SECURITY.md).

## Development

For local setup and first-time development workflow, see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).
For the contribution workflow, see [CONTRIBUTING.md](CONTRIBUTING.md).

> Note: the `docs/` folder still describes some features (Video Editor, Cloud Upload, Raycast) that were
> removed during the KiteSnap rebrand — treat [KITESNAP_FEATURES.md](KITESNAP_FEATURES.md) as the
> source of truth for what's actually in the app today.

## Acknowledgments

KiteSnap started as a fork of [Snapzy](https://github.com/duongductrong/snapzy) and is inspired by
[CleanShot X](https://cleanshot.com/).

## License

BSD 3-Clause License. See [LICENSE](LICENSE).
