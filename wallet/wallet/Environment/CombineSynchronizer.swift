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
    
    var initializer: Initializer {
        synchronizer.initializer
    }
    private var synchronizer: SDKSynchronizer
    
    var walletDetailsBuffer: CurrentValueSubject<[DetailModel],Never>
    var status: CurrentValueSubject<Status,Never>
    var progress: CurrentValueSubject<Float,Never>
    var syncBlockHeight: CurrentValueSubject<BlockHeight,Never>
    var minedTransaction = PassthroughSubject<PendingTransactionEntity,Never>()
    var balance: CurrentValueSubject<Double,Never>
    var verifiedBalance: CurrentValueSubject<Double,Never>
    var cancellables = [AnyCancellable]()
    var errorPublisher = PassthroughSubject<Error, Never>()
    var receivedTransactions: Future<[ConfirmedTransactionEntity],Never> {
        Future<[ConfirmedTransactionEntity], Never>() {
            promise in
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else {
                    promise(.success([]))
                    return
                }
                promise(.success(self.synchronizer.receivedTransactions))
            }
        }
    }
    
    var sentTransactions: Future<[ConfirmedTransactionEntity], Never> {
        Future<[ConfirmedTransactionEntity], Never>() {
            promise in
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else {
                    promise(.success([]))
                    return
                }
                promise(.success(self.synchronizer.sentTransactions))
            }
        }
    }
    
    var pendingTransactions: Future<[PendingTransactionEntity], Never> {
        
        Future<[PendingTransactionEntity], Never>(){
            [weak self ] promise in
            
            guard let self = self else {
                promise(.success([]))
                return
            }
            
            DispatchQueue.global().async {
                promise(.success(self.synchronizer.pendingTransactions))
            }
        }
    }
        
    init(initializer: Initializer) throws {
        self.walletDetailsBuffer = CurrentValueSubject([DetailModel]())
        self.synchronizer = try SDKSynchronizer(initializer: initializer)
        self.status = CurrentValueSubject(.disconnected)
        self.progress = CurrentValueSubject(0)
        self.balance = CurrentValueSubject(0)
        self.verifiedBalance = CurrentValueSubject(0)
        self.syncBlockHeight = CurrentValueSubject(ZcashSDK.SAPLING_ACTIVATION_HEIGHT)
        
        NotificationCenter.default.publisher(for: .synchronizerSynced).sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
            self.balance.send(initializer.getBalance().asHumanReadableZecBalance())
            self.verifiedBalance.send(initializer.getVerifiedBalance().asHumanReadableZecBalance())
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerSynced).sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
            self.walletDetails.sink(receiveCompletion: { _ in
            }) { [weak self] (details) in
                guard !details.isEmpty else { return }
                self?.walletDetailsBuffer.send(details)
            }
            .store(in: &self.cancellables)
        }).store(in: &cancellables)
        NotificationCenter.default.publisher(for: .synchronizerStarted).sink { [weak self] _ in
            self?.status.send(.syncing)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerProgressUpdated).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] (progressNotification) in
            guard let self = self else { return }
            guard let newProgress = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.progress] as? Float else { return }
            self.progress.send(newProgress)
            
            guard let blockHeight = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.blockHeight] as? BlockHeight else { return }
            self.syncBlockHeight.send(blockHeight)
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerMinedTransaction).sink(receiveValue: { [weak self] minedNotification in
            guard let self = self else { return }
            guard let minedTx = minedNotification.userInfo?[SDKSynchronizer.NotificationKeys.minedTransaction] as? PendingTransactionEntity else { return }
            self.minedTransaction.send(minedTx)
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerFailed).sink {[weak self] (notification) in
            
            guard let self = self else { return }
            
            guard let error = notification.userInfo?[SDKSynchronizer.NotificationKeys.error] as? Error else {
                self.errorPublisher.send(WalletError.genericErrorWithMessage(message: "An error ocurred, but we can't figure out what it is. Please check device logs for more details")
                )
                return
            }
            self.errorPublisher.send(error)
        }.store(in: &cancellables)
        
    }
    
    func start(retry: Bool = false){
        
        do {
            if retry {
                stop()
            }
            try synchronizer.start(retry: retry)
        } catch {
            logger.error("error starting \(error)")
            self.errorPublisher.send(error)
        }
    }
    
    func stop() {
        synchronizer.stop()
    }
    
    func cancel(pendingTransaction: PendingTransactionEntity) -> Bool {
        synchronizer.cancelSpend(transaction: pendingTransaction)
    }
    
    deinit {
        for c in cancellables {
            c.cancel()
        }
    }
    
    func send(with spendingKey: String, zatoshi: Int64, to recipientAddress: String, memo: String?,from account: Int) -> Future<PendingTransactionEntity,Error>  {
        Future<PendingTransactionEntity, Error>() {
            promise in
            self.synchronizer.sendToAddress(spendingKey: spendingKey, zatoshi: zatoshi, toAddress: recipientAddress, memo: memo, from: account) { (result) in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success(let pendingTx):
                    promise(.success(pendingTx))
                }
            }
        }
    }
}

extension CombineSynchronizer {
    var walletDetails: Future<[DetailModel], Error> {
        Future<[DetailModel],Error>() {
            [weak self] promise in
            guard let self = self else {
                promise(.success([]))
                return
            }
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else { return }
                var collectables = Set<AnyCancellable>()
                
                do {
                    
                    let blockHeight = self.syncBlockHeight.value
                    let pending = try self.synchronizer.allPendingTransactions().map { DetailModel(pendingTransaction: $0, latestBlockHeight: blockHeight) }
                    
                    let txs = try self.synchronizer.allClearedTransactions().map { DetailModel(confirmedTransaction: $0, sent: ($0.toAddress != nil)) }.filter({ s in
                        pending.first { (p) -> Bool in
                            p.id == s.id
                            } == nil })
      
                    Publishers.Merge( Publishers.Sequence<[DetailModel],Never>(sequence: txs),
                                      Publishers.Sequence<[DetailModel],Never>(sequence: pending)
                    ).collect().sink { details in
                        
                        promise(.success(
                            details.sorted(by: { (a,b) in
                                a.date > b.date
                            })
                            )
                        )
                    }
                    .store(in: &collectables)
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
