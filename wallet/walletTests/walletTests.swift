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
@testable import ZcashLightClientKit
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
        
        XCTAssertEqual(MnemonicSeedProvider.default.toSeed(mnemonic: phrase)?.hexString,expectedSeed)
    }
    
    func testRestoreZaddress() {
        ZECCWalletEnvironment.shared.nuke()
        let phrase = "human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        
        let expectedAddress = "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c"
        let seed = MnemonicSeedProvider.default.toSeed(mnemonic: phrase)
        
        let hex = "f4e3d38d9c244da7d0407e19a93c80429614ee82dcf62c141235751c9f1228905d12a1f275f5c22f6fb7fcd9e0a97f1676e0eec53fdeeeafe8ce8aa39639b9fe"
               
        XCTAssertEqual(seed?.hexString, hex)
        
        try! SeedManager.default.importSeed(seed!)
        try! SeedManager.default.importPhrase(bip39: phrase)
        let accounts = try! ZECCWalletEnvironment.shared.initializer.initialize(seedProvider: SeedManager.default, walletBirthdayHeight: 692345)
        
        XCTAssertEqual(SeedManager.default.seed(), seed)
        XCTAssertNotNil(accounts)
        guard let address = ZECCWalletEnvironment.shared.initializer.getAddress() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(address, expectedAddress)
        
        
    }
    
    func testCompatibility() {
        let words = "human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        let hex = "f4e3d38d9c244da7d0407e19a93c80429614ee82dcf62c141235751c9f1228905d12a1f275f5c22f6fb7fcd9e0a97f1676e0eec53fdeeeafe8ce8aa39639b9fe"
        
        XCTAssertTrue(MnemonicSeedProvider.default.isValid(mnemonic: words))
        XCTAssertEqual(MnemonicSeedProvider.default.toSeed(mnemonic: words)?.hexString, hex)
    }
    
}

extension Array where Element == UInt8 {
    var hexString: String {
        self.map { String(format: "%02x", $0) }.joined()
    }
}
