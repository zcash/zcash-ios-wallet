//
//  CombineSynchronizer.swift
//  wallet
//
//  Created by Francisco Gindre on 1/27/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine
import ZcashLightClientKit
class CombineSynchronizer {
    
    var initializer: Initializer
    private var synchronizer: SDKSynchronizer
    
    var status: CurrentValueSubject<Status, Never>
    var progress: CurrentValueSubject<Float,Never>
    var minedTransaction = PassthroughSubject<PendingTransactionEntity,Never>()
    var balance: CurrentValueSubject<Double,Never>
    var verifiedBalance: CurrentValueSubject<Double,Never>
    var cancellables = [AnyCancellable]()
    init(initializer: Initializer) throws {
        self.initializer = initializer
        self.synchronizer = try SDKSynchronizer(initializer: initializer)
        self.status = CurrentValueSubject(.synced)
        self.progress = CurrentValueSubject(0)
        self.balance = CurrentValueSubject(0)
        self.verifiedBalance = CurrentValueSubject(0)
        
        cancellables.append(
            NotificationCenter.default.publisher(for: .synchronizerSynced).sink(receiveValue: { _ in
                self.balance.send(initializer.getBalance().asHumanReadableZecBalance())
                self.verifiedBalance.send(initializer.getVerifiedBalance().asHumanReadableZecBalance())
            })
        )
        cancellables.append( NotificationCenter.default.publisher(for: .synchronizerStarted).sink { _ in
            self.status.send(.syncing)
            }
        )
        cancellables.append(
            NotificationCenter.default.publisher(for: .synchronizerProgressUpdated).receive(on: DispatchQueue.main).sink(receiveValue: { (progressNotification) in
                guard let newProgress = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.progress] as? Float else { return }
                self.progress.send(newProgress)
            })
        )
        cancellables.append(
            NotificationCenter.default.publisher(for: .synchronizerMinedTransaction).sink(receiveValue: {minedNotification in
                guard let minedTx = minedNotification.userInfo?[SDKSynchronizer.NotificationKeys.minedTransaction] as? PendingTransactionEntity else { return }
                self.minedTransaction.send(minedTx)
            })
        )
    }
    
    func start(){
        do {
            try synchronizer.start()
        } catch {
            print("error starting \(error)")
        }
    }
    
    func stop() {
        do {
            try synchronizer.stop()
        } catch {
            print("error stopping \(error)")
        }  
    }
    
    deinit {
        for c in cancellables {
            c.cancel()
        }
    }
}
