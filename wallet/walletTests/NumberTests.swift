//
//  NumberTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 3/19/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import XCTest
@testable import ECC_Wallet
class NumberTests: XCTestCase {
    
    
    func test() {
        let amount = 0.0003
        let zatoshi: Int64 = 30000
        
        XCTAssertEqual(amount.toZatoshi(),zatoshi)
        
    }
}
