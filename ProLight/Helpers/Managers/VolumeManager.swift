//
//  VolumeManager.swift
//  ProLight
//
//  Created by Paul  on 2/28/26.
//

import SwiftUI
import MediaPlayer
import AVFoundation

final class VolumeManager {
    
    private static var previousVolume: Float?
    
    // Save current volume
    static func saveCurrentVolume() {
        previousVolume = AVAudioSession.sharedInstance().outputVolume
    }
    
    // Set system volume
    static func setSystemVolume(to value: Float) {
        let volumeView = MPVolumeView(frame: .zero)
        
        if let slider = volumeView.subviews.compactMap({ $0 as? UISlider }).first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                slider.value = min(max(value, 0.0), 1.0)
            }
        }
    }
    
    // Restore previous volume
    static func restoreVolume() {
        guard let previousVolume else { return }
        setSystemVolume(to: previousVolume)
    }
}
