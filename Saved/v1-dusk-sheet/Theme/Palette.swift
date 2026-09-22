import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Colours pulled from the bed illustration: warm moonlight, lavender linen, dusk blue.
enum Palette {
    // Ink
    static let ink = Color(hex: 0x262C4F)
    static let inkSoft = Color(hex: 0x262C4F, opacity: 0.58)

    // Moonlight
    static let moon = Color(hex: 0xFFD36B)
    static let moonGlow = Color(hex: 0xFFEAB0)

    // Sheet surface, top to bottom
    static let cream = Color(hex: 0xF7EFDF)
    static let creamWarm = Color(hex: 0xFCF1D6)
    static let lilacMist = Color(hex: 0xEFEAF3)
    static let lavender = Color(hex: 0xE4E0F4)
    static let lavenderLight = Color(hex: 0xEEE9F3)
    static let lavenderDeep = Color(hex: 0xD9D9F2)
    static let periwinkle = Color(hex: 0xBAC2EC)
    static let periwinkleLight = Color(hex: 0xC9CDF1)
    static let periwinkleDeep = Color(hex: 0xAEB7E7)

    // Illustration accents
    static let dream = Color(hex: 0x7C84CC)
    static let badge = Color(hex: 0xFF4D5E)

    // Night sky behind the sheet
    static let nightTop = Color(hex: 0x121530)
    static let nightMid = Color(hex: 0x23285A)
    static let nightBottom = Color(hex: 0x3B3F82)
}
