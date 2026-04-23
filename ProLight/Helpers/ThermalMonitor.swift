//
//  ThermalMonitor.swift
//  ProLight
//
//  Created by Paul  on 4/23/26.
//

import SwiftUI

final class ThermalMonitor: ObservableObject {
    @Published var thermalState: ProcessInfo.ThermalState = .nominal
    
    private var observer: NSObjectProtocol?
    
    init() {
        // Apple notes you should read thermalState before registering
        thermalState = ProcessInfo.processInfo.thermalState
        
        observer = NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.thermalState = ProcessInfo.processInfo.thermalState
        }
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var borderColor: Color {
        switch thermalState {
        case .nominal:
            return .clear
        case .fair:
            return .yellow
        case .serious:
            return .orange
        case .critical:
            return .red
        @unknown default:
            return .gray
        }
    }
    
    var borderWidth: CGFloat {
        switch thermalState {
        case .nominal:
            return 0
        case .fair:
            return 3
        case .serious:
            return 5
        case .critical:
            return 7
        @unknown default:
            return 3
        }
    }
}
