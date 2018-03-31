//
//  XCTestWDUnitTest.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 31/3/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Swifter
import XCTestWD

class XCTestWDUnitTest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testApplicationLaunch() {
        let application = XCTestWDApplication.activeApplication()
        XCTAssert(application != nil, "application should not be nil")
    }
}
