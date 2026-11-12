import SwiftUI

// MARK: - الألوان

extension Color {
    static let appBackground = Color(.systemBackground)
    static let fieldBackground = Color(.tertiarySystemBackground)   // الحقول والكروت
    static let tagBackground = Color(.secondarySystemBackground)    // التاقات
    static let appGreen = Color(red: 0.25, green: 0.49, blue: 0.40)         // الأزرار
    static let checkGreen = Color(red: 0.37, green: 0.88, blue: 0.63)       // علامة الصح
    static let progressGreen = Color(red: 0.38, green: 0.72, blue: 0.58)    // شريط التقدم
    static let sunTagText = Color(red: 0.72, green: 0.78, blue: 0.45)       // نص تاق الإضاءة
    static let deleteRed = Color(red: 0.93, green: 0.29, blue: 0.27)        // الحذف
}

// MARK: - تأثير الـ Glass للأزرار

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
