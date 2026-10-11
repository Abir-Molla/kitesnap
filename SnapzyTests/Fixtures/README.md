# Test Fixtures

This directory contains static assets used by unit and snapshot tests.

## Structure

```
Fixtures/
├── Images/         — PNGs for capture, OCR, QR, and snapshot tests
├── Recording/      — JSON session states, short video clips
└── Scroll/         — Sequences for scrolling-capture stitcher tests
```

## Adding Fixtures

1. Place files in the appropriate subdirectory.
2. Keep total fixture size < 10 MB to keep CI fast.
3. Document provenance in this README.

## Existing Fixtures

- `Images/solid_red_100x100.png` — Synthetic 100×100 red PNG for basic capture tests.
- `Images/transparent_fringe_400x400.png` — 400×400 PNG with transparent edges for fringe-trim tests.
- `Images/retina_2x_200x200.png` — 200×200 @2x PNG for scale-sensitive tests.
- `Recording/empty_session_state.json` — Minimal recording metadata JSON.

## Regenerating Synthetic Images

Use `TestImageFactory.swift` or ImageMagick:

```bash
magick -size 100x100 xc:red SnapzyTests/Fixtures/Images/solid_red_100x100.png
```
