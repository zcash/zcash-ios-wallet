//
//  walletTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import zECC_Wallet
import MnemonicKit
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
    
    func testKeyPadDecimalLimit() {
        let keyPadViewModel = KeyPadViewModel()
        
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("hello world"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("0.0"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1.0"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("100000"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1.0000000"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1000000.0000000"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1.0000000"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("1.00000000"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("0.000000001"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("0.000000000"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("0.0000000000"))
        
    }
    
    func testMnemonics() {
        
        guard let phrase = Mnemonic.generateMnemonic(strength: 256) else {
            XCTFail()
            return
        }
        
        
        XCTAssertTrue(phrase.split(separator: " ").count == 24)
        
        XCTAssertNotNil(Mnemonic.deterministicSeedString(from: phrase),"could not generate seed from phrase: \(phrase)")
        
    }
    
    
    func testRestore() {
        let expectedSeed =    "715b4b7950c2153e818f88122f8e54a00e36c42e47ba9589dc82fcecfc5b7ec7d06f4e3a3363a0221e06f14f52e03294290139d05d293059a55076b7f37d6726"
           
        let phrase = "abuse fee wage robot october tongue utility gloom dizzy best victory armor second share pilot help cotton mango music decorate scheme mix tell never"
        
        XCTAssertEqual(Mnemonic.deterministicSeedString(from: phrase),expectedSeed)
    }
}
