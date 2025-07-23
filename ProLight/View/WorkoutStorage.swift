//
//  WorkoutStorage.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import Foundation

class WorkoutStorage: ObservableObject {
    @Published var workouts: [Workout] = []
    
    private let fileURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("workouts.json")
    }()
    
    init() {
        load()
    }
    
    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Workout].self, from: data) {
            workouts = decoded
        }
    }
    
    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(workouts) {
            try? data.write(to: fileURL)
        }
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.insert(workout, at: 0)
        save()
    }
}
