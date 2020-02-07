//
//  SendFlowEnvironment.swift
//  wallet
//
//  Created by Francisco Gindre on 1/13/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

final class SendFlowEnvironment: ObservableObject {
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
}
