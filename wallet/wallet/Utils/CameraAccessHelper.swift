//
//  CameraAccessHelper.swift
//  wallet
//
//  Created by Francisco Gindre on 2/5/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import AVFoundation

class CameraAccessHelper {
    
    enum Status {
        case authorized
        case unauthorized
        case unavailable
        case undetermined
    }
    
    static var authorizationStatus: CameraAccessHelper.Status {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)

        switch cameraAuthorizationStatus {
        case .authorized:
            return Status.authorized
        case .denied:
            return Status.unauthorized
        case .restricted:
            return .unavailable
        case .notDetermined:
            return Status.undetermined
        @unknown default:
            return .unavailable
        }
    }
}
