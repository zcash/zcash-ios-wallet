//
//  walletUITests.swift
//  walletUITests
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import XCTest

class walletUITests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
       

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
    func testSeedRestore() {
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        app.launch()
        app.buttons["Restore"].tap()
        
        XCTAssertNotNil(app.staticTexts.allElementsBoundByIndex.first(where: {$0.label == "Make sure nobody is watching you!"}))
        
        let seedPhraseTextfield = app.textFields.firstMatch
        seedPhraseTextfield.tap()
        seedPhraseTextfield.typeText("human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe")
        XCTAssertNotNil(app.staticTexts.allElementsBoundByIndex.first(where: { (element) -> Bool in
            element.label  == "Your seed phrase is valid"
        }))
        guard let proceedButton = app.buttons.allElementsBoundByIndex.first(where: { $0.label == "Proceed" }) else {
            XCTFail("Proceed button not found")
            return
        }
        XCTAssertTrue(proceedButton.isEnabled)
        seedPhraseTextfield.typeText("")
        seedPhraseTextfield.clearAndEnterText(text: "Human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe")
        
        XCTAssertNotNil(app.staticTexts.allElementsBoundByIndex.first(where: { (element) -> Bool in
            element.label == "Your seed phrase is invalid!"
        }))
        app.tap()
        
        guard let disabledProceedButton = app.buttons.allElementsBoundByIndex.first(where: { $0.label == "Proceed" }) else {
                   XCTFail("Proceed button not found")
                   return
               }
        XCTAssertFalse(disabledProceedButton.isEnabled)
    }
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}
