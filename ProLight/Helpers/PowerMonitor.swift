//
//  PowerMonitor.swift
//  ProLight
//
//  Created by Paul  on 4/23/26.
//

import SwiftUI

final class PowerMonitor: ObservableObject {
    @Published var isLowPowerMode: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    private var observer: NSObjectProtocol?
    
    init() {
        observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
