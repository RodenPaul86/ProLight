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
    
    // MARK: - Steps
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            var displayAmount: String
            if let quantity = result?.sumQuantity() {
                displayAmount = quantity.doubleValue(for: .count()).formattedString() ?? "0"
            } else {
                displayAmount = error != nil ? "No data" : "0"
            }
            
            // Fetch 7-day weekly totals
            self.fetchWeeklyData(for: steps, unit: .count()) { weeklyValues in
                let activity = cardElements(
                    id: 0, title: "Steps", subtitle: "Steps",
                    image: "shoeprints.fill", tintColor: .green,
                    amount: displayAmount, weeklyData: weeklyValues
                )
                DispatchQueue.main.async { self.activities["todaySteps"] = activity }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Calories
    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            let burned = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            let displayAmount = burned > 0 ? "\(burned.formattedString()!) kcal" : "No data"
            
            self.fetchWeeklyData(for: calories, unit: .kilocalorie()) { weeklyValues in
                let activity = cardElements(
                    id: 1, title: "Calories", subtitle: "Burned",
                    image: "flame", tintColor: .red,
                    amount: displayAmount, weeklyData: weeklyValues
                )
                DispatchQueue.main.async { self.activities["todayCalories"] = activity }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Stairs
    func fetchTodayStairsClimbed() {
        let flights = HKQuantityType(.flightsClimbed)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: flights, quantitySamplePredicate: predicate) { _, result, error in
            let count = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            let displayAmount = count > 0 ? count.formattedString()! : "No data"
            
            self.fetchWeeklyData(for: flights, unit: .count()) { weeklyValues in
                let activity = cardElements(
                    id: 3, title: "Stairs", subtitle: "Flights Climbed",
                    image: "figure.stairs", tintColor: .orange,
                    amount: displayAmount, weeklyData: weeklyValues
                )
                DispatchQueue.main.async { self.activities["todayStairs"] = activity }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Walking Distance
    func fetchTodayWalkingDistance() {
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate) { _, result, error in
            let meters = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
            let displayAmount = meters > 0 ? String(format: "%.2f km", meters / 1000) : "No data"

            self.fetchWeeklyData(for: distanceType, unit: .meter()) { weeklyValues in
                // Convert each day's meters → km for display
                let kmValues = weeklyValues.map { $0 / 1000 }
                let activity = cardElements(
                    id: 4, title: "Distance", subtitle: "Distance",
                    image: "map", tintColor: .blue,
                    amount: displayAmount, weeklyData: kmValues
                )
                DispatchQueue.main.async { self.activities["todayWalkingDistance"] = activity }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Walking Speed
    func fetchTodayWalkingSpeed() {
        let speedType = HKQuantityType(.walkingSpeed)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let mps = HKUnit.meter().unitDivided(by: .second())
        
        let query = HKSampleQuery(sampleType: speedType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            var displayAmount = "No data"
            if let speedSamples = samples as? [HKQuantitySample], !speedSamples.isEmpty {
                let total = speedSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: mps) }
                let mph = (total / Double(speedSamples.count)) * 2.23694
                displayAmount = String(format: "%.2f mph", mph)
            }
            
            self.fetchWeeklyData(for: speedType, unit: mps, options: .discreteAverage) { weeklyValues in
                let mphValues = weeklyValues.map { $0 * 2.23694 }
                let activity = cardElements(
                    id: 5, title: "Speed", subtitle: "Average Speed",
                    image: "speedometer", tintColor: .purple,
                    amount: displayAmount, weeklyData: mphValues
                )
                DispatchQueue.main.async { self.activities["todayWalkingSpeed"] = activity }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Heart Rate
    func fetchTodayHeartRate() {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let bpm = HKUnit.count().unitDivided(by: .minute())
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            var displayAmount = "No data"
            if let hrSamples = samples as? [HKQuantitySample], !hrSamples.isEmpty {
                let total = hrSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: bpm) }
                displayAmount = String(format: "%.0f bpm", total / Double(hrSamples.count))
            }
            
            self.fetchWeeklyData(for: heartRateType, unit: bpm, options: .discreteAverage) { weeklyValues in
                let activity = cardElements(
                    id: 6, title: "Heart Rate", subtitle: "Average Today",
                    image: "heart.fill", tintColor: .pink,
                    amount: displayAmount, weeklyData: weeklyValues
                )
                DispatchQueue.main.async { self.activities["todayHeartRate"] = activity }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: Running
    func fetchCurrentWeekWorkoutStats() {
        let workout = HKSampleType.workoutType()
        // Extend lookback to 7 days to match the other charts
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: .startOfDay)!
        let timePredicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKSampleQuery(sampleType: workout, predicate: timePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, sample, error in
            if let error = error {
                print("Error fetching week running data: \(error.localizedDescription)")
                return
            }
            
            let workouts = (sample as? [HKWorkout] ?? []).filter { $0.workoutActivityType == .running }
            
            // Total minutes this week (existing behaviour)
            let runningCount = workouts.reduce(0) { $0 + Int($1.duration) / 60 }
            let displayAmount = runningCount > 0 ? "\(runningCount) min" : "No data"
            
            // Build a [Double] of daily minutes over the last 7 days
            let calendar = Calendar.current
            var dailyMinutes: [Double] = Array(repeating: 0, count: 7)
            
            for w in workouts {
                // How many days ago did this workout start? (0 = today, 6 = 6 days ago)
                let daysAgo = calendar.dateComponents([.day], from: calendar.startOfDay(for: w.startDate), to: .startOfDay).day ?? 0
                let index = 6 - daysAgo   // index 0 = 6 days ago, index 6 = today
                if index >= 0 && index < 7 {
                    dailyMinutes[index] += Double(Int(w.duration) / 60)
                }
            }
            
            let activity = cardElements(
                id: 2,
                title: "Running",
                subtitle: runningCount > 0 ? "Weekly Run" : "Data from Watch",
                image: "figure.run",
                tintColor: .blue,
                amount: displayAmount,
                weeklyData: dailyMinutes
            )
            
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

// MARK: - Fetch Helper
extension HealthManager {
    /// Fetches the last 7 days of daily totals for a given quantity type.
    /// Returns an array of 7 Doubles ordered Monday → today.
    private func fetchWeeklyData(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        options: HKStatisticsOptions = .cumulativeSum,
        completion: @escaping ([Double]) -> Void
    ) {
        let calendar = Calendar.current
        
        // Build exactly 7 day-start dates: [6 days ago ... today]
        let today = calendar.startOfDay(for: Date())
        let dayStarts: [Date] = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: -6 + $0, to: today)
        }
        
        let startDate = dayStarts.first!
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)! // end of today
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: startDate, // anchor = exactly 6 days ago midnight
            intervalComponents: interval
        )
        
        let handle: (HKStatisticsCollection) -> Void = { results in
            // Map each known date to its bucket value — always exactly 7 entries
            let values: [Double] = dayStarts.map { day in
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: day)!
                if let stats = results.statistics(for: day) {
                    if options == .cumulativeSum {
                        return stats.sumQuantity()?.doubleValue(for: unit) ?? 0
                    } else {
                        return stats.averageQuantity()?.doubleValue(for: unit) ?? 0
                    }
                }
                return 0
            }
            completion(values)
        }
        
        query.initialResultsHandler = { _, results, _ in
            guard let results else { return }
            handle(results)
        }
        
        query.statisticsUpdateHandler = { _, _, results, _ in
            guard let results else { return }
            handle(results)
        }
        
        healthStore.execute(query)
    }
}
