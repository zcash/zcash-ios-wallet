//
//  FileHelperTests.swift
//  ECC-WalletTests
//
//  Created by Francisco Gindre on 3/13/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet_no_logs
class FileHelperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try FileManager.default.createDirectory(at: try URL.logsDirectory(), withIntermediateDirectories: false, attributes: nil)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try? FileManager.default.removeItem(at: try URL.logsDirectory())
    }

    func testAllFiles() throws {
        let location = try URL.logsDirectory()
        
        try "file 1".write(to: location.appendingPathComponent("file1.txt"), atomically: true, encoding: .utf8)
        try "file 2".write(to: location.appendingPathComponent("file2.txt"), atomically: true, encoding: .utf8)
        try "file 3".write(to: location.appendingPathComponent("file3.txt"), atomically: true, encoding: .utf8)
        
        XCTAssertEqual(try LogfileHelper.allLogfiles().count, 3)
    }
    
    func testLatestFile() throws {
        let location = try URL.logsDirectory()
        
        try "file 1".write(to: location.appendingPathComponent("file1.txt"), atomically: true, encoding: .utf8)
        try "file 2".write(to: location.appendingPathComponent("file2.txt"), atomically: true, encoding: .utf8)
        try "file 4".write(to: location.appendingPathComponent("file3.txt"), atomically: true, encoding: .utf8)
        
        let latest = try LogfileHelper.latestLogfile()
        XCTAssertEqual(latest?.lastPathComponent, "file3.txt")
    }

    

}
