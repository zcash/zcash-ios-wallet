//
//  KeyPadViewModelTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 1/6/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import XCTest
import Combine
@testable import ECC_Wallet
class KeyPadViewModelTests: XCTestCase {
    
    
    
    func testInitializer() {
        let value: Double = 1.234
        let textValue = "1.234"
        let viewModel = KeyPadViewModel(initialValue: value)
        
        XCTAssertEqual(viewModel.value, value)
        XCTAssertEqual(viewModel.text, textValue)
        
    }
    
    func testDelete() {
        let value: Double = 1.234
        let viewModel = KeyPadViewModel(initialValue: value)
        
        viewModel.deleteTapped()
        XCTAssertEqual("1.23", viewModel.text)
        XCTAssertEqual(1.23, viewModel.value)
        
        viewModel.deleteTapped()
        XCTAssertEqual("1.2", viewModel.text)
        XCTAssertEqual(1.2, viewModel.value)
        
        viewModel.deleteTapped()
        XCTAssertEqual("1.", viewModel.text)
        XCTAssertEqual(1, viewModel.value)
        
        viewModel.deleteTapped()
        XCTAssertEqual("1", viewModel.text)
        XCTAssertEqual(1, viewModel.value)
        
        viewModel.deleteTapped()
        XCTAssertEqual("", viewModel.text)
        XCTAssertEqual(0, viewModel.value)
        
    }
    
    func testInteger() {
        
        let viewModel = KeyPadViewModel()
        
        viewModel.numberTapped("1")
        
        XCTAssertEqual("1", viewModel.text)
        XCTAssertEqual(Double(1), viewModel.value)
        
        viewModel.dotTapped()
        XCTAssertEqual("1.", viewModel.text)
        XCTAssertEqual(Double(1), viewModel.value)
        
        viewModel.numberTapped("2")
        XCTAssertEqual("1.2", viewModel.text)
        XCTAssertEqual(Double(1.2), viewModel.value)
        
        viewModel.numberTapped("3")
        XCTAssertEqual("1.23", viewModel.text)
        XCTAssertEqual(Double(1.23), viewModel.value)
        
        viewModel.numberTapped("4")
        XCTAssertEqual("1.234", viewModel.text)
        XCTAssertEqual(Double(1.234), viewModel.value)
        
        viewModel.numberTapped("5")
        XCTAssertEqual("1.2345", viewModel.text)
        XCTAssertEqual(Double(1.2345), viewModel.value)
        
        viewModel.numberTapped("6")
        XCTAssertEqual("1.23456", viewModel.text)
        XCTAssertEqual(Double(1.23456), viewModel.value)
        
        viewModel.numberTapped("7")
        XCTAssertEqual("1.234567", viewModel.text)
        XCTAssertEqual(Double(1.234567), viewModel.value)
        
    }
    
    func testNoLeadingZero() {
        let viewModel = KeyPadViewModel()
        viewModel.numberTapped("0")
        viewModel.numberTapped("1")
        XCTAssertEqual(viewModel.text, "1")
    }
    
    func testZeroLeadingDecimals() {
        let viewModel = KeyPadViewModel()
        viewModel.numberTapped("0")
        viewModel.dotTapped()
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("1")
        XCTAssertEqual(viewModel.text, "0.00001")
    }
    
    func dotStressing() {
        let viewModel = KeyPadViewModel()
        
        tapKey(".", times: 5, on: viewModel)
        viewModel.numberTapped("1")
        
        XCTAssertEqual(".1", viewModel.text)
        XCTAssertEqual(Double(0.1), viewModel.value)
        
        tapKey(".", times: Int.random(in: 1 ..< 3), on: viewModel)
        XCTAssertEqual(".1", viewModel.text)
        XCTAssertEqual(Double(0.1), viewModel.value)
        
        viewModel.numberTapped("0")
        viewModel.numberTapped("1")
        XCTAssertEqual(".101", viewModel.text)
        XCTAssertEqual(Double(0.101), viewModel.value)
        
    }
    
    func regretDecimal() {
        
        let viewModel = KeyPadViewModel()
        
        viewModel.valuePressed("9")
        viewModel.valuePressed("9")
        viewModel.valuePressed(".")
        viewModel.valuePressed("5")
        
        XCTAssertEqual("99.5", viewModel.text)
        XCTAssertEqual(Double(99.5), viewModel.value)
        
        viewModel.deleteTapped()
        viewModel.deleteTapped()
        
        XCTAssertEqual("99", viewModel.text)
        XCTAssertEqual(Double(99), viewModel.value)
        
        viewModel.dotTapped()
        viewModel.dotTapped()
        
        XCTAssertEqual("99.9", viewModel.text)
        XCTAssertEqual(Double(99.9), viewModel.value)
        
    }
    
    func testUpdates() {
        let viewModel = KeyPadViewModel()
        let expect = XCTestExpectation(description: self.description)
        _ = viewModel.$value.sink(receiveValue: { value in
            expect.fulfill()
            XCTAssertEqual(0.0, value)
        })
        
        viewModel.valuePressed("1")
        _ = viewModel.$value.sink(receiveValue: { value in
            expect.fulfill()
            XCTAssertEqual(1.0, value)
        })
        wait(for: [expect], timeout: 1)
        
        
    }
    func tapKey(_ key: String, times: Int, on viewModel: KeyPadViewModel) {
        for _ in 0 ..< times {
            viewModel.valuePressed(key)
        }
    }
    
}
