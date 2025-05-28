//
//  flasherWatchLight.swift
//  ProLightWatch Extension
//
//  Created by Paul on 5/8/19.
//  Copyright © 2019 Studio4Designsoftware. All rights reserved.
//

import WatchKit
import Foundation

class flasherWatchLight: WKInterfaceController {

    
    @IBOutlet var btnFlash: WKInterfaceButton!
    
    var lightOn = false
    var strobeOn = false
    var timer = Timer()
    var dblTimerSpeed = 1.0
    
    func playHaptic(Click_ type: WKHapticType) {
        
        enum WKHapticType : Int {
            case Notification
            case DirectionUp
            case DirectionDown
            case Success
            case Failure
            case Retry
            case Start
            case Stop
            case Click
        }
    }
    
    
    @IBAction func btnFlashAction() {
        if strobeOn == false {
            strobeOn = true
            setOn()
        } else {
            strobeOn = false
        }
        
        if strobeOn == true {
            lightOn = false
            timer = Timer.scheduledTimer(timeInterval: dblTimerSpeed, target: self, selector: #selector(strobWatchLight.strobeLight), userInfo: nil, repeats: true)
        } else {
            setOff()
        }
    }
    
    func setOn() {
        btnFlash.setTitle("")
        btnFlash.setBackgroundColor(UIColor.white)
    }
    
    func setOff() {
        btnFlash.setTitle("Tap the screen for Flashing Light")
        timer.invalidate()
        btnFlash.setBackgroundColor(UIColor.black)
    }
    
    
    @objc func strobeLight() {
        if lightOn == false {
            btnFlash.setBackgroundColor(UIColor.white)
            WKInterfaceDevice.current().play(WKHapticType.click)
            lightOn = true
        }
        else {
            btnFlash.setBackgroundColor(UIColor.black)
            btnFlash.setTitle("")
            lightOn = false
        }
    }
    
    
    func awakeWithContext(context: AnyObject?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        super.willActivate()
        // This method is called when watch view controller is about to be visible to user
        
        lightOn = false
        strobeOn = false
        btnFlash.setBackgroundColor(UIColor.black)
        btnFlash.setTitle("Tap the screen for Flashing Light")
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        // This method is called when watch view controller is no longer visible
        
        timer.invalidate()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
