//
//  HealthKitManager.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func startWorkoutSession() {
        // Add real HKWorkoutSession if needed. This is a stub for now.
        print("HealthKit workout session started")
    }
    
    func endWorkoutSession() {
        print("HealthKit workout session ended")
    }
}
