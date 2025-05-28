//
//  MorseSound.swift
//  ProLight
//
//  Created by Paul Roden II on 3/27/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftAlertView

class MorseSound: UIViewController, UITextViewDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var convertFrom: UITextView!
    @IBOutlet weak var convertedTo: UITextView!
    @IBOutlet weak var convertToMorseButton: UIButton!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var shouldRepeat: UIBarButtonItem!
    @IBOutlet weak var wpmPicker: UIPickerView!
    
    var wpm: Double = 20.0
    private let dataSource = ["20", "19", "18", "17", "16", "15"]
    var repeatSound: Bool = false
    var morseCodeText: String!
    var mapMorseCode: [String: String] = MorseCodeManager.getMorseCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wpmPicker.dataSource = self
        wpmPicker.delegate = self
        convertFrom.delegate = self
        
        convertFrom.layer.cornerRadius = 20
        convertFrom.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        convertFrom.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        convertFrom.layer.shadowOpacity = 1.0
        convertFrom.layer.shadowRadius = 5.0
        convertFrom.layer.masksToBounds = false
        convertFrom.layer.cornerRadius = 20
        
        convertedTo.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        convertedTo.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        convertedTo.layer.shadowOpacity = 1.0
        convertedTo.layer.shadowRadius = 5.0
        convertedTo.layer.masksToBounds = false
        convertedTo.layer.cornerRadius = 20
        
        convertToMorseButton.layer.cornerRadius = 15
        wpmPicker.layer.cornerRadius = 15
        wpmPicker.setValue(UIColor.white, forKey: "textColor")
        
        shouldRepeat.tintColor = .darkGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
//MARK: Convert Button (Sound)
    @IBAction func convertToMorse(_ sender: UIButton) {
        if (convertToMorseButton.currentTitle == "Convert") {
            engine.attach(srcNode)
            engine.connect(srcNode, to: mainMixer, format: inputFormat)
            engine.connect(mainMixer, to: output, format: outputFormat)
            mainMixer.outputVolume = 0.5
            if (convertFrom.text != "") {
                cancelBtn.isEnabled = false
                wpmPicker.isUserInteractionEnabled = false
                convertFrom.resignFirstResponder()
                morseCodeText = convertFrom.text
                initializeString(toConvert: &morseCodeText)
                tempConvert()
                if (repeatSound == false) {
                    convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode)
                    
                } else {
                    while repeatSound == true {
                        convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode)
                        do { usleep(480000) }
                    }
                }
            } else {
                SwiftAlertView.show(title: "No Input!",
                                    message: "Input field cannot be empty",
                                    buttonTitles: "OK") { alert in
                    alert.style = .auto
                    alert.buttonTitleColor = .systemBlue
                    alert.cancelButtonIndex = 0
                    alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
                }
            }
        } else {
            if repeatSound == true {
                shouldRepeat.tintColor = .darkGray
                repeatSound = false
            }
            engine.detach(srcNode)
            wpmPicker.isUserInteractionEnabled = true
            convertToMorseButton.setTitle("Convert", for: .normal)
            cancelBtn.isEnabled = true
        }
    }

//MARK: Repeat Button
    @IBAction func enableDisableRepeat(_ sender: Any) {
        repeatSound.toggle()
        if repeatSound == true {
            shouldRepeat.tintColor = .green
        } else {
            shouldRepeat.tintColor = .darkGray
        }
    }
    
//MARK: Dismiss Button
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
//MARK: Support Function(s)
    //Modifies Morse to display in correct format to display
    func tempConvert() {
        convertedTo.text = ""
        for index in 0..<morseCodeText.length {
            let tempString = mapMorseCode[morseCodeText[index]] ?? "#"
            convertedTo.text = convertedTo.text + " " + tempString
        }
    }
    
    //Hides keyboard when enter/done is pressed
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            convertFrom.resignFirstResponder()
            return false
        }
        return true
    }
    
    //Initializes engine to play sound
    func playSound(duration: Float) {
        do {
            try engine.start()
            CFRunLoopRunInMode(.defaultMode, CFTimeInterval(duration), false)
            engine.stop()
        } catch {
                print("Could not start engine: \(error)")
        }
    }
    
//MARK: Main Convert Function and Logic
    //Converts Text to Morse Code and palys the sound
    func convert(morseCodeText: String, mapMorseCode: [String:String]){
        convertToMorseButton.setTitle("Stop", for: .normal)
        
        let msTime: Int = Int(duration * 1000000)
        for index in 0..<morseCodeText.length {
            let tempString = mapMorseCode[morseCodeText[index]] ?? "#"
            if (tempString == "/") {
                do { usleep(useconds_t(msTime*6)) }
            }
            for j in 0..<tempString.length {
                if (tempString[j] == ".") {
                    playSound(duration: duration)
                }
                else if (tempString[j] == "-") {
                    playSound(duration: (duration * 3))
                }
                do { usleep(useconds_t(msTime)) }
            }
            do { usleep(useconds_t(msTime*2)) }
        }
        wpmPicker.isUserInteractionEnabled = true
        convertToMorseButton.setTitle("Convert", for: .normal)
        cancelBtn.isEnabled = true
    }

//MARK: objC Function(s)
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            if notification.name == UIResponder.keyboardWillShowNotification {
                convertFrom.frame.origin.y -= keyboardFrame.height
                convertFrom.frame.origin.y += 10
            }
            else if notification.name == UIResponder.keyboardWillHideNotification {
                convertFrom.frame.origin.y += keyboardFrame.height
                convertFrom.frame.origin.y -= 10
            }
        }
    }
    
//MARK: Deinitializer
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//MARK: MorseSound Class END
}

//MARK: Global Variables
let frequency: Float = 550
let amplitude: Float = min(max(0.5, 0.0), 1.0)
var duration: Float = 0.06
let twoPi = 2 * Float.pi
let sine = { (phase: Float) -> Float in
    return sin(phase)
}
var signal: (Float) -> Float = sine
let engine = AVAudioEngine()
let mainMixer = engine.mainMixerNode
let output = engine.outputNode
let outputFormat = output.inputFormat(forBus: 0)
let sampleRate = Float(outputFormat.sampleRate)
let inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                sampleRate: outputFormat.sampleRate,
                                channels: 1,
                                interleaved: outputFormat.isInterleaved)
var currentPhase: Float = 0
let phaseIncrement = (twoPi / sampleRate) * frequency

let srcNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
    let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
    for frame in 0..<Int(frameCount) {
        let value = signal(currentPhase) * amplitude
        currentPhase += phaseIncrement
        if currentPhase >= twoPi {
            currentPhase -= twoPi
        }
        if currentPhase < 0.0 {
            currentPhase += twoPi
        }
        for buffer in ablPointer {
            let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
            buf[frame] = value
        }
    }
    return noErr
}

extension MorseSound: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        wpm = Double(dataSource[row]) ?? 20
        duration = Float(60 / (50 * wpm))
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = "\(dataSource[row]) WPM"
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        return myTitle
    }
}
