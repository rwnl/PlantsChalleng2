import UserNotifications

// مسؤول عن إشعارات التذكير بالسقي
class NotificationManager {
    static let shared = NotificationManager()

    // وقت التذكير: الساعة 9 صباحاً (حطيته افتراضي)
   
    private let reminderHour = 9
    private let reminderMinute = 0

    // جدولة إشعار لنبتة يطلب الصلاحية أول مرة
    func schedule(for plant: Plant) {
        let center = UNUserNotificationCenter.current()

        // لحذف الإشعار القديم مفيد لما نعدّل النبتة
        center.removePendingNotificationRequests(withIdentifiers: [plant.id.uuidString])

        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let's water your plant"
        content.sound = .default

        
        
        // للتجربة فقط: يطلع الإشعار بعد 10 ثواني
       // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let trigger = makeTrigger(days: plant.wateringDays.days)
        let request = UNNotificationRequest(identifier: plant.id.uuidString, content: content, trigger: trigger)

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                center.add(request)
            }
        }
    }

    // إلغاء إشعار نبتة (لما احذفها)
    func cancel(for plant: Plant) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plant.id.uuidString])
    }

    private func makeTrigger(days: Int) -> UNNotificationTrigger {
        var time = DateComponents()
        time.hour = reminderHour
        time.minute = reminderMinute

        if days == 1 {
            // كل يوم الساعة 9
            return UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        } else if days == 7 {
            // كل أسبوع في نفس يوم الأسبوع اللي أضفنا فيه النبتة
            time.weekday = Calendar.current.component(.weekday, from: Date())
            return UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        } else {
            // كل يومين أو ثلاثة: يتكرر بعد المدة من وقت الحفظ
            let seconds = TimeInterval(days * 24 * 60 * 60)
            return UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: true)
        }
    }
}
