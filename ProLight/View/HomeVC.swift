//
//  HomeVC.swift
//  ProLight
//
//  Created by Paul on 9/19/16.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import UIKit
import SwiftUI
import AVFoundation
import Foundation
import MediaPlayer
import MapKit
import StoreKit
import CoreLocation
import SafariServices
import CTFeedbackSwift
import SwiftAlertView
import RevenueCat

class HomeVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var btnModView: UIView!
    @IBOutlet weak var strobLightView: UIView!
    @IBOutlet weak var screenLightView: UIView!
    @IBOutlet weak var flashingLightView: UIView!
    @IBOutlet weak var menuConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sosBtn: UIButton!
    @IBOutlet weak var weatherBtn: UIButton!
    @IBOutlet weak var batteryBtn: UIBarButtonItem!
    
    @IBOutlet weak var hideClockBtn: UISwitch!
    @IBOutlet weak var soundBtn: UISwitch!
    @IBOutlet weak var voiceBtn: UISwitch!
    @IBOutlet weak var voiceLabel: UILabel!
    @IBOutlet weak var hapticsBtn: UISwitch!
    @IBOutlet weak var hapticLabel: UILabel!
    
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var cancelMenu: UIButton!
    
    @IBOutlet weak var mainBtnView: UIView!
    @IBOutlet weak var mainOnOff: UIButton!
    @IBOutlet weak var strob: UIButton!
    @IBOutlet weak var scrLight: UIButton!
    @IBOutlet weak var flash: UIButton!
    @IBOutlet weak var morse: UIButton!
    
    @IBOutlet weak var strobSettingView: UIView!
    @IBOutlet weak var lightSettingView: UIView!
    @IBOutlet weak var flashSettingView: UIView!
    @IBOutlet weak var morseCodeView: UIView!
    
    @IBOutlet weak var mainLightLabel: UILabel!
    @IBOutlet weak var lightSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var segmentCon: UISegmentedControl!
    
    // MARK: Variables
    var isSOSActive = false
    var isFlashing = false
    var isTorchOn = false
    let captureDevice = AVCaptureDevice.default(for: .video)
    let offPosition: Float = 0.0
    let dimPosition: Float = 0.5
    let brightPosition: Float = 1.0
    var shouldSnapToPosition = false
    
    var theContainer: UIView!
    let defaults = UserDefaults.standard
    var showAlertJustOnce:Bool = true
    var player: AVAudioPlayer?
    
    let speechSynthesizer = AVSpeechSynthesizer()
    var alreadyBeenDisplayed = false
    
    var faceBookBtnCenter: CGPoint!
    var twitterBtnCenter: CGPoint!
    var smsTextMBtnCenter: CGPoint!
    
    var pressed = false
    var strobOn = false
    var lightBtnOn = false
    var lightIsOn = false
    var a = false
    
    var lightShouldAlwaysBeOn = false
    var lightShouldAlwaysBeOff = true
    var timer = Timer()
    var dblTimerSpeed:Double = 0.0648415
    var fltStrobeSpeed:Float = 0.0
    var intStrobeSpeed:Int = 0
    var sliderRange:Float = 0.897
    
    var theTimer = Timer()
    var offTimer = Timer()
    var lightTimer = Timer()
    var onTime:Double = 0.01
    var offTime:Double = 0.0
    var secondOffTime:Double = 0.0
    var shouldDouble:Bool = false
    var firstOfDouble = false
    
    //this varables are for the card view
    enum CardState {
        case expanded
        case collapsed
    }
    
    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView!
    
    let cardHeight:CGFloat = 550
    let cardHandleAreaHeight:CGFloat = 50
    
    let timeFormatter = DateFormatter()
    let dayFormatter = DateFormatter()
    
    var welcomeHasBeenDisplayed = false
    
    var cardVisible = false
    var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    func setCount(theCount: Int) {
        defaults.set(theCount, forKey: "Flash Count")
    }
    
    func getCount() -> Int {
        return defaults.integer(forKey: "Flash Count")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func deleteDefault() {
        UserDefaults.standard.removeObject(forKey: "isPayWallSowing")
        UserDefaults.standard.synchronize()
    }
    
    //Date & Time
    @objc func updateDateTime() {
        timeFormatter.dateFormat = "hh:mm aa"
        timeFormatter.timeStyle = .short
        
        dayFormatter.dateFormat = "dd.MM.yyyy"
        dayFormatter.dateStyle = .medium
        
        let currentTime = timeFormatter.string(from: Date())
        let currentDay = dayFormatter.string(from: Date())
        
        timeLabel.text = currentTime
        dateLabel.text = currentDay
    }
    
    @IBOutlet weak var batteryInfo: UILabel!
    
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    // MARK: view Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsEnabled()
        setupBatteryMonitoring()
        setupCaptureDevice() // Comment this out for testing in simulator.
        coreDesign()
        setupCard()
        
        lightSlider.value = captureDevice?.torchLevel ?? 0.0
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sliderPanned(_:)))
        lightSlider.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func coreDesign() {
        menuConstraint.constant = -400
        cancelMenu.alpha = 0
        
        btnModView.layer.borderColor = Theme.current.Appearance.cgColor
        mainBtnView.layer.borderColor = Theme.current.Appearance.cgColor
        strobLightView.layer.borderColor = Theme.current.Appearance.cgColor
        screenLightView.layer.borderColor = Theme.current.Appearance.cgColor
        flashingLightView.layer.borderColor = Theme.current.Appearance.cgColor
        morseCodeView.layer.borderColor = Theme.current.Appearance.cgColor
        weatherBtn.layer.borderColor = Theme.current.Appearance.cgColor
        sosBtn.layer.borderColor = Theme.current.Appearance.cgColor
        
        strob.setTitleColor(Theme.current.mainButtons, for: .normal)
        flash.setTitleColor(Theme.current.mainButtons, for: .normal)
        scrLight.setTitleColor(Theme.current.mainButtons, for: .normal)
        morse.setTitleColor(Theme.current.mainButtons, for: .normal)
        
        viewBorder(borderView: sosBtn, width: 1, radius: 30, bounds: true)
        viewBorder(borderView: weatherBtn, width: 1, radius: 30, bounds: true)
        viewBorder(borderView: btnModView, width: 1, radius: btnModView.frame.width / 2, bounds: true)
        viewBorder(borderView: mainOnOff, width: 1, radius: mainOnOff.frame.width / 2, bounds: true)
        viewBorder(borderView: mainBtnView, width: 1, radius: mainBtnView.frame.width / 2, bounds: true)
        
        strobLightView.layer.borderWidth = 1
        flashingLightView.layer.borderWidth = 1
        screenLightView.layer.borderWidth = 1
        morseCodeView.layer.borderWidth = 1
        
        UIViewSetup(view: lightSettingView)
        UIViewSetup(view: strobSettingView)
        UIViewSetup(view: flashSettingView)
        
        flash.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        strob.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -4)
        scrLight.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        morse.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -4)
        
        let nonSelectedTitleText = [NSAttributedString.Key.foregroundColor: UIColor.green]
        segmentCon.setTitleTextAttributes(nonSelectedTitleText, for: .normal)
        
        let selectedTitleText = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentCon.setTitleTextAttributes(selectedTitleText, for: .selected)
        
        let btn_LongPress_gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleBtnLongPressgesture(_:)))
        mainOnOff.addGestureRecognizer(btn_LongPress_gesture)
    }
    private func setupBatteryMonitoring() {
        //Begins battery state monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
        Timer.scheduledTimer(timeInterval: onTime, target: self, selector: #selector(someFunction), userInfo: nil, repeats: true)
        
        //Disables auto lock
        UIApplication.shared.isIdleTimerDisabled = true
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(HomeVC.updateDateTime), userInfo: nil, repeats: true)
    }
    
    // MARK: iOS Device Light Capability
    private func setupCaptureDevice() {
        if let device = AVCaptureDevice.default(for: .video) {
            if (device.hasTorch) {
                // Device has torch
                print("Device: haves a LED")
                strob.isEnabled = true
                flash.isEnabled = true
                scrLight.isEnabled = true
                morse.isEnabled = true
            } else {
                // Device does not have torch
                print("Device: cant use LED")
                btnModView.isHidden = true
            }
        } else {
            // Device does not support video type (and so, no torch)
            print("Device: No LED")
            btnModView.isHidden = true
        }
    }
    private func buttonsEnabled() {
        strob.isEnabled = true
        flash.isEnabled = true
        scrLight.isEnabled = true
        morse.isEnabled = true
    }
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let hideClock = defaults.bool(forKey: "stateOfClock")
        self.hideClockBtn.setOn(hideClock, animated: false)
        
        let glassSound = defaults.bool(forKey: "stateOfSound")
        self.soundBtn.setOn(glassSound, animated: false)
        
        let hapticsOff = defaults.bool(forKey: "stateOfHaptics")
        self.hapticsBtn.setOn(hapticsOff, animated: false)
        
        let voiceSound = defaults.bool(forKey: "stateOfVoice")
        self.voiceBtn.setOn(voiceSound, animated: false)
        
        let batteryText = String(format: "%.0f%%", batteryLevel * 100)
        
        if hideClockBtn.isOn {
            timeLabel.alpha = 0
            dateLabel.alpha = 0
        } else {
            timeLabel.alpha = 1
            dateLabel.alpha = 1
        }
        
        if welcomeHasBeenDisplayed == false {
            welcomeHasBeenDisplayed = true
            
            timeFormatter.dateFormat = "hh:mm aa"
            let currentTime = timeFormatter.string(from: Date())
            
            voiceSpeech(message: "Welcome to ProLight, the current time is \(currentTime), and your phones battery is \(batteryText)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppReviewRequest.requestReviewIfNeeded()
    }
    
    @objc func handleBtnLongPressgesture(_ recognizer: UILongPressGestureRecognizer?) {
        // as you hold the button this would fire
        if recognizer?.state == .began {
            print("hold down")
            if hapticsBtn.isOn {
                print("no haptics")
            } else {
                buttonVibration(style: .rigid)
            }
            
            if IAPManager.shared.isPremium() {
                var swiftUIView = clockView()
                swiftUIView.backToMAinVC = self
                let contentView = UIHostingController(rootView: swiftUIView)
                contentView.overrideUserInterfaceStyle = .dark
                contentView.isModalInPresentation = true
                self.present(contentView, animated: true, completion: nil)
            } else {
                SwiftAlertView.show(title: "Unlock Desk Mode",
                                    message: "Unlock Desk Mode to enhance your experience.",
                                    buttonTitles: "Cancel", "Unlock Now") { alert in
                    alert.style = .auto
                    alert.buttonTitleColor = .systemBlue
                    alert.cancelButtonIndex = 0
                    alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
                }.onButtonClicked { _, buttonIndex in
                    if buttonIndex == 0 {
                        self.dismiss(animated: true)
                    } else if buttonIndex == 1 {
                        var swiftUIView = payWall()
                        swiftUIView.backToMAinVC = self
                        let contentView = UIHostingController(rootView: swiftUIView)
                        contentView.overrideUserInterfaceStyle = .dark
                        self.present(contentView, animated: true, completion: nil)
                    }
                }
            }
        }
        //as you release the button this would fire
        if recognizer?.state == .ended {
            print("hold release")
        }
    }
    
    @objc func someFunction() {
        let batteryText = String(format: "%.0f%%", batteryLevel * 100)
        
        self.batteryInfo.text = "\(batteryText)"
        
        if (UIDevice.current.batteryState == .charging) {
            //battState.text = "Connected"
            UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.batteryBtn.isEnabled = false
                self.batteryBtn.title = "⚡️"
                
                self.mainOnOff.imageView?.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
                self.mainOnOff.backgroundColor = UIColor.clear
                
            }, completion: nil)
        } else if (UIDevice.current.batteryState == .unplugged) {
            //battState.text = "Unconnected"
            UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: {
                
                self.batteryBtn.isEnabled = true
                self.batteryBtn.title = "\(batteryText)"
                
                self.mainOnOff.imageView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                self.mainOnOff.backgroundColor = UIColor.black
                
            }, completion: nil)
        } else if (UIDevice.current.batteryState == .unknown) {
            batteryBtn.title = "100%"
        }
    }
    
    @IBAction func mapMode(_ sender: UIButton) {
        var swiftUIView = nearby()
        swiftUIView.backToMAinVC = self
        let contentView = UIHostingController(rootView: swiftUIView)
        self.present(contentView, animated: true, completion: nil)
    }
    
    @IBAction func menuOpen(_ sender: UIBarButtonItem) {
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        menuDidAnimateIn()
        menuConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func menuClose(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.cancelMenu.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.cancelMenu.alpha = 0
            self.cardViewController.indicatorLine.alpha = 1
        }) { (success:Bool) in
        }
        menuConstraint.constant = -400
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func batteryOptions() {
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        let batteryText = String(format: "%.0f%%", batteryLevel * 100)
        voiceSpeech(message: "Your \(UIDevice.current.modelName) battery is \(batteryText)")
    }
    
    func menuDidAnimateIn() {
        UIView.animate(withDuration: 0.4) {
            self.cancelMenu.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.cancelMenu.alpha = 0.8
            self.cancelMenu.transform = CGAffineTransform.identity
            self.cardViewController.indicatorLine.alpha = 0
        }
    }
    
    // MARK: - Strob light function
    func lightShouldBeOff() {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device?.hasTorch)!{
            do {
                try device?.lockForConfiguration()
                
                if lightShouldAlwaysBeOff == true {
                    device?.torchMode = .off
                }
                device?.unlockForConfiguration()
            } catch {
                print("\(error)")
            }
        }
    }
    
    func lightAlwaysOn() {
        lightShouldAlwaysBeOff = false
        lightBtnOn = true
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device?.hasTorch)!{
            do {
                try device?.lockForConfiguration()
                if lightShouldAlwaysBeOn == true {
                    device?.torchMode = .on
                }
                else {
                    device?.torchMode = .off
                }
                device?.unlockForConfiguration()
            } catch {
                print("\(error)")
            }
        }
    }
    
    // MARK: - On & Off function
    @objc func strobeLight() {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if lightBtnOn == true {
            if (device?.hasTorch)!{
                do {
                    try device?.lockForConfiguration()
                    
                    if strobOn == true {
                        device?.torchMode = .off
                        strobOn = false
                    } else {
                        try device?.setTorchModeOn(level: 1.0)
                        strobOn =  true
                        
                        if lightBtnOn == false {
                            device?.torchMode = .off
                        }
                    }
                    device?.unlockForConfiguration()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc func lightOn() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        if shouldDouble == true {
            //turns light on the first time
            if firstOfDouble == false {
                firstOfDouble = true
                if (device.hasTorch) {
                    do {
                        try device.lockForConfiguration()
                        try device.setTorchModeOn(level: 1.0)
                        setCount(theCount: (getCount()) + 1)
                        device.unlockForConfiguration()
                    } catch {
                        print(error)
                    }
                }
                offTimer.invalidate()
                lightTimer = Timer.scheduledTimer(timeInterval: onTime, target: self, selector: #selector(HomeVC.lightOffTimed), userInfo: nil, repeats: true)
            }
                //turns light on for the second time
            else {
                firstOfDouble = false
                if (device.hasTorch) {
                    do {
                        try device.lockForConfiguration()
                        try device.setTorchModeOn(level: 1.0)
                        setCount(theCount: (getCount()) + 1)
                        device.unlockForConfiguration()
                    } catch {
                        print(error)
                    }
                }
                offTimer.invalidate()
                lightTimer = Timer.scheduledTimer(timeInterval: onTime, target: self, selector: #selector(HomeVC.doubleOffTimed), userInfo: nil, repeats: true)
            }
        }
            // non double light
        else if shouldDouble == false {
            if (device.hasTorch) {
                do {
                    try device.lockForConfiguration()
                    try device.setTorchModeOn(level: 1.0)
                    setCount(theCount: (getCount()) + 1)
                    device.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
            offTimer.invalidate()
            lightTimer = Timer.scheduledTimer(timeInterval: onTime, target: self, selector: #selector(HomeVC.lightOffTimed), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: - Turns light off no matter what the setting is...
    func lightOff() {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                
                device?.torchMode = .off
                device?.unlockForConfiguration()
                
            } catch {
                print("\(error)")
            }
        }
        lightIsOn = false
        offTimer.invalidate()
        lightTimer.invalidate()
    }
    
    @objc func lightOffTimed() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                
                device.torchMode = .off
                device.unlockForConfiguration()
                
            } catch {
                print(error)
            }
        }
        lightTimer.invalidate()
        offTimer = Timer.scheduledTimer(timeInterval: offTime, target: self, selector: #selector(HomeVC.lightOn), userInfo: nil, repeats: true)
    }
    
    @objc func doubleOffTimed() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                
                device.torchMode = .off
                device.unlockForConfiguration()
                
            } catch {
                print(error)
            }
        }
        lightTimer.invalidate()
        offTimer = Timer.scheduledTimer(timeInterval: secondOffTime, target: self, selector: #selector(HomeVC.lightOn), userInfo: nil, repeats: true)
    }
    
    func playButtonSound() {
        if soundBtn.isOn {
            SoundHelper.shared.stopSound()
        } else {
            SoundHelper.shared.startSound()
        }
    }
    
    // MARK: Main Light
    @IBAction func mainLight(_ sender: Any) {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            if (device.hasTorch) {
                playButtonSound()
                if hapticsBtn.isOn {
                    print("no haptics")
                } else {
                    buttonVibration(style: .rigid)
                }
                
                pressed = !pressed
                if pressed {
                    voiceSpeech(message: "light on")
                    lightSettingView.isHidden = false
                    
                    scrLight.isEnabled = false
                    scrLight.setTitleColor(.darkGray, for: .normal)
                    strob.isEnabled = false
                    strob.setTitleColor(.darkGray, for: .normal)
                    flash.isEnabled = false
                    flash.setTitleColor(.darkGray, for: .normal)
                    morse.isEnabled = false
                    morse.setTitleColor(.darkGray, for: .normal)
                    
                    lightSlider.value = 4
                    mainLightLabel.text = "LED: Bright"
                    showMLightSettings()
                    TurnONTorch.shared.toggleTorch(on: true)
                    
                    let image = UIImage(named: "powerBtnOn.png") as UIImage?
                    mainOnOff.setImage(image, for: .normal)
                } else {
                    voiceSpeech(message: "light off")
                    lightSettingView.isHidden = true
                    
                    scrLight.isEnabled = true
                    scrLight.setTitleColor(Theme.current.mainButtons, for: .normal)
                    strob.isEnabled = true
                    strob.setTitleColor(Theme.current.mainButtons, for: .normal)
                    flash.isEnabled = true
                    flash.setTitleColor(Theme.current.mainButtons, for: .normal)
                    morse.isEnabled = true
                    morse.setTitleColor(Theme.current.mainButtons, for: .normal)
                    
                    hideMLightSettings()
                    TurnONTorch.shared.toggleTorch(on: false)
                    
                    let image = UIImage(named: "powerBtnOff.png") as UIImage?
                    mainOnOff.setImage(image, for: .normal)
                }
            } else {
                // Device does not have torch
                playButtonSound()
                voiceSpeech(message: "screen light on")
                let viewController:ScreenVC = UIStoryboard(name: Storyboard.ScreenLightVC, bundle: nil).instantiateViewController(withIdentifier: StoryboardID.ScreenLight) as! ScreenVC
                self.present(viewController, animated: true, completion: nil)
            }
            
        } else {
            // Device does not support video type (and so, no torch)
            playButtonSound()
            voiceSpeech(message: "screen light on")
            let viewController:ScreenVC = UIStoryboard(name: Storyboard.ScreenLightVC, bundle: nil).instantiateViewController(withIdentifier: StoryboardID.ScreenLight) as! ScreenVC
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @objc func sliderPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            shouldSnapToPosition = true
        case .changed:
            shouldSnapToPosition = false
        case .ended:
            shouldSnapToPosition = true
            mainLightSlider()
        default:
            break
        }
    }
    
    @IBAction func sliderTouchUpInside(_ sender: UISlider) {
        shouldSnapToPosition = true
        mainLightSlider()
    }
    
    func mainLightSlider() {
        let currentValue = lightSlider.value
        
        // Determine the closest desired brightness position
        var snapValue: Float
        
        if currentValue <= (offPosition + dimPosition) / 2 {
            snapValue = offPosition
            mainLightLabel.text = "LED: Off"
        } else if currentValue <= (dimPosition + brightPosition) / 2 {
            snapValue = dimPosition
            mainLightLabel.text = "LED: Dim"
        } else {
            snapValue = brightPosition
            mainLightLabel.text = "LED: Bright"
        }
        
        // Snap the slider to the desired brightness position
        lightSlider.setValue(snapValue, animated: true)
        
        // Update the torch brightness
        updateTorchBrightness(snapValue)
    }
    
    @objc func updateTorchBrightness(_ brightness: Float) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            // Set the torch brightness
            if brightness == 0.0 {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: brightness)
            }
        } catch {
            print("Could not set torch brightness: \(error.localizedDescription)")
        }
    }
    
    // MARK: Strob Light
    @IBAction func strobLight(_ sender: Any) {
        playButtonSound()
        
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        if IAPManager.shared.isPremium() {
            pressed = !pressed
            if pressed {
                voiceSpeech(message: "strobe light on")
                strobSettingView.isHidden = false
                
                scrLight.isEnabled = false
                scrLight.setTitleColor(.darkGray, for: .normal)
                mainOnOff.isEnabled = false
                flash.isEnabled = false
                flash.setTitleColor(.darkGray, for: .normal)
                morse.isEnabled = false
                morse.setTitleColor(.darkGray, for: .normal)
                
                showStrobSettings()
                lightBtnOn = true
                lightShouldAlwaysBeOn = false
                strobeLight()
                strobSliderDidChange(slider)
                
                if lightIsOn == true {
                    hideSegSettings()
                    lightOff()
                    lightIsOn = false
                }
            } else {
                voiceSpeech(message: "strobe light off")
                strobSettingView.isHidden = true
                
                scrLight.isEnabled = true
                scrLight.setTitleColor(Theme.current.mainButtons, for: .normal)
                mainOnOff.isEnabled = true
                flash.isEnabled = true
                flash.setTitleColor(Theme.current.mainButtons, for: .normal)
                morse.isEnabled = true
                morse.setTitleColor(Theme.current.mainButtons, for: .normal)
                
                hideStrobSettings()
                timer.invalidate()
                lightBtnOn = false
                lightShouldAlwaysBeOff = true
                lightShouldBeOff()
            }
        } else {
            var swiftUIView = payWall()
            swiftUIView.backToMAinVC = self
            let contentView = UIHostingController(rootView: swiftUIView)
            contentView.overrideUserInterfaceStyle = .dark
            self.present(contentView, animated: true, completion: nil)
        }
    }
    
    @IBAction func sliderSpeedAction(_ sender: Any) {
        //
        //slider range is .897
        //slider range 909
        //
        if slider.value >= 0.92 {
            speedLabel.text = "Always On"
        } else if slider.value <= 0.041 {
            speedLabel.text = "Really Fast!"
        } else {
            fltStrobeSpeed = slider.value * 100
            print("Strobe speed \(fltStrobeSpeed)")
            intStrobeSpeed = Int(fltStrobeSpeed)
            speedLabel.text = "Strobe Speed: \(intStrobeSpeed)"
        }
    }
    @IBAction func sliderAct(_ sender: Any) {
        strobSliderDidChange(slider)
    }
    @objc func strobSliderDidChange(_ slider: UISlider) {
        // caping the lowest speed at .041000
        // highest speed before ∞ will be .92000
        // the defualt speed is 0.0648415
        
        //strob.setTitleColor( .green, for: .normal)
        
        print(slider.value)
        
        //set value of the slider to dblTimerSpeed and convert the slider which is a float to double. The timer only accepts double.
        dblTimerSpeed = Double(slider.value)
        print("dblTimerSpeed \(dblTimerSpeed)")
        
        if dblTimerSpeed >= 0.92 {
            
            timer.invalidate()
            lightShouldAlwaysBeOn = true
            lightAlwaysOn()
            
        } else {
            lightShouldAlwaysBeOn = false
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: dblTimerSpeed, target: self, selector: #selector(HomeVC.strobeLight), userInfo: nil, repeats: true)
        }
        lightShouldBeOff()
    }
    
    // MARK: Flashing Light
    @IBAction func flasherLight(_ sender: Any) {
        playButtonSound()
        
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        if IAPManager.shared.isPremium() {
            hideStrobSettings()
            
            pressed = !pressed
            if pressed {
                voiceSpeech(message: "flashing light on")
                flashSettingView.isHidden = false
                
                scrLight.isEnabled = false
                scrLight.setTitleColor(.darkGray, for: .normal)
                mainOnOff.isEnabled = false
                strob.isEnabled = false
                strob.setTitleColor(.darkGray, for: .normal)
                morse.isEnabled = false
                morse.setTitleColor(.darkGray, for: .normal)
                
                showSegSettings()
                lightIsOn = true
                segAction(self)
                
                if lightBtnOn == true {
                    hideStrobSettings()
                    timer.invalidate()
                    lightBtnOn = false
                    lightShouldAlwaysBeOff = true
                    lightShouldBeOff()
                }
            } else {
                voiceSpeech(message: "flashing light off")
                flashSettingView.isHidden = true
                
                scrLight.isEnabled = true
                scrLight.setTitleColor(Theme.current.mainButtons, for: .normal)
                mainOnOff.isEnabled = true
                strob.isEnabled = true
                strob.setTitleColor(Theme.current.mainButtons, for: .normal)
                morse.isEnabled = true
                morse.setTitleColor(Theme.current.mainButtons, for: .normal)
                
                lightIsOn = false
                hideSegSettings()
                lightOff()
            }
        } else {
            var swiftUIView = payWall()
            swiftUIView.backToMAinVC = self
            let contentView = UIHostingController(rootView: swiftUIView)
            contentView.overrideUserInterfaceStyle = .dark
            self.present(contentView, animated: true, completion: nil)
        }
    }
    
    @IBAction func segAction(_ sender: AnyObject) {
        if segmentCon.selectedSegmentIndex == 0 {
            print("\(segmentCon.selectedSegmentIndex) Slow")
            // On time 0.01
            // Off time 1.6
            onTime = 0.01
            offTime = 1.6
            shouldDouble = false
            lightIsOn = true
            //checkBtnOn()
            lightOn()
        } else if segmentCon.selectedSegmentIndex == 1 {
            print("\(segmentCon.selectedSegmentIndex) Normal")
            // On time 0.01
            // Off time 1.2
            offTime = 1.2
            shouldDouble = false
            lightIsOn = true
            //checkBtnOn()
            lightOn()
        } else if segmentCon.selectedSegmentIndex == 2 {
            print("\(segmentCon.selectedSegmentIndex) Fast")
            // On time = 0.01
            // Off time 1.0
            offTime = 1.0
            shouldDouble = false
            lightIsOn = true
            //checkBtnOn()
            lightOn()
        } else if segmentCon.selectedSegmentIndex == 3 {
            print("\(segmentCon.selectedSegmentIndex) Faster")
            // On time = 0.01
            // Off time 0.7
            offTime = 0.7
            shouldDouble = false
            lightIsOn = true
            //checkBtnOn()
            lightOn()
        } else if segmentCon.selectedSegmentIndex == 4 {
            print("\(segmentCon.selectedSegmentIndex) Double")
            // On time = 0.01
            // Off time = 1.0
            // Second Off Time = 0.3
            offTime = 1.4
            secondOffTime = 0.3
            shouldDouble = true
            lightIsOn = true
            //checkBtnOn()
            lightOn()
        }
    }
    
    @IBAction func morseCode(_ sender: Any) {
        voiceSpeech(message: "Morse Code")
        playButtonSound()
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        let morseAlert = UIAlertController(title: "“Morse code” This method is used to encode text characters as standardized sequences of two different signal durations, called dots and dashes. The codes are transmitted as electrical pulses or visual signals, such as flashing lights.", message: nil, preferredStyle: .actionSheet)
        /*
        morseAlert.addAction(UIAlertAction(title: "Morse Code Chart", style: .default, handler: { morseDoc in
            let documentFileURL = Bundle.main.url(forResource: "morseCodeChart", withExtension: "pdf")!
            let document = PDFDocument(url: documentFileURL)!
            let readerController = PDFViewController.createNew(with: document, title: "Morse Code Chart")
            let navVC = UINavigationController(rootViewController: readerController)
            self.present(navVC, animated: true, completion: nil)
        }))
        */
        morseAlert.addAction(UIAlertAction(title: "LED Flash", style: .default, handler: { morseLight in
            let viewController:MorseFlash = UIStoryboard(name: Storyboard.FlashVC, bundle: nil).instantiateViewController(withIdentifier: StoryboardID.flashView) as! MorseFlash
            viewController.overrideUserInterfaceStyle = .dark
            self.present(viewController, animated: true, completion: nil)
        }))
        
        if IAPManager.shared.isPremium() {
            morseAlert.addAction(UIAlertAction(title: "Sounds", style: .default, handler: { morseSound in
                let viewController:MorseSound = UIStoryboard(name: Storyboard.SoundVC, bundle: nil).instantiateViewController(withIdentifier: StoryboardID.soundView) as! MorseSound
                viewController.overrideUserInterfaceStyle = .dark
                self.present(viewController, animated: true, completion: nil)
            }))
            
            morseAlert.addAction(UIAlertAction(title: "Vibrations", style: .default, handler: { morseVibe in
                let viewController:MorseVibration = UIStoryboard(name: Storyboard.VibarionVC, bundle: nil).instantiateViewController(withIdentifier: StoryboardID.vibrationView) as! MorseVibration
                viewController.overrideUserInterfaceStyle = .dark
                self.present(viewController, animated: true, completion: nil)
            }))
        }
        
        morseAlert.view.tintColor = Theme.current.alertButtons
        morseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(morseAlert, animated: true)
    }
    
    @IBAction func localWeatherBtn(_ sender: UIButton) {
        voiceSpeech(message: "you're local weather")
        playButtonSound()
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        if IAPManager.shared.isPremium() {
            var swiftUIView = weatherKitUI()
            swiftUIView.backToMAinVC = self
            let contentView = UIHostingController(rootView: swiftUIView)
            contentView.overrideUserInterfaceStyle = .dark
            self.present(contentView, animated: true, completion: nil)
        } else {
            var swiftUIView = payWall()
            swiftUIView.backToMAinVC = self
            let contentView = UIHostingController(rootView: swiftUIView)
            contentView.overrideUserInterfaceStyle = .dark
            self.present(contentView, animated: true, completion: nil)
        }
    }
    
    @IBAction func sosHelpBtn(_ sender: UIButton) {
        playButtonSound()
        
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .heavy)
        }
        
        if isFlashing {
            isSOSActive = false
            isFlashing = false
            turnOffTorch()
            
            sosBtn.layer.borderColor = Theme.current.Appearance.cgColor
        } else {
            isSOSActive = true
            flashSOS()
            
            sosBtn.layer.borderColor = Theme.current.sosEmergency.cgColor
        }
    }
    
    func flashSOS() {
        let morseCode = [ // ...---...
            // S: Dot-Dot-Dot
            [0.2, 0.2, 0.2],
            // O: Dash-Dash-Dash
            [0.4, 0.4, 0.4],
            // S: Dot-Dot-Dot
            [0.2, 0.2, 0.2]
        ]
        
        var totalTime: TimeInterval = 0
        
        isFlashing = true
        
        for code in morseCode {
            for timeInterval in code {
                totalTime += timeInterval
                DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
                    if self.isSOSActive == true {
                        self.toggleTorch()
                    }
                }
            }
            totalTime += 0.2 // Pause between characters
        }
        
        let loopTime = totalTime + 2.0 // Pause before looping again
        DispatchQueue.main.asyncAfter(deadline: .now() + loopTime) {
            if self.isSOSActive == true {
                self.flashSOS()
            } else {
                self.isFlashing = false
                self.turnOffTorch()
            }
        }
    }
    
    func toggleTorch() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.torchMode = device.torchMode == .on ? .off : .on
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }
    }
    
    func turnOffTorch() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be turned off.")
            }
        }
    }
    
    func showMLightSettings() {
        UIView.animate(withDuration: 0.4, animations: {
            self.lightSettingView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.lightSettingView.alpha = 1
        })
    }
    
    func hideMLightSettings() {
        UIView.animate(withDuration: 0.4, animations: {
            self.lightSettingView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.lightSettingView.alpha = 0
        })
    }
    
    func showStrobSettings() {
        UIView.animate(withDuration: 0.4, animations: {
            self.strobSettingView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.strobSettingView.alpha = 1
        })
    }
    func hideStrobSettings() {
        UIView.animate(withDuration: 0.4, animations: {
            self.strobSettingView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.strobSettingView.alpha = 0
        })
    }
    
    func showSegSettings() {
        UIView.animate(withDuration: 0.4, animations: {
            self.flashSettingView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.flashSettingView.alpha = 1
        })
    }
    func hideSegSettings() {
        UIView.animate(withDuration: 0.4, animations: {
            self.flashSettingView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.flashSettingView.alpha = 0
        })
    }
    
    @IBAction func screenAction(_ sender: Any) {
        playButtonSound()
        voiceSpeech(message: "screen light on")
        
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        let viewController:ScreenVC = UIStoryboard(name: Storyboard.ScreenLightVC, bundle: nil).instantiateViewController(withIdentifier: StoryboardID.ScreenLight) as! ScreenVC
        self.present(viewController, animated: true, completion: nil)
    }
    
    func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage {
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
    
    // MARK: Menu settings / actions
    @IBAction func clockAction(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "stateOfClock")
        
        if hideClockBtn.isOn {
            voiceSpeech(message: "clock disabled")
            timeLabel.alpha = 0
            dateLabel.alpha = 0
        } else {
            voiceSpeech(message: "clock enabled")
            timeLabel.alpha = 1
            dateLabel.alpha = 1
        }
    }
    
    @IBAction func batteryAction(_ sender: UIButton) {
        pressed = !pressed
        if pressed {
            //mainOnOff.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.mainOnOff.alpha = 0
            }, completion: nil)
            batteryLabel.text = "Showing"
        }else {
            //mainOnOff.alpha = 1
            UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.mainOnOff.alpha = 1
            }, completion: nil)
            batteryLabel.text = "Hidden"
        }
    }
    
    @IBAction func setSound(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "stateOfSound")
        
        if soundBtn.isOn {
            voiceSpeech(message: "sound muted")
        } else {
            voiceSpeech(message: "sound unmuted")
        }
    }
    
    @IBAction func setHaptics(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "stateOfHaptics")
        
        if hapticsBtn.isOn {
            voiceSpeech(message: "haptics off")
            hapticLabel.text = "Haptics Off"
        } else {
            voiceSpeech(message: "haptics on")
            hapticLabel.text = "Haptics On"
        }
    }
    
    @IBAction func setVoice(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "stateOfVoice")
        
        if voiceBtn.isOn {
            voiceSpeech(message: "voice on")
            voiceLabel.text = "Voice On"
        } else {
            voiceSpeech(message: "voice off")
            voiceLabel.text = "Voice Off"
        }
    }
    
    // MARK: - Subscribe Button
    @IBAction func premium(_ sender: UIButton) {
        voiceSpeech(message: "activate premium content")
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        if IAPManager.shared.isPremium() {
            let alert = UIAlertController(title: "Subscription Active",
                                          message: "Thank you for your support! It appears that you already have an active subscription for this app. \n\nIf you're experiencing any issues or have any questions, please reach out to our support team. Enjoy using this app!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Manage Subscription", style: .destructive, handler: { action in
                if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Need Support?", style: .default, handler: { action in
                let configuration = FeedbackConfiguration(toRecipients: ["studio4designsoftware@outlook.com"],
                                                          hidesUserEmailCell: true,
                                                          usesHTML: true)
                
                let controller = FeedbackViewController(configuration: configuration)
                controller.overrideUserInterfaceStyle = .dark
                let navVC = UINavigationController(rootViewController: controller)
                navVC.view.tintColor = Theme.current.cancelText
                self.present(navVC, animated:true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            var swiftUIView = payWall()
            swiftUIView.backToMAinVC = self
            let contentView = UIHostingController(rootView: swiftUIView)
            contentView.overrideUserInterfaceStyle = .dark
            present(contentView, animated: true, completion: nil)
        }
    }
    
// MARK: - About Button
    @IBAction func about(_ sender: UIButton) {
        voiceSpeech(message: "about this app")
        
        var swiftUIView = AboutVC()
        swiftUIView.backToMAinVC = self
        let contentView = UIHostingController(rootView: swiftUIView)
        contentView.overrideUserInterfaceStyle = .dark
        present(contentView, animated: true, completion: nil)
    }
    
    @IBAction func whatsNewAction(_ sender: UIButton) {
        voiceSpeech(message: "open whats new")
        
        let swiftUIView = whatsNewView()
        //swiftUIView.backToMAinVC = self
        let contentView = UIHostingController(rootView: swiftUIView)
        contentView.overrideUserInterfaceStyle = .dark
        present(contentView, animated: true, completion: nil)
    }
    
    @IBAction func AppIconBtn(_ sender: UIButton) {
        voiceSpeech(message: "Change App Icon")
        
        let swiftUIView = ChangeAppIconView()
        //swiftUIView.backToMAinVC = self
        let contentView = UIHostingController(rootView: swiftUIView)
        contentView.overrideUserInterfaceStyle = .dark
        present(contentView, animated: true, completion: nil)
    }
    
// MARK: - Share App
    @IBAction func shareApp(_ sender: Any) {
        voiceSpeech(message: "share this app")
        
        if let myWebsite = NSURL(string: "https://itunes.apple.com/us/app/prolight/id1173567157?mt=8") {
            let objectsToShare = [myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            // Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList]
            
            present(activityVC, animated: true, completion: nil)
        }
    }
    
// MARK: - Send Feedback
    @IBAction func sendFeedback(_ sender: Any) {
        voiceSpeech(message: "send feedback")
        
        let configuration = FeedbackConfiguration(toRecipients: ["studio4designsoftware@outlook.com"],
                                                  hidesUserEmailCell: true,
                                                  usesHTML: true)
        
        let controller = FeedbackViewController(configuration: configuration)
        controller.overrideUserInterfaceStyle = .dark
        let navVC = UINavigationController(rootViewController: controller)
        navVC.view.tintColor = Theme.current.cancelText
        self.present(navVC, animated:true, completion: nil)
    }
    
    @IBAction func moreApps(_ sender: Any) {
        voiceSpeech(message: "more of our apps")
        //showIndicator()
        openStoreProductWithiTunesItemIdentifier("693041126")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            //self.hideIndicator()
        }
    }
    
// MARK: - MAP-VIEW CARD
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        visualEffectView.alpha = 0
        
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeVC.handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(HomeVC.handleCardPan(recognizer:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handleCardTap(recognizer:UITapGestureRecognizer) {
        if hapticsBtn.isOn {
            print("no haptics")
        } else {
            buttonVibration(style: .soft)
        }
        
        if defaults.value(forKey: "stateOfVoice") != nil {
            let switchOn: Bool = defaults.value(forKey: "stateOfVoice") as! Bool
            
            pressed = !pressed
            if pressed {
                if switchOn == true {
                    voiceSpeech(message: "map view open")
                } else if switchOn == false {
                }
            } else {
                if switchOn == true {
                    voiceSpeech(message: "map view closed")
                } else if switchOn == false {
                }
            }
            
        }
        cardViewController.searchBar.endEditing(true)
        
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc func handleCardPan(recognizer:UIPanGestureRecognizer) {
        cardViewController.searchBar.endEditing(true)
        
        switch recognizer.state {
        case .began:
            //start animation transition
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            //update transition
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            //continue transition
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                    self.cardViewController.indicatorLine.alpha = 0
                    self.cardViewController.directionsLabel.alpha = 1
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                    self.cardViewController.indicatorLine.alpha = 1
                    self.cardViewController.directionsLabel.alpha = 0
                }
            }
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.alpha = 1
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.alpha = 0
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    
    func startInteractiveTransition (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            //run animations
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

extension HomeVC: SFSafariViewControllerDelegate {
    func safariVC(website: String, bar: UIColor, elements: UIColor) {
        let urlString = website
        let url = URL(string: urlString)
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        
        let safariVC = SFSafariViewController(url: url!, configuration: configuration)
        safariVC.modalPresentationStyle = UIModalPresentationStyle.popover
        safariVC.preferredBarTintColor = bar
        safariVC.preferredControlTintColor = elements
        
        present(safariVC, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

// This extension is for the "whats new view"
extension HomeVC {
    func whatsNewIfNeeded() {
        let items = [WhatsNew.Item(title: "ProLight Premium",
                                   subtitle: "Go premium with ProLight premium, this paid subscription includes: Nightstand Clock, Current Weather, and More ways to use ''Morse Code''",
                                   image: UIImage(named: "paywall")),
                     
                     WhatsNew.Item(title: "Screen Light: Single Finger Touch",
                                   subtitle: "One-finger tap on your screen will turn on/off the screen.",
                                   image: UIImage(named: "touchOne")),
                     
                     WhatsNew.Item(title: "Screen Light: Two Finger Touch",
                                   subtitle: "Two-finger tap on your screen will hide all the buttons on the screen.",
                                   image: UIImage(named: "touchTwo"))
        ]
        
        let theme = WhatsNewViewController.Theme { configuration in
            configuration.apply(animation: .fade)
            configuration.backgroundColor = .black
            configuration.titleView.titleColor = .green
            configuration.itemsView.titleColor = .green
            configuration.itemsView.subtitleColor = .green
            configuration.completionButton.backgroundColor = .green
            configuration.completionButton.titleColor = .black
        }
        
        let config = WhatsNewViewController.Configuration(theme: theme)
        let whatsNew = WhatsNew(title: "Whats New\nWith ProLight", items: items)
        let keyValueVersionStore = KeyValueWhatsNewVersionStore(keyValueable: UserDefaults.standard)
        let newFeaturesVC = WhatsNewViewController(whatsNew: whatsNew, configuration: config, versionStore: keyValueVersionStore)
        
        if let show = newFeaturesVC {
            self.present(show, animated: true)
        }
    }
    
// device voice
    func voiceSpeech(message: String) {
        if voiceBtn.isOn {
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
        }
    }
}

extension HomeVC: SKStoreProductViewControllerDelegate {
    func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self

        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    private func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
