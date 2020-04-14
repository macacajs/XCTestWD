//
//  XCTestWDFailureProofTestCase.swift
//  XCTestWD
//
//  Created by SamuelZhaoY on 3/10/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

import Foundation
import XCTest

open class XCTestWDFailureProofTest : XCTestCase
{
    override open func setUp() {
        super.setUp()
        continueAfterFailure = true;
        if(self.responds(to: #selector(setter: internalImplementation))){
            internalImplementation = XCTestWDImplementationFailureHoldingProxy.proxy(with: self.internalImplementation)
        } else {
            shouldSetShouldHaltWhenReceivesControl = false
            shouldHaltWhenReceivesControl = false
        }
    }
    
    override open func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: Int, expected: Bool) {
        print("catching internal failure: \(description) in file: \(filePath) at line: \(lineNumber)")
    }
}
