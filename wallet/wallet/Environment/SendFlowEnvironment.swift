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



final class SendFlowEnvironment: ObservableObject {
    
    enum FlowError: Error {
        case invalidEnvironment
    }
    
    @Published var amount: String
    @Published var isActive: Bool = false
    @Published var address: String
    @Published var verifiedBalance: Double
    @Published var memo: String = ""
    @Published var includesMemo = false
    @Published var isDone = false

    
    init(amount: Double, verifiedBalance: Double, address: String = "") {
        self.amount = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? ""
        self.verifiedBalance = verifiedBalance
        self.address = address
    }
    
    func send() -> Future<PendingTransactionEntity,Error> {
        
        guard let zatoshi = NumberFormatter.zecAmountFormatter.number(from: self.amount)?.doubleValue.toZatoshi(),
              self.address.isValidZaddress,
              let environment = SceneDelegate.shared.environment,
              let spendingKey = SeedManager.default.getKeys()?.first else {
                  return Future<PendingTransactionEntity,Error>() { $0(.failure(FlowError.invalidEnvironment))}
        }
        
        return environment.synchronizer.send(
                with: spendingKey,
                zatoshi: zatoshi,
                to: self.address,
                memo: self.memo.isEmpty ? nil : self.memo,
                from: 0
            )
    }
}
