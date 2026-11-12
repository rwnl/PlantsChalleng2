import Foundation


//hi

// MARK: - النبتة
struct Plant: Identifiable, Codable, Equatable {
    var id = UUID()                       // id مميز لكل نبتة
    var name: String
    var room: String
    var light: String
    var wateringDays: WateringFrequency
    var water: String
    var lastWateredDate: Date? = nil      // آخر مرة انسقت فيها

    // هل انسقت اليوم؟ (كل يوم جديد ترجع false تلقائياً)
    var isWatered: Bool {
        guard let date = lastWateredDate else { return false }
        return Calendar.current.isDateInToday(date)
    }
}

// MARK: - تكرار السقي
enum WateringFrequency: String, CaseIterable, Codable, CustomStringConvertible {
    case everyDay = "Every day"
    case every2Days = "Every 2 days"
    case every3Days = "Every 3 days"
    case weekly = "Once a week"

    // النص اللي يظهر في القائمة
    var description: String { rawValue }

    // كم يوم بين كل سقي (يستخدمها الإشعار)
    var days: Int {
        switch self {
        case .everyDay: return 1
        case .every2Days: return 2
        case .every3Days: return 3
        case .weekly: return 7
        }
    }
}

// MARK: - خيارات القوائم المنسدلة 
// أول خيار في كل قائمة هو الخيار الافتراضي
struct PlantOptions {
    static let rooms = ["Bedroom", "Living Room", "Kitchen", "Balcony", "Bathroom"]
    static let lights = ["Full sun", "Partial sun", "Low light"]
    static let waterAmounts = ["20-50 ml", "50-100 ml", "100-200 ml", "200-300 ml"]
}

// MARK: - بيانات تجريبية للـ Preview
extension Plant {
    static let samplePlants = [
        Plant(name: "Monstera", room: "Kitchen", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml"),
        Plant(name: "Pothos", room: "Bedroom", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml"),
        Plant(name: "Orchid", room: "Living Room", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml"),
        Plant(name: "Spider", room: "Kitchen", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml")
    ]

    // نبتة انسقت (للـ Preview)
    static var wateredSample: Plant {
        var plant = samplePlants[1]
        plant.lastWateredDate = Date()
        return plant
    }
}
