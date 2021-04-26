//
//  ReadableBalance.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 4/26/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit
struct ReadableBalance {
    var verified: Double
    var total: Double
}

extension ReadableBalance {
    init(walletBalance: WalletBalance) {
        self.init(verified: walletBalance.verified.asHumanReadableZecBalance(),
                        total: walletBalance.total.asHumanReadableZecBalance())
    }
    
    static var zero: ReadableBalance {
        ReadableBalance(verified: 0, total: 0)
    }
}
