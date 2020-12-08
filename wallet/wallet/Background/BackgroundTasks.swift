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
    static let backgroundProcessingBlockThreshold = 1000
    static let backgroundProcessingTaskIdentifier = "co.electriccoin.backgroundProcessingTask"
    static let backgroundAppRefreshTaskIdentifier = "co.electriccoin.backgroundAppRefreshTask"
    var cancellables = [AnyCancellable]()
    static let `default` = BackgroundTaskSyncronizing()
    
    func handleBackgroundAppRefreshTask(_ task: BGAppRefreshTask) {
        logger.debug("initalizing task: \(task.identifier)")
        tracker.track(.tap(action: .backgroundAppRefreshStart), properties: [:])
        
        ZECCWalletEnvironment.shared.synchronizer.status.dropFirst(1).sink { (status) in
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
                tracker.track(.tap(action: .backgroundAppRefreshEnd), properties: ["completion": "true"])
            case .disconnected, .stopped:
                task.setTaskCompleted(success: false)
                tracker.track(.tap(action: .backgroundAppRefreshEnd), properties: ["completion": "false"])
            default:
                break
            }
        }.store(in: &self.cancellables)
        
        task.expirationHandler = {
            
            let status = ZECCWalletEnvironment.shared.synchronizer.status.value
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
                tracker.track(.tap(action: .backgroundAppRefreshEnd), properties: ["completion": "true"])
            default:
                task.setTaskCompleted(success: false)
                tracker.track(.tap(action: .backgroundAppRefreshEnd), properties: ["completion": "false"])
            }
            ZECCWalletEnvironment.shared.synchronizer.stop()
        }
        
        do {
            try ZECCWalletEnvironment.shared.synchronizer.start(retry: true)
        } catch {
            tracker.track(.error(severity: .noncritical), properties: [
                            ErrorSeverity.messageKey : "error starting background refresh",
                            ErrorSeverity.underlyingError : "\(error)"])
        }
    }

    func handleBackgroundProcessingTask(_ task: BGProcessingTask) {
        logger.debug("initalizing task: \(task.identifier)")
        tracker.track(.tap(action: .backgroundProcessingStart), properties: [:])
        
        ZECCWalletEnvironment.shared.synchronizer.status.sink { (status) in
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
                tracker.track(.tap(action: .backgroundProcessingEnd), properties: ["completion": "true"])
            case .disconnected, .stopped:
                task.setTaskCompleted(success: false)
                tracker.track(.tap(action: .backgroundProcessingEnd), properties: ["completion": "false"])
            default:
                break
            }
        }.store(in: &self.cancellables)
        
        task.expirationHandler = {
            
            let status = ZECCWalletEnvironment.shared.synchronizer.status.value
            switch status {
            case .synced:
                task.setTaskCompleted(success: true)
                tracker.track(.tap(action: .backgroundProcessingEnd), properties: ["completion": "true"])
            default:
                task.setTaskCompleted(success: false)
                tracker.track(.tap(action: .backgroundProcessingEnd), properties: ["completion": "false"])
            }
            ZECCWalletEnvironment.shared.synchronizer.stop()
        }
        do {
            try ZECCWalletEnvironment.shared.synchronizer.start(retry: true)
        } catch {
            tracker.track(.error(severity: .noncritical), properties: [
                            ErrorSeverity.messageKey : "error starting background refresh",
                            ErrorSeverity.underlyingError : "\(error)"])
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskSyncronizing.backgroundAppRefreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // Fetch no earlier than 60 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error("Could not schedule app refresh: \(error)")
            tracker.track(.error(severity: .warning), properties: [ErrorSeverity.messageKey : "Could not schedule app refresh",
                                                                   ErrorSeverity.underlyingError : "\(error)"])
        }
    }
    
    func scheduleBackgroundProcessing() {
        
        do {
            let synchronizer = ZECCWalletEnvironment.shared.synchronizer
            
            let downloadedHeight = try synchronizer.latestDownloadedHeight()
            
            synchronizer.latestHeight.dropFirst(1).sink { (completion) in
                switch completion {
                case .failure(let error):
                    Self.trackError(error, message: "Could not schedule background Processing")
                case .finished:
                    break
                }
            } receiveValue: { (height) in
                guard abs(downloadedHeight - height) > Self.backgroundProcessingBlockThreshold else {
                    return // don't fire up this task
                }
                do {
                let request = BGProcessingTaskRequest(identifier: BackgroundTaskSyncronizing.backgroundProcessingTaskIdentifier)
                request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60 * 60) // Fetch no earlier than 2 hours from now
                request.requiresNetworkConnectivity = true
                request.requiresExternalPower = true
                
                try BGTaskScheduler.shared.submit(request)
            } catch {
                Self.trackError(error, message: "Could not schedule app refresh")
            }
                
            }.store(in: &cancellables)

        } catch {
            Self.trackError(error, message: "Could not schedule app refresh")
        }
    }
    
    private static func trackError(_ error: Error, message: String) {
        logger.error("\(message): \(error)")
        tracker.track(.error(severity: .warning),
                      properties: [ErrorSeverity.messageKey : message,
                                   ErrorSeverity.underlyingError : "\(error)"])
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
