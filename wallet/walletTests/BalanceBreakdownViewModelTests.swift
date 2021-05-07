//
//  BalanceBreakdownViewModelTests.swift
//  ECC-WalletTests
//
//  Created by Francisco Gindre on 4/27/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet_no_logs

typealias StringTuple = (String,String)
class BalanceBreakdownViewModelTests: XCTestCase {
    /**
      Double represents the human readable Zec Amount in decimals
     (String, String) is a touple where component 0 is the more significant portion of the number as a String,
     and component 1 is the least significanto poriton of the number as a string.
     string representation is 10 figures in total including whole numbers and decimal fractions
     */
    var testVector: [(Double,(String,String))] {
        [
            
            (20.94431563,("20.944","31563")),
            ((12345),("12345.000","00")),
            ((0.1),("0.100","000000")),
            ((0.01),("0.010","000000")),
            ((0.011),("0.011","000000")),
            ((0.0101),("0.010","100000")),
            ((0.01011),("0.010","110000")),
            ((0.010101),("0.010","101000")),
            ((0.0101011),("0.010","101100")),
            ((0.01010101),("0.010","101010")),
            ((0.010101011),("0.010","101011")),
            ((0.0101010111),("0.010","101011")),
            ((9.010101011),("9.010","101011")),
            ((89.010101011),("89.010","10101")),
            ((789.010101011),("789.010","1010")),
            ((6789.010101011),("6789.010","101")),
            ((56789.010101011),("56789.010","10")),
            ((456789.010101011),("456789.010","1")),
            ((3456789.010101011),("3456789.010","")),

        ]
    }


    func testZecAmountBreakdown() throws {
        for tuple in testVector {
            let amount = tuple.0
            let expectedStringTuple = tuple.1
            let result = AmountBreakdownViewModel.breakAmountDown(value: amount,
                                                                  count: 10,
                                                                  formatter: NumberFormatter.zecAmountBreakdownFormatter,
                                                                  highlightingDecimals: 3)
            XCTAssertTrue(tupleEquals(result,expectedStringTuple),"result: \(result) is not equal to expected \(expectedStringTuple) for amount: \(amount)")
        }
    }
    
    func tupleEquals(_ lhs: (String,String),_ rhs: (String,String)) -> Bool {
        lhs.0 == rhs.0 && lhs.1 == rhs.1
    }
}


