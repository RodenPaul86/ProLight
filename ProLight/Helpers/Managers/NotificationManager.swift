//
//  NotificationManager.swift
//  ProLight
//
//  Created by Paul  on 8/11/25.
//

import Foundation
import UserNotifications
import WeatherKit
import CoreLocation

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
    
    // MARK: - Weather Alerts
    func sendWeatherAlertNotification(alert: WeatherAlert) {
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
        let regionStr = alert.region ?? ""
        let issuedTime = alert.severity
        return "\(alert.summary)-\(issuedTime)-\(regionStr)"
    }
    
    // MARK: - Sunrise & Sunset
    func scheduleSunriseSunsetNotifications(for location: CLLocation) async {
        do {
            let service = WeatherService.shared
            let daily = try await service.weather(for: location, including: .daily)
            
            guard let today = daily.forecast.first else {
                print("No daily forecast available")
                return
            }
            
            if let sunrise = today.sun.sunrise {
                scheduleNotification(
                    identifier: "sunrise",
                    title: "Sunrise",
                    body: "The sun rises at \(formattedTime(from: sunrise))",
                    date: sunrise
                )
            }
            
            if let sunset = today.sun.sunset {
                scheduleNotification(
                    identifier: "sunset",
                    title: "Sunset",
                    body: "The sun sets at \(formattedTime(from: sunset))",
                    date: sunset
                )
            }
        } catch {
            print("Error fetching sunrise/sunset: \(error.localizedDescription)")
        }
    }
    
    private func scheduleNotification(identifier: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling \(identifier) notification: \(error.localizedDescription)")
            } else {
                print("\(identifier.capitalized) notification scheduled for \(date)")
            }
        }
    }
    
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
