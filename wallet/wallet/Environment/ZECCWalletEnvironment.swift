//
//  ZECCWalletEnvironment.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI
import ZcashLightClientKit
import Combine
enum WalletState {
    case initalized
    case uninitialized
    case syncing
    case synced
}


final class ZECCWalletEnvironment: ObservableObject {
    
    static let genericErrorMessage = "An error ocurred, please check your device logs"
    static var shared: ZECCWalletEnvironment = try! ZECCWalletEnvironment() // app can't live without this existing.
    static let memoLengthLimit: Int = 512
    
    @Published var state: WalletState
    
    let endpoint = LightWalletEndpoint(address: ZcashSDK.isMainnet ? "lightwalletd.electriccoin.co" : "lightwalletd.testnet.electriccoin.co", port: 9067, secure: true)
    var dataDbURL: URL
    var cacheDbURL: URL
    var pendingDbURL: URL
    var outputParamsURL: URL
    var spendParamsURL: URL
    var initializer: Initializer {
        synchronizer.initializer
    }
    var synchronizer: CombineSynchronizer
    var cancellables = [AnyCancellable]()
    
    static func getInitialState() -> WalletState {
        guard (try? SeedManager.default.exportPhrase()) != nil else {
            return .uninitialized
        }
        return .initalized
    }
    
    private init() throws {
        self.dataDbURL = try URL.dataDbURL()
        self.cacheDbURL = try URL.cacheDbURL()
        self.pendingDbURL = try URL.pendingDbURL()
        self.outputParamsURL = try URL.outputParamsURL()
        self.spendParamsURL = try  URL.spendParamsURL()
        
        self.state = Self.getInitialState()
        
        let initializer = Initializer(
            cacheDbURL: self.cacheDbURL,
            dataDbURL: self.dataDbURL,
            pendingDbURL: self.pendingDbURL,
            endpoint: endpoint,
            spendParamsURL: self.spendParamsURL,
            outputParamsURL: self.outputParamsURL,
            
            loggerProxy: logger)
        self.synchronizer = try CombineSynchronizer(initializer: initializer)
    }
    
    func createNewWallet() throws {
        
        do {
            let randomPhrase = try MnemonicSeedProvider.default.randomMnemonic()
            
            let birthday = WalletBirthday.birthday(with: BlockHeight.max)
            
            try SeedManager.default.importBirthday(birthday.height)
            try SeedManager.default.importPhrase(bip39: randomPhrase)
            try self.initialize()
        
        } catch {
            throw WalletError.createFailed(underlying: error)
        }
    }
    
    func initialize() throws {
        let seedPhrase = try SeedManager.default.exportPhrase()
        let seedBytes = try MnemonicSeedProvider.default.toSeed(mnemonic: seedPhrase)
        let viewingKeys = try DerivationTool.default.deriveViewingKeys(seed: seedBytes, numberOfAccounts: 1)
        try self.initializer.initialize(viewingKeys: viewingKeys, walletBirthday: try SeedManager.default.exportBirthday())
        self.subscribeToApplicationNotificationsPublishers()
        try self.synchronizer.start()
    }
    
    /**
     only for internal use
     */
    func nuke(abortApplication: Bool = false) {
        self.synchronizer.stop()
        
        SeedManager.default.nukeWallet()
        
        do {
            try FileManager.default.removeItem(at: self.dataDbURL)
        } catch {
            logger.error("could not nuke wallet: \(error)")
        }
        do {
            try FileManager.default.removeItem(at: self.cacheDbURL)
        } catch {
            logger.error("could not nuke wallet: \(error)")
        }
        do {
            try FileManager.default.removeItem(at: self.pendingDbURL)
        } catch {
            logger.error("could not nuke wallet: \(error)")
        }
        
        if abortApplication {
            abort()
        }
    }
    
    static func mapError(error: Error) -> WalletError {
        if let walletError = error as? WalletError {
            return walletError
        } else if let rustError = error as? RustWeldingError {
            switch rustError {
            case .genericError(let message):
                return WalletError.genericErrorWithMessage(message: message)
            case .dataDbInitFailed(let message):
                return WalletError.initializationFailed(message: message)
            case .dataDbNotEmpty:
                return WalletError.initializationFailed(message: "attempt to initialize a db that was not empty")
            case .saplingSpendParametersNotFound:
                return WalletError.createFailed(underlying: rustError)
            case .malformedStringInput:
                return WalletError.genericErrorWithError(error: rustError)
            default:
                return WalletError.genericErrorWithError(error: rustError)
            }
        } else if let synchronizerError = error as? SynchronizerError {
            switch synchronizerError {
            case .generalError(let message):
                return WalletError.genericErrorWithMessage(message: message)
            case .initFailed(let message):
                return WalletError.initializationFailed(message: "Synchronizer failed to initialize: \(message)")
            case .syncFailed:
                return WalletError.synchronizerFailed
            case .connectionFailed(let error):
                return WalletError.connectionFailedWithError(error: error)
            case .maxRetryAttemptsReached(attempts: let attempts):
                return WalletError.maxRetriesReached(attempts: attempts)
            case .connectionError:
              return WalletError.connectionFailed
            case .networkTimeout:
                return WalletError.networkTimeout
            case .uncategorized(let underlyingError):
                return WalletError.genericErrorWithError(error: underlyingError)
            case .criticalError:
                return WalletError.criticalError
            case .parameterMissing(let underlyingError):
                return WalletError.sendFailed(error: underlyingError)
            }
        } else if let serviceError = error as? LightWalletServiceError {
            switch serviceError {
            case .criticalError:
                return WalletError.criticalError
            case .userCancelled:
                return WalletError.connectionFailed
            case .unknown:
                return WalletError.connectionFailed
            case .failed:
                return WalletError.connectionFailedWithError(error: error)
            case .generalError:
                return WalletError.connectionFailed
            case .invalidBlock:
                return WalletError.genericErrorWithError(error: error)
            case .sentFailed(let error):
                return WalletError.sendFailed(error: error)
            case .genericError(error: let error):
                return WalletError.genericErrorWithError(error: error)
            case .timeOut:
                return WalletError.networkTimeout
            }
        }
        
        return WalletError.genericErrorWithError(error: error)
    }
    deinit {
        cancellables.forEach {
            c in
            c.cancel()
        }
    }
    
    
    // Mark: handle background activity
    
    var appCycleCancellables = [AnyCancellable]()
    
    var taskIdentifier: UIBackgroundTaskIdentifier = .invalid
    
    private var isBackgroundAllowed: Bool {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            return true
        default:
            return false
        }
    }
    
    private var isSubscribedToAppDelegateEvents = false
    
    private func registerBackgroundActivity() {
        if self.taskIdentifier == .invalid {
            self.taskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "ZcashLightClientKit.SDKSynchronizer", expirationHandler: { [weak self, weak logger] in
                logger?.info("BackgroundTask Expiration Handler Called")
                guard let self = self else { return }
                self.invalidateBackgroundActivity()
                self.synchronizer.stop()
            })
        }
    }
    
    private func invalidateBackgroundActivity() {
        guard self.taskIdentifier != .invalid else {
            return
        }
        UIApplication.shared.endBackgroundTask(self.taskIdentifier)
        self.taskIdentifier = .invalid
    }
    
    func subscribeToApplicationNotificationsPublishers() {
        self.isSubscribedToAppDelegateEvents = true
        let center = NotificationCenter.default
        
        center.publisher(for: UIApplication.willEnterForegroundNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self, weak logger] _ in
                
                logger?.debug("applicationWillEnterForeground")
                guard let self = self else { return }
                
                self.invalidateBackgroundActivity()
                do {
                    try self.synchronizer.start()
                } catch {
                    logger?.debug("applicationWillEnterForeground --> Error restarting: \(error)")
                }
                
            }
            .store(in: &appCycleCancellables)
        
        center.publisher(for: UIApplication.willResignActiveNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self, weak logger] _ in
                self?.registerBackgroundActivity()
                logger?.debug("applicationWillResignActive")
            }
            .store(in: &appCycleCancellables)
        
        center.publisher(for: UIApplication.willTerminateNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.synchronizer.stop()
            }
            .store(in: &appCycleCancellables)
        
    }
    
    func unsubscribeFromApplicationNotificationsPublishers() {
        self.isSubscribedToAppDelegateEvents = false
        self.appCycleCancellables.forEach { $0.cancel() }
    }
}

extension ZECCWalletEnvironment {
    static var appBuild: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    static var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    func isValidShieldedAddress(_ address: String) -> Bool {
        self.initializer.isValidShieldedAddress(address)
    }
    
    func isValidTransparentAddress(_ address: String) -> Bool {
        self.initializer.isValidTransparentAddress(address)
    }
    
    func isValidAddress(_ address: String) -> Bool {
        self.initializer.isValidShieldedAddress(address) || self.initializer.isValidTransparentAddress(address)
    }
    func sufficientFundsToSend(amount: Double) -> Bool {
        return sufficientFunds(availableBalance: self.initializer.getVerifiedBalance(), zatoshiToSend: amount.toZatoshi())
    }
    private func sufficientFunds(availableBalance: Int64, zatoshiToSend: Int64) -> Bool {
        availableBalance - zatoshiToSend  - Int64(ZcashSDK.defaultFee()) >= 0
    }
    static var minerFee: Double {
        Int64(ZcashSDK.defaultFee()).asHumanReadableZecBalance()
    }
}
