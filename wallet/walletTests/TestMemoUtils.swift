//
//  TestMemoUtils.swift
//  ECC-WalletTests
//
//  Created by Francisco Gindre on 12/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet_Testnet
class TestMemoUtils: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testExtractStandardAddressFromMemo() throws {
        let standard = """
        Reply-To: ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr
        """
        
        XCTAssertEqual(standard.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
    }
    
    func testExtractWithControlCharacters() throws {
        let testMemo = "\nReply-To: ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
        XCTAssertEqual(testMemo.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
    }
    
    func testExtract() throws {
        
        let standard1 = """
        Canopy test
        Reply-To: ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr
        """
        XCTAssertEqual(standard1.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
    }
    
    func testExtractStandardWithoutColon() throws {
        let standardWithoutColon = """
        Canopy test
        reply-to ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr
        """
        XCTAssertEqual(standardWithoutColon.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
        
    }
    
    func testExtractSpaceInsteadOfDash() throws {
        let spaceInsteadOfDash = """
        Canopy test
        reply to: ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr
        """
        
        XCTAssertEqual(spaceInsteadOfDash.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
        
    }
    
    func testExtractSpaceInsteadOfDashWithoutColon() throws {
        let spaceInsteadOfDashWithoutColon = """
        Canopy test
        reply to ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr
        """
        
        XCTAssertEqual(spaceInsteadOfDashWithoutColon.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
        
    }
    
    func testExtractPreviousStandard() throws {
        let previousStandard = """
        sent from: ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr
        """
        
        XCTAssertEqual(previousStandard.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
        
    }
    
    func testExtractPreviousStardardWithoutColon() throws {
        let previousStardardWithoutColon = """
        sent from ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr
        """
        
        XCTAssertEqual(previousStardardWithoutColon.extractValidAddress(), "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr")
    }
}
