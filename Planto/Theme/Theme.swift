import SwiftUI

// الطبقة: دعم (ألوان وتأثيرات تستخدمها الـ Views)

// MARK: - تحويل الـ hex إلى لون
// نكتب اللون مثل 0x338069 بدل ما نحسب red و green و blue
extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - الألوان
// الخلفيات من ألوان النظام (تصير غامقة تلقائياً مع الدارك مود)
// والأخضر والأحمر ألوان التطبيق نفسه
extension Color {
    static let appBackground = Color(.systemBackground)
    static let fieldBackground = Color(.tertiarySystemBackground)   // الحقول والكروت
    static let tagBackground = Color(.secondarySystemBackground)    // التاقات
    static let appGreen = Color(hex: 0x338069)                      // الأزرار: + والشيك وSet Plant Reminder
    static let checkGreen = Color(red: 0.37, green: 0.88, blue: 0.63)       // علامة الصح
    static let progressGreen = Color(red: 0.38, green: 0.72, blue: 0.58)    // شريط التقدم
    static let sunTagText = Color(hex: 0xCCC785)                    // نص تاق الإضاءة
    static let waterTagText = Color(hex: 0xCAF3FB)                  // نص تاق كمية الماء
    static let deleteRed = Color(red: 0.93, green: 0.29, blue: 0.27)        // الحذف
}

// MARK: - تأثير الـ Glass للأزرار (مثل التصميم)
// خلفية شفافة + تدرّج لون خفيف + حدّ فاتح رفيع + ظل ناعم
extension View {
    func glassStyle<S: Shape>(in shape: S, tint: Color? = nil) -> some View {
        let base = tint ?? Color.white
        let topOpacity = tint == nil ? 0.14 : 0.90      // لون الزر من فوق
        let bottomOpacity = tint == nil ? 0.05 : 0.70   // ويخف شوي لتحت

        return self
            .background {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(
                        LinearGradient(
                            colors: [base.opacity(topOpacity), base.opacity(bottomOpacity)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .overlay {
                shape.stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            }
            .shadow(color: Color.black.opacity(0.25), radius: 6, y: 3)
    }
}
