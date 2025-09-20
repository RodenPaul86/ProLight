//
//  MorseTranslatorView.swift
//  ProLight
//
//  Created by Paul  on 9/18/25.
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - Morse Translator View with Audio & Separator Options

struct MorseTranslatorWithAudioView: View {
    @StateObject private var vm = MorseAudioViewModel()
    @State private var showingShare = false
    @State private var shareText: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Mode + separator
                HStack {
                    Picker("", selection: $vm.mode) {
                        ForEach(MorseAudioViewModel.Mode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                    
                    Menu {
                        Picker("Letter separator", selection: $vm.separatorMode) {
                            ForEach(MorseAudioViewModel.SeparatorMode.allCases, id: \.self) {
                                Text($0.label).tag($0)
                            }
                        }
                    } label: {
                        Label("Separator", systemImage: "ellipsis.circle")
                    }
                }
                .padding(.horizontal)
                
                // Input
                Group {
                    Text("Input").font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                    TextEditor(text: $vm.input)
                        .padding(8)
                        .frame(minHeight: 120)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.2)))
                        .padding(.horizontal)
                }
                
                
                HStack {
                    Button(action: vm.swap) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.2)))
                    }
                    
                    Button(action: { UIPasteboard.general.string = vm.input }) {
                        Image(systemName: "doc.on.doc")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.2)))
                    }
                    
                    Button(action: {
                        vm.clear()
                    }) {
                        Image(systemName: "trash")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.2)))
                    }
                    
                    Button(action: {
                        UIApplication.shared.dismissKeyboard()
                        vm.computeTranslation()
                        if vm.isFlashEnabled == true {
                            vm.flashCurrentOutput()
                        }
                    }) {
                        Label("Translate", systemImage: "captions.bubble")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.2)))
                    }
                }
                .padding(.horizontal)
                
                // Output
                Group {
                    Text("Output").font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                    ScrollView {
                        Text(vm.output).frame(maxWidth: .infinity, alignment: .leading).padding(12)
                    }
                    .frame(minHeight: 120)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.2)))
                    .padding(.horizontal)
                }
                
                // Controls: WPM + Play
                HStack {
                    VStack(alignment: .leading) {
                        Text("WPM: \(vm.wpm)")
                        Slider(value: $vm.wpmDouble, in: 5...40, step: 1)
                            .frame(minWidth: 180)
                            .onChange(of: vm.wpmDouble) { _, _ in vm.updateWPM() }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if vm.isPlaying { vm.stopPlayback() } else { vm.playCurrentOutput() }
                    }) {
                        Label(vm.isPlaying ? "Stop" : "Play", systemImage: vm.isPlaying ? "stop.fill" : "play.fill")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.primary))
                    }
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button(action: { UIPasteboard.general.string = vm.output }) {
                        Image(systemName: "doc.on.doc")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.2)))
                    }
                    
                    Button(action: {
                        shareText = vm.output
                        showingShare = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    Text("letter sep: \(vm.letterSeparatorDescription)").font(.caption).foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Morse Code")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { vm.isFlashEnabled.toggle() }) {
                    Image(systemName:vm.isFlashEnabled ? "bolt.fill" : "bolt.slash")
                }
            }
        }
        .onAppear { vm.start() }
        .sheet(isPresented: $showingShare) {
            ActivityViewController(activityItems: [shareText])
        }
    }
}

extension MorseAudioViewModel {
    func flashCurrentOutput() {
        guard !output.isEmpty else { return }
        flashMorse(output)
    }
    
    private func flashMorse(_ morse: String) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        let dotDuration = 1.2 / Double(wpm)   // same as audio
        let dashDuration = dotDuration * 3
        let intraElementGap = dotDuration
        let interLetterGap = dotDuration * 3
        let interWordGap = dotDuration * 7
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try device.lockForConfiguration()
                
                func flash(on: Bool, duration: TimeInterval) {
                    if on {
                        try? device.setTorchModeOn(level: 1.0) // full brightness
                    } else {
                        device.torchMode = .off
                    }
                    Thread.sleep(forTimeInterval: duration)
                }
                
                let normalized = morse
                    .replacingOccurrences(of: "·", with: ".")
                    .replacingOccurrences(of: "−", with: "-")
                
                var i = 0
                let chars = Array(normalized)
                while i < chars.count {
                    let ch = chars[i]
                    switch ch {
                    case ".":
                        flash(on: true, duration: dotDuration)
                        flash(on: false, duration: intraElementGap)
                    case "-":
                        flash(on: true, duration: dashDuration)
                        flash(on: false, duration: intraElementGap)
                    case " ":
                        flash(on: false, duration: interLetterGap)
                    case "/":
                        flash(on: false, duration: interWordGap)
                    default:
                        flash(on: false, duration: interLetterGap)
                    }
                    i += 1
                }
                
                device.torchMode = .off
                device.unlockForConfiguration()
            } catch {
                print("Torch error: \(error)")
            }
        }
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - ViewModel
final class MorseAudioViewModel: ObservableObject {
    enum Mode: CaseIterable {
        case encode, decode, auto
        var label: String {
            switch self { case .encode: return "Encode"; case .decode: return "Decode"; case .auto: return "Auto" }
        }
    }
    
    enum SeparatorMode: CaseIterable {
        case singleSpace, doubleSpace, slash
        var label: String {
            switch self {
            case .singleSpace: return "Single Space"
            case .doubleSpace: return "Double Space"
            case .slash: return "Slash ( / )"
            }
        }
        var encodeWordSeparator: String {
            switch self {
            case .singleSpace: return " " // letter separator + letter separator would yield ambiguous; we'll use single space between letters and double space between words when requested
            case .doubleSpace: return "  "
            case .slash: return " / "
            }
        }
        var decodeWordSeparators: [String] {
            switch self {
            case .singleSpace: return ["   ", " / ", "  "] // be lenient: 3 spaces, slash, 2 spaces
            case .doubleSpace: return ["  ", " / "]
            case .slash: return [" / ", "  ", "   "]
            }
        }
    }
    
    // MARK: Published
    @Published var input: String = "Enter text or Morse code" { didSet { publishInputChange() } }
    @Published private(set) var output: String = ""
    @Published var mode: Mode = .auto { didSet { computeTranslation() } }
    @Published var autoTranslate: Bool = true
    @Published var separatorMode: SeparatorMode = .slash { didSet { computeTranslation() } }
    @Published var isFlashEnabled: Bool = false
    
    // WPM controls (exposed as Double for Slider)
    @Published var wpm: Int = 18 { didSet { updateDurations() } }
    var wpmDouble: Double {
        get { Double(wpm) }
        set { wpm = Int(newValue) }
    }
    
    // Playback state
    @Published private(set) var isPlaying: Bool = false
    
    // Morse engine
    private var cancellables = Set<AnyCancellable>()
    private var player: MorsePlayer?
    
    // computed separator descriptions
    var letterSeparatorDescription: String {
        return "letters: space, words: " + (separatorMode == .slash ? "/": (separatorMode == .doubleSpace ? "two spaces" : "single space"))
    }
    
    init() {
        computeTranslation()
        updateDurations()
    }
    
    func start() {
        player = MorsePlayer()
        updateDurations()
    }
    
    func toggleAutoTranslate() {
        autoTranslate.toggle()
        computeTranslation()
    }
    
    func clear() {
        input = ""
        output = ""
    }
    
    // MARK: - Audio control
    
    func updateWPM() {
        // slider changed
        updateDurations()
    }
    
    private func updateDurations() {
        player?.wpm = wpm
    }
    
    // MARK: - Translation
    
    private func publishInputChange() {
        if autoTranslate {
            Just(input)
                .debounce(for: .milliseconds(180), scheduler: RunLoop.main)
                .sink { [weak self] _ in self?.computeTranslation() }
                .store(in: &cancellables)
        } else {
            computeTranslationIfNeeded()
        }
    }
    
    private func computeTranslationIfNeeded() { computeTranslation() }
    
    func computeTranslation() {
        switch mode {
        case .encode: output = MorseCoder.encodeToMorse(input, separatorMode: separatorMode)
        case .decode: output = MorseCoder.decodeFromMorse(input, separatorMode: separatorMode)
        case .auto:
            let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { output = "" ; return }
            // If it looks like morse (only . - / space) -> decode
            let morseAllowed = CharacterSet(charactersIn: ".-/ ·− ").isSuperset(of: CharacterSet(charactersIn: trimmed))
            if morseAllowed && trimmed.rangeOfCharacter(from: CharacterSet.letters.union(.decimalDigits)) == nil {
                output = MorseCoder.decodeFromMorse(input, separatorMode: separatorMode)
            } else {
                output = MorseCoder.encodeToMorse(input, separatorMode: separatorMode)
            }
        }
    }
    
    func swap() {
        let oldInput = input
        input = output
        output = oldInput
        if mode == .encode { mode = .decode }
        else if mode == .decode { mode = .encode }
    }
    
    // MARK: - Audio control
    
    func playCurrentOutput() {
        guard !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if isPlaying { stopPlayback(); return }
        player?.wpm = wpm
        isPlaying = true
        player?.play(morse: output, separatorMode: separatorMode) { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
            }
        }
    }
    
    func stopPlayback() {
        player?.stop()
        isPlaying = false
    }
}

// MARK: - Morse Encoding / Decoding utilities (separator-aware)

struct MorseCoder {
    // mapping uppercase character to morse using dots and dashes (dot = ".", dash = "-")
    static let charToMorse: [Character: String] = [
        "A": ".-","B":"-...","C":"-.-.","D":"-..","E":".","F":"..-.","G":"--.","H":"....",
        "I":"..","J":".---","K":"-.-","L":".-..","M":"--","N":"-.","O":"---","P":".--.",
        "Q":"--.-","R":".-.","S":"...","T":"-","U":"..-","V":"...-","W":".--","X":"-..-",
        "Y":"-.--","Z":"--..",
        "0":"-----","1":".----","2":"..---","3":"...--","4":"....-","5":".....",
        "6":"-....","7":"--...","8":"---..","9":"----.",
        ".":".-.-.-",",":"--..--","?":"..--..","'":".----.","!":"-.-.--","/":"-..-.",
        "(":"-.--.",")":"-.--.-","&":".-... ",":":"---...",";":"-.-.-.","=":"-...-",
        "+":".-.-.", "-":"-....-","_":"..--.-","\"":".-..-.","$":"...-..-","@":".--.-."
    ]
    
    static let morseToChar: [String: Character] = {
        var dict = [String: Character]()
        for (c, m) in charToMorse { dict[m] = c }
        return dict
    }()
    
    // Encodes text into morse with configurable separators
    static func encodeToMorse(_ text: String, separatorMode: MorseAudioViewModel.SeparatorMode) -> String {
        let words = text.uppercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let encodedWords = words.map { word -> String in
            let letters = Array(word)
            let encodedLetters = letters.map { char -> String in
                if let code = charToMorse[char] {
                    return code
                } else {
                    return "?" // unknown
                }
            }
            return encodedLetters.joined(separator: " ") // letters separated by single space
        }
        
        // For word separation use the chosen mode
        switch separatorMode {
        case .singleSpace:
            // use two spaces for words to reduce ambiguity between letter space and word space
            return encodedWords.joined(separator: "  ")
        case .doubleSpace:
            return encodedWords.joined(separator: "  ")
        case .slash:
            return encodedWords.joined(separator: " / ")
        }
    }
    
    // Decodes morse into text; be permissive about separators
    static func decodeFromMorse(_ morse: String, separatorMode: MorseAudioViewModel.SeparatorMode) -> String {
        let normalized = morse.replacingOccurrences(of: "·", with: ".").replacingOccurrences(of: "−", with: "-").trimmingCharacters(in: .whitespacesAndNewlines)
        // Determine word splits based on separator mode but allow multiple fallback separators
        var wordTokens: [String] = []
        switch separatorMode {
        case .slash:
            wordTokens = normalized.components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        case .doubleSpace:
            // split on 2+ spaces first, else on slash
            if normalized.contains("  ") {
                wordTokens = normalized.components(separatedBy: "  ").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            } else {
                wordTokens = normalized.components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            }
        case .singleSpace:
            // try 3+ spaces (common convention), then 2 spaces, then slash
            if normalized.contains("   ") { wordTokens = normalized.components(separatedBy: "   ").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
            else if normalized.contains("  ") { wordTokens = normalized.components(separatedBy: "  ").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
            else { wordTokens = normalized.components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
        }
        
        var decodedWords: [String] = []
        for token in wordTokens {
            let letterTokens = token.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            var decoded = ""
            for symbol in letterTokens {
                if let ch = morseToChar[symbol] {
                    decoded.append(ch)
                } else {
                    decoded.append("�")
                }
            }
            if !decoded.isEmpty { decodedWords.append(decoded) }
        }
        return decodedWords.joined(separator: " ")
    }
}

// MARK: - Morse Player (AVAudioEngine)

final class MorsePlayer {
    // Playback parameters
    var wpm: Int = 18 {
        didSet { computeDurations() }
    }
    private(set) var dotDuration: TimeInterval = 0.0 // seconds
    private var dashDuration: TimeInterval { dotDuration * 3 }
    private var intraElementGap: TimeInterval { dotDuration } // between dots/dashes in same letter
    private var interLetterGap: TimeInterval { dotDuration * 3 } // between letters
    private var interWordGap: TimeInterval { dotDuration * 7 } // between words
    
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var sampleRate: Double = 44100.0
    private var amplitude: Float = 0.3
    private var frequency: Double = 750.0
    
    private var isPlaying = false
    private var completion: (() -> Void)?
    
    init() {
        sampleRate = Double(engine.outputNode.outputFormat(forBus: 0).sampleRate)
        engine.attach(playerNode)
        let mainMixer = engine.mainMixerNode
        engine.connect(playerNode, to: mainMixer, format: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1))
        do { try engine.start() } catch {
            print("Audio engine start error:", error.localizedDescription)
        }
        computeDurations()
    }
    
    private func computeDurations() {
        // standard formula: dot = 1.2 / WPM
        dotDuration = 1.2 / Double(max(1, wpm))
    }
    
    func play(morse: String, separatorMode: MorseAudioViewModel.SeparatorMode, completion: (() -> Void)? = nil) {
        guard !isPlaying else { return }
        isPlaying = true
        self.completion = completion
        
        // Build a sequence of actions: sound for dot/dash and silent gaps for spaces/slashes
        // Normalize morse representation so that we interpret: '.' and '-' as elements; spaces separate letters; "/" separate words.
        let normalized = morse.replacingOccurrences(of: "·", with: ".").replacingOccurrences(of: "−", with: "-")
        // We'll read character-by-character but allow multi-character separators (like " / " or double spaces)
        var tokens: [PlaybackToken] = []
        
        // Tokenize respecting slash and multi-spaces
        // First replace common word separators with explicit token markers:
        var processing = normalized
        processing = processing.replacingOccurrences(of: " / ", with: " / ")
        processing = processing.replacingOccurrences(of: "/", with: " / ")
        
        // Replace runs of 2+ spaces with " / " (word gap) to be generous
        let twoOrMoreSpacesRegex = try? NSRegularExpression(pattern: " {2,}", options: [])
        processing = twoOrMoreSpacesRegex?.stringByReplacingMatches(in: processing, options: [], range: NSRange(location: 0, length: processing.utf16.count), withTemplate: " / ") ?? processing
        
        // Trim and collapse multiple single spaces between elements to single space (letter gap)
        let multiSpaceRegex = try? NSRegularExpression(pattern: " {1,}", options: [])
        processing = multiSpaceRegex?.stringByReplacingMatches(in: processing, options: [], range: NSRange(location: 0, length: processing.utf16.count), withTemplate: " ") ?? processing
        
        // Now parse tokens
        for ch in processing {
            if ch == "." {
                tokens.append(.element(.dot))
            } else if ch == "-" {
                tokens.append(.element(.dash))
            } else if ch == " " {
                tokens.append(.gap(.letter))
            } else if ch == "/" {
                tokens.append(.gap(.word))
            } else {
                // unknown -> short pause
                tokens.append(.gap(.letter))
            }
        }
        
        // Now schedule buffers according to tokens sequence
        // We'll schedule tone buffers and silent buffers sequentially using the playerNode's scheduleBuffer with startTime nil for immediate sequential playback.
        playerNode.play()
        
        // Start with an empty delay buffer? Instead schedule buffers synchronously
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        // Keep a queue of AVAudioPCMBuffer to schedule
        var buffers: [AVAudioPCMBuffer] = []
        
        func toneBuffer(duration: TimeInterval) -> AVAudioPCMBuffer {
            let frameCount = AVAudioFrameCount(max(1, Int(round(duration * sampleRate))))
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
            buffer.frameLength = frameCount
            let ptr = buffer.floatChannelData![0]
            let increment = 2.0 * Double.pi * frequency / sampleRate
            var phase = 0.0
            for i in 0..<Int(frameCount) {
                ptr[i] = Float(sin(phase) * Double(amplitude))
                phase += increment
                if phase > Double.pi * 2.0 { phase -= Double.pi * 2.0 }
            }
            return buffer
        }
        
        func silentBuffer(duration: TimeInterval) -> AVAudioPCMBuffer {
            let frameCount = AVAudioFrameCount(max(1, Int(round(duration * sampleRate))))
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
            buffer.frameLength = frameCount
            let ptr = buffer.floatChannelData![0]
            for i in 0..<Int(frameCount) { ptr[i] = 0.0 }
            return buffer
        }
        
        // Build buffers sequence with proper intra-element gaps (between dot/dash in same letter)
        var i = 0
        while i < tokens.count {
            let tok = tokens[i]
            switch tok {
            case .element(let e):
                switch e {
                case .dot:
                    buffers.append(toneBuffer(duration: dotDuration))
                case .dash:
                    buffers.append(toneBuffer(duration: dashDuration))
                }
                // after element, if next token is element (within same letter), add intra-element gap (1 dot)
                let next = (i + 1 < tokens.count) ? tokens[i + 1] : nil
                if let nextTok = next {
                    switch nextTok {
                    case .element:
                        buffers.append(silentBuffer(duration: intraElementGap))
                    case .gap(let g):
                        // if gap is letter, we will add inter-letter gap later when processing the gap token
                        break
                    }
                } else {
                    // end -> nothing
                }
            case .gap(let kind):
                switch kind {
                case .letter:
                    // inter-letter gap (3 dot units) -- but we may already have had intra-element gap; ensure at least inter-letter gap
                    buffers.append(silentBuffer(duration: interLetterGap))
                case .word:
                    buffers.append(silentBuffer(duration: interWordGap))
                }
            }
            i += 1
        }
        
        // Schedule buffers
        var delay: TimeInterval = 0
        for buf in buffers {
            playerNode.scheduleBuffer(buf, at: nil, options: [], completionHandler: nil)
            // we intentionally schedule without precise start times; AVAudioPlayerNode will play them in queued order
            // note: scheduling many buffers is okay for moderate-length morse phrases
        }
        
        // Schedule a final callback when node completes playback of queued buffers.
        // Since AVAudioPlayerNode doesn't have a clear 'completion for all buffers' callback, we'll compute total time and dispatch after that.
        let totalDuration = buffers.reduce(0) { $0 + TimeInterval(Double($1.frameLength) / sampleRate) }
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 0.05) { [weak self] in
            self?.playerNode.stop()
            self?.isPlaying = false
            completion?()
        }
    }
    
    func stop() {
        playerNode.stop()
        isPlaying = false
    }
    
    enum PlaybackToken {
        case element(Element)
        case gap(Gap)
        enum Element { case dot, dash }
        enum Gap { case letter, word }
    }
}

// MARK: - ActivityView (share sheet)

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

