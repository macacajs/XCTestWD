//
//  XCTestWDFindElementUtils.swift
//  XCTestWD
//
//  Created by zhaoy on 7/5/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation

class XCTestWDFindElementUtils {
    
    // TODO: provide alert filter here
    
    
    
    // Routing for xpath, class name, name, id
    static func filterElement(usingText:String, withValue:String, underElement:XCUIElement, returnAfterFirstMatch:Bool) -> [XCUIElement]? {
        
        let isSearchByIdentifier = (usingText == "name" || usingText == "id" || usingText == "accessibility id")
        
        if usingText == "xpath" {
            return underElement.descendantsMatchingXPathQuery(xpathQuery: withValue,
                                                              returnAfterFirstMatch: returnAfterFirstMatch)
        } else if usingText == "class name" {
            return underElement.descendantsMatchingClassName(className: withValue,
                                                             returnAfterFirstMatch: returnAfterFirstMatch)
        } else if isSearchByIdentifier {
            return underElement.descendantsMatchingIdentifier(accessibilityId: withValue,
                                                              returnAfterFirstMatch: returnAfterFirstMatch)
        }
        
        return nil
    }
}
