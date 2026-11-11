import SwiftUI

// الشاشة الرئيسية: تعرض حسب حالة الـ ViewModel
// Start (أول تشغيل) / فاضية / قائمة اليوم / All Done
struct MyPlantsView: View {
    @State private var viewModel = PlantsViewModel()
    @State private var showSheet = false
    @State private var selectedPlant: Plant? = nil   // nil = نبتة جديدة

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // العنوان
                Text("My Plants 🌱")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                DividerLine()

                content
            }

            // زر + (ما يظهر في شاشة Start)
            if viewModel.hasSeenStart {
                AddButton {
                    openSheet(for: nil)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showSheet) {
            SetReminderView(plant: selectedPlant, onSave: viewModel.save, onDelete: viewModel.delete)
        }
    }

    // MARK: - المحتوى حسب الحالة

    @ViewBuilder
    private var content: some View {
        switch viewModel.screenState {
        case .start:
            StartView(onStart: {
                viewModel.finishStart()
                openSheet(for: nil)
            })
        case .empty:
            Text("No reminders set yet..")
                .font(.system(size: 12))
                .foregroundColor(Color.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .list:
            plantList
        case .allDone:
            AllDoneView()
        }
    }

    private var plantList: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(viewModel.message)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .padding(.top, 38)

                ProgressBarView(progress: viewModel.progress)
                    .padding(.horizontal, 28)
                    .padding(.top, 18)
                    .padding(.bottom, 34)

                ForEach(viewModel.plants) { plant in
                    VStack(spacing: 0) {
                        SwipeToDeleteRow(onDelete: {
                            withAnimation { viewModel.delete(plant) }
                        }) {
                            PlantRowView(plant: plant, onToggle: {
                                withAnimation { viewModel.toggleWatered(plant) }
                            })
                            .contentShape(Rectangle())
                            .onTapGesture {
                                openSheet(for: plant)   // الضغط على الصف = تعديل
                            }
                        }
                        DividerLine()
                    }
                }
            }
            .padding(.bottom, 80)   // مساحة عشان زر + ما يغطي آخر صف
        }
    }

    private func openSheet(for plant: Plant?) {
        selectedPlant = plant
        showSheet = true
    }
}

// MARK: - شاشة "Start your plant journey!" (أول تشغيل بس)
private struct StartView: View {
    var onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image("plantHappy")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .padding(.top, 64)

            Text("Start your plant journey!")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 36)

            Text("Now all your plants will be in one place and\nwe will help you take care of them :)🪴")
                .font(.system(size: 12))
                .foregroundColor(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            Button(action: onStart) {
                Text("Set Plant Reminder")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 256, height: 38)
                    .glassStyle(in: Capsule(), tint: Color.appGreen)
            }
            .buttonStyle(.plain)
            .padding(.top, 100)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - شاشة "All Done!" لما كل النباتات تنسقي
private struct AllDoneView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("plantWink")
                .resizable()
                .scaledToFit()
                .frame(width: 130)

            Text("All Done! 🎉")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 24)

            Text("All Reminders Completed")
                .font(.system(size: 11))
                .foregroundColor(Color.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 180)   // نرفعها شوي فوق الوسط مثل التصميم
    }
}

#Preview {
    MyPlantsView()
        .preferredColorScheme(.dark)
}
