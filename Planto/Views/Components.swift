import SwiftUI

// Small views that are used on more than one screen

// MARK: - Green + button
struct AddButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .glassStyle(in: Circle(), tint: Color.appGreen)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Thin divider line
struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.12))
            .frame(height: 0.5)
    }
}

// MARK: - Small tag like "Full sun" and "20-50 ml"
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

// MARK: - Progress bar (progress goes from 0 to 1)
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

// MARK: - Plant row
struct PlantRowView: View {
    var plant: Plant
    var onToggle: () -> Void   // called when the circle is tapped
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // Room name
            HStack(spacing: 4) {
                Image(systemName: "location")
                    .font(.system(size: 9))
                Text("in \(plant.room)")
                    .font(.system(size: 11))
            }
            .foregroundColor(Color.primary.opacity(plant.isWatered ? 0.25 : 0.45))
            .padding(.leading, 34)
            
            // Circle + plant name
            HStack(spacing: 10) {
                Button(action: onToggle) {
                    checkCircle
                }
                .buttonStyle(.plain)
                
                Text(plant.name)
                    .font(.system(size: 22))
                    .foregroundColor(Color.primary.opacity(plant.isWatered ? 0.5 : 1.0))
            }
            
            // Tags
            HStack(spacing: 8) {
                TagView(icon: "sun.max", text: plant.light, textColor: Color.sunTagText)
                TagView(icon: "drop", text: plant.water, textColor: Color.waterTagText)
            }
            .opacity(plant.isWatered ? 0.5 : 1.0)
            .padding(.leading, 34)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // The circle: empty, or green with a check mark
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

// MARK: - Swipe to delete
// Wraps any row, so it can slide to the left and show the red delete button
struct SwipeToDeleteRow<Content: View>: View {
    var onDelete: () -> Void
    var content: Content
    
    @State private var offset: CGFloat = 0     // how far the row moved
    @State private var isOpen = false          // is the delete button showing?
    
    private let openWidth: CGFloat = 80        // how far the row slides to show the button
    
    init(onDelete: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDelete = onDelete
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            
            // Delete button (hidden behind the row)
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 38)
                    .background(Color.deleteRed)
                    .clipShape(Capsule())
            }
            .padding(.trailing, 12)
            
            // The row itself
            content
                .background(Color.appBackground)
                .allowsHitTesting(!isOpen)
                .overlay {
                    // When the row is open, tapping it closes it again
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
                // Ignore vertical drags (so we don't break scrolling)
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                
                let start: CGFloat = isOpen ? -openWidth : 0
                let newOffset = start + value.translation.width
                offset = min(0, max(newOffset, -openWidth - 20))
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    // Open if dragged more than half, otherwise close
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

#Preview("Plant Rows") {
    VStack(spacing: 0) {
        SwipeToDeleteRow(onDelete: {}) {
            PlantRowView(plant: Plant.samplePlants[0], onToggle: {})
        }
        DividerLine()
        PlantRowView(plant: Plant(name: "Pothos", room: "Bedroom", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml", lastWateredDate: Date()), onToggle: {})
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

#Preview("Add Button") {
    AddButton(action: {})
        .padding(40)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

#Preview("Tags") {
    HStack {
        TagView(icon: "sun.max", text: "Full sun", textColor: Color.sunTagText)
        TagView(icon: "drop", text: "20-50 ml", textColor: Color.waterTagText)
    }
    .padding(40)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}

#Preview("Progress Bar") {
    ProgressBarView(progress: 0.5)
        .padding(40)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
