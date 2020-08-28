//
//  Foundation+Zcash.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/21/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit

extension Int {
    var isMined: Bool {
        self >= ZcashSDK.SAPLING_ACTIVATION_HEIGHT
    }
}
