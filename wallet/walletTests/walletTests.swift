//
//  walletTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet_no_logs
import MnemonicSwift
@testable import ZcashLightClientKit
class walletTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testReplyToMemo() {
        let memo = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments!"
        let replyTo = "testsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        let replyToMemo = SendFlowEnvironment.includeReplyTo(address: replyTo, in: memo)
        
        let expected = memo + "\nReply-To: \(replyTo)"
        XCTAssertTrue(replyToMemo.count <= SendFlowEnvironment.maxMemoLength)
        XCTAssertEqual(replyToMemo, expected)
        
    }
    
    func testOnlyReplyToMemo() {
        let memo = ""
        let replyTo = "testsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        let replyToMemo = SendFlowEnvironment.buildMemo(memo: memo, includesMemo: true, replyToAddress: replyTo)
        
        let expected = memo + "\nReply-To: \(replyTo)"
        guard replyToMemo != nil else {
            XCTFail("memo nil when it shouldn't be")
            return }
        XCTAssertTrue(replyToMemo!.count <= SendFlowEnvironment.maxMemoLength)
        XCTAssertEqual(replyToMemo, expected)
        
    }
    
    func testReplyToHugeMemo() {
        let memo = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments!"
        let replyTo = "testsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        let replyToMemo = SendFlowEnvironment.includeReplyTo(address: replyTo, in: memo)
        
        let trimmedExpected = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have "
        let expected = trimmedExpected + "\nReply-To: \(replyTo)"
        XCTAssertTrue(replyToMemo.count <= SendFlowEnvironment.maxMemoLength)
        XCTAssertEqual(replyToMemo, expected)
        XCTAssertEqual(trimmedExpected, replyToMemo.removingReplyTo)
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
    
    func testMnemonics() throws {
        
        let phrase = try Mnemonic.generateMnemonic(strength: 256)

        
        XCTAssertTrue(phrase.split(separator: " ").count == 24)
        
        XCTAssertNotNil(try Mnemonic.deterministicSeedString(from: phrase),"could not generate seed from phrase: \(phrase)")
        
    }
    
    
    func testRestore() throws {
        let expectedSeed =    "715b4b7950c2153e818f88122f8e54a00e36c42e47ba9589dc82fcecfc5b7ec7d06f4e3a3363a0221e06f14f52e03294290139d05d293059a55076b7f37d6726"
           
        let phrase = "abuse fee wage robot october tongue utility gloom dizzy best victory armor second share pilot help cotton mango music decorate scheme mix tell never"
        
        XCTAssertEqual(try MnemonicSeedProvider.default.toSeed(mnemonic: phrase).hexString,expectedSeed)
    }
    
    func testRestoreZaddress() throws {
        ZECCWalletEnvironment.shared.nuke()
        let phrase = "human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        
        let expectedAddress = "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c"
        let seed = try MnemonicSeedProvider.default.toSeed(mnemonic: phrase)
        
        let hex = "f4e3d38d9c244da7d0407e19a93c80429614ee82dcf62c141235751c9f1228905d12a1f275f5c22f6fb7fcd9e0a97f1676e0eec53fdeeeafe8ce8aa39639b9fe"
               
        XCTAssertEqual(seed.hexString, hex)
        
        try! SeedManager.default.importSeed(seed)
        try! SeedManager.default.importPhrase(bip39: phrase)
        try! ZECCWalletEnvironment.shared.initializer.initialize(viewingKeys: DerivationTool.default.deriveViewingKeys(seed: seed, numberOfAccounts: 0), walletBirthday: 692345)
        
        XCTAssertEqual(SeedManager.default.seed(), seed)
        
        guard let address = ZECCWalletEnvironment.shared.initializer.getAddress() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(address, expectedAddress)

    }
    
    func testAddressSlicing() {
        let address = "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c"
                
        let split = address.slice(into: 8)
        
        XCTAssert(split.count == 8)
    }
    func testCompatibility() throws {
        let words = "human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        let hex = "f4e3d38d9c244da7d0407e19a93c80429614ee82dcf62c141235751c9f1228905d12a1f275f5c22f6fb7fcd9e0a97f1676e0eec53fdeeeafe8ce8aa39639b9fe"
        
        XCTAssertNoThrow(try MnemonicSeedProvider.default.isValid(mnemonic: words))
        XCTAssertEqual(try MnemonicSeedProvider.default.toSeed(mnemonic: words).hexString, hex)
    }
    
    func testAlmostIncludesReplyTo() {
           let memo = "this is a test memo"
           let addr = "nowhere"
           let expected = "\(memo)\nReply-To: \(addr)"
           XCTAssertFalse(expected.includesReplyTo)
           XCTAssertNil(expected.replyToAddress)
       }
    
    func testIncludesReplyTo() {
        let memo = "this is a test memo"
        let addr = "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c"
        let expected = "\(memo)\nReply-To: \(addr)"
        XCTAssertTrue(expected.includesReplyTo)
        XCTAssertNotNil(expected.replyToAddress)
    }
    
    func testBuildMemo() {
        let memo = "this is a test memo"
        let addr = "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c"
        let expected = "\(memo)\nReply-To: \(addr)"
        
        XCTAssertEqual(expected, SendFlowEnvironment.buildMemo(memo: memo, includesMemo: true, replyToAddress: addr))
        
        XCTAssertEqual(nil, SendFlowEnvironment.buildMemo(memo: "", includesMemo: true, replyToAddress: nil))
        XCTAssertEqual(nil, SendFlowEnvironment.buildMemo(memo: memo, includesMemo: false, replyToAddress: addr))
    }
    
    func testBlockExplorerUrl() {
        let txId = "4fd71c6363ac451674ae117f98e8225e0d4d1de67d44091287e62ba0ccf5358b"
        let expectedMainnetURL = "https://explorer.z.cash/tx/\(txId)"
        let expectedTestnetURL = "https://explorer.testnet.z.cash/tx/\(txId)"
        
        let mainnetURL = UrlHandler.blockExplorerURL(for: txId, mainnet: true)?.absoluteString
        let testnetURL = UrlHandler.blockExplorerURL(for: txId, mainnet: false)?.absoluteString
        
        XCTAssertEqual(mainnetURL, expectedMainnetURL)
        XCTAssertEqual(testnetURL, expectedTestnetURL)
    }
}

extension Array where Element == UInt8 {
    var hexString: String {
        self.map { String(format: "%02x", $0) }.joined()
    }
}
