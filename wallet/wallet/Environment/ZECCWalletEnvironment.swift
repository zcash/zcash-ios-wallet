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
    enum WalletError: Error {
        case createFailed
        case initializationFailed(message: String)
        case genericError(message: String)
        case connectionFailed(message: String)
        case maxRetriesReached(attempts: Int)
    }
    static let genericErrorMessage = "An error ocurred, please check your device logs"
    static var shared: ZECCWalletEnvironment = try! ZECCWalletEnvironment() // app can't live without this existing.
    
    @Published var state: WalletState
    
    let endpoint = LightWalletEndpoint(address: ZcashSDK.isMainnet ? "lightwalletd.z.cash" : "lightwalletd.testnet.z.cash", port: "9067", secure: true)
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
    
    static func mapError(error: Error) -> ZECCWalletEnvironment.WalletError {
        
        if let rustError = error as? RustWeldingError {
            switch rustError {
            case .genericError(let message):
                return ZECCWalletEnvironment.WalletError.genericError(message: message)
            case .dataDbInitFailed(let message):
                return ZECCWalletEnvironment.WalletError.genericError(message: message)
            case .dataDbNotEmpty:
                return ZECCWalletEnvironment.WalletError.genericError(message: "attempt to initialize a db that was not empty")
            case .saplingSpendParametersNotFound:
                return ZECCWalletEnvironment.WalletError.createFailed
            }
        } else if let synchronizerError = error as? SynchronizerError {
            switch synchronizerError {
            case .generalError(let message):
                return ZECCWalletEnvironment.WalletError.genericError(message: message)
            case .initFailed(let message):
                return WalletError.initializationFailed(message: "Synchronizer failed to initialize: \(message)")
            case .syncFailed:
                return WalletError.genericError(message: "Synchronizing failed")
            case .connectionFailed(let message):
                return WalletError.connectionFailed(message: message)
            case .maxRetryAttemptsReached(attempts: let attempts):
                return WalletError.maxRetriesReached(attempts: attempts)
            }
        }
        
        return ZECCWalletEnvironment.WalletError.genericError(message: Self.genericErrorMessage)
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
}
