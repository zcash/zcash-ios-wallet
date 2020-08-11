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
    
    let endpoint = LightWalletEndpoint(address: ZcashSDK.isMainnet ? "lightwalletd.z.cash" : "lightwalletd.testnet.z.cash", port: 9067, secure: true)
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
        guard let keys = SeedManager.default.getKeys(), keys.count > 0 else {
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
        cancellables.append(
            self.synchronizer.status.map({
                status -> WalletState in
                switch status {
                case .synced:
                    return WalletState.synced
                case .syncing:
                    return WalletState.syncing
                default:
                    return Self.getInitialState()
                    
                }
            }).sink(receiveValue: { status  in
                self.state = status
            })
        )
        
    }
    
    func createNewWallet() throws {
        
        guard let randomPhrase = MnemonicSeedProvider.default.randomMnemonic(),
            let randomSeed = MnemonicSeedProvider.default.toSeed(mnemonic: randomPhrase) else {
                throw WalletError.createFailed
        }
        let birthday = WalletBirthday.birthday(with: BlockHeight.max)
        try SeedManager.default.importSeed(randomSeed)
        try SeedManager.default.importBirthday(birthday.height)
        try SeedManager.default.importPhrase(bip39: randomPhrase)
        try self.initialize()
    }
    
    func initialize() throws {
        
        if let keys = try self.initializer.initialize(seedProvider: SeedManager.default, walletBirthdayHeight: try SeedManager.default.exportBirthday()) {
            
            SeedManager.default.saveKeys(keys)
        }
        
        
        self.synchronizer.start()
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
        
        if let rustError = error as? RustWeldingError {
            switch rustError {
            case .genericError(let message):
                return WalletError.genericErrorWithMessage(message: message)
            case .dataDbInitFailed(let message):
                return WalletError.initializationFailed(message: message)
            case .dataDbNotEmpty:
                return WalletError.initializationFailed(message: "attempt to initialize a db that was not empty")
            case .saplingSpendParametersNotFound:
                return WalletError.createFailed
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
        availableBalance - zatoshiToSend  - Int64(ZcashSDK.MINERS_FEE_ZATOSHI) >= 0
    }
    static var minerFee: Double {
        Int64(ZcashSDK.MINERS_FEE_ZATOSHI).asHumanReadableZecBalance()
    }
}
