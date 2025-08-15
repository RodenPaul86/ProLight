//
//  UltrasonicRepellentView.swift
//  ProLight
//
//  Created by Paul  on 8/15/25.
//

import SwiftUI
import AVFoundation

// MARK: - Audio Engine
final class UltrasonicRepellent: ObservableObject {
    // Public controls
    @Published var isRunning: Bool = false
    @Published var frequency: Double = 17500 { // Hz
        didSet { frequency = min(max(frequency, 12000), 21000) }
    }
    @Published var gain: Double = 0.2 { // 0.0 - 1.0 (use low defaults for safety)
        didSet { gain = min(max(gain, 0.0), 1.0) }
    }
    @Published var sweepEnabled: Bool = true
    @Published var sweepMin: Double = 15000
    @Published var sweepMax: Double = 20000
    @Published var sweepSpeed: Double = 200 // Hz per second

    // Private audio
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?

    // Phase accumulator for sine generation
    private var phase: Double = 0
    private var currentFreq: Double = 17500
    private var lastRenderTime: AVAudioTime?

    // Session setup
    func configureSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, options: [.mixWithOthers]) // mix so users can keep using other audio
        try session.setPreferredSampleRate(48_000)
        try session.setActive(true)
    }

    func start() {
        guard !isRunning else { return }
        do {
            try configureSession()
        } catch {
            print("Audio session error: \(error)")
        }

        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        phase = 0
        currentFreq = frequency

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)

            // Time delta per sample
            let dt = 1.0 / sampleRate

            // Simple sweep behavior
            var targetFreq = self.frequency
            if self.sweepEnabled {
                // If min > max, swap to be safe
                let minF = min(self.sweepMin, self.sweepMax)
                let maxF = max(self.sweepMin, self.sweepMax)
                // Bounce sweep between min and max by drifting target toward edge and flipping
                if self.currentFreq >= maxF { targetFreq = minF }
                else if self.currentFreq <= minF { targetFreq = maxF }
                else {
                    // Drift towards upper bound by sweepSpeed
                    let direction: Double = (self.currentFreq < (minF + maxF)/2) ? 1 : 1
                    targetFreq = direction > 0 ? maxF : minF
                }
                // Move currentFreq toward target with a limited slope per second
                let maxStepPerSample = self.sweepSpeed * dt
                let delta = targetFreq - self.currentFreq
                let step = max(min(delta, maxStepPerSample), -maxStepPerSample)
                self.currentFreq += step
            } else {
                self.currentFreq = targetFreq
            }

            let twoPi = 2.0 * Double.pi
            let amplitude = min(max(self.gain, 0), 1)

            for frame in 0..<frames {
                // Increment phase based on current frequency
                self.phase += (twoPi * self.currentFreq) * dt
                if self.phase > twoPi { self.phase -= twoPi }
                let sample = Float(sin(self.phase) * amplitude)

                for buffer in ablPointer {
                    let ptr = buffer.mData!.assumingMemoryBound(to: Float.self)
                    ptr[frame] = sample
                }
            }
            return noErr
        }

        self.sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            isRunning = true
        } catch {
            print("Engine start error: \(error)")
            stop()
        }

        // Observe interruptions
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    }

    func stop() {
        guard isRunning else { return }
        engine.stop()
        if let node = sourceNode { engine.detach(node) }
        sourceNode = nil
        isRunning = false
        do { try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation) } catch { }
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }

    @objc private func handleInterruption(_ note: Notification) {
        guard let info = note.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        if type == .began { stop() }
    }
}

// MARK: - SwiftUI UI
struct UltrasonicRepellentView: View {
    @StateObject private var engine = UltrasonicRepellent()
    @Environment(\.scenePhase) private var scenePhase

    // Some phones/speakers roll off above ~18 kHz. Give a practical range.
    private let minFreq: Double = 12000
    private let maxFreq: Double = 21000

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Insect Repellent (Experimental)")
                    .font(.title2).bold()
                Text("High-frequency tone often marketed to repel insects. Effectiveness is not guaranteed. Use at low volume to protect hearing.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.top)

            // Frequency control
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Frequency", systemImage: "waveform")
                    Spacer()
                    Text("\(Int(engine.frequency)) Hz")
                        .monospaced()
                        .foregroundStyle(.secondary)
                }
                Slider(value: $engine.frequency, in: minFreq...maxFreq, step: 50)
                    .disabled(engine.sweepEnabled)
                if engine.sweepEnabled {
                    Text("Frequency controlled by sweep").font(.caption).foregroundStyle(.secondary)
                }
            }

            // Sweep controls
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $engine.sweepEnabled) { Label("Sweep Frequency", systemImage: "arrow.triangle.2.circlepath") }
                Group {
                    HStack {
                        Text("Range")
                        Spacer()
                        Text("\(Int(engine.sweepMin))–\(Int(engine.sweepMax)) Hz").monospaced().foregroundStyle(.secondary)
                    }
                    RangeSlider(minValue: $engine.sweepMin, maxValue: $engine.sweepMax, bounds: minFreq...maxFreq)
                    HStack {
                        Text("Sweep Speed")
                        Spacer()
                        Text("\(Int(engine.sweepSpeed)) Hz/s").monospaced().foregroundStyle(.secondary)
                    }
                    Slider(value: $engine.sweepSpeed, in: 50...1000, step: 10)
                }
                .opacity(engine.sweepEnabled ? 1 : 0.4)
                .disabled(!engine.sweepEnabled)
            }

            // Gain control with safety hint
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Volume", systemImage: "speaker.wave.2")
                    Spacer()
                    Text(String(format: "%.0f%%", engine.gain * 100)).monospaced().foregroundStyle(.secondary)
                }
                Slider(value: $engine.gain, in: 0...0.6, step: 0.01)
                Text("Keep low to protect hearing—especially around kids & pets.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Start/Stop
            Button(action: { engine.isRunning ? engine.stop() : engine.start() }) {
                HStack(spacing: 8) {
                    Image(systemName: engine.isRunning ? "stop.fill" : "play.fill")
                    Text(engine.isRunning ? "Stop" : "Start")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(engine.isRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(radius: 4)
            }
            .padding(.top, 6)

            // Tips
            VStack(alignment: .leading, spacing: 8) {
                Label("Tips", systemImage: "lightbulb")
                    .font(.headline)
                Text("• Works best near where insects gather (doors, tent entry).\n• Try different frequency ranges; some speakers can’t output >18 kHz loudly.\n• Not a substitute for repellents or nets.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .onChange(of: scenePhase) { phase in
            if phase == .background { engine.stop() }
        }
        .onDisappear { engine.stop() }
    }
}

// MARK: - RangeSlider (simple two-thumb slider)
struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let bounds: ClosedRange<Double>

    @State private var width: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let track = geo.size.width
            let minX = position(for: minValue, in: track)
            let maxX = position(for: maxValue, in: track)

            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.2)).frame(height: 6)
                Capsule().fill(Color.accentColor).frame(width: max(0, maxX - minX), height: 6).offset(x: minX)
                Thumb().position(x: minX, y: 6)
                    .gesture(DragGesture().onChanged { g in
                        let v = value(for: g.location.x, in: track)
                        minValue = min(max(bounds.lowerBound, v), maxValue)
                    })
                Thumb().position(x: maxX, y: 6)
                    .gesture(DragGesture().onChanged { g in
                        let v = value(for: g.location.x, in: track)
                        maxValue = max(min(bounds.upperBound, v), minValue)
                    })
            }
            .frame(height: 20)
            .onAppear { width = track }
        }
        .frame(height: 24)
    }

    private func position(for value: Double, in width: CGFloat) -> CGFloat {
        guard bounds.upperBound > bounds.lowerBound else { return 0 }
        let t = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return CGFloat(t) * width
    }

    private func value(for x: CGFloat, in width: CGFloat) -> Double {
        guard width > 0 else { return bounds.lowerBound }
        let t = min(max(0, x / width), 1)
        return bounds.lowerBound + Double(t) * (bounds.upperBound - bounds.lowerBound)
    }
}

struct Thumb: View {
    var body: some View {
        Circle().fill(.background)
            .overlay(Circle().stroke(Color.secondary, lineWidth: 1))
            .frame(width: 24, height: 24)
            .shadow(radius: 1)
    }
}

// MARK: - Preview
#Preview {
    UltrasonicRepellentView()
}
