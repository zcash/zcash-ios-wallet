//
//  PendingTransactionModelTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 7/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet
class DetailCardTests: XCTestCase {

   

    func testSubtitle() throws {
        
        let date = "some_date"
        let minedHeight = 10
        let latestHeight = 12
        // transaction submitted, not mined
        XCTAssertEqual(DetailModel.subtitle(isPending: true, isSubmitSuccess: true, minedHeight: -1, date: date, latestBlockHeight: -1), "Pending confirmation".localized())
        // transaction submitted, not mined, height info available
        XCTAssertEqual(DetailModel.subtitle(isPending: true, isSubmitSuccess: true, minedHeight: -1, date: date, latestBlockHeight: latestHeight), "Pending confirmation".localized())
        
        // transaction submitted, mined with height
        XCTAssertEqual(DetailModel.subtitle(isPending: true, isSubmitSuccess: true, minedHeight: minedHeight, date: date, latestBlockHeight: latestHeight), "Confirmations".localized(with: abs(latestHeight - minedHeight)))
        
        // submitted, mined but no info on current latestheight
        XCTAssertEqual(DetailModel.subtitle(isPending: true, isSubmitSuccess: true, minedHeight: minedHeight, date: date, latestBlockHeight: -1), "Pending confirmation".localized())
        
        // submission failed
        XCTAssertEqual(DetailModel.subtitle(isPending: false, isSubmitSuccess: false, minedHeight: -1, date: date, latestBlockHeight: latestHeight), "Sent %s".localized(with: date))
        
    }


}
