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
    
    @Published var amount: String
    @Binding var isActive: Bool
    @Published var address: String
    @Published var verifiedBalance: Double
    @Published var memo: String = ""
    @Published var includesMemo = false
    @Published var isDone = false

    
    init(amount: Double, verifiedBalance: Double, address: String = "", isActive: Binding<Bool>) {
        self.amount = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? ""
        self.verifiedBalance = verifiedBalance
        self.address = address
        self._isActive = isActive
    }
    
    func send() -> Future<PendingTransactionEntity,Error> {
        
        guard let zatoshi = NumberFormatter.zecAmountFormatter.number(from: self.amount)?.doubleValue.toZatoshi(),
              self.address.isValidZaddress,
              let spendingKey = SeedManager.default.getKeys()?.first else {
                  return Future<PendingTransactionEntity,Error>() { $0(.failure(FlowError.invalidEnvironment))}
        
        }
        let environment = ZECCWalletEnvironment.shared
        
        return environment.synchronizer.send(
                with: spendingKey,
                zatoshi: zatoshi,
                to: self.address,
                memo: self.memo.isEmpty ? nil : self.memo,
                from: 0
            )
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
