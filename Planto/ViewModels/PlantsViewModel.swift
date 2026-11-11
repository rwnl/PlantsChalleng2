import Foundation
import Observation

// الحالات الأربع للشاشة الرئيسية
enum PlantsScreenState {
    case start      // أول تشغيل
    case empty      // ما فيه نباتات
    case list       // قائمة اليوم
    case allDone    // كل النباتات انسقت
}

// الـ ViewModel للشاشة الرئيسية: فيه كل المنطق (الحفظ والإشعارات والحسابات)
// الشاشة (View) تعرض بس، وتنادي الدوال اللي هنا
@Observable
class PlantsViewModel {
    var plants: [Plant]
    var hasSeenStart: Bool

    private static let plantsKey = "savedPlants"
    private static let startKey = "hasSeenStart"

    init() {
        plants = PlantsViewModel.loadPlants()
        hasSeenStart = UserDefaults.standard.bool(forKey: PlantsViewModel.startKey)
    }

    // MARK: - الحسابات

    var wateredCount: Int {
        plants.filter { $0.isWatered }.count
    }

    // رقم من 0 إلى 1 لشريط التقدم
    var progress: Double {
        plants.isEmpty ? 0 : Double(wateredCount) / Double(plants.count)
    }

    // الرسالة فوق شريط التقدم
    var message: String {
        if wateredCount == 0 {
            return "Your plants are waiting for a sip 💦"
        }
        return "\(wateredCount) of your plants feel loved today ✨"
    }

    // أي شاشة نعرض؟
    var screenState: PlantsScreenState {
        if !hasSeenStart { return .start }
        if plants.isEmpty { return .empty }
        if wateredCount == plants.count { return .allDone }
        return .list
    }

    // MARK: - الإجراءات

    func finishStart() {
        hasSeenStart = true
        UserDefaults.standard.set(true, forKey: PlantsViewModel.startKey)
    }

    // إضافة نبتة جديدة أو تحديث نبتة موجودة
    func save(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
        } else {
            plants.append(plant)
        }
        NotificationManager.shared.schedule(for: plant)
        persist()
    }

    func delete(_ plant: Plant) {
        NotificationManager.shared.cancel(for: plant)
        plants.removeAll { $0.id == plant.id }
        persist()
    }

    // الضغط على الدائرة: سقيت / ما سقيت
    func toggleWatered(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index].lastWateredDate = plants[index].isWatered ? nil : Date()
        persist()
    }

    // MARK: - الحفظ على الجهاز

    private func persist() {
        if let data = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(data, forKey: PlantsViewModel.plantsKey)
        }
    }

    private static func loadPlants() -> [Plant] {
        guard let data = UserDefaults.standard.data(forKey: plantsKey) else { return [] }
        return (try? JSONDecoder().decode([Plant].self, from: data)) ?? []
    }
}
