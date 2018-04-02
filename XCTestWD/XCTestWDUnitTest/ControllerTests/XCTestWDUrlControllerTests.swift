//
//  XCTestWDUrlController.swift
//  XCTestWDUnitTest
//
//  Created by SamuelZhaoY on 2/4/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import XCTest
import Nimble
@testable import XCTestWD
@testable import Swifter

class XCTestWDUrlControllerTests: XCTestWDUnitTestBase {
    
    func testUrlController() {
        let request = Swifter.HttpRequest.init()
        let response = XCTestWDUrlController.url(request: request)
        response.shouldBeSuccessful()
    }
}
