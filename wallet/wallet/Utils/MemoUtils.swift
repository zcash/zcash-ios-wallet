//
//  MemoUtils.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 12/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation


extension String  {
    static let includeMemoPrefixStandard = "Reply-To:"
    
    static let recognizedPrefixes = [
        includeMemoPrefixStandard,      // standard
        "reply-to",                     // standard w/o colon
        "reply to:",                    // space instead of dash
        "reply to",                     // space instead of dash w/o colon
        "sent from:",                   // previous standard
        "sent from"                     // previous standard w/o colon
    ]
    
    func extractValidAddress() -> String? {
        guard self.count >= 25 else {
            return nil
        }
        
        for prefix in Self.recognizedPrefixes {
            guard let keywordRange = self.range(of: prefix),
                  keywordRange.upperBound < self.endIndex else {
                continue
            }
            
            let addressSlice = self[keywordRange.upperBound ..< self.endIndex]
            
            let afterReplyToString = String(addressSlice).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters))
            
            guard afterReplyToString.isValidAddress else {
                return nil
            }
            
            return afterReplyToString
        }
        return nil
    }
}
