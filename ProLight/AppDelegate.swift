//
//  AppDelegate.swift
//  ProLight
//
//  Created by Paul on 9/19/16.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import UIKit
import AVFoundation
//import BugShaker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var captureDevice: AVCaptureDevice?
    var isTorchOnInBackground = false
    
    let kVersion = "CFBundleShortVersionString"
    let kBuild = "CFBundleVersion"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //bugReporter()
        IAPManager.shared.configure()
        IAPManager.shared.getSubscriptionStatus(completion: nil)
        
        captureDevice = AVCaptureDevice.default(for: .video)
        
        // Register for background notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Register for foreground notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        return true
    }
    
    @objc func handleAppDidEnterBackground() {
        if let device = captureDevice, device.isTorchActive {
            isTorchOnInBackground = true
            toggleTorch(on: false)
        }
    }
    
    @objc func handleAppWillEnterForeground() {
        if isTorchOnInBackground {
            DispatchQueue.main.async {
                self.toggleTorch(on: true)
            }
            isTorchOnInBackground = false
        }
    }
    
    func toggleTorch(on: Bool) {
        guard let device = captureDevice, device.hasTorch else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            if on {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Could not toggle tourch: \(error.localizedDescription)")
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if isTorchOnInBackground {
            DispatchQueue.main.async {
                self.toggleTorch(on: true)
            }
            isTorchOnInBackground = false
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        toggleTorch(on: false)
    }

//MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    //MARK: Software Version and Build
    func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        return version
    }
    
    func getBuild() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let build = dictionary[kBuild] as! String
        return build
    }
    /*
     //MARK: Bug Reporting
     func bugReporter() {
     BugShaker.configure(to: ["studio4designsoftware@outlook.com"], subject: "ProLight: Bug Report", body: "\nDevice: \(UIDevice.current.modelName)\n\(UIDevice.current.systemName): \(UIDevice.current.systemVersion)\nApp: \(Bundle.main.displayName)\nVersion: \(getVersion())\nBuild: \(getBuild())")
     BugShaker.isEnabled = true
     }
     }
     */
}
