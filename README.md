# Unplug

A screen-time detox app for iOS that puts distracting apps to bed. This first slice is the
**wind-down bottom sheet**: a floating card that shows Instagram, TikTok and X being tucked
in for the night, built in SwiftUI with motion throughout.

## Run it

1. Open `Unplug.xcodeproj` in Xcode 16 or later.
2. Pick an iPhone simulator (iOS 18+) and press **Run**.
3. Tap **Start wind down**.

Every view also has an Xcode Preview. `WindDownSheet.swift` previews the sheet on its own.

## What moves

The sheet is dark night glass with soft aurora lights drifting behind it. All text uses SF Pro Rounded.

| Element | Motion |
| --- | --- |
| Sheet | Springs up from the bottom and frosts the screen behind it. Drag it down to dismiss (a flick works too). Pulling up meets rubber-band resistance. |
| Illustration | The moon floats and glows, stars twinkle and the bed breathes. Awake apps show buzzing notification badges that pop when tucked in, then "z"s drift up. |
| App lineup (the loading indicator) | Each app sits in a ring that fills with moonlight. The current app gently pulses. When it's asleep it dims, a moon badge bounces in, and the line to the next app lights up. |
| Title and subtitle | Words rise into place one by one. The subtitle says which app is getting sleepy. Every text change moves bottom to top only, never sideways. |
| Stats | Three columns (Asleep, Back online, Screen-free), each with its icon on the left. The "Asleep" count rolls up. Icons are placeholders: swap them in `WindDownSheet.swift`. |
| Button | A "Tucking in…" pill with a spinning sparkle grows into a full-width glowing **Good night** button. |
| Finish | A burst of star-dust confetti and a success haptic. |

All looping motion pauses when **Reduce Motion** is on.

Earlier versions are saved in `Saved/`:
- `v1-dusk-sheet`: light dusk sheet with a progress bar and serif title
- `v2-glass-lineup`: first glass version with the boxed two-column stats

## Project layout

```
Unplug/
  App/            App entry and root view
  Theme/          Palette (colours from the illustration) and shared motion helpers
  Sheet/          FloatingSheet: the reusable bottom-sheet container
  Tonight/        Placeholder home screen and star field
  WindDown/       The wind-down sheet and its parts
  Assets.xcassets The illustration, split into layers, plus the app icon
```

### Reusing the sheet

`floatingSheet` works with any content:

```swift
SomeScreen()
    .floatingSheet(isPresented: $isShowing) {
        MySheetContent(onClose: { isShowing = false })
    }
```

### The illustration

The bed artwork is cut into five transparent layers (`SleepBed`, `SleepMoon`, and three
star layers) so each can animate on its own. Stacked in place, they reproduce the original
image pixel for pixel. Layer positions, badge anchors and "z" origins are in the `Artboard`
enum in `SleepIllustration.swift`, measured in the original 1233 × 1275 px artwork.

## Next steps

`WindDownModel.run()` currently simulates the work with timed steps. To block apps for real,
replace those steps with FamilyControls and ManagedSettings calls, and keep updating
`tuckedCount` and `progress`. The sheet animates from those two values alone.
