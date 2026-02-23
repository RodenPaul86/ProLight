//
//  EmergencyToneEngine.swift
//  ProLight
//
//  Created by Paul  on 2/23/26.
//

import AVFoundation

final class EmergencyToneEngine {
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    private var currentPhase: Double = 0
    private var frequency: Double = 900
    private var isPlaying = false
    
    private let sampleRate: Double = 44100
    private let amplitude: Double = 0.95
    
    private var frequencyTimer: Timer?
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        let mainMixer = engine.mainMixerNode
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                
                let sampleVal = Float(self.amplitude * sin(2.0 * .pi * self.currentPhase))
                
                self.currentPhase += self.frequency / self.sampleRate
                
                if self.currentPhase >= 1.0 {
                    self.currentPhase -= 1.0
                }
                
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    buf[frame] = sampleVal
                }
            }
            
            return noErr
        }
        
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: mainMixer, format: format)
    }
    
    func start() {
        guard !isPlaying else { return }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            try engine.start()
            isPlaying = true
            startOscillation()
        } catch {
            print("Failed to start audio engine:", error)
        }
    }
    
    func stop() {
        frequencyTimer?.invalidate()
        frequencyTimer = nil
        engine.stop()
        isPlaying = false
    }
    
    private func startOscillation() {
        frequencyTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            self.frequency = self.frequency == 900 ? 1400 : 900
        }
    }
}
