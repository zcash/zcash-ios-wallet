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
    
    var status: CurrentValueSubject<Status, Never>
    var progress: CurrentValueSubject<Float,Never>
    var syncBlockHeight: CurrentValueSubject<BlockHeight,Never>
    var minedTransaction = PassthroughSubject<PendingTransactionEntity,Never>()
    var balance: CurrentValueSubject<Double,Never>
    var verifiedBalance: CurrentValueSubject<Double,Never>
    var cancellables = [AnyCancellable]()
    
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
        
        self.synchronizer = try SDKSynchronizer(initializer: initializer)
        self.status = CurrentValueSubject(.disconnected)
        self.progress = CurrentValueSubject(0)
        self.balance = CurrentValueSubject(0)
        self.verifiedBalance = CurrentValueSubject(0)
        self.syncBlockHeight = CurrentValueSubject(ZcashSDK.SAPLING_ACTIVATION_HEIGHT)
        
        NotificationCenter.default.publisher(for: .synchronizerSynced).sink(receiveValue: { _ in
            self.balance.send(initializer.getBalance().asHumanReadableZecBalance())
            self.verifiedBalance.send(initializer.getVerifiedBalance().asHumanReadableZecBalance())
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerStarted).sink { _ in
            self.status.send(.syncing)
        }.store(in: &cancellables)
        
        
        NotificationCenter.default.publisher(for: .synchronizerProgressUpdated).receive(on: DispatchQueue.main).sink(receiveValue: { (progressNotification) in
            guard let newProgress = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.progress] as? Float else { return }
            self.progress.send(newProgress)
            
            guard let blockHeight = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.blockHeight] as? BlockHeight else { return }
            self.syncBlockHeight.send(blockHeight)
        }).store(in: &cancellables)
        
        
        NotificationCenter.default.publisher(for: .synchronizerMinedTransaction).sink(receiveValue: {minedNotification in
            guard let minedTx = minedNotification.userInfo?[SDKSynchronizer.NotificationKeys.minedTransaction] as? PendingTransactionEntity else { return }
            self.minedTransaction.send(minedTx)
        }).store(in: &cancellables)
        
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
                var collectables = Set<AnyCancellable>()
                
                do {
                    
                    
                    let c =  Publishers.Sequence<[DetailModel], Never>(sequence: try self.synchronizer.allClearedTransactions().map {  DetailModel(confirmedTransaction: $0, sent: $0.toAddress != nil) })
                    
                    let p = Publishers.Sequence<[DetailModel], Never>(sequence: try self.synchronizer.allPendingTransactions().map { DetailModel(pendingTransaction: $0, latestBlockHeight: self.syncBlockHeight.value) })
                    
                    Publishers.Merge(c, p).collect().sink {
                        promise(.success($0))
                    }
                    .store(in: &collectables)
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}


extension Date {
    var transactionDetail: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy h:mm a"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
extension DetailModel {
    init(confirmedTransaction: ConfirmedTransactionEntity, sent: Bool = false) {
        self.date = Date(timeIntervalSince1970: confirmedTransaction.blockTimeInSeconds)
        self.id = confirmedTransaction.transactionEntity.transactionId.toHexStringTxId()
        self.shielded = confirmedTransaction.toAddress?.starts(with: "z") ?? true // FIXME: find a better way to do thies
        self.status = sent ? .paid(success: confirmedTransaction.minedHeight > 0) : .received
        self.subtitle = sent ? "Sent" : "Received" + " \(self.date.transactionDetail)"
        self.zAddress = confirmedTransaction.toAddress
        self.zecAmount = Int64(confirmedTransaction.value).asHumanReadableZecBalance()
    }
    init(pendingTransaction: PendingTransactionEntity, latestBlockHeight: BlockHeight? = nil) {
        self.date = Date(timeIntervalSince1970: pendingTransaction.createTime)
        self.id = pendingTransaction.rawTransactionId?.toHexStringTxId() ?? String(pendingTransaction.createTime)
        self.shielded = pendingTransaction.toAddress.starts(with: "z") // FIXME: find a better way to do thies
        self.status = .paid(success: pendingTransaction.isSubmitSuccess)
        if let latest = latestBlockHeight {
            self.subtitle = "\(abs(latest - pendingTransaction.expiryHeight - ZcashSDK.EXPIRY_OFFSET)) of 10 Confirmations"
        } else {
            self.subtitle = "Sent \(self.date.transactionDetail)"
        }
        self.zAddress = pendingTransaction.toAddress
        self.zecAmount = Int64(pendingTransaction.value).asHumanReadableZecBalance()
        
    }
}
