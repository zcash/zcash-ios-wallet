//
//  AddressValidator.swift
//  wallet
//
//  Created by Francisco Gindre on 7/30/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

protocol AddressValidator {
    static func isValidShieldedAddress(_ address: String) -> Bool
    static func isValidTransparentAddress(_ address: String) -> Bool
}




class DefaultAddressValidator: AddressValidator {
    static func isValidShieldedAddress(_ address: String) -> Bool {
        ZECCWalletEnvironment.shared.isValidShieldedAddress(address)
    }
    
    static func isValidTransparentAddress(_ address: String) -> Bool {
        ZECCWalletEnvironment.shared.isValidTransparentAddress(address)
    }
    
    
}
