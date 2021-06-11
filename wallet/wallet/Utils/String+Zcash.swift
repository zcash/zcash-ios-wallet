//
//  String+Zcash.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit

extension String {
    
    var isValidShieldedAddress: Bool {
        (try? DerivationTool.default.isValidShieldedAddress(self)) ?? false
    }
    
    var isValidTransparentAddress: Bool {
        (try? DerivationTool.default.isValidTransparentAddress(self)) ?? false
    }
    
    var isValidAddress: Bool {
        self.isValidShieldedAddress || self.isValidTransparentAddress
    }
    
    /**
     This only shows an abbreviated and redacted version of the Z addr for UI purposes only
     */
    var shortZaddress: String? {
        guard isValidAddress else { return nil }
        return String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: 8)])
            + "..."
            + String(self[self.index(self.endIndex, offsetBy: -8) ..< self.endIndex])
    }
}
