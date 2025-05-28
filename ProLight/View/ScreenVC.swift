//
//  screenLight.swift
//  ProLight
//
//  Created by Paul on 10/4/16.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import UIKit
import SwiftUI
import Foundation
import AVFoundation
import MediaPlayer
import SwiftAlertView

class ScreenVC: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var StrobLight: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var colorSeg: UISegmentedControl!
    @IBOutlet weak var dismissBtn: UIButton!
    
    // MARK: - Variables
    var mainController: HomeVC?
    var oneTapGesture = UITapGestureRecognizer()
    var twoTapGesture = UITapGestureRecognizer()
    
    var didTap = false
    
    let defaults = UserDefaults.standard
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let home = HomeVC()
    
    // MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTap()
        
        segmentControl.setTitle("OFF", forSegmentAt: 0)
        segmentControl.setTitle("ON", forSegmentAt: 1)
        segmentControl.setTitle("Flashing", forSegmentAt: 2)
        segmentControl.setTitle("Strobing", forSegmentAt: 3)
        
        colorSeg.setTitle("White", forSegmentAt: 0)
        colorSeg.setTitle("Red", forSegmentAt: 1)
    }
    
    func setupView() {
        viewShadow(view: dismissBtn, radius: 10, opacity: 0.4, color: .black)
        
        let nonSelectedTitleText = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentControl.setTitleTextAttributes(nonSelectedTitleText, for: .normal)
        colorSeg.setTitleTextAttributes(nonSelectedTitleText, for: .normal)
        
        let selectedTitleText = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentControl.setTitleTextAttributes(selectedTitleText, for: .selected)
        colorSeg.setTitleTextAttributes(selectedTitleText, for: .selected)
        
        if traitCollection.userInterfaceStyle == .light {
            // Light mode
            self.view.backgroundColor = UIColor.white
            colorSeg.alpha = 0
            
        } else {
            // Dark mode
            self.view.backgroundColor = UIColor.red
            colorSeg.alpha = 1
        }
    }
    
    func setupTap() {
        // TAP Gesture
        oneTapGesture = UITapGestureRecognizer(target: self, action: #selector(ScreenVC.myviewTapped(_:)))
        oneTapGesture.numberOfTapsRequired = 1
        oneTapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(oneTapGesture)
        
        twoTapGesture = UITapGestureRecognizer(target: self, action: #selector(ScreenVC.hideElements(_:)))
        twoTapGesture.numberOfTapsRequired = 1
        twoTapGesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoTapGesture)
        
        view.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        seizureAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //BrightnessToggle.maxBrightness()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        voiceSpeech(message: "screen light off")
        playButtonSound()
        hapticsButton()
        
        //BrightnessToggle.restoreBrightness()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func strobController(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            voiceSpeech(message: "light off")
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            StrobLight.isHidden = true
            
            if traitCollection.userInterfaceStyle == .light {
                self.view.backgroundColor = UIColor.black
                colorSeg.alpha = 0
            } else {
                self.view.backgroundColor = UIColor.black
                colorSeg.selectedSegmentIndex = 1
                colorSeg.setEnabled(false, forSegmentAt: 0)
                colorSeg.layer.opacity = 0.5
            }
        case 1:
            voiceSpeech(message: "light on")
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            StrobLight.isHidden = true
            
            if traitCollection.userInterfaceStyle == .light {
                self.view.backgroundColor = UIColor.white
            } else {
                self.view.backgroundColor = UIColor.red
                colorSeg.selectedSegmentIndex = 1
                colorSeg.setEnabled(true, forSegmentAt: 0)
                colorSeg.layer.opacity = 1
            }
            
        case 2:
            if IAPManager.shared.isPremium() {
                voiceSpeech(message: "flashing light")
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                StrobLight.isHidden = false
                
                if traitCollection.userInterfaceStyle == .light {
                    // Light mode
                    StrobLight.animationImages = [
                        UIImage(named: "whiteScreen")!,
                        UIImage(named: "blackScreen")!
                    ]
                    colorSeg.alpha = 0
                } else {
                    // Dark mode
                    StrobLight.animationImages = [
                        UIImage(named: "redScreen")!,
                        UIImage(named: "blackScreen")!
                    ]
                    colorSeg.alpha = 0
                    colorSeg.selectedSegmentIndex = 1
                }
                StrobLight.animationDuration = 1.0
                StrobLight.startAnimating()
            } else {
                segmentControl.selectedSegmentIndex = 1
                
                var swiftUIView = payWall()
                swiftUIView.backToMainView = self
                let contentView = UIHostingController(rootView: swiftUIView)
                contentView.overrideUserInterfaceStyle = .dark
                self .present(contentView, animated: true, completion: nil)
            }
        case 3:
            if IAPManager.shared.isPremium() {
                voiceSpeech(message: "strobing light")
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                StrobLight.isHidden = false
                if traitCollection.userInterfaceStyle == .light {
                    // Light mode
                    StrobLight.animationImages = [
                        UIImage(named: "whiteScreen")!,
                        UIImage(named: "blackScreen")!
                    ]
                    colorSeg.alpha = 0
                } else {
                    // Dark mode
                    StrobLight.animationImages = [
                        UIImage(named: "redScreen")!,
                        UIImage(named: "blackScreen")!
                    ]
                    colorSeg.alpha = 0
                    colorSeg.selectedSegmentIndex = 1
                }
                StrobLight.animationDuration = 0.1
                StrobLight.startAnimating()
            } else {
                segmentControl.selectedSegmentIndex = 1
                
                var swiftUIView = payWall()
                swiftUIView.backToMainView = self
                let contentView = UIHostingController(rootView: swiftUIView)
                contentView.overrideUserInterfaceStyle = .dark
                self .present(contentView, animated: true, completion: nil)
            }
        default:
            break;
        }
    }
    
    @IBAction func screenLightColor(_ sender: UISegmentedControl) {
        switch colorSeg.selectedSegmentIndex {
        case 0:
            self.view.backgroundColor = UIColor.white
        case 1:
            self.view.backgroundColor = UIColor.red
        default:
            break;
        }
        
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        if traitCollection.userInterfaceStyle == .light {
            if self.view.backgroundColor == UIColor.white {
                voiceSpeech(message: "light off")
                self.view.backgroundColor = UIColor.black
                segmentControl.selectedSegmentIndex = 0
            } else {
                voiceSpeech(message: "light on")
                self.view.backgroundColor = UIColor.white
                segmentControl.selectedSegmentIndex = 1
            }
        } else {
            if self.view.backgroundColor == UIColor.red {
                voiceSpeech(message: "light off")
                self.view.backgroundColor = UIColor.black
                segmentControl.selectedSegmentIndex = 0
                colorSeg.selectedSegmentIndex = 1
                colorSeg.setEnabled(false, forSegmentAt: 0)
                colorSeg.layer.opacity = 0.5
                
                if segmentControl.alpha == 0 {
                    colorSeg.alpha = 0
                    
                }
                
            } else {
                voiceSpeech(message: "light on")
                self.view.backgroundColor = UIColor.red
                segmentControl.selectedSegmentIndex = 1
                colorSeg.setEnabled(true, forSegmentAt: 0)
                colorSeg.layer.opacity = 1.0
                
                if segmentControl.alpha == 0 {
                    colorSeg.alpha = 0
                }
            }
        }
    }
    
    @objc func hideElements(_ sender: UITapGestureRecognizer) {
        didTap = !didTap
        if didTap {
            fadeOut()
        } else {
            fadeIn()
        }
    }
}

extension ScreenVC {
    func seizureAlert() {
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set("No", forKey:"isFirstTime")
            
            SwiftAlertView.show(title: "Important: Seizure Warning",
                                message: "This application contains visual elements that may trigger seizures or cause discomfort for individuals with photosensitive epilepsy or other similar conditions. If you have a history of seizures or are prone to experiencing discomfort due to visual stimuli, please exercise caution while using this app.",
                                buttonTitles: "Got it") { alert in
                alert.style = .auto
                alert.buttonTitleColor = .systemBlue
                alert.cancelButtonIndex = 0
                alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
            }
        }
    }
    
    func voiceSpeech(message: String) {
        if UserDefaults.standard.value(forKey: "stateOfVoice") != nil {
            let switchOn: Bool = UserDefaults.standard.value(forKey: "stateOfVoice") as! Bool
            
            if switchOn == true {
                let message = message
                let speechUtterance = AVSpeechUtterance(string: message)
                speechSynthesizer.speak(speechUtterance)
            } else if switchOn == false {
                
            }
        }
    }
    
    func playButtonSound() {
        if UserDefaults.standard.value(forKey: "stateOfSound") != nil {
            let switchOn: Bool = UserDefaults.standard.value(forKey: "stateOfSound") as! Bool
            
            if switchOn == true {
                SoundHelper.shared.stopSound()
            } else if switchOn == false {
                SoundHelper.shared.startSound()
            }
        } else {
            SoundHelper.shared.startSound()
        }
    }
    
    func hapticsButton() {
        if defaults.value(forKey: "stateOfHaptics") != nil {
            let switchOn: Bool = defaults.value(forKey: "stateOfHaptics") as! Bool
            
            if switchOn == true {
                print("no haptics")
            } else if switchOn == false {
                buttonVibration(style: .rigid)
            }
        } else {
            buttonVibration(style: .rigid)
        }
    }
    
    func SOSView(shortInterval: Float, longInterval: Float, pauseInterval: Float, sequencePauseInterval: Float) {
        
    }
    
    func animate(_ animatedView: UIView?, afterDelay delay: Float) {
        
    }
    
}


extension ScreenVC {
    func fadeIn(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            if self.traitCollection.userInterfaceStyle == .light {
                self.segmentControl.alpha = 1.0
                self.dismissBtn.alpha = 1.0
            } else {
                self.segmentControl.alpha = 1.0
                self.dismissBtn.alpha = 1.0
                self.colorSeg.alpha = 1.0
            }
        })
    }
    
    func fadeOut(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            if self.traitCollection.userInterfaceStyle == .light {
                self.segmentControl.alpha = 0.0
                self.dismissBtn.alpha = 0.0
                self.colorSeg.alpha = 0.0
            } else {
                self.segmentControl.alpha = 0.0
                self.dismissBtn.alpha = 0.0
                self.colorSeg.alpha = 0.0
            }
        })
    }
}
