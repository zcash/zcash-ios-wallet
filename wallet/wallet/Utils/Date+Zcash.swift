//
//  Date+Zcash.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/19/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/mm/dd"
        
        return formatter.string(from: self) == formatter.string(from: otherDate)
    }
    
    func transactionDetailFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mma"
        
        return formatter.string(from: self).lowercased()
    }
}
