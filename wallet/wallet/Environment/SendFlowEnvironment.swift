//
//  SendFlowEnvironment.swift
//  wallet
//
//  Created by Francisco Gindre on 1/13/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit
import Combine
import SwiftUI

class SendFlow {
    
    static var current: SendFlowEnvironment?
    
    static func end() {
        guard let current = self.current else {
            return
        }
        
        current.close()
        
        Self.current = nil
    }
    
    @discardableResult static func start(appEnviroment: ZECCWalletEnvironment,
                      isActive: Binding<Bool>,
                      amount: Double) -> SendFlowEnvironment {

        let flow = SendFlowEnvironment(amount: amount,
                                       verifiedBalance: appEnviroment.getShieldedVerifiedBalance().asHumanReadableZecBalance(),
                                       isActive: isActive)
        Self.current = flow
        NotificationCenter.default.post(name: .sendFlowStarted, object: nil)
        return flow
    }
}

final class SendFlowEnvironment: ObservableObject {
    enum FlowState {
        case preparing
        case downloadingParameters
        case sending
        case finished
        case failed(error: UserFacingErrors)
    }
    static let maxMemoLength: Int = ZECCWalletEnvironment.memoLengthLimit
    enum FlowError: Error {
        case invalidEnvironment
        case duplicateSent
        case invalidAmount(message: String)
        case derivationFailed(error: Error)
        case derivationFailed(message: String)
        case invalidDestinationAddress(address: String)
    }
    
    @Published var showScanView = false
    @Published var amount: String
    @Binding var isActive: Bool
    @Published var address: String
    @Published var verifiedBalance: Double
    @Published var memo: String = ""
    @Published var includesMemo = false
    @Published var includeSendingAddress: Bool = false
    @Published var isDone = false
    @Published var state: FlowState = .preparing
    var txSent = false

    var error: Error?
    var showError = false
    var pendingTx: PendingTransactionEntity?
    var diposables = Set<AnyCancellable>()
    
    fileprivate init(amount: Double, verifiedBalance: Double, address: String = "", isActive: Binding<Bool>) {
        self.amount = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? ""
        self.verifiedBalance = verifiedBalance
        self.address = address
        self._isActive = isActive
        
        NotificationCenter.default.publisher(for: .qrZaddressScanned)
                   .receive(on: DispatchQueue.main)
                   .debounce(for: 1, scheduler: RunLoop.main)
                   .sink(receiveCompletion: { (completion) in
                       switch completion {
                       case .failure(let error):
                        tracker.report(handledException: DeveloperFacingErrors.handledException(error: error))
                           logger.error("error scanning: \(error)")
                           tracker.track(.error(severity: .noncritical), properties:  [ErrorSeverity.messageKey : "\(error)"])
                           self.error = error
                       case .finished:
                           logger.debug("finished scanning")
                       }
                   }) { (notification) in
                       guard let address = notification.userInfo?["zAddress"] as? String else {
                           return
                       }
                       self.showScanView = false
                       logger.debug("got address \(address)")
                       self.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
                       
               }
               .store(in: &diposables)
    }
    
    deinit {
        diposables.forEach { d in
            d.cancel()
        }
    }

    func clearMemo() {
        self.memo = ""
        self.includeSendingAddress = false
        self.includesMemo = false
    }

    func fail(_ error: Error) {
        self.error = error
        self.showError = true
        self.isDone = true
        self.state = .failed(error: mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error)))
    }
    func preSend() {
        guard case FlowState.preparing = self.state else {
            let message = "attempt to start a pre-send stage where status was not .preparing and was \(self.state) instead"
            logger.error(message)
            tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : message])
            fail(FlowError.duplicateSent)
            return
        }
        
        self.state = .downloadingParameters
        SaplingParameterDownloader.downloadParametersIfNeeded()
            .receive(on: DispatchQueue.main)
            
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.state = .failed(error: error.code.asUserFacingError())
                    self?.fail(error.code.asUserFacingError())
                    break
                case .finished:
                    break
                }
            } receiveValue: { [weak self] _ in
                self?.send()
            }
            .store(in: &self.diposables)

    }
    
    func send() {
        guard !txSent else {
            let message = "attempt to send tx twice"
            logger.error(message)
            tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : message])
            fail(FlowError.duplicateSent)
            return
        }
        self.state = .sending
        let environment = ZECCWalletEnvironment.shared
        guard let zatoshi = doubleAmount?.toZatoshi() else {
            let message = "invalid zatoshi amount: \(String(describing: doubleAmount))"
            logger.error(message)
            fail(FlowError.invalidAmount(message: message))
            return
        }
            
        do {
            let phrase = try SeedManager.default.exportPhrase()
            let seedBytes = try MnemonicSeedProvider.default.toSeed(mnemonic: phrase)
            guard let spendingKey = try DerivationTool.default.deriveSpendingKeys(seed: seedBytes, numberOfAccounts: 1).first else {
                let message = "no spending key for account 1"
                logger.error(message)
                self.fail(FlowError.derivationFailed(message: "no spending key for account 1"))
                return
            }
           
            guard let replyToAddress = environment.getShieldedAddress() else {
                let message = "could not derive user's own address"
                logger.error(message)
                self.fail(FlowError.derivationFailed(message: "could not derive user's own address"))
                return
            }
    
            UserSettings.shared.lastUsedAddress = self.address
            environment.synchronizer.send(
                with: spendingKey,
                zatoshi: zatoshi,
                to: self.address,
                memo: try Self.buildMemo(
                    memo: self.memo,
                    includesMemo: self.includesMemo,
                    replyToAddress: self.includeSendingAddress ? replyToAddress : nil
                ),
                from: 0
            )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] (completion) in
                    guard let self = self else {
                        return
                    }
                    
                    switch completion {
                    case .finished:
                        logger.debug("send flow finished")
                    case .failure(let error):
                        tracker.report(handledException: DeveloperFacingErrors.handledException(error: error))
                        logger.error("\(error)")
                        self.error = error
                        self.showError = true
                        tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : "\(ZECCWalletEnvironment.mapError(error: error))"])
                        
                    }
                    // fix me:
                    self.isDone = true
                    
                }) { [weak self] (transaction) in
                    guard let self = self else {
                        return
                    }
                        self.pendingTx = transaction
                    self.state = .finished
                }.store(in: &diposables)
            
                
            self.txSent = true
            
        } catch {
            logger.error("failed to send: \(error)")
            self.fail(error)
        }
    }
    
    var hasErrors: Bool {
        self.error != nil || self.showError
    }
    var hasFailed: Bool {
        isDone && hasErrors
    }
    
    var hasSucceded: Bool {
        isDone && !hasErrors
    }
    var doubleAmount: Double? {
        NumberFormatter.zecAmountFormatter.number(from: self.amount)?.doubleValue
    }
    func close() {
        self.isActive = false
        NotificationCenter.default.post(name: .sendFlowClosed, object: nil)
    }
    
    static func replyToAddress(_ address: String) -> String {
        "\nReply-To: \(address)"
    }
    
    static func includeReplyTo(address: String, in memo: String, charLimit: Int = SendFlowEnvironment.maxMemoLength) throws -> String {
        
        guard let isValidZAddr = try? DerivationTool.default.isValidShieldedAddress(address),
              isValidZAddr else {
            let msg = "the provided reply-to address is invalid"
            logger.error(msg)
            throw SendFlowEnvironment.FlowError.derivationFailed(message: msg)
        }
        
        let replyTo = replyToAddress(address)
        
        if (memo.count + replyTo.count) >= charLimit {
            let truncatedMemo = String(memo[memo.startIndex ..< memo.index(memo.startIndex, offsetBy: (memo.count - replyTo.count))])
            
            return truncatedMemo + replyTo
        }
        return memo + replyTo
        
    }
    
    static func buildMemo(memo: String, includesMemo: Bool, replyToAddress: String?) throws -> String? {
        
        guard includesMemo else { return nil }
        
        if let addr = replyToAddress {
            return try includeReplyTo(address: addr, in: memo)
        }
        guard !memo.isEmpty else { return nil }
        
        guard !memo.isEmpty else { return nil }
        
        return memo
       
    }
}

extension Notification.Name {
    static let sendFlowClosed = Notification.Name("sendFlowClosed")
    static let sendFlowStarted = Notification.Name("sendFlowStarted")
}

