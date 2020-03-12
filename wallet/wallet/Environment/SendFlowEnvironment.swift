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
    
    let maxMemoLength: Int = 512
    enum FlowError: Error {
        case invalidEnvironment
    }
    @Published var showScanView = false
    @Published var amount: String
    @Binding var isActive: Bool
    @Published var address: String
    @Published var verifiedBalance: Double
    @Published var memo: String = ""
    @Published var includesMemo = false
    @Published var isDone = false
    var error: Error?
    var showError = false
    var pendingTx: PendingTransactionEntity?
    var diposables = Set<AnyCancellable>()
    
    init(amount: Double, verifiedBalance: Double, address: String = "", isActive: Binding<Bool>) {
        self.amount = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? ""
        self.verifiedBalance = verifiedBalance
        self.address = address
        self._isActive = isActive
    }
    
    deinit {
        diposables.forEach { d in
            d.cancel()
        }
    }
    
    func send() {
        
        guard let zatoshi = NumberFormatter.zecAmountFormatter.number(from: self.amount)?.doubleValue.toZatoshi(),
              self.address.isValidZaddress,
              let spendingKey = SeedManager.default.getKeys()?.first else {
                self.error = FlowError.invalidEnvironment
                self.showError = true
                return
        }
        
        let environment = ZECCWalletEnvironment.shared
        
        environment.synchronizer.send(
                with: spendingKey,
                zatoshi: zatoshi,
                to: self.address,
                memo: self.memo.isEmpty ? nil : self.memo,
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
                }
            }) { [weak self] (transaction) in
                guard let self = self else {
                                   return
                               }
                self.pendingTx = transaction
        }.store(in: &diposables)
        
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
                self.address = address
              
        }
        .store(in: &diposables)
    }
    
    static func includeReplyTo(address: String, in memo: String) -> String {
        
        let replyTo = "...\nReply to:\n\(address)"
        
        if (memo.count + replyTo.count) >= 512 {
            let truncatedMemo = String(memo[memo.startIndex ..< memo.index(memo.startIndex, offsetBy: (memo.count - replyTo.count))])
            
            return truncatedMemo + replyTo
        }
        return memo + replyTo
        
    }
}

extension Notification.Name {
    static let sendFlowClosed = Notification.Name("sendFlowClosed")
}
