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
    
    @Published var activites: [String : cardElements] = [:]
    
    @Published var mockActivites: [String : cardElements] = [
        "todaySteps" : cardElements(id: 0, title: "Steps", subtitle: "Steps", image: "shoeprints.fill", tintColor: .green, amount: "12,123"),
        "todayCalories" : cardElements(id: 1, title: "Calories", subtitle: "Burned", image: "flame", tintColor: .red, amount: "900 kcal"),
        "weekRunning" : cardElements(id: 2, title: "Running", subtitle: "Running", image: "figure.run", tintColor: .blue, amount: "90 min"),
        "todayStairs" : cardElements(id: 3, title: "Stairs", subtitle: "Flights Climbed",image: "figure.stairs", tintColor: .orange, amount: "2"),
        "todayWalkingDistance" : cardElements(id: 4, title: "Distance", subtitle: "Distance", image: "map", tintColor: .blue, amount: "1.05 km"),
        "todayWalkingSpeed" : cardElements(id: 5, title: "Speed", subtitle: "Average Speed", image: "speedometer", tintColor: .purple, amount: "3 mph")
    ]
    
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let flights = HKQuantityType(.flightsClimbed)
        let walkingDistance = HKQuantityType(.distanceWalkingRunning)
        let walkingSpeed = HKQuantityType(.walkingSpeed)
        let workout = HKObjectType.workoutType()
        
        let healthTypes: Set = [steps, calories, flights, walkingDistance, walkingSpeed, workout]
        
        Task {
            do {
                try? await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
                fetchTodayStairsClimbed()
                fetchCurrentWeekWorkoutStats()
                fetchTodayWalkingDistance()
                fetchTodayWalkingSpeed()
            } catch {
                print("error fetching health data...")
            }
        }
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays step count...")
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            let displayAmount = stepCount.formattedString() ?? "No Data"
            let activity = cardElements(id: 0, title: "Steps", subtitle: "Steps", image: "shoeprints.fill", tintColor: .green, amount: displayAmount)
            
            DispatchQueue.main.async {
                self.activites["todaySteps"] = activity
            }
            
            print(stepCount.formattedString())
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
                self.activites["todayCalories"] = activity
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
                self.activites["todayStairs"] = activity
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
                self.activites["todayWalkingDistance"] = activity
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
                self.activites["todayWalkingSpeed"] = activity
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
                    self.activites["weekRunning"] = activity
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
                self.activites["weekRunning"] = activity
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
