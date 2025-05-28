//
//  MorseVibration.swift
//  ProLight
//
//  Created by Paul Roden II on 3/27/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import UIKit
import CoreHaptics
import SwiftAlertView

class MorseVibration: UIViewController, UITextViewDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var convertFrom: UITextView!
    @IBOutlet weak var convertedTo: UITextView!
    @IBOutlet weak var convertToMorseButton: UIButton!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var shouldRepeat: UIBarButtonItem!
    
    var repeatVibration: Bool = false
    var morseCodeText: String!
    var mapMorseCode: [String: String] = MorseCodeManager.getMorseCode()
    var engine: CHHapticEngine!
    var forceStop: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        shouldRepeat.tintColor = .darkGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
//MARK: Convert Button (Vibration)
    @IBAction func convertToMorse(_ sender: UIButton) {
        forceStop = false
        if convertToMorseButton.currentTitle == "Convert" {
            if (convertFrom.text != "") {
                cancelBtn.isEnabled = false
                convertFrom.resignFirstResponder()
                morseCodeText = convertFrom.text
                initializeString(toConvert: &morseCodeText)
                tempConvert()
                if repeatVibration == false {
                    convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode )
                } else {
                    convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode)
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
            if repeatVibration == true {
                shouldRepeat.tintColor = .darkGray
                repeatVibration = false
            }
            forceStop = true
            engine?.stop()
            convertToMorseButton.setTitle("Convert", for: .normal)
            cancelBtn.isEnabled = true
        }
    }
    
//MARK: Repeat Button
    @IBAction func enableDisableRepeat(_ sender: Any) {
        repeatVibration.toggle()
        if repeatVibration == true {
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
    
//MARK: Main Convert Function and Logic
    //Converts Text to Morse Code and palys the vibrations
    func convert(morseCodeText: String, mapMorseCode: [String:String]) {
        convertToMorseButton.setTitle("Stop", for: .normal)
        DispatchQueue.global(qos: .utility).async {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            do {
                self.engine = try CHHapticEngine()
                try self.engine?.start()
            } catch {
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
            for index in 0..<morseCodeText.length {
                let tempString = mapMorseCode[morseCodeText[index]] ?? "#"
                
                if (tempString == "/") {
                    do { usleep(720000) }
                }
                if self.forceStop == false {
                    for j in 0..<tempString.length {
                        if (tempString[j] == ".") {
                            do {usleep(30000)}
                            let dot = CHHapticEvent(eventType: .hapticTransient, parameters: [.init(parameterID: .hapticIntensity, value: 1), .init(parameterID: .hapticSharpness, value: 0.55)], relativeTime: 0)
                            do {
                                let pattern = try CHHapticPattern(events: [dot], parameters: [])
                                let player = try self.engine?.makePlayer(with: pattern)
                                try player?.start(atTime: 0)
                            } catch {
                                print("Failed to play pattern: \(error.localizedDescription).")
                            }
                        }
                        else if (tempString[j] == "-") {
                            do {usleep(30000)}
                            let dit = CHHapticEvent(eventType: .hapticContinuous, parameters: [.init(parameterID: .hapticIntensity, value: 0.81), .init(parameterID: .hapticSharpness, value: 0.8)], relativeTime: 0, duration: 0.12)
                            do {
                                let pattern = try CHHapticPattern(events: [dit], parameters: [])
                                let player = try self.engine?.makePlayer(with: pattern)
                                try player?.start(atTime: 0)
                            } catch {
                                print("Failed to play pattern: \(error.localizedDescription).")
                            }
                            do {usleep(60000)}
                        }
                        do { usleep(120000) }
                    }
                }
                do { usleep(240000) }
            }
            DispatchQueue.main.async {
                if self.repeatVibration == true {
                    do { usleep(480000) }
                    self.convert(morseCodeText: morseCodeText, mapMorseCode: mapMorseCode)
                } else {
                    self.forceStop = false
                    self.convertToMorseButton.setTitle("Convert", for: .normal)
                    self.cancelBtn.isEnabled = true
                    
                }
            }
        }
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
    
//MARK: MorseVibration Class END
}
