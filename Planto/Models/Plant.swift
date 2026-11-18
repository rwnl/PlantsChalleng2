import Foundation

// MARK: - Plant
struct Plant: Identifiable, Codable, Equatable {
    var id = UUID()                    // unique id for each plant
    var name: String
    var room: String
    var light: String
    var wateringDays: WateringFrequency
    var water: String
    var lastWateredDate: Date? = nil   // last time the plant was watered (nil = never)
    var startDate: Date? = nil         // the day the plant was added
    
    // true if the plant was watered today (becomes false again on a new day)
    var isWatered: Bool {
        guard let date = lastWateredDate else { return false }
        return Calendar.current.isDateInToday(date)
    }
}

// MARK: - Watering Frequency
enum WateringFrequency: String, CaseIterable, Codable, CustomStringConvertible {
    case everyDay = "Every day"
    case every2Days = "Every 2 days"
    case every3Days = "Every 3 days"
    case weekly = "Once a week"
    case every10Days = "Every 10 days"
    case every2Weeks = "Every 2 weeks"

    // text shown in the picker
    var description: String { rawValue }

    // number of days between waterings (used by notifications)
    var days: Int {
        switch self {
        case .everyDay: return 1
        case .every2Days: return 2
        case .every3Days: return 3
        case .weekly: return 7
        case .every10Days: return 10
        case .every2Weeks: return 14
        }
    }
}

// MARK: - Picker Options
// the first option in each list is the default
struct PlantOptions {
    static let rooms = ["Bedroom", "Living Room", "Kitchen", "Balcony", "Bathroom"]
    static let lights = ["Full sun", "Partial sun", "Low light"]
    static let waterAmounts = ["20-50 ml", "50-100 ml", "100-200 ml", "200-300 ml"]
}

// MARK: - Sample Data (for previews only)
extension Plant {
    static let samplePlants = [
        Plant(name: "Monstera", room: "Kitchen", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml"),
        Plant(name: "Pothos", room: "Bedroom", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml"),
        Plant(name: "Orchid", room: "Living Room", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml"),
        Plant(name: "Spider", room: "Kitchen", light: "Full sun", wateringDays: .everyDay, water: "20-50 ml")
    ]
}
