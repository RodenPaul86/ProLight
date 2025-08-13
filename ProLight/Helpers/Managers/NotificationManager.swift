//
//  NotificationManager.swift
//  ProLight
//
//  Created by Paul  on 8/11/25.
//

import Foundation
import UserNotifications
import WeatherKit

@MainActor
class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    private var notifiedAlertIDs: Set<String> = []
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            print("Notifications granted: \(granted)")
        }
    }
    
    func sendWeatherAlertNotification(alert: WeatherAlert) {
        // Generate a unique ID from its properties
        
        let alertID = generateID(for: alert)
        
        if notifiedAlertIDs.contains(alertID) {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Weather Alert"
        content.body = alert.summary
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: alertID,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                self.notifiedAlertIDs.insert(alertID)
            }
        }
    }
    
    private func generateID(for alert: WeatherAlert) -> String {
        // Use the actual 'region' property, or empty string if nil
        let regionStr = alert.region ?? ""
        // Use 'issuedDate' (or what your version shows) and convert to timestamp
        let issuedTime = alert.severity
        return "\(alert.summary)-\(issuedTime)-\(regionStr)"
    }
}
