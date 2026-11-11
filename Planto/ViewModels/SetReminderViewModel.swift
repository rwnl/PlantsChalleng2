import Foundation
import Observation

// الـ ViewModel لنافذة Set Reminder: يحمل قيم الفورم ويقرر إذا كان مكتمل
@Observable
class SetReminderViewModel {
    var name: String
    var room: String
    var light: String
    var wateringDays: WateringFrequency
    var water: String

    // النبتة اللي نعدّلها (nil = نبتة جديدة)
    let existingPlant: Plant?

    init(plant: Plant? = nil) {
        existingPlant = plant
        name = plant?.name ?? ""
        room = plant?.room ?? PlantOptions.rooms[0]
        light = plant?.light ?? PlantOptions.lights[0]
        wateringDays = plant?.wateringDays ?? .everyDay
        water = plant?.water ?? PlantOptions.waterAmounts[0]
    }

    // الفورم مكتمل لما يكون فيه اسم نبتة
    var isFormComplete: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // يرجّع النبتة بالقيم الحالية (نبقي نفس الـ id لو نعدّل)
    func makePlant() -> Plant {
        var plant = existingPlant ?? Plant(name: "", room: "", light: "", wateringDays: .everyDay, water: "")
        plant.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        plant.room = room
        plant.light = light
        plant.wateringDays = wateringDays
        plant.water = water
        return plant
    }
}
