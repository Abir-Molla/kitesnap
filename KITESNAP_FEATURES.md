# KiteSnap — Feature List

> Verified directly against the current codebase on 2026-10-12 (not the upstream `README.md`,
> which still describes removed features like Cloud Upload and Video Editor from before the
> rebrand/strip-down). Use this file as ground truth for what KiteSnap actually does today.

## Vision

Native macOS menu-bar app for screenshots, screen recording, and annotation — privacy-first,
zero-cloud, one-time-purchase alternative to CleanShot X. No cloud upload, no remote OCR, no
telemetry. Everything runs on-device via Apple frameworks (ScreenCaptureKit, Vision, AVFoundation).
Built with SwiftUI + AppKit, GRDB (SQLite) for capture history, Sparkle for updates.

---

## 1. Screenshot Capture

- **Fullscreen capture**
- **Area (selection) capture** — manual drag or Application Capture mode (toggle window-snap vs. freeform with `A`)
- **Area capture + inline annotate** — annotate immediately before saving
- **Active window capture**
- **Application window capture**
- **Scrolling capture** — auto-scroll + live stitched preview for tall pages/documents
- **Delayed capture** — configurable countdown timer
- **Repeat last area** — re-fire the last area selection instantly
- **Object/subject cutout capture** — foreground subject extraction (on-device, `ForegroundCutoutService`)
- **Smart Element capture** — AX-tree aware element detection, captures a specific UI element under the cursor
- **OCR text capture** — select a region, extract text directly (Apple Vision, on-device)
- **QR code detection** inside captures (`QRCodeService`, `QRCodeDetection`, `QRPayloadClassifier`)
- Window shadow capture support, multi-monitor aware area selection with magnifier + coordinate bubble
- Background cursor control, live passthrough input during selection

## 2. Screen Recording

- **Screen recording** (full screen or region) and **Application recording** (single-app window)
- Video or **GIF** output (`GIFConverter`)
- **System audio + microphone** capture, with live **audio level meter / waveform**
- **Camera overlay** during recording (including placement controls)
- **Mouse click highlight** overlay
- **Keystroke overlay** (on-screen key display while recording)
- **Live on-screen annotation** while recording (its own toolbar, canvas, tool state — independent of the main Annotate editor)
- Recording status bar with pause/resume, output-mode toggle, mic/camera/system-audio toggles
- Recording metadata tracking + scheduled cleanup

## 3. Annotation Editor

15 tools (`AnnotationToolType`): selection, crop, rectangle, filled rectangle, oval, arrow, line,
text, highlighter, blur, spotlight, counter, watermark, pencil, mockup.

- Crop with edge-snapping and auto-crop-to-content
- Text tool with text-snapping
- Highlighter with text-aware snapping
- Blur / pixelate regions, plus an **automatic local sensitive-data redaction** pass (on-device, no network)
- Spotlight (dim everything except a focus region)
- Counter (auto-incrementing numbered markers)
- Watermark tool (default text: "KiteSnap")
- **Mockup backgrounds** with a 3D renderer (`AnnotateMockup3DRenderer`) for device/browser frame presentation
- Combine multiple images into one canvas (drag/drop + snapping layout)
- Image rotation, zoom/pan
- Per-session persistence (`AnnotationSessionStore`) so edits survive reopening a capture
- Drag-to-app export straight from the editor
- Inline area-annotate overlay (lighter-weight variant used for the "capture + inline annotate" flow)

## 4. Quick Access

Floating panel that appears after every capture (CleanShot-style), bottom-corner positioned,
non-activating `NSPanel`:

- Stacked cards (up to 5 visible) with hover-revealed action buttons
- Actions: copy, save/open, edit (opens Annotate), dismiss, pin-to-screen
- **Pin to screen** — detach a card into its own floating always-visible window
- Swipe-to-dismiss (trackpad two-finger swipe or mouse drag), configurable per-direction swipe actions
- Drag-to-external-app (native file drag out of the card)
- Configurable auto-dismiss timer (pauses on hover), slide or scale animation style
- Per-card keyboard shortcuts (fire on whichever card is hovered)
- Scale/position/animation-style all user-configurable

## 5. Capture History

- Persisted in a local SQLite database (GRDB) — `captureHistoryRecord` table
- Floating history panel + full browsable grid (screenshots, videos, GIFs)
- Filter by type/time, filename search
- Quick copy / open / delete, drag-to-app reuse
- Reopen any past capture directly in Annotate (restores its annotation session)
- Configurable retention policy and panel layout

## 6. Shortcuts & Automation

- Fully configurable **global keyboard shortcuts** for every capture/recording/annotation action, with system-shortcut-conflict detection
- **`kitesnap://` URL scheme** (with `snapzy://` kept for backward compatibility) for external launchers/automation:
  - `capture/{fullscreen, area, repeat-area, delayed, application, active-window, area-annotate, scrolling, ocr, smart-element, object-cutout}`
  - `record/{screen, application}`
  - `open/annotate`, `open/combine` (accepts `?file=` params to skip the picker)
  - `open/history`, `show/shortcuts`
  - `settings` / `settings?tab=<name>` — deep-links into any of the 10 preference tabs
  - Toggle-able from Settings → Advanced
- On-screen shortcut cheat-sheet overlay (`ShortcutOverlayManager`)

## 7. Onboarding

- Splash screen + first-run guided flow: language selection, permissions setup, shortcut configuration
- "Restart Onboarding" available anytime from the menu bar

## 8. Settings (10 tabs)

General · Menu Bar · Capture · Annotate · Quick Access · History · Shortcuts · Permissions ·
Advanced · About — each with its own dedicated SwiftUI settings view. Notable advanced features:

- **Advanced**: TOML config export/import (`~/.config/.../config.toml`-style), one-time config-folder grant, debounced background sync, safe sync-before-open, launch-time auto-apply — for portable settings / dotfile workflows / machine-to-machine setup
- **Menu Bar**: customizable menu item order/visibility per group (Capture / Recording / Tools), custom menu bar icon
- **Permissions**: guided Screen Recording / Microphone / Accessibility grant flow

## 9. Updates & Diagnostics

- In-app update checks via **Sparkle**, feed pointed at `github.com/Abir-Molla/kitesnap`
- "Up to Date" / "Check for Updates" feedback in Preferences sidebar
- Local diagnostic log bundles (`DiagnosticLogger`, `CrashSentinel`, `LogCleanupScheduler`) — opt-in, local-only
- Performance signposts for instrumentation

## 10. Platform, Privacy & Security

- Native macOS menu-bar app (SwiftUI + AppKit), light/dark/system appearance theming
- **Zero cloud**: no upload providers, no remote OCR endpoint, no telemetry — confirmed by codebase
  (no Cloud Upload feature folder, `Services/Networking` contains only a local `URLSessionProtocol`
  abstraction used for the Sparkle update check)
- OCR runs entirely on-device via Apple Vision (`VisionOCRProvider`); there is no custom/remote OCR endpoint
- Local SQLite database (GRDB) for capture history, with repair/reset/backup-on-reset handling
- Security-scoped bookmarks for user-selected folders

---

### Explicitly removed (do not reintroduce without discussion)

Per the rebrand: Video Editor, Cloud Upload (S3/Imgur/etc.), remote/custom OCR endpoints, sponsor
links, contributor popups, telemetry/crash-report URLs, the Liquid Glass Playground/Design Studio,
and the menu-bar icon style switcher (menu bar always shows KiteSnap's own icon now).
