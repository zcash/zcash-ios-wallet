//
//  BalanceUtils.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit

extension Int64 {
    func asHumanReadableZecBalance() -> Double {
        Double(self) / Double(ZcashSDK.ZATOSHI_PER_ZEC)
    }
}

extension Double {
    func toZatoshi() -> Int64 {
        Int64(self * Double(ZcashSDK.ZATOSHI_PER_ZEC))
    }
    
    func toZecAmount() -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension NumberFormatter {
    static var zecAmountFormatter: NumberFormatter {
        
        let fmt = NumberFormatter()
        
        fmt.alwaysShowsDecimalSeparator = true
        fmt.allowsFloats = true
        fmt.maximumFractionDigits = 8
        fmt.minimumFractionDigits = 0
        fmt.minimumIntegerDigits = 0
        return fmt
        
    }
    
    static var zeroBalanceFormatter: NumberFormatter {
        
        let fmt = NumberFormatter()
        
        fmt.alwaysShowsDecimalSeparator = false
        fmt.allowsFloats = true
        fmt.maximumFractionDigits = 0
        fmt.minimumFractionDigits = 0
        fmt.minimumIntegerDigits = 1
        return fmt
        
    }
}

