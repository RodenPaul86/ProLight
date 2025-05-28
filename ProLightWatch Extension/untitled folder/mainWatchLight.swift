//
//  mainWatchLight.swift
//  ProLightWatch Extension
//
//  Created by Paul on 5/6/19.
//  Copyright © 2019 Studio4Designsoftware. All rights reserved.
//

import WatchKit
import Foundation


class mainWatchLight: WKInterfaceController {
    //
    // Simple flashlight for the watch
    //
    
    @IBOutlet var lightBtn: WKInterfaceButton!
    
    var pressed = false
    
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
    
    
    @IBAction func btnLightOnAction() {
        pressed = !pressed
        
        if pressed {
            lightBtn.setBackgroundColor(UIColor.white)
            WKInterfaceDevice.current().play(WKHapticType.click)
            lightBtn.setTitle("")
        } else {
            lightBtn.setBackgroundColor(UIColor.black)
            WKInterfaceDevice.current().play(WKHapticType.click)
            lightBtn.setTitle("Tap the screen for Light")
        }
    }
    
    
    func awakeWithContext(context: AnyObject?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        super.willActivate()
        // This method is called when watch view controller is about to be visible to user
        
        pressed = false
        lightBtn.setBackgroundColor(UIColor.black)
        lightBtn.setTitle("Tap the screen for Light")
    }
    
    override func didDeactivate() {
        super.didDeactivate()

        // This method is called when watch view controller is no longer visible
        lightBtn.setBackgroundColor(UIColor.black)
        lightBtn.setTitle("Tap the screen for Light")
    }
}
