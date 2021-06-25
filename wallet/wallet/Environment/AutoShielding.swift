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
