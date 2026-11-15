import SwiftUI

// الطبقة: View
// نافذة Set Reminder: نستخدمها للإضافة وللتعديل
// plant = nil يعني نبتة جديدة، وإذا فيه نبتة يعني تعديل
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

            // زر الحذف يظهر في التعديل بس
            if let plant = viewModel.existingPlant {
                deleteButton(for: plant)
            }

            Spacer()
        }
        .presentationDragIndicator(.hidden)
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

    // حقل اسم النبتة
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

    // الكرت الأول: Room و Light
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

    // الكرت الثاني: Watering Days و Water
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

    // زر Delete Reminder الأحمر (مسطح مثل التصميم)
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
                .font(.system(size: 16))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 17))
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
