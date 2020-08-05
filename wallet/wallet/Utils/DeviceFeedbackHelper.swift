//
//  DeviceFeedbackHelper.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/5/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

import AVFoundation
class DeviceFeedbackHelper {
    
    static func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
