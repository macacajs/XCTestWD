//
//  testUITests.swift
//  testUITests
//
//  Created by xdf on 14/04/2017.
//  Copyright © 2017 xdf. All rights reserved.
//

import XCTest
import Swifter

class XCTextWDRunner: XCTestCase {
  var server: HttpServer?
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    XCUIApplication().launch()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testRunner() {
    XCTestWDServer().startServer()
  }
}
