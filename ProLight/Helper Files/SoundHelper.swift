//
//  SoundHelper.swift
//  ProLight
//
//  Created by Paul on 2/28/20.
//  Copyright © 2020 Studio4Designsoftware. All rights reserved.
//

import Foundation
import AVFoundation

class SoundHelper {
    static let shared = SoundHelper()
    var audioPlayer: AVAudioPlayer?
    
    //MARK: - Start Audio
    func startSound() {
        if let bundle = Bundle.main.path(forResource: "glassButton", ofType: "wav") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.numberOfLoops = 0
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
    //MARK: - Stop Audio
    func stopSound() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.stop()
    }
    
    //MARK: - volume
    func setVolume() {
        audioPlayer?.volume = 0
    }
}
