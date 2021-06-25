//
//  AutoShielding.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 6/25/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine
import ZcashLightClientKit

enum AutoShieldingResult {
    case notNeeded
    case shielded(pendingTx: PendingTransactionEntity)
}

protocol AutoShieldingStrategy {
    var shouldAutoShield: Bool { get }
    func shield() -> Future<AutoShieldingResult,Error>
}

protocol UserSession {
    var didFirstSync: Bool { get }
    var alreadyAutoShielded: Bool { get }
    func markFirstSync()
    func markAutoShield()
}

typealias PrivateKeyAccountIndexPair = (privateKey: String, account: Int, index: Int)

protocol ShieldingKeyProviding {
    func getTransparentSecretKey() throws -> PrivateKeyAccountIndexPair
    func getSpendingKey() throws -> PrivateKeyAccountIndexPair
}

class Session {
    static var unique = Session()
    
    private init(){}
    
    private var didFirstSync: Bool = false
    private var alreadyAutoShielded: Bool = false
    
    func markFirstSync() {
        didFirstSync = true
    }
    
    func markAutoShield() {
        alreadyAutoShielded = true
    }
}

protocol AutoShielder {
    var strategy: AutoShieldingStrategy { get }
    func shield() -> Future<AutoShieldingResult, Error>
}

extension AutoShielder {
    func shield() -> Future<AutoShieldingResult, Error> {
        guard strategy.shouldAutoShield else {
            return Future<AutoShieldingResult,Error> { promise in
                promise(.success(.notNeeded))
            }
        }
            
        return strategy.shield()
    }
}

class ConcreteAutoShielder: AutoShielder {
    
    var strategy: AutoShieldingStrategy
    
    init(autoShielding: AutoShieldingStrategy) {
        self.strategy = autoShielding
    }
}

class ThresholdDrivenAutoShielding: AutoShieldingStrategy {
    
    var shouldAutoShield: Bool {
        // Shields after first sync, once per session.
        session.didFirstSync && !session.alreadyAutoShielded
    }
    
    var synchronizer: Synchronizer
    var session: UserSession
    var keyProviding: ShieldingKeyProviding
    var threshold: Int64

    init(session: UserSession,
         synchronizer: Synchronizer,
         keyProviding: ShieldingKeyProviding,
         threshold zatoshiThreshold: Int64) {
        self.session = session
        self.synchronizer = synchronizer
        self.keyProviding = keyProviding
        self.threshold = zatoshiThreshold
    }
    
    func shield() -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult, Error> { promise in
            
            do {
                let spendingKeyKeyPair = try self.keyProviding.getSpendingKey()
                let tskKeyPair = try self.keyProviding.getTransparentSecretKey()
                let fromAccount = tskKeyPair.account
                let tsk = tskKeyPair.privateKey
                let spendingKey = spendingKeyKeyPair.privateKey
                // TODO: add parameters to vary the index and the account to shield from
                let tAddress = try DerivationTool.default.deriveTransparentAddressFromPrivateKey(tsk)
                
                // this strategy attempts to shield once per session, regardless of the result.
                self.session.markAutoShield()
                
                self.synchronizer.shieldFunds(spendingKey: spendingKey, transparentSecretKey: tsk, memo: "Shielding from your t-address:\(tAddress)", from: fromAccount) { result in
                    
                    switch result {
                    case .success(let pendingTx):
                        promise(.success(.shielded(pendingTx: pendingTx)))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            } catch {
                promise(.failure(ShieldFundsError.keyDerivationError(underlyingError: error)))
            }
        }
    }
}
