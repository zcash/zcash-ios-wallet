//
//  String+localized.swift
//  wallet
//
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

extension String {
    public func localized() -> String {
        return NSLocalizedString(self, comment:"")
    }
    
    public func localized(with arguments: CVarArg...) -> String {
        return String.init(format: self.localized(), arguments: arguments)
    }
}
