import Foundation
import Observation

// ViewModel for the Set Reminder sheet: it holds the form values and decides if the form is complete
@Observable
class SetReminderViewModel {
    var name: String
    var room: String
    var light: String
    var wateringDays: WateringFrequency
    var water: String
    
    // The plant we are editing (nil = a new plant)
    let existingPlant: Plant?
    
    init(plant: Plant? = nil) {
        existingPlant = plant
        name = plant?.name ?? ""  // ?? gives a default value if it is nil
        room = plant?.room ?? PlantOptions.rooms[0]
        light = plant?.light ?? PlantOptions.lights[0]
        wateringDays = plant?.wateringDays ?? .everyDay
        water = plant?.water ?? PlantOptions.waterAmounts[0]
    }
    
    // The form is complete when the plant has a name
    var isFormComplete: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Returns the plant with the current values (keeps the same id when editing)
    func makePlant() -> Plant {
        var plant = existingPlant ?? Plant(name: "", room: "", light: "", wateringDays: .everyDay, water: "")
        plant.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        plant.room = room
        plant.light = light
        plant.wateringDays = wateringDays
        plant.water = water
        
        // Save the first day once, so the watering schedule counts from it
        if plant.startDate == nil {
            plant.startDate = Date()
        }
        return plant
    }
}
