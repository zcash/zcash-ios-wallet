//
//  ParameterDownloadsTests.swift
//  ECC-WalletTests
//
//  Created by Francisco Gindre on 6/22/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import XCTest
import Combine
import ZcashLightClientKit
@testable import ECC_Wallet_Testnet
class ParameterDownloadsTests: XCTestCase {

 
    var cancellables = [AnyCancellable]()
    
    var defaultSpendURL = FileManager.default.temporaryDirectory.appendingPathComponent("sapling-spend.params")
    var defaultOutputURL = FileManager.default.temporaryDirectory.appendingPathComponent("sapling-output.params")
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: defaultOutputURL)
        try? FileManager.default.removeItem(at: defaultSpendURL)
    }
    
    func testDownloadSpendOnly() throws {
        let outputStoreURL = defaultOutputURL
        let spendStoreURL = defaultSpendURL
        
        // create the empty output file
        createEmptyFile(at: outputStoreURL)
        // verify that the file is there
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputStoreURL.path))
        
        let expectation = XCTestExpectation(description: "download expectation")
        
        SaplingParameterDownloader.downloadParametersIfNeeded(
            spendParamsDownloadURL: URL(string: SaplingParameterDownloader.spendParamsURLString)!, outputParamsDownloadURL: URL(string: SaplingParameterDownloader.outputParamsURLString)!, spendParamsStoreURL: spendStoreURL,
            outputParamsStoreURL: outputStoreURL)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion
                {
                case .failure(let error):
                    expectation.fulfill()
                    XCTFail("failed with error: \(error)")
                case .finished:
                    break
                    
                }
            } receiveValue: { result in
                expectation.fulfill()
                XCTAssertEqual(spendStoreURL.path, result.0.path)
                XCTAssertEqual(outputStoreURL.path, result.1.path)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10000)
        
    }
    
    func testDownloadOutputOnly() throws {
        let outputStoreURL = defaultOutputURL
        let spendStoreURL = defaultSpendURL
        
        // create the empty output file
        createEmptyFile(at: spendStoreURL)
        // verify that the file is there
        XCTAssertTrue(FileManager.default.fileExists(atPath: spendStoreURL.path))
        
        let expectation = XCTestExpectation(description: "download expectation")
        
        SaplingParameterDownloader.downloadParametersIfNeeded(
            spendParamsDownloadURL: URL(string: SaplingParameterDownloader.spendParamsURLString)!, outputParamsDownloadURL: URL(string: SaplingParameterDownloader.outputParamsURLString)!, spendParamsStoreURL: spendStoreURL,
            outputParamsStoreURL: outputStoreURL)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion
                {
                case .failure(let error):
                    expectation.fulfill()
                    XCTFail("failed with error: \(error)")
                case .finished:
                    break
                    
                }
            } receiveValue: { result in
                expectation.fulfill()
                XCTAssertEqual(spendStoreURL.path, result.0.path)
                XCTAssertEqual(outputStoreURL.path, result.1.path)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10000)
    }

    func testDownloadBothFiles() throws {
        let outputStoreURL = defaultOutputURL
        let spendStoreURL = defaultSpendURL
        
        
        // verify that the file is there
        XCTAssertFalse(FileManager.default.fileExists(atPath: outputStoreURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: spendStoreURL.path))
        
        let expectation = XCTestExpectation(description: "download expectation")
        
        SaplingParameterDownloader.downloadParametersIfNeeded(
            spendParamsDownloadURL: URL(string: SaplingParameterDownloader.spendParamsURLString)!, outputParamsDownloadURL: URL(string: SaplingParameterDownloader.outputParamsURLString)!, spendParamsStoreURL: spendStoreURL,
            outputParamsStoreURL: outputStoreURL)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion
                {
                case .failure(let error):
                    expectation.fulfill()
                    XCTFail("failed with error: \(error)")
                case .finished:
                    break
                    
                }
            } receiveValue: { result in
                expectation.fulfill()
                XCTAssertEqual(spendStoreURL.path, result.0.path)
                XCTAssertEqual(outputStoreURL.path, result.1.path)
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10000)
    }
    
    
    func createEmptyFile(at url: URL) {
        FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
    }
}
