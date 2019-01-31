//
//  HttpPostApiDemo_SuryaUITests.swift
//  HttpPostApiDemo_SuryaUITests
//
//  Created by Toor, Sanju on 01/02/19.
//  Copyright © 2019 Toor, Sanju. All rights reserved.
//

import XCTest

class HttpPostApiDemo_SuryaUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testTapSearchButton() {
        XCUIApplication().textFields["textView"].tap()
        XCUIApplication().textFields["textView"].typeText("sanjutoor@gmail.com")
        XCUIApplication().buttons["Search"].tap()
        XCUIApplication().alerts["text Field is empty"]
        sleep(3)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
