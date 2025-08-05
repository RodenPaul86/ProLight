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
    
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        
        let healthTypes: Set = [steps, calories]
        
        Task {
            do {
                try? await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
            } catch {
                print("error fetching...")
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
            let activity = cardElements(id: 0, title: "Today Steps", subtitle: "Goal 10,000", image: "figure.walk", amount: stepCount.formattedString()!)
            DispatchQueue.main.async {
                self.activites["todaySteps"] = activity
            }
            
            print(stepCount.formattedString()!)
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays calories data...")
                return
            }
            
            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let activity = cardElements(id: 1, title: "Today Calories", subtitle: "Goal 900", image: "flame", amount: caloriesBurned.formattedString()!)
            DispatchQueue.main.async {
                self.activites["todayCalories"] = activity
            }
            
            print(caloriesBurned.formattedString()!)
        }
        
        healthStore.execute(query)
    }
}

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

extension Double {
    func formattedString() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
