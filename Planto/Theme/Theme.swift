import SwiftUI



// MARK: - Hex to Color
// we write the color like 0x338069 instead of calculating red, green and blue
extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Colors
extension Color {
    static let appBackground = Color(.systemBackground)
    static let fieldBackground = Color(.tertiarySystemBackground)   // fields and cards
    static let tagBackground = Color(.secondarySystemBackground)    // tags
    static let appGreen = Color(hex: 0x338069)                      // buttons: plus, check, Set Plant Reminder
    static let checkGreen = Color(red: 0.37, green: 0.88, blue: 0.63)       // watered check mark
    static let progressGreen = Color(red: 0.38, green: 0.72, blue: 0.58)    // progress bar
    static let sunTagText = Color(hex: 0xCCC785)                    // light tag text
    static let waterTagText = Color(hex: 0xCAF3FB)                  // water tag text
    static let deleteRed = Color(red: 0.93, green: 0.29, blue: 0.27)        // delete
}

// MARK: - Glass effect for buttons
// iOS 26 and above: the real system Liquid Glass
// older iOS: a simple colored background
extension View {
    @ViewBuilder
    func glassStyle<S: Shape>(in shape: S, tint: Color? = nil) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tint).interactive(), in: shape)
        } else {
            self.background(tint ?? Color.fieldBackground, in: shape)
        }
    }
}
