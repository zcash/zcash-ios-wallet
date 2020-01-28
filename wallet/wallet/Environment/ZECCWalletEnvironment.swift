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
    @Published var state = WalletState.uninitialized
    
    let endpoint = LightWalletEndpoint(address: ZcashSDK.isMainnet ? "lightwalletd.z.cash" : "lightwalletd.testnet.z.cash", port: "9067", secure: true)
    var dataDbURL: URL
    var cacheDbURL: URL
    var pendingDbURL: URL
    var outputParamsURL: URL
    var spendParamsURL: URL
    var initializer: Initializer
    var synchronizer: CombineSynchronizer
    var cancellables = [AnyCancellable]()
    init() throws {
        self.dataDbURL = try URL.dataDbURL()
        self.cacheDbURL = try URL.cacheDbURL()
        self.pendingDbURL = try URL.pendingDbURL()
        self.outputParamsURL = try URL.outputParamsURL()
        self.spendParamsURL = try  URL.spendParamsURL()
        
        self.initializer = Initializer(
            cacheDbURL: self.cacheDbURL,
            dataDbURL: self.dataDbURL,
            pendingDbURL: self.pendingDbURL,
            endpoint: endpoint,
            spendParamsURL: self.spendParamsURL,
            outputParamsURL: self.outputParamsURL)
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
                    return WalletState.initalized
                
                }
                }).sink(receiveValue: { status  in
                    self.state = status
                })
            )
        self.state = isInitialized ? WalletState.initalized : WalletState.uninitialized
    }
    
    var isInitialized: Bool {
        initializer.getAddress() != nil && (try? SeedManager.default.exportSeed()) != nil
    }
    
    
    func initialize() throws {
        
        if let keys = try self.initializer.initialize(seedProvider: SeedManager.default, walletBirthdayHeight: 620000) {
            
            SeedManager.default.saveKeys(keys)
        }
        
        
        self.synchronizer.start()
    }
    
    deinit {
        cancellables.forEach {
            c in
            c.cancel()
        }
    }
    
}
