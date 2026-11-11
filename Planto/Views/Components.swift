import SwiftUI

// الأجزاء الصغيرة اللي تتكرر في أكثر من شاشة

// MARK: - زر + الأخضر
struct AddButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .glassStyle(in: Circle(), tint: Color.appGreen)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - خط رفيع فاصل
struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.12))
            .frame(height: 0.5)
    }
}

// MARK: - التاق الصغير مثل "Full sun" و "20-50 ml"
struct TagView: View {
    var icon: String
    var text: String
    var textColor: Color = .primary

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(textColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.tagBackground)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - شريط التقدم (progress من 0 إلى 1)
struct ProgressBarView: View {
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.2))
                Capsule()
                    .fill(Color.progressGreen)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 5)
        .animation(.easeInOut, value: progress)
    }
}

// MARK: - صف النبتة
struct PlantRowView: View {
    var plant: Plant
    var onToggle: () -> Void   // لما نضغط الدائرة

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            // اسم الغرفة
            HStack(spacing: 4) {
                Image(systemName: "location")
                    .font(.system(size: 9))
                Text("in \(plant.room)")
                    .font(.system(size: 11))
            }
            .foregroundColor(Color.primary.opacity(plant.isWatered ? 0.25 : 0.45))
            .padding(.leading, 34)

            // الدائرة + اسم النبتة
            HStack(spacing: 10) {
                Button(action: onToggle) {
                    checkCircle
                }
                .buttonStyle(.plain)

                Text(plant.name)
                    .font(.system(size: 22))
                    .foregroundColor(Color.primary.opacity(plant.isWatered ? 0.5 : 1.0))
            }

            // التاقات
            HStack(spacing: 8) {
                TagView(icon: "sun.max", text: plant.light, textColor: Color.sunTagText)
                TagView(icon: "drop", text: plant.water)
            }
            .opacity(plant.isWatered ? 0.5 : 1.0)
            .padding(.leading, 34)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // الدائرة: فاضية، أو خضراء فيها علامة صح
    private var checkCircle: some View {
        ZStack {
            if plant.isWatered {
                Circle()
                    .fill(Color.checkGreen)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.appBackground)
            } else {
                Circle()
                    .stroke(Color.primary.opacity(0.6), lineWidth: 1.5)
            }
        }
        .frame(width: 24, height: 24)
        .contentShape(Circle())
    }
}

// MARK: - السحب للحذف
// يلف أي صف ويخليه ينسحب لليسار ويطلع زر الحذف الأحمر
struct SwipeToDeleteRow<Content: View>: View {
    var onDelete: () -> Void
    var content: Content

    @State private var offset: CGFloat = 0     // كم انسحب الصف
    @State private var isOpen = false          // هل زر الحذف ظاهر؟

    private let openWidth: CGFloat = 80        // كم ينسحب الصف لين يظهر الزر

    init(onDelete: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDelete = onDelete
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {

            // زر الحذف (مخفي ورا الصف)
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 38)
                    .background(Color.deleteRed)
                    .clipShape(Capsule())
            }
            .padding(.trailing, 12)

            // الصف نفسه
            content
                .background(Color.appBackground)
                .allowsHitTesting(!isOpen)
                .overlay {
                    // لما يكون الصف مسحوب، الضغطة عليه ترجعه مكانه
                    if isOpen {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { close() }
                    }
                }
                .offset(x: offset)
                .simultaneousGesture(dragGesture)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                // نتجاهل السحب العمودي (عشان ما نخرب السكرول)
                guard abs(value.translation.width) > abs(value.translation.height) else { return }

                let start: CGFloat = isOpen ? -openWidth : 0
                let newOffset = start + value.translation.width
                offset = min(0, max(newOffset, -openWidth - 20))
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    if offset < -openWidth / 2 {
                        offset = -openWidth
                        isOpen = true
                    } else {
                        offset = 0
                        isOpen = false
                    }
                }
            }
    }

    private func close() {
        withAnimation(.easeOut(duration: 0.2)) {
            offset = 0
            isOpen = false
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SwipeToDeleteRow(onDelete: {}) {
            PlantRowView(plant: Plant.samplePlants[0], onToggle: {})
        }
        DividerLine()
        PlantRowView(plant: Plant.wateredSample, onToggle: {})
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
