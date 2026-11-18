import SwiftUI

// Layer: View
// The Set Reminder sheet: used for adding and for editing
// plant = nil means a new plant, and if there is a plant it means editing
struct SetReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SetReminderViewModel
    
    var onSave: (Plant) -> Void
    var onDelete: (Plant) -> Void
    
    init(plant: Plant? = nil,
         onSave: @escaping (Plant) -> Void,
         onDelete: @escaping (Plant) -> Void = { _ in }) {
        _viewModel = State(initialValue: SetReminderViewModel(plant: plant))
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            nameField
            firstCard
            secondCard
            
            // The delete button shows only when editing
            if let plant = viewModel.existingPlant {
                deleteButton(for: plant)
            }
            
            Spacer()
        }
        .presentationDragIndicator(.hidden)
    }
    
    // MARK: - Parts
    
    // Top bar: X button, title and check button
    private var topBar: some View {
        ZStack {
            Text("Set Reminder")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .glassStyle(in: Circle())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Check button: works only when the form is complete
                Button(action: save) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .glassStyle(in: Circle(), tint: Color.appGreen)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isFormComplete)
                .opacity(viewModel.isFormComplete ? 1.0 : 0.4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // Plant name field
    private var nameField: some View {
        HStack(spacing: 8) {
            Text("Plant Name")
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            TextField("", text: $viewModel.name, prompt: Text("Pothos").foregroundColor(Color.secondary))
                .font(.system(size: 17))
                .foregroundColor(.primary)
                .tint(Color.checkGreen)
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background(Color.fieldBackground)
        .clipShape(Capsule())
        .padding(.horizontal, 16)
        .padding(.top, 54)
    }
    
    // First card: Room and Light
    private var firstCard: some View {
        VStack(spacing: 0) {
            OptionRow(icon: "location", title: "Room", selection: $viewModel.room, options: PlantOptions.rooms)
            DividerLine()
                .padding(.horizontal, 14)
            OptionRow(icon: "sun.max", title: "Light", selection: $viewModel.light, options: PlantOptions.lights)
        }
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal, 16)
        .padding(.top, 44)
    }
    
    // Second card: Watering Days and Water
    private var secondCard: some View {
        VStack(spacing: 0) {
            OptionRow(icon: "drop", title: "Watering Days", selection: $viewModel.wateringDays, options: WateringFrequency.allCases)
            DividerLine()
                .padding(.horizontal, 14)
            OptionRow(icon: "drop", title: "Water", selection: $viewModel.water, options: PlantOptions.waterAmounts)
        }
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal, 16)
        .padding(.top, 46)
    }
    
    // Red Delete Reminder button (flat, like the design)
    private func deleteButton(for plant: Plant) -> some View {
        Button {
            onDelete(plant)
            dismiss()
        } label: {
            Text("Delete Reminder")
                .font(.system(size: 17))
                .foregroundColor(Color.deleteRed)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.fieldBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 64)
    }
    
    // Send the plant to the main screen, then close the sheet
    private func save() {
        onSave(viewModel.makePlant())
        dismiss()
    }
}

// MARK: - A row inside a card: icon + title + dropdown menu (like Room and Light)
// Works with any type (text or enum) as long as it has a text description
struct OptionRow<Option: Hashable & CustomStringConvertible>: View {
    var icon: String
    var title: String
    @Binding var selection: Option
    var options: [Option]
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Dropdown menu (shows the value with the two arrows)
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(Color.secondary)
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
    }
}

#Preview("New") {
    SetReminderView(onSave: { _ in })
        .preferredColorScheme(.dark)
}

#Preview("Edit") {
    SetReminderView(plant: Plant.samplePlants[1], onSave: { _ in }, onDelete: { _ in })
        .preferredColorScheme(.dark)
}
