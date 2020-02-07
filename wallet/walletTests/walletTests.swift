//
//  walletTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import zECC_Wallet

class walletTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testZaddressValidator() {
        let zAddresss = "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        let expected = "Ztestsap...tyjdc2p6"
        
        XCTAssertEqual(zAddresss.shortZaddress, expected)
        XCTAssertNil("testsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6".shortZaddress)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
