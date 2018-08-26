//
//  XCTestWDFindElementUtils.swift
//  XCTestWD
//
//  Created by zhaoy on 7/5/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation

class XCTestWDFindElementUtils {

    static func filterElement(usingText:String, withvalue:String, underElement:XCUIElement) throws -> XCUIElement? {
        return try filterElements(usingText:usingText, withValue:withvalue, underElement:underElement, returnAfterFirstMatch:true)?.first
    }
    
    
    // Routing for xpath, class name, name, id
    static func filterElements(usingText:String, withValue:String, underElement:XCUIElement, returnAfterFirstMatch:Bool) throws -> [XCUIElement]? {
        
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
        } else if usingText == "predicate string" {
            let predicate = NSPredicate.xctestWDPredicate(withFormat: withValue)
            return underElement.descendantsMatching(Predicate: predicate!, returnAfterFirstMatch)
        }
        
        throw XCTestWDRoutingError.noSuchUsingMethod
    }
}
