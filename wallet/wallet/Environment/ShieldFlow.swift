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
    var cancellables = [AnyCancellable]()
    private var synchronizer: CombineSynchronizer = ZECCWalletEnvironment.shared.synchronizer
    
    private init() {
        self.status = CurrentValueSubject<Status,Error>(.notStarted)
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
        do {
            let derivationTool = DerivationTool.default
            let s = try SeedManager.default.exportPhrase()
            let seed = try MnemonicSeedProvider.default.toSeed(mnemonic: s)
            let keys = try derivationTool.deriveSpendingKeys(seed: seed, numberOfAccounts: 1)
            guard let sk = keys.first else {
                self.status.send(completion: .failure(KeyDerivationErrors.unableToDerive))
                return }
            let tsk = try derivationTool.deriveTransparentPrivateKey(seed: seed)
            
            self.synchronizer.shieldFunds(spendingKey: sk,
                                          transparentSecretKey: tsk,
                                          memo: "Shielding is Fun!",
                                          from: 0)
                .receive(on: DispatchQueue.main)
                .sink { [weak self](completion) in
                    switch completion {
                    case .failure(let e):
                        logger.error("failed to shield funds \(e.localizedDescription)")
                        tracker.report(handledException: DeveloperFacingErrors.handledException(error: e))
                        self?.status.send(completion: .failure(e))
                    case .finished:
                        self?.status.send(completion: .finished)
                    }
                } receiveValue: { [weak self](p) in
                    logger.debug("shielded \(p)")
                    self?.status.send(.ended)
                }
                .store(in: &cancellables)

        } catch {
            self.status.send(completion: .failure(error))
        }
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



final class MockFailingShieldFlow: ShieldingPowers {
    
    var status: CurrentValueSubject<ShieldFlow.Status, Error> = CurrentValueSubject(ShieldFlow.Status.notStarted)
    
    func shield() {
        status.send(.shielding)
        DispatchQueue.global().asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.status.send(completion: .failure(SynchronizerError.generalError(message: "Could Not Shield Funds")))
        }
    }
}

final class MockSuccessShieldFlow: ShieldingPowers {
    var status: CurrentValueSubject<ShieldFlow.Status, Error> = CurrentValueSubject(ShieldFlow.Status.notStarted)
    
    func shield() {
        status.send(.shielding)
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.status.send(completion: .finished)
        }
    }
}
