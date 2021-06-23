//
//  UILogicTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 3/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet_Testnet
class UILogicTests: XCTestCase {

  
    func testSlicing() throws {
        let words = "kitchen renew wide common vague fold vacuum tilt amazing pear square gossip jewel month tree shock scan alpha just spot fluid toilet view dinner".split(separator: " ").map({s -> String in String(s)})
        
        let grid = [
            ["kitchen","renew", "wide"],
            ["common", "vague", "fold"],
            ["vacuum", "tilt", "amazing"],
            ["pear", "square", "gossip"],
            ["jewel", "month", "tree"],
            ["shock", "scan", "alpha"],
            ["just", "spot", "fluid"],
            ["toilet", "view", "dinner"]
        ]
        
        XCTAssertEqual(words.slice(maxSliceCount: 3), grid)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
