import Foundation
import Observation

// The four states of the main screen
enum PlantsScreenState {
    case start      // first launch
    case empty      // no plants yet
    case list       // today's plants
    case allDone    // all plants are watered
}

// ViewModel for the main screen: it holds all the logic (saving, notifications, calculations)
// The View only shows things and calls the functions here
@Observable
class PlantsViewModel {
    var plants: [Plant]
    var hasSeenStart: Bool
    
    private static let plantsKey = "savedPlants"
    private static let startKey = "hasSeenStart"
    
    init() {
        
        // TEST ONLY    UserDefaults.standard.removeObject(forKey: PlantsViewModel.startKey)
        
        plants = PlantsViewModel.loadPlants()
        hasSeenStart = UserDefaults.standard.bool(forKey: PlantsViewModel.startKey)
        NotificationManager.shared.refresh(plants: plants)
    }
    
    // MARK: - Calculations
    
    // How many plants are watered today
    var wateredCount: Int {
        plants.filter { $0.isWatered }.count
    }
    
    // A number from 0 to 1 for the progress bar
    var progress: Double {
        plants.isEmpty ? 0 : Double(wateredCount) / Double(plants.count)
    }
    
    // The message above the progress bar
    var message: String {
        if wateredCount == 0 {
            return "Your plants are waiting for a sip 💦"
        }
        return "\(wateredCount) of your plants feel loved today ✨"
    }
    
    // Which screen should we show?
    var screenState: PlantsScreenState {
        if !hasSeenStart { return .start }
        if plants.isEmpty { return .empty }
        if wateredCount == plants.count { return .allDone }
        return .list
    }
    
    // MARK: - Actions
    
    // Called when the user leaves the start screen
    func finishStart() {
        hasSeenStart = true
        UserDefaults.standard.set(true, forKey: PlantsViewModel.startKey)
    }
    
    // Add a new plant or update an existing one
    func save(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
        } else {
            plants.append(plant)
        }
        persist()
        NotificationManager.shared.refresh(plants: plants)
    }
    
    // Remove a plant
    func delete(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        persist()
        NotificationManager.shared.refresh(plants: plants)
    }
    
    // Tap on the circle: watered / not watered
    func toggleWatered(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index].lastWateredDate = plants[index].isWatered ? nil : Date()
        persist()
        NotificationManager.shared.refresh(plants: plants)
    }
    
    // MARK: - Saving on the device
    
    // Save the plants as JSON in UserDefaults
    private func persist() {
        if let data = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(data, forKey: PlantsViewModel.plantsKey)
        }
    }
    
    // Read the saved plants (empty list if nothing is saved)
    private static func loadPlants() -> [Plant] {
        guard let data = UserDefaults.standard.data(forKey: plantsKey) else { return [] }
        return (try? JSONDecoder().decode([Plant].self, from: data)) ?? []
    }
}
