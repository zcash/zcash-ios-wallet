//
//  ShieldFlow.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 1/27/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import ZcashLightClientKit

protocol ShieldingPowers {
    var status: CurrentValueSubject<ShieldFlow.Status,Error> { get set }
    func shield()
}

final class ShieldFlow: ShieldingPowers {
    
    enum Status {
        case notStarted
        case shielding
        case ended
    }
    
    var status: CurrentValueSubject<ShieldFlow.Status, Error>
    var shielder: AutoShielder
    var cancellables = [AnyCancellable]()
    private var synchronizer: CombineSynchronizer = ZECCWalletEnvironment.shared.synchronizer
    
    private init() {
        self.status = CurrentValueSubject<Status,Error>(.notStarted)
        self.shielder = AutoShieldingBuilder.manualShielder(keyProvider: DefaultShieldingKeyProvider(), shielder: synchronizer.synchronizer)
    }
    
    private static var _currentFlow: ShieldingPowers?
    
    static var current: ShieldingPowers {
        guard let flow = _currentFlow else {
            let f = ShieldFlow()
            _currentFlow = f
            return f
        }
        
        return flow
    }
    
    static func endFlow() {
        _currentFlow = nil
    }
    
    func shield() {
        self.status.send(.shielding)
        self.shielder.shield()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                   case .failure(let e):
                       logger.error("failed to shield funds \(e.localizedDescription)")
                       tracker.report(handledException: DeveloperFacingErrors.handledException(error: e))
                       self?.status.send(completion: .failure(e))
                   case .finished:
                       self?.status.send(completion: .finished)
                   }
            } receiveValue: { [weak self] result in
                switch result{
                case .notNeeded:
                    logger.warn(" -- WARNING -- You manually shielded funds but the result was not needed. This is probably a programming error")
                case .shielded(let pendingTx):
                    logger.debug("shielded \(pendingTx)")
                }
                self?.status.send(.ended)
            }
            .store(in: &cancellables)
    }
}

fileprivate struct ShieldFlowEnvironmentKey: EnvironmentKey {
    static let defaultValue: ShieldingPowers = ShieldFlow.current
}
extension View {
    func shieldFlowEnvironment(_ env: ShieldingPowers) -> some View {
        environment(\.shieldFlowEnvironment, env)
    }
}
extension EnvironmentValues {
    var shieldFlowEnvironment: ShieldingPowers  {
        get {
            self[ShieldFlowEnvironmentKey.self]
        }
        set {
            self[ShieldFlowEnvironmentKey.self] = newValue
        }
    }
}
