import UserNotifications

// مسؤول عن إشعارات التذكير بالسقي
class NotificationManager {
    static let shared = NotificationManager()

    // وقت التذكير: الساعة 3 مساءً (15 بنظام 24 ساعة)
    private let reminderHour = 15
    private let reminderMinute = 0

    // عدد الإشعارات اللي نجدولها مقدماً للنبتة (لما التكرار مو يومي ولا أسبوعي)
    private let upcomingCount = 10

    // جدولة إشعارات نبتة (يطلب الصلاحية أول مرة)
    func schedule(for plant: Plant) {
        let center = UNUserNotificationCenter.current()

        // نحذف الإشعارات القديمة (مفيد لما نعدّل النبتة)
        cancel(for: plant)

        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let's water your plant"
        content.sound = .default

        let requests = makeRequests(for: plant, content: content)

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                for request in requests {
                    center.add(request)
                }
            }
        }
    }

    // إلغاء كل إشعارات نبتة (لما نحذفها أو نعدّلها)
    func cancel(for plant: Plant) {
        var ids = [plant.id.uuidString]
        for number in 1...upcomingCount {
            ids.append("\(plant.id.uuidString)-\(number)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // نبني الإشعارات حسب أيام السقي
    private func makeRequests(for plant: Plant, content: UNNotificationContent) -> [UNNotificationRequest] {
        let days = plant.wateringDays.days
        let id = plant.id.uuidString

        var time = DateComponents()
        time.hour = reminderHour
        time.minute = reminderMinute

        // كل يوم: إشعار واحد يتكرر
        if days == 1 {
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            return [UNNotificationRequest(identifier: id, content: content, trigger: trigger)]
        }

        // كل أسبوع: إشعار واحد يتكرر في نفس يوم الأسبوع
        if days == 7 {
            time.weekday = Calendar.current.component(.weekday, from: Date())
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            return [UNNotificationRequest(identifier: id, content: content, trigger: trigger)]
        }

        // باقي الحالات (2 و3 و10 و14): نجدول عدة إشعارات مقدماً، كلها الساعة 3
        var requests: [UNNotificationRequest] = []
        for number in 1...upcomingCount {
            let date = Calendar.current.date(byAdding: .day, value: days * number, to: Date()) ?? Date()
            var parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
            parts.hour = reminderHour
            parts.minute = reminderMinute

            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            requests.append(UNNotificationRequest(identifier: "\(id)-\(number)", content: content, trigger: trigger))
        }
        return requests
    }
}
