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

    func testReplyToMemo() {
        let memo = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments!"
        let replyTo = "testsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        let replyToMemo = SendFlowEnvironment.includeReplyTo(address: replyTo, in: memo)
        
        let expected = memo + "\nReply to:\n\(replyTo)"
        XCTAssertTrue(replyToMemo.count <= 512)
        XCTAssertEqual(replyToMemo, expected)
        
    }
    
    func testReplyToHugeMemo() {
        let memo = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments!"
        let replyTo = "testsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        let replyToMemo = SendFlowEnvironment.includeReplyTo(address: replyTo, in: memo)
        
        let expected = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Ha" + "...\nReply to:\n\(replyTo)"
        XCTAssertTrue(replyToMemo.count <= 512)
        XCTAssertEqual(replyToMemo, expected)
        
    }
    
}
