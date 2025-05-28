//
//  TurnONTorch.swift
//  ProLight
//
//  Created by Paul Roden II on 3/13/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import Foundation
import AVFoundation

class TurnONTorch {
    static let shared = TurnONTorch()
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("There was an error : \(error.localizedDescription)")
        }
    }
}
