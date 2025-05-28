//
//  strobWatchLight.swift
//  ProLightWatch Extension
//
//  Created by Paul on 5/6/19.
//  Copyright © 2019 Studio4Designsoftware. All rights reserved.
//

import WatchKit
import Foundation


class strobWatchLight: WKInterfaceController {
    
    @IBOutlet var btnStrobe: WKInterfaceButton!
    
    var lightOn = false
    var strobeOn = false
    var timer = Timer()
    var dblTimerSpeed = 0.1
    
    
    
    @IBAction func btnStrobeAction() {
        
        if strobeOn == false {
            strobeOn = true
        }
        else {
            strobeOn = false
            
        }
        
        
        if strobeOn == true {
            lightOn = false
            timer = Timer.scheduledTimer(timeInterval: dblTimerSpeed, target: self, selector: #selector(strobWatchLight.strobeLight), userInfo: nil, repeats: true)
            
        }
        else {
            turnLightOff()
            
        }
    }
    
    func turnLightOff() {
        btnStrobe.setTitle("Tap the screen for Strobe Light")
        timer.invalidate()
        btnStrobe.setBackgroundColor(UIColor.black)
        
    }
    
    @objc func strobeLight() {
        
        if lightOn == false {
            btnStrobe.setBackgroundColor(UIColor.white)
            WKInterfaceDevice.current().play(WKHapticType.click)
            lightOn = true
        }
        else {
            btnStrobe.setBackgroundColor(UIColor.black)
            btnStrobe.setTitle("")
            lightOn = false
        }
    }
    
    @IBAction func btnFast() {
        timer.invalidate()
        dblTimerSpeed = 0.15
        strobeOn = true
        timer = Timer.scheduledTimer(timeInterval: dblTimerSpeed, target: self, selector: #selector(strobWatchLight.strobeLight), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func btnNormal() {
        timer.invalidate()
        dblTimerSpeed = 0.5
        strobeOn = true
        timer = Timer.scheduledTimer(timeInterval: dblTimerSpeed, target: self, selector: #selector(strobWatchLight.strobeLight), userInfo: nil, repeats: true)
    }
    
    @IBAction func btnSlow() {
        timer.invalidate()
        dblTimerSpeed = 0.8
        strobeOn = true
        timer = Timer.scheduledTimer(timeInterval: dblTimerSpeed, target: self, selector: #selector(strobWatchLight.strobeLight), userInfo: nil, repeats: true)
    }
    
    
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
    
    
    func awakeWithContext(context: AnyObject?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        super.willActivate()
        // This method is called when watch view controller is about to be visible to user
        
        lightOn = false
        strobeOn = false
        btnStrobe.setBackgroundColor(UIColor.black)
        btnStrobe.setTitle("Tap the screen for Strobe Light")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        timer.invalidate()
        super.didDeactivate()
    }
    
    
    
    
    
    
    
    
}
