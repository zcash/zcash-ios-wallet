//
//  BackgroundTasks.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 10/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import BackgroundTasks
import Combine
class BackgroundTaskSyncronizing {
    static let backgroundProcessingTaskIdentifier = "co.electriccoin.backgroundProcessingTask"
    static let backgroundAppRefreshTaskIdentifier = "co.electriccoin.backgroundAppRefreshTask"
    var cancellables = [AnyCancellable]()
    static let `default` = BackgroundTaskSyncronizing()
    
    func handleBackgroundAppRefreshTask(_ task: BGAppRefreshTask) {
        logger.debug("initalizing task: \(task.identifier)")
        ZECCWalletEnvironment.shared.synchronizer.stop()
        ZECCWalletEnvironment.shared.synchronizer.start(retry: true)
        ZECCWalletEnvironment.shared.synchronizer.status.sink { (status) in
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
            case .disconnected, .stopped:
                task.setTaskCompleted(success: false)
            default:
                break
            }
        }.store(in: &self.cancellables)
        
        task.expirationHandler = {
            
            let status = ZECCWalletEnvironment.shared.synchronizer.status.value
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
            
            default:
                task.setTaskCompleted(success: false)
            }
            ZECCWalletEnvironment.shared.synchronizer.stop()
            
            
        }
    }
    // TODO: Handle this better ideally this backgroudn processing task will  be executed when there are a lot of blocks to download and process
    func handleBackgroundProcessingTask(_ task: BGProcessingTask) {
        logger.debug("initalizing task: \(task.identifier)")
        ZECCWalletEnvironment.shared.synchronizer.stop()
        ZECCWalletEnvironment.shared.synchronizer.start(retry: true)
        ZECCWalletEnvironment.shared.synchronizer.status.sink { (status) in
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
            case .disconnected, .stopped:
                task.setTaskCompleted(success: false)
            default:
                break
            }
        }.store(in: &self.cancellables)
        
        task.expirationHandler = {
            
            let status = ZECCWalletEnvironment.shared.synchronizer.status.value
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
            
            default:
                task.setTaskCompleted(success: false)
            }
            ZECCWalletEnvironment.shared.synchronizer.stop()
            
            
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
