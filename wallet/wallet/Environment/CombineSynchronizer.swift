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
    var unifiedAddress: UnifiedAddress! // FIXMME: There's no sense of a key-less synchronizer
    private(set) var synchronizer: SDKSynchronizer
    var walletDetailsBuffer: CurrentValueSubject<[DetailModel],Never>
    var status: CurrentValueSubject<Status,Never>
    var progress: CurrentValueSubject<Float,Never>
    var syncBlockHeight: CurrentValueSubject<BlockHeight,Never>
    var minedTransaction = PassthroughSubject<PendingTransactionEntity,Never>()
    var shieldedBalance: CurrentValueSubject<WalletBalance, Never>
    var transparentBalance: CurrentValueSubject<WalletBalance, Never>
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
    
    var latestHeight: Future<BlockHeight,Error> {
        Future<BlockHeight,Error>() {
            [weak self ] promise in
            
            guard let self = self else { return }
            self.synchronizer.latestHeight { (result) in
                switch result {
                case .success(let height):
                    promise(.success(height))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    func latestDownloadedHeight() throws -> BlockHeight {
        try self.synchronizer.latestDownloadedHeight()
    }
    
    init(initializer: Initializer) throws {
        self.walletDetailsBuffer = CurrentValueSubject([DetailModel]())
        self.synchronizer = try SDKSynchronizer(initializer: initializer)
        self.status = CurrentValueSubject(.disconnected)
        self.progress = CurrentValueSubject(0)
        self.balance = CurrentValueSubject(0)
        self.shieldedBalance = CurrentValueSubject(Balance(verified: 0, total: 0))
        self.transparentBalance = CurrentValueSubject(Balance(verified: 0, total: 0))
        self.verifiedBalance = CurrentValueSubject(0)
        self.syncBlockHeight = CurrentValueSubject(ZcashSDK.SAPLING_ACTIVATION_HEIGHT)
        
        // BUGFIX: transactions history empty when synchronizer fails to connect to server
        // fill with initial values
        self.updatePublishers()
        
        // Subscribe to SDKSynchronizer notifications
        
        NotificationCenter.default.publisher(for: .synchronizerSynced)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
                self.updatePublishers()
        }).store(in: &cancellables)
        

        NotificationCenter.default.publisher(for: .synchronizerStarted)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
            self?.status.send(.syncing)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerProgressUpdated)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (progressNotification) in
            guard let self = self else { return }
            guard let newProgress = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.progress] as? Float else { return }
            self.progress.send(newProgress)
            
            guard let blockHeight = progressNotification.userInfo?[SDKSynchronizer.NotificationKeys.blockHeight] as? BlockHeight else { return }
            self.syncBlockHeight.send(blockHeight)
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerMinedTransaction)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] minedNotification in
            guard let self = self else { return }
            guard let minedTx = minedNotification.userInfo?[SDKSynchronizer.NotificationKeys.minedTransaction] as? PendingTransactionEntity else { return }
            self.minedTransaction.send(minedTx)
        }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerFailed)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] (notification) in
            
            guard let self = self else { return }
            
            guard let error = notification.userInfo?[SDKSynchronizer.NotificationKeys.error] as? Error else {
                self.errorPublisher.send(WalletError.genericErrorWithMessage(message: "An error ocurred, but we can't figure out what it is. Please check device logs for more details")
                )
                return
            }
                
            self.errorPublisher.send(error)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerStopped)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.status.send(.stopped)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerDisconnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.status.send(.disconnected)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerSyncing)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.status.send(.syncing)
            }
            .store(in: &cancellables)
    }
    
    
    
    func prepare() throws {
        guard let uvk = self.initializer.viewingKeys.first else {
            throw SynchronizerError.initFailed(message: "unable to derive unified address. this is probably a programming error")
        }
        do {
            self.unifiedAddress = try DerivationTool.default.deriveUnifiedAddressFromUnifiedViewingKey(uvk)
        } catch {
            throw SynchronizerError.initFailed(message: "unable to derive unified address: \(error.localizedDescription)")
        }
        
        try self.synchronizer.prepare()
    }
    
    func start(retry: Bool = false) throws {
        
        do {
            if retry {
                stop()
            }
            try synchronizer.start(retry: retry)
        } catch {
            logger.error("error starting \(error)")
            throw error
        }
    }
    
    func stop() {
        synchronizer.stop()
    }
    
    func cancel(pendingTransaction: PendingTransactionEntity) -> Bool {
        synchronizer.cancelSpend(transaction: pendingTransaction)
    }
    
    func rewind(_ policy: RewindPolicy) throws {
        try synchronizer.rewind(policy)
    }
    
    func updatePublishers() {
        if let ua = self.unifiedAddress,
           let tBalance = try? synchronizer.getTransparentBalance(address: ua.tAddress) {
            self.transparentBalance.send(tBalance)
        } else {
            self.transparentBalance.send(Balance(verified: 0, total: 0))
        }
        
        let shieldedVerifiedBalance = synchronizer.getShieldedVerifiedBalance()
        let shieldedTotalBalance = synchronizer.getShieldedBalance(accountIndex: 0)
        
        self.shieldedBalance.send(Balance(verified: shieldedVerifiedBalance, total: shieldedTotalBalance))
        
        self.balance.send(initializer.getBalance().asHumanReadableZecBalance())
        self.verifiedBalance.send(initializer.getVerifiedBalance().asHumanReadableZecBalance())
        self.status.send(synchronizer.status)
        self.walletDetails.sink(receiveCompletion: { _ in
            }) { [weak self] (details) in
                guard !details.isEmpty else { return }
                self?.walletDetailsBuffer.send(details)
        }
        .store(in: &self.cancellables)
    }
    
    deinit {
        synchronizer.stop()
        for c in cancellables {
            c.cancel()
        }
    }
    
    func send(with spendingKey: String, zatoshi: Int64, to recipientAddress: String, memo: String?,from account: Int) -> Future<PendingTransactionEntity,Error>  {
        Future<PendingTransactionEntity, Error>() { [weak self]
            promise in
            self?.synchronizer.sendToAddress(spendingKey: spendingKey, zatoshi: zatoshi, toAddress: recipientAddress, memo: memo, from: account) { [weak self](result) in
                self?.updatePublishers()
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success(let pendingTx):
                    promise(.success(pendingTx))
                }
            }
        }
    }
    
    public func shieldFunds(spendingKey: String, transparentSecretKey: String, memo: String?, from accountIndex: Int) -> Future<PendingTransactionEntity, Error> {
        Future<PendingTransactionEntity, Error>() { [weak self]
            promise in
            self?.synchronizer.shieldFunds(spendingKey: spendingKey, transparentSecretKey: transparentSecretKey, memo: memo, from: accountIndex) {[weak self] (result) in
                self?.updatePublishers()
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success(let pendingTx):
                    promise(.success(pendingTx))
                }
            }
        }
    }
    
    func unshieldedBalance(for tAddress: String) -> Future<WalletBalance,Error> {
        Future<WalletBalance,Error>() { [weak self]
            promise in
            
            guard let self = self else { return }
            
            let walletBirthday = (try? SeedManager.default.exportBirthday()) ?? ZcashSDK.SAPLING_ACTIVATION_HEIGHT
            
            self.synchronizer.refreshUTXOs(address: tAddress, from: walletBirthday, result: { [weak self] (r) in
                guard let self = self else { return }
                switch r {
                case .success:
                    do {
                        let balance = try self.synchronizer.getTransparentBalance(address: tAddress)
                        promise(.success(balance))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }
    }
    
    func cachedUnshieldedBalance(for tAddress: String) -> Future<WalletBalance,Error>  {
        Future<WalletBalance,Error>() { [weak self] promise in
            guard let self = self else { return }
            do {
                promise(.success(try self.synchronizer.getTransparentBalance(address: tAddress)))
            } catch {
                promise(.failure(error))
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

extension CombineSynchronizer {
    func fullRescan() {
        do {
            try self.rewind(.birthday)
            try self.start(retry: true)
        } catch {
            logger.error("Full rescan failed \(error)")
        }
    }
    
    func quickRescan() {
        do {
            let blocksPerDay = 60*60*24/75
            let oneWeekOfblocks = blocksPerDay * 7      //8064
            let rewindHeight = max(try self.latestDownloadedHeight() - oneWeekOfblocks, try SeedManager.default.exportBirthday())
            try self.rewind(.height(blockheight: rewindHeight))
            try self.start(retry: true)
        } catch {
            logger.error("Quick rescan failed \(error)")
        }
    }
    
    func getTransparentAddress(account: Int = 0) -> TransparentAddress? {
        self.synchronizer.getTransparentAddress(accountIndex: account)
    }
    func getShieldedAddress(account: Int = 0) -> SaplingShieldedAddress? {
        self.synchronizer.getShieldedAddress(accountIndex: account)
    }
}


fileprivate struct Balance: WalletBalance {
    var verified: Int64
    var total: Int64
}
