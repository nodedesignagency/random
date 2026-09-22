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

| Element | Motion |
| --- | --- |
| Sheet | Springs up from the bottom and frosts the screen behind it. Drag it down to dismiss (a flick works too). Pulling up meets rubber-band resistance. |
| Background | A mesh gradient drifts slowly from warm moonlight to periwinkle dusk. |
| Moon | Drops in with a spin, then floats and sways. A glow behind it pulses. |
| Stars and sparkles | Pop in one after another, then twinkle, each on its own rhythm. |
| Bed | Rises in, then breathes gently. |
| Notification badges | Each awake app has a red badge that buzzes every few seconds. When the app is tucked in, its badge pops with a moonlight ring. |
| "z"s | Drift up from each app once it's asleep. |
| Progress bar | Fills with a spring and has a highlight that keeps sweeping across it. It glows when complete. |
| Status | The spinner turns into a filled check mark. Each status message pushes the previous one out. |
| Title | Words rise into place one by one with a blur. On completion they float away and the new title cascades in. |
| Close button | Spins in and squishes when pressed. |
| Haptics | A light tap for each app tucked in, and a success haptic at the end. |

All looping motion pauses when **Reduce Motion** is on.

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
