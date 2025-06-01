//
//  FlashController.swift
//  ProLight
//
//  Created by Paul  on 6/1/25.
//

import SwiftUI
import AVFoundation

class FlashController: ObservableObject {
    private var timer: Timer?
    
    func startFlashing(frequencyHz: Double, intensity: Float) {
        stopFlashing()
        
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        let interval = 1.0 / frequencyHz
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            do {
                try device.lockForConfiguration()
                if device.isTorchActive {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: intensity)
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch error: \(error)")
            }
        }
    }
    
    func updateBrightness(level: Float) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                try device.setTorchModeOn(level: level)
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to update strobe brightness: \(error)")
        }
    }
    
    func stopFlashing() {
        timer?.invalidate()
        timer = nil
        
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            print("Torch stop error: \(error)")
        }
    }
}
