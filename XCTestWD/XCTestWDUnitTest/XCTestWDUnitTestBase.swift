
//
//  XCTestWDUnitTestBase.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 1/4/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
@testable import XCTestWD

class XCTestWDUnitTestBase: XCTestCase {

    var springApplication:XCUIApplication?

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCTestWDSessionManager.singleton.clearAll()
        self.springApplication = XCTestWDApplication.activeApplication()
    }
    
    override func tearDown() {
        super.tearDown()
        XCTestWDSessionManager.singleton.clearAll()
    }
}
