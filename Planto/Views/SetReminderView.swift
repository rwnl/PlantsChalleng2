import SwiftUI

// نافذة Set Reminder: نستخدمها للإضافة وللتعديل
// plant = nil يعني نبتة جديدة، وإذا فيه نبتة يعني تعديل
struct SetReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SetReminderViewModel
    @FocusState private var isNameFocused: Bool

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

            // زر الحذف يظهر في التعديل بس
            if let plant = viewModel.existingPlant {
                deleteButton(for: plant)
            }

            Spacer()
        }
        .presentationDragIndicator(.hidden)
        .onAppear {
            if viewModel.existingPlant == nil {
                isNameFocused = true
            }
        }
    }

    // MARK: - الأجزاء

    // الشريط العلوي: X والعنوان وزر الشيك
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

                // زر الشيك: ما يشتغل إلا لما الفورم يكتمل
                Button(action: save) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
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

    // حقل اسم النبتة
    private var nameField: some View {
        HStack(spacing: 6) {
            Text("Plant Name")
                .font(.system(size: 14))
                .foregroundColor(.primary)

            TextField("", text: $viewModel.name, prompt: Text("Pothos").foregroundColor(Color.secondary))
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .tint(Color.checkGreen)
                .focused($isNameFocused)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.top, 40)
    }

    // الكرت الأول: Room و Light
    private var firstCard: some View {
        VStack(spacing: 0) {
            OptionRow(icon: "location", title: "Room", selection: $viewModel.room, options: PlantOptions.rooms)
            DividerLine()
            OptionRow(icon: "sun.max", title: "Light", selection: $viewModel.light, options: PlantOptions.lights)
        }
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 48)
    }

    // الكرت الثاني: Watering Days و Water
    private var secondCard: some View {
        VStack(spacing: 0) {
            OptionRow(icon: "drop", title: "Watering Days", selection: $viewModel.wateringDays, options: WateringFrequency.allCases)
            DividerLine()
            OptionRow(icon: "drop", title: "Water", selection: $viewModel.water, options: PlantOptions.waterAmounts)
        }
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 36)
    }

    // زر Delete Reminder الأحمر
    private func deleteButton(for plant: Plant) -> some View {
        Button {
            onDelete(plant)
            dismiss()
        } label: {
            Text("Delete Reminder")
                .font(.system(size: 14))
                .foregroundColor(Color.deleteRed)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .glassStyle(in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 48)
    }

    private func save() {
        onSave(viewModel.makePlant())
        dismiss()
    }
}

// MARK: - صف في الكرت: أيقونة + اسم + قائمة منسدلة (مثل Room و Light)
// يشتغل مع أي نوع (نص أو enum) طالما له وصف نصي
struct OptionRow<Option: Hashable & CustomStringConvertible>: View {
    var icon: String
    var title: String
    @Binding var selection: Option
    var options: [Option]

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer()

            // القائمة المنسدلة (تعرض القيمة مع السهمين)
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(Color.secondary)
        }
        .padding(.horizontal, 12)
        .frame(height: 43)
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
