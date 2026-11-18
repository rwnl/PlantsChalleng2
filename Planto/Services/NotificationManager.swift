import UserNotifications

// Layer: Service
// Builds one reminder per day at 3 PM for all plants that need water that day
class NotificationManager {
    static let shared = NotificationManager()
    
    private let reminderHour = 14
    private let reminderMinute = 15
    private let daysAhead = 30   // how many days ahead we schedule
    
    // Deletes all old reminders and builds them again from the current plants
    func refresh(plants: [Plant]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // no plants = no reminders (and no permission popup)
        guard !plants.isEmpty else { return }
        
        let requests = makeRequests(for: plants)
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                for request in requests {
                    center.add(request)
                }
            }
        }
    }
    
    // One request for each day that has at least one plant to water
    private func makeRequests(for plants: [Plant]) -> [UNNotificationRequest] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var requests: [UNNotificationRequest] = []
        
        for offset in 0..<daysAhead {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today),
                  let time = calendar.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: day),
                  time > Date() else { continue }   // skip if 3 PM already passed
            
            let duePlants = plants.filter { isDue($0, on: day) }
            if duePlants.isEmpty { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Planto"
            content.body = duePlants.count == 1 ? "Hey! let's water your plant" : "Hey! let's water your plants"
            content.sound = .default
            
            var parts = calendar.dateComponents([.year, .month, .day], from: day)
            parts.hour = reminderHour
            parts.minute = reminderMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            requests.append(UNNotificationRequest(identifier: "planto-\(offset)", content: content, trigger: trigger))
        }
        return requests
    }
    
    // Does this plant need water on this day?
    private func isDue(_ plant: Plant, on day: Date) -> Bool {
        let calendar = Calendar.current
        
        // already watered today = no reminder for it today
        if calendar.isDateInToday(day) && plant.isWatered { return false }
        
        // count days from the last watering (or from the day it was added)
        let anchor = calendar.startOfDay(for: plant.lastWateredDate ?? plant.startDate ?? Date())
        let passedDays = calendar.dateComponents([.day], from: anchor, to: day).day ?? 0
        
        return passedDays >= 0 && passedDays % plant.wateringDays.days == 0
    }
}
