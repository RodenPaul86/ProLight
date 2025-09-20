//
//  HealthManager.swift
//  ProLight
//
//  Created by Paul  on 8/5/25.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var activities: [String : cardElements] = [:]
    @Published var orderedActivities: [cardElements] = []
    
    @Published var mockActivites: [String : cardElements] = [
        "todaySteps" : cardElements(id: 0, title: "Steps", subtitle: "Steps", image: "shoeprints.fill", tintColor: .green, amount: "12,123"),
        "todayCalories" : cardElements(id: 1, title: "Calories", subtitle: "Burned", image: "flame", tintColor: .red, amount: "900 kcal"),
        "weekRunning" : cardElements(id: 2, title: "Running", subtitle: "Running", image: "figure.run", tintColor: .blue, amount: "90 min"),
        "todayStairs" : cardElements(id: 3, title: "Stairs", subtitle: "Flights Climbed",image: "figure.stairs", tintColor: .orange, amount: "2"),
        "todayWalkingDistance" : cardElements(id: 4, title: "Distance", subtitle: "Distance", image: "map", tintColor: .blue, amount: "1.05 km"),
        "todayWalkingSpeed" : cardElements(id: 5, title: "Speed", subtitle: "Average Speed", image: "speedometer", tintColor: .purple, amount: "3 mph"),
        "todayHeartRate" : cardElements(id: 6, title: "Heart Rate", subtitle: "Average Today", image: "heart.fill", tintColor: .pink, amount: "72 bpm")
    ]
    
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let flights = HKQuantityType(.flightsClimbed)
        let walkingDistance = HKQuantityType(.distanceWalkingRunning)
        let walkingSpeed = HKQuantityType(.walkingSpeed)
        let workout = HKObjectType.workoutType()
        let heartRate = HKQuantityType(.heartRate)
        
        let healthTypes: Set = [steps, calories, flights, walkingDistance, walkingSpeed, workout, heartRate]
        
        Task {
            do {
                try? await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
                fetchTodayStairsClimbed()
                fetchCurrentWeekWorkoutStats()
                fetchTodayWalkingDistance()
                fetchTodayWalkingSpeed()
                fetchTodayHeartRate()
            } catch {
                print("error fetching health data...")
            }
        }
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            var displayAmount: String
            
            if let error = error {
                print("error fetching todays step count: \(error.localizedDescription)")
                displayAmount = "Error"
            } else if let quantity = result?.sumQuantity() {
                let stepCount = quantity.doubleValue(for: .count())
                displayAmount = stepCount.formattedString() ?? "0"
                print(stepCount.formattedString())
            } else {
                // No data for today
                displayAmount = "No Data"
            }
            
            let activity = cardElements(
                id: 0,
                title: "Steps",
                subtitle: "Steps",
                image: "shoeprints.fill",
                tintColor: .green,
                amount: displayAmount
            )
            
            DispatchQueue.main.async {
                self.activities["todaySteps"] = activity
            }
        }
        healthStore.execute(query)
    }
    
    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            
            var displayAmount = "No Data"
            
            if let error = error {
                print("Error fetching calories: \(error.localizedDescription)")
            } else if let caloriesBurned = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                displayAmount = caloriesBurned.formattedString()!
            }
            
            let activity = cardElements(id: 1, title: "Calories", subtitle: "Burned", image: "flame", tintColor: .red, amount: "\(displayAmount) kcal")
            
            DispatchQueue.main.async {
                self.activities["todayCalories"] = activity
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayStairsClimbed() {
        let flights = HKQuantityType(.flightsClimbed)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: flights, quantitySamplePredicate: predicate) { _, result, error in
            
            var displayAmount = "No Data"
            
            if let error = error {
                print("Error fetching stairs climbed: \(error.localizedDescription)")
            } else if let flightsCount = result?.sumQuantity()?.doubleValue(for: .count()) {
                displayAmount = flightsCount.formattedString()!
            }
            
            let activity = cardElements(id: 3, title: "Stairs", subtitle: "Flights Climbed", image: "figure.stairs", tintColor: .orange, amount: displayAmount)
            
            DispatchQueue.main.async {
                self.activities["todayStairs"] = activity
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayWalkingDistance() {
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate) { _, result, error in
            
            var displayAmount = "No Data"
            
            if let error = error {
                print("Error fetching walking distance: \(error.localizedDescription)")
            } else if let distance = result?.sumQuantity()?.doubleValue(for: .meter()) {
                displayAmount = String(format: "%.2f km", distance / 1000)
            }
            
            let activity = cardElements(id: 4, title: "Distance", subtitle: "Distance", image: "map", tintColor: .blue, amount: displayAmount)
            
            DispatchQueue.main.async {
                self.activities["todayWalkingDistance"] = activity
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayWalkingSpeed() {
        let speedType = HKQuantityType(.walkingSpeed)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKSampleQuery(sampleType: speedType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            
            var displayAmount = "No Data"
            
            if let error = error {
                print("Error fetching walking speed samples: \(error.localizedDescription)")
            } else if let speedSamples = samples as? [HKQuantitySample], !speedSamples.isEmpty {
                // Calculate average speed from all samples
                let totalSpeed = speedSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: .meter().unitDivided(by: .second())) }
                let averageSpeed = totalSpeed / Double(speedSamples.count)
                let mph = averageSpeed * 2.23694 // convert m/s to mph
                
                displayAmount = String(format: "%.2f mph", mph)
            }
            
            let activity = cardElements(id: 5, title: "Speed", subtitle: "Average Speed", image: "speedometer", tintColor: .purple, amount: displayAmount)
            
            DispatchQueue.main.async {
                self.activities["todayWalkingSpeed"] = activity
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayHeartRate() {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            
            var displayAmount = "No Data"
            
            if let error = error {
                print("Error fetching heart rate: \(error.localizedDescription)")
            } else if let hrSamples = samples as? [HKQuantitySample], !hrSamples.isEmpty {
                let totalHR = hrSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) }
                let avgHR = totalHR / Double(hrSamples.count)
                displayAmount = String(format: "%.0f bpm", avgHR)
            }
            
            let activity = cardElements(id: 6, title: "Heart Rate", subtitle: "Average Today", image: "heart.fill", tintColor: .pink, amount: displayAmount)
            
            DispatchQueue.main.async {
                self.activities["todayHeartRate"] = activity
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchCurrentWeekWorkoutStats() {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        
        let query = HKSampleQuery(sampleType: workout, predicate: timePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, sample, error in
            if let error = error {
                print("Error fetching week running data: \(error.localizedDescription)")
                return
            }
            
            guard let workouts = sample as? [HKWorkout], !workouts.isEmpty else {
                let activity = cardElements(id: 2, title: "Running", subtitle: "Data from Watch", image: "figure.run", tintColor: .blue, amount: "No Data")
                DispatchQueue.main.async {
                    self.activities["weekRunning"] = activity
                }
                return
            }
            
            var runningCount: Int = 0
            for workout in workouts {
                if workout.workoutActivityType == .running {
                    let duration = Int(workout.duration) / 60
                    runningCount += duration
                }
            }
            
            let activity = cardElements(id: 2, title: "Running", subtitle: "Weekly Run", image: "figure.run", tintColor: .blue, amount: "\(runningCount) min")
            
            DispatchQueue.main.async {
                self.activities["weekRunning"] = activity
            }
        }
        
        healthStore.execute(query)
    }
}

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        
        return calendar.date(from: components)!
    }
}

extension Double {
    func formattedString() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self)) ?? nil
    }
}
