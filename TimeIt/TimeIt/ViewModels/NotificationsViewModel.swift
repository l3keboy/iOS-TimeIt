//
//  NotificationsViewModel.swift
//  TimeIt
//
//  Created by Luke Hendriks on 07/07/2022.
//

import UserNotifications

class NotificationsViewModel {
    let notificationCenter = UNUserNotificationCenter.current()
    var userAllowedNotifications = false
    
    let TIMER_NOTIFICATION_IDENTIFIER = "TimerNotification"
    
    static var shared = NotificationsViewModel()
    private init() {}
    
    func requestPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { allowed, error in
            if allowed == false {
                self.userAllowedNotifications = false
            } else if allowed == true {
                self.userAllowedNotifications = true
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.userAllowedNotifications = true
            } else {
                self.userAllowedNotifications = false
            }
        }
    }
    
    func createTimerNotification(notificationDelay: Double, notificationTitle: String, notificationDescription: String) {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.subtitle = notificationDescription
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationDelay, repeats: false)
        
        let request = UNNotificationRequest(identifier: TIMER_NOTIFICATION_IDENTIFIER, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    func removeNotificationRequest(notificationIdentifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
}
