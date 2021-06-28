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

protocol ShieldingCapable: AnyObject {
    /**
    Sends zatoshi.
    - Parameter spendingKey: the key that allows spends to occur.
    - Parameter transparentSecretKey: the key that allows to spend transaprent funds
    - Parameter memo: the optional memo to include as part of the transaction.
    - Parameter accountIndex: the optional account id that will be used to shield  your funds to. By default, the first account is used.
    */
    func shieldFunds(spendingKey: String, transparentSecretKey: String, memo: String?, from accountIndex: Int, resultBlock: @escaping (_ result: Result<PendingTransactionEntity, Error>) -> Void)
}

protocol AutoShieldingStrategy {
    var shouldAutoShield: Bool { get }
    func shield(autoShielder: AutoShielder) -> Future<AutoShieldingResult, Error>
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

class Session: UserSession {
    
    private init(){}
    
    static var unique = Session()
    private(set) var didFirstSync: Bool = false
    private(set) var alreadyAutoShielded: Bool = false
    
    func markFirstSync() {
        didFirstSync = true
    }
    
    func markAutoShield() {
        alreadyAutoShielded = true
    }
}

protocol AutoShielder: AnyObject {
    var keyProviding: ShieldingKeyProviding {get }
    var strategy: AutoShieldingStrategy { get }
    var shielder: ShieldingCapable { get }
    var keyDeriver: KeyDeriving { get }
    func shield() -> Future<AutoShieldingResult, Error>
}

extension AutoShielder {
    func shield() -> Future<AutoShieldingResult, Error> {
        guard strategy.shouldAutoShield else {
            return Future<AutoShieldingResult,Error> { promise in
                promise(.success(.notNeeded))
            }
        }
            
        return Future<AutoShieldingResult, Error> {[weak self] promise in
            
            guard let self = self else {
                promise(.failure(ShieldFundsError.shieldingFailed(underlyingError: DeveloperFacingErrors.unexpectedBehavior(message: "Weak reference is nil. This is probably a programing error"))))
                return
            }
            
            do {
                let spendingKeyKeyPair = try self.keyProviding.getSpendingKey()
                let tskKeyPair = try self.keyProviding.getTransparentSecretKey()
                let fromAccount = tskKeyPair.account
                let tsk = tskKeyPair.privateKey
                let spendingKey = spendingKeyKeyPair.privateKey
                // TODO: add parameters to vary the index and the account to shield from
                let tAddress = try self.keyDeriver.deriveTransparentAddressFromPrivateKey(tsk)
                
                self.shielder.shieldFunds(spendingKey: spendingKey, transparentSecretKey: tsk, memo: "Shielding from your t-address:\(tAddress)", from: fromAccount) { result in
                    
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

class ConcreteAutoShielder: AutoShielder {
    var keyDeriver: KeyDeriving
    
    var shielder: ShieldingCapable
    var strategy: AutoShieldingStrategy
    var keyProviding: ShieldingKeyProviding
    
    init(autoShielding: AutoShieldingStrategy,
         keyProviding: ShieldingKeyProviding,
         keyDeriver: KeyDeriving,
         shielder: ShieldingCapable) {
        self.strategy = autoShielding
        self.keyProviding = keyProviding
        self.shielder = shielder
        self.keyDeriver = keyDeriver
    }
}

class ThresholdDrivenAutoShielding: AutoShieldingStrategy {
    
    var shouldAutoShield: Bool {
        // Shields after first sync, once per session.
        session.didFirstSync && !session.alreadyAutoShielded
    }
    var session: UserSession
    var threshold: Int64

    init(session: UserSession,
         threshold zatoshiThreshold: Int64) {
        self.session = session
        self.threshold = zatoshiThreshold
    }
    
    func shield(autoShielder: AutoShielder) -> Future<AutoShieldingResult, Error> {
        // this strategy attempts to shield once per session, regardless of the result.
        self.session.markAutoShield()
        return autoShielder.shield()
    }
}

class ManualShielding: AutoShieldingStrategy {
    var shouldAutoShield: Bool {
        true
    }
    
    func shield(autoShielder: AutoShielder) -> Future<AutoShieldingResult, Error> {
        autoShielder.shield()
    }
}

class AutoShieldingBuilder {
    static func manualShielder(keyProvider: ShieldingKeyProviding,
                               shielder: ShieldingCapable) -> AutoShielder {
        
        return ConcreteAutoShielder(autoShielding: ManualShielding(),
                                    keyProviding: keyProvider,
                                    keyDeriver: DerivationTool.default,
                                    shielder: shielder)
    }
    
    static func thresholdAutoShielder(keyProvider: ShieldingKeyProviding,
                                      shielder: ShieldingCapable,
                                      threshold: Int64) -> AutoShielder {
        
        return ConcreteAutoShielder(
            autoShielding: ThresholdDrivenAutoShielding(session: Session.unique,
                                                        threshold: threshold),
            keyProviding: keyProvider,
            keyDeriver: DerivationTool.default,
            shielder: shielder)
    }
}
