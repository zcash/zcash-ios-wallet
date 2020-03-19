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

final class SendFlowEnvironment: ObservableObject {
    
    static let maxMemoLength: Int = 255
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
    
    init(amount: Double, verifiedBalance: Double, address: String = "", isActive: Binding<Bool>) {
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
            logger.error("attempt to send tx twice")
            return
        }
        let environment = ZECCWalletEnvironment.shared
        guard let zatoshi = NumberFormatter.zecAmountFormatter.number(from: self.amount)?.doubleValue.toZatoshi(),
            self.address.isValidZaddress,
            let spendingKey = SeedManager.default.getKeys()?.first,
            let replyToAddress = environment.initializer.getAddress() else {
                self.error = FlowError.invalidEnvironment
                self.showError = true
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
                    self.isDone = true
                case .failure(let error):
                    logger.error("\(error)")
                    self.error = error
                    self.showError = true
                    self.isDone = true
                }
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
    
    func close() {
        NotificationCenter.default.post(name: .sendFlowClosed, object: nil)
        self.isActive = false
    }
    
    static func includeReplyTo(address: String, in memo: String, charLimit: Int = SendFlowEnvironment.maxMemoLength) -> String {
        
        let replyTo = "\nfrom \(address)"
        
        if (memo.count + replyTo.count) >= charLimit {
            let truncatedMemo = String(memo[memo.startIndex ..< memo.index(memo.startIndex, offsetBy: (memo.count - replyTo.count))])
            
            return truncatedMemo + replyTo
        }
        return memo + replyTo
        
    }
    
    static func buildMemo(memo: String, includesMemo: Bool, replyToAddress: String?) -> String? {
        guard !memo.isEmpty else { return nil }
        
        guard includesMemo else { return nil }
        
        if let addr = replyToAddress {
            return includeReplyTo(address: addr, in: memo)
        }
        
        return memo
    }
}

extension Notification.Name {
    static let sendFlowClosed = Notification.Name("sendFlowClosed")
}
