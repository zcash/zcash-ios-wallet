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
    enum SubscriberErrors: Error {
        case notifactionMissingValueForKey(_ key: String)
    }
    
    var initializer: Initializer {
        synchronizer.initializer
    }
    var unifiedAddress: UnifiedAddress! // FIXMME: There's no sense of a key-less synchronizer
    private(set) var synchronizer: SDKSynchronizer
    var walletDetailsBuffer: CurrentValueSubject<[DetailModel],Never>
    var connectionState: CurrentValueSubject<ConnectionState,Never>
    var syncStatus: CurrentValueSubject<SyncStatus,Never>
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
        self.syncStatus = CurrentValueSubject(.disconnected)
        self.balance = CurrentValueSubject(0)
        self.shieldedBalance = CurrentValueSubject(Balance(verified: 0, total: 0))
        self.transparentBalance = CurrentValueSubject(Balance(verified: 0, total: 0))
        self.verifiedBalance = CurrentValueSubject(0)
        self.syncBlockHeight = CurrentValueSubject(ZcashSDK.SAPLING_ACTIVATION_HEIGHT)
        self.connectionState = CurrentValueSubject(self.synchronizer.connectionState)
        
        
        // Subscribe to SDKSynchronizer notifications
        
        NotificationCenter.default.publisher(for: .synchronizerSynced)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
                self.updatePublishers()
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
            
        Publishers.Merge(NotificationCenter.default.publisher(for: .blockProcessorStatusChanged), NotificationCenter.default.publisher(for: .blockProcessorUpdated))
            .receive(on: DispatchQueue.main)
            .compactMap { n -> SyncStatus? in
                guard let userInfo = n.userInfo else {
                    logger.error("error: \(SubscriberErrors.notifactionMissingValueForKey("userInfo"))")
                    return nil }
                
                switch  n.name {
                case .blockProcessorStatusChanged:
                    guard let status = userInfo[CompactBlockProcessorNotificationKey.newStatus] as? CompactBlockProcessor.State else {
                        logger.error("error: \(SubscriberErrors.notifactionMissingValueForKey(CompactBlockProcessorNotificationKey.progress))")
                        return nil}
                    return status.syncStatus
                case .blockProcessorUpdated:
                    guard let update = userInfo[CompactBlockProcessorNotificationKey.progress] as? CompactBlockProgress else {
                        logger.error("error: \(SubscriberErrors.notifactionMissingValueForKey(CompactBlockProcessorNotificationKey.progress))")
                        return nil }
                    return update.syncStatus
                default:
                    return nil
                }
                
            }
            .sink(receiveValue: { [weak self] status in
                self?.syncStatus.send(status)
            })
            .store(in: &cancellables)
            
            
        NotificationCenter.default.publisher(for: .blockProcessorUpdated)
            .receive(on: DispatchQueue.main)
            .map { notification -> CompactBlockProgress? in
                
                guard let progress = notification.userInfo?[CompactBlockProcessorNotificationKey.progress] as? CompactBlockProgress else {
                    let error = SubscriberErrors.notifactionMissingValueForKey(CompactBlockProcessorNotificationKey.progress)
                    
                    tracker.report(handledException: error)
                    return nil
                }
                
                return progress
            }
            
            .compactMap({ progress -> SyncStatus? in
                
                switch progress {
                
                case .download(let progressReport):
                    return SyncStatus.downloading(progressReport)
                case .validate:
                    return .validating
                case .scan(let progressReport):
                    return .scanning(progressReport)
                case .enhance(let enhancingReport):
                    return .enhancing(enhancingReport)
                case .fetch:
                    return .fetching
                case .none:
                    return nil
                }
            })
            .sink(receiveValue: { [weak self] status in
                self?.syncStatus.send(status)
            })
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: .synchronizerConnectionStateChanged)
            .compactMap { notification -> ConnectionState? in
                guard let connectionState = notification.userInfo?[SDKSynchronizer.NotificationKeys.currentConnectionState] as? ConnectionState else {
                    return nil
                }
                return connectionState
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.connectionState.send(value)
            })
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
        
        tryToCopyParamsToNewLocation()
        
        try self.synchronizer.prepare()
        
        // BUGFIX: transactions history empty when synchronizer fails to connect to server
        // fill with initial values
        self.updatePublishers()
    }
    
    func tryToCopyParamsToNewLocation() {

        do {
            
            let manager = FileManager.default
            
            let newSpendParamsURL = try URL.spendParamsURL()
            
            
            if let previousSpendParamsURL = URL.bundledSpendParamsURL(),
               !manager.isFilePresent(newSpendParamsURL) {
                try? manager.copyItem(at: previousSpendParamsURL, to: newSpendParamsURL)
            }
            
            let newOutputParamsURL = try URL.outputParamsURL()
            
            if let previousOutputParamsURL = URL.bundledOutputParamsURL(), !manager.isFilePresent(newOutputParamsURL) {
                try? manager.copyItem(at: previousOutputParamsURL, to: newOutputParamsURL)
            }
            
        } catch {
            let message = "attempt to copy parameters from bundle to documents directory failed with error: \(error)"
            logger.warn(message)
            trackError(WalletError.genericErrorWithMessage(message: message))
        }
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

        self.syncStatus.send(synchronizer.status)
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
            try self.rewind(.quick)
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


extension CompactBlockProcessor.State {
    var syncStatus: SyncStatus? {
        switch self {
        case .stopped:
            return .stopped
        case .downloading:
            return .downloading(NullProgress())
        case .error(let e):
            return .error(e)
        case .fetching:
            return .fetching
        case .synced:
            return .synced
        case .scanning:
            return .scanning(NullProgress())
        case .validating:
            return .validating
        case .enhancing:
            return nil
        
        }
    }
}

fileprivate struct NullEnhancementProgress: EnhancementProgress {
    var totalTransactions: Int { 0 }
    var enhancedTransactions: Int { 0 }
    var lastFoundTransaction: ConfirmedTransactionEntity? { nil }
    var range: CompactBlockRange { 0 ... 0 }
}

fileprivate struct NullProgress: BlockProgressReporting {
    var startHeight: BlockHeight {
        0
    }
    
    var targetHeight: BlockHeight {
        0
    }
    
    var progressHeight: BlockHeight {
        0
    }
}

extension CompactBlockProgress {
    var syncStatus: SyncStatus {
        switch self {
        case .download(let progress):
            return .downloading(progress)
        case .validate:
            return .validating
        case .scan(let progress):
            return .scanning(progress)
        case .enhance(let enhanceProgress):
            return .enhancing(enhanceProgress)
        case .fetch:
            return .fetching
        }
    }
}
