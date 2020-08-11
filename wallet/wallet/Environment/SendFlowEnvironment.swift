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
        
        current.isActive = false
        
        Self.current = nil
    }
    
    @discardableResult static func start(appEnviroment: ZECCWalletEnvironment,
                      isActive: Binding<Bool>,
                      amount: Double) -> SendFlowEnvironment {

        let flow = SendFlowEnvironment(amount: amount,
                                       verifiedBalance: appEnviroment.initializer.getVerifiedBalance().asHumanReadableZecBalance(),
                                       isActive: isActive)
        Self.current = flow
        return flow
    }
}

final class SendFlowEnvironment: ObservableObject {
    
    static let maxMemoLength: Int = ZECCWalletEnvironment.memoLengthLimit
    enum FlowError: Error {
        case invalidEnvironment
        case duplicateSent
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


    func send() {
        guard !txSent else {
            let message = "attempt to send tx twice"
            logger.error(message)
            tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : message])
            return
        }
        let environment = ZECCWalletEnvironment.shared
        guard let zatoshi = doubleAmount?.toZatoshi(),
            environment.isValidAddress(self.address),
            let spendingKey = SeedManager.default.getKeys()?.first,
            let replyToAddress = environment.initializer.getAddress() else {
                self.error = FlowError.invalidEnvironment
                self.showError = true
                self.isDone = true
                return
        }

        environment.synchronizer.send(
            with: spendingKey,
            zatoshi: zatoshi,
            to: self.address,
            memo: Self.buildMemo(
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
                    logger.error("\(error)")
                    self.error = error
                    self.showError = true
                    tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : "\(ZECCWalletEnvironment.mapError(error: error))"])
                    SendFlow.end()
                }
                // fix me:                
                self.isDone = true
                
            }) { [weak self] (transaction) in
                guard let self = self else {
                    return
                }
                    self.pendingTx = transaction
            }.store(in: &diposables)
        
        self.txSent = true

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
    
    static func includeReplyTo(address: String, in memo: String, charLimit: Int = SendFlowEnvironment.maxMemoLength) -> String {
        
        let replyTo = replyToAddress(address)
        
        if (memo.count + replyTo.count) >= charLimit {
            let truncatedMemo = String(memo[memo.startIndex ..< memo.index(memo.startIndex, offsetBy: (memo.count - replyTo.count))])
            
            return truncatedMemo + replyTo
        }
        return memo + replyTo
        
    }
    
    static func buildMemo(memo: String, includesMemo: Bool, replyToAddress: String?) -> String? {
        
        guard includesMemo else { return nil }
        
        if let addr = replyToAddress {
            return includeReplyTo(address: addr, in: memo)
        }
        guard !memo.isEmpty else { return nil }
        
        guard !memo.isEmpty else { return nil }
        
        return memo
    }
}

extension Notification.Name {
    static let sendFlowClosed = Notification.Name("sendFlowClosed")
}
