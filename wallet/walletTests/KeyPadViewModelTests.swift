//
//  KeyPadViewModelTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 1/6/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import XCTest
import Combine
import SwiftUI
@testable import ECC_Wallet_no_logs
class KeyPadViewModelTests: XCTestCase {
    
    
    
    func testInitializer() {
        var _value = "1.234"
        var viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))
        
        XCTAssertEqual(viewModel.value, _value)
        
        _value = ""
        viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))
        
        XCTAssertEqual(viewModel.value, "0")
    }
    
    func testDelete() {
        var _value = "1.234"
        let viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))
        
        viewModel.deleteTapped()
        XCTAssertEqual("1.23", viewModel.value)
        
        
        viewModel.deleteTapped()
        XCTAssertEqual("1.2", viewModel.value)

        
        viewModel.deleteTapped()
        XCTAssertEqual("1.", viewModel.value)

        
        viewModel.deleteTapped()
        XCTAssertEqual("1", viewModel.value)

        
        viewModel.deleteTapped()
        XCTAssertEqual("0", viewModel.value)
                
    }
    
    func testInteger() {
        var _value = ""
        let viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))
        
        // make sure that initial value is zero
        XCTAssertEqual(_value, "0")
        
        viewModel.numberTapped("1")

        XCTAssertEqual("1", viewModel.value)

        viewModel.dotTapped()
        XCTAssertEqual("1.", viewModel.value)

        viewModel.numberTapped("2")
        XCTAssertEqual("1.2", viewModel.value)

        viewModel.numberTapped("3")
        XCTAssertEqual("1.23", viewModel.value)

        viewModel.numberTapped("4")
        XCTAssertEqual("1.234", viewModel.value)

        viewModel.numberTapped("5")
        XCTAssertEqual("1.2345", viewModel.value)

        viewModel.numberTapped("6")
        XCTAssertEqual("1.23456", viewModel.value)

        viewModel.numberTapped("7")
        XCTAssertEqual("1.234567", viewModel.value)

    }

    func testNoLeadingZero() {
        
        var _value = ""
        let viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("1")
        XCTAssertEqual(viewModel.value, "1")
    }

    func testDotLeadingDecimal() {
        var _value = ""
        let viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))
        viewModel.dotTapped()
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("1")
        XCTAssertEqual(viewModel.value, "0.00001")
    }

    func testZeroLeadingDecimals() {
        var _value = ""
        let viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))
        viewModel.numberTapped("0")
        viewModel.dotTapped()
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("0")
        viewModel.numberTapped("1")
        XCTAssertEqual(viewModel.value, "0.00001")
    }

    func dotStressing() {
        var _value = ""
        let viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))

        tapKey(".", times: 5, on: viewModel)
        viewModel.numberTapped("1")

        XCTAssertEqual(".1", viewModel.value)

        tapKey(".", times: Int.random(in: 1 ..< 3), on: viewModel)
        XCTAssertEqual(".1", viewModel.value)

        viewModel.numberTapped("0")
        viewModel.numberTapped("1")
        XCTAssertEqual(".101", viewModel.value)

    }

    func regretDecimal() {

        var _value = ""
        let viewModel = KeyPadViewModel(value: Binding(get: {
            _value
        }, set: { (v) in
            _value = v
        }))

        viewModel.valuePressed("9")
        viewModel.valuePressed("9")
        viewModel.valuePressed(".")
        viewModel.valuePressed("5")

        XCTAssertEqual("99.5", viewModel.value)

        viewModel.deleteTapped()
        viewModel.deleteTapped()

        XCTAssertEqual("99", viewModel.value)

        viewModel.dotTapped()
        viewModel.dotTapped()

        XCTAssertEqual("99.9", viewModel.value)

    }

    func tapKey(_ key: String, times: Int, on viewModel: KeyPadViewModel) {
        for _ in 0 ..< times {
            viewModel.valuePressed(key)
        }
    }
    
}
