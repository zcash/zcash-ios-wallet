//
//  TestMemoUtils.swift
//  ECC-WalletTests
//
//  Created by Francisco Gindre on 12/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet_no_logs
class TestMemoUtils: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testExtractStandardAddressFromMemo() throws {
        let standard = """
        Reply-To: zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c
        """
        
        XCTAssertEqual(standard.extractValidAddress(), "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c")
    }
    
    func testExtract() throws {
        
        let standard1 = """
        Canopy test
        Reply-To: zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c
        """
        XCTAssertEqual(standard1.extractValidAddress(), "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c")
    }
    
    func testExtractStandardWithoutColon() throws {
        let standardWithoutColon = """
        Canopy test
        reply-to zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c
        """
        XCTAssertEqual(standardWithoutColon.extractValidAddress(), "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c")
        
    }
    
    func testExtractSpaceInsteadOfDash() throws {
        let spaceInsteadOfDash = """
        Canopy test
        reply to: zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c
        """
        
        XCTAssertEqual(spaceInsteadOfDash.extractValidAddress(), "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c")
        
    }
    
    func testExtractSpaceInsteadOfDashWithoutColon() throws {
        let spaceInsteadOfDashWithoutColon = """
        Canopy test
        reply to zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c
        """
        
        XCTAssertEqual(spaceInsteadOfDashWithoutColon.extractValidAddress(), "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c")
        
    }
    
    func testExtractPreviousStandard() throws {
        let previousStandard = """
        sent from: zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c
        """
        
        XCTAssertEqual(previousStandard.extractValidAddress(), "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c")
        
    }
    
    func testExtractPreviousStardardWithoutColon() throws {
        let previousStardardWithoutColon = """
        sent from zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c
        """
        
        XCTAssertEqual(previousStardardWithoutColon.extractValidAddress(), "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c")
    }
}
