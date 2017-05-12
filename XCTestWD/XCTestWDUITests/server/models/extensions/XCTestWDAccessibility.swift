//
//  XCUIElement+XCTestWDAccessibility.swift
//  XCTestWD
//
//  Created by zhaoy on 29/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation

func firstNonEmptyValue(_ value1:Any?, _ value2:Any?) -> Any? {
    if value1 != nil {
        return value1
    } else {
        return value2
    }
}

extension XCUIElement {
    
    func wdValue() -> Any! {
        var value = self.value
        if self.elementType == XCUIElementType.staticText {
            value = firstNonEmptyValue(self.value, self.label)
        }
        if self.elementType == XCUIElementType.button {
            value = firstNonEmptyValue(self.value, self.isSelected ? true: nil)
        }
        if self.elementType == XCUIElementType.switch {
            value = self.value as! Int > 0
        }
        if self.elementType == XCUIElementType.textField ||
           self.elementType == XCUIElementType.textView ||
            self.elementType == XCUIElementType.secureTextField {
            value = firstNonEmptyValue(self.value, self.placeholderValue)
        }
        
        return value
    }
    
    func wdLabel() -> String {
        if self.elementType == XCUIElementType.textField {
            return self.label
        } else if self.label.characters.count > 0 {
            return self.label
        } else {
            return ""
        }
    }
    
    func wdName() -> String? {
        let name = (firstNonEmptyValue(self.identifier, self.label) as? String)
        if name?.characters.count == 0 {
            return nil
        } else {
            return name
        }
    }

    
    func wdType() -> String {
        return XCUIElementTypeTransformer.singleton.stringWithElementType(self.elementType)
    }
    
    func isWDEnabled() -> Bool {
        return self.isEnabled
    }
    
    func wdFrame() -> CGRect {
        return self.frame.integral
    }
    
    func wdRect() -> [String:CGFloat] {
        return [
            "x":self.frame.minX,
            "y":self.frame.minY,
            "width":self.frame.width,
            "height":self.frame.height]
    }
    
    func checkLastSnapShot() -> XCElementSnapshot {
        if self.lastSnapshot != nil {
            return self.lastSnapshot
        }
        self.resolve()
        return self.lastSnapshot
    }
    
    //MARK: element query
    
    func descendantsMatchingXPathQuery(xpathQuery:String, returnAfterFirstMatch:Bool) -> [XCUIElement]? {
        let query = xpathQuery.replacingOccurrences(of: "XCUIElementTypeAny", with: "*")
        var matchSnapShots = XCTestWDXPath.findMatchesIn(self.lastSnapshot, query)
        
        if matchSnapShots == nil || matchSnapShots!.count == 0 {
            return [XCUIElement]()
        }
        
        if returnAfterFirstMatch {
            matchSnapShots = [matchSnapShots!.first!]
        }

        var matchingTypes = Set<XCUIElementType>()
        for snapshot in matchSnapShots! {
            matchingTypes.insert(XCUIElementTypeTransformer.singleton.elementTypeWithTypeName(snapshot.wdType()))
        }

        var map = [XCUIElementType:[XCUIElement]]()
        for type in matchingTypes {
            let descendantsOfType = self.descendants(matching: type).allElementsBoundByIndex
            map[type] = descendantsOfType
        }

        var matchingElements = [XCUIElement]()
        for snapshot in matchSnapShots! {
            var elements = map[snapshot.elementType]
            if query.contains("last()") {
                elements = elements?.reversed()
            }
            
            innerLoop: for element in elements! {
                if element.checkLastSnapShot()._matchesElement(snapshot) {
                    matchingElements.append(element)
                    break innerLoop
                }
            }
            
        }

        return matchingElements
    }
    
    func descendantsMatchingIdentifier(accessibilityId:String, returnAfterFirstMatch:Bool) -> [XCUIElement]? {
        var result = [XCUIElement]()
        
        if self.identifier == accessibilityId {
            result.append(self)
            if returnAfterFirstMatch {
                return result
            }
        }
        
        let query = self.descendants(matching: XCUIElementType.any).matching(identifier: accessibilityId);
        result.append(contentsOf: XCUIElement.extractMatchElementFromQuery(query: query, returnAfterFirstMatch: returnAfterFirstMatch))
        
        return result
    }
    
    func descendantsMatchingClassName(className:String, returnAfterFirstMatch:Bool) -> [XCUIElement]? {
        var result = [XCUIElement]()
        
        let type = XCUIElementTypeTransformer.singleton.elementTypeWithTypeName(className)
        if self.elementType == type || type == XCUIElementType.any {
            result.append(self);
            if returnAfterFirstMatch {
                return result
            }
        }
        
        let query = self.descendants(matching: type);
        result.append(contentsOf: XCUIElement.extractMatchElementFromQuery(query: query, returnAfterFirstMatch: returnAfterFirstMatch))
        
        return result
    }
    
    static func extractMatchElementFromQuery(query:XCUIElementQuery, returnAfterFirstMatch:Bool) -> [XCUIElement] {
        if !returnAfterFirstMatch {
            return query.allElementsBoundByIndex
        }
        
        let matchedElement = query.element(boundBy: 0)
        
        if query.allElementsBoundByIndex.count == 0{
            return [XCUIElement]()
        } else {
            return [matchedElement]
        }
    }
}

extension XCElementSnapshot {
    
    func wdValue() -> Any? {
        var value = self.value
        if self.elementType == XCUIElementType.staticText {
            value = firstNonEmptyValue(self.value, self.label)
        }
        if self.elementType == XCUIElementType.button {
            value = firstNonEmptyValue(self.value, self.isSelected ? true: nil)
        }
        if self.elementType == XCUIElementType.switch {
            value = self.value as! Int > 0
        }
        if self.elementType == XCUIElementType.textField ||
            self.elementType == XCUIElementType.textView ||
            self.elementType == XCUIElementType.secureTextField {
            value = firstNonEmptyValue(self.value, self.placeholderValue)
        }
        
        return value
    }
    
    func wdLabel() -> String? {
        if self.elementType == XCUIElementType.textField {
            return self.label
        } else if self.label.characters.count > 0 {
            return self.label
        } else {
            return nil
        }
    }
    
    func wdName() -> String? {
        let name = (firstNonEmptyValue(self.identifier, self.label) as? String)
        if name?.characters.count == 0 {
            return nil
        } else {
            return name
        }
    }
    
    func wdType() -> String {
        return XCUIElementTypeTransformer.singleton.stringWithElementType(self.elementType)
    }
    
    func isWDEnabled() -> Bool {
        return self.isEnabled
    }
    
    func wdFrame() -> CGRect {
        return self.frame.integral
    }
    
    func wdRect() -> [String:CGFloat] {
        return [
            "x":self.frame.minX,
            "y":self.frame.minY,
            "width":self.frame.width,
            "height":self.frame.height]
    }
    
    func isWDVisible() -> Bool {
        if self.frame.isEmpty || self.visibleFrame.isEmpty {
            return false
        }

        let app: XCElementSnapshot? = _rootElement() as! XCElementSnapshot?
        let screenSize: CGSize? = MathUtils.adjustDimensionsForApplication((app?.frame.size)!, (XCUIDevice.shared().orientation))
        let screenFrame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((screenSize?.width)!), height: CGFloat((screenSize?.height)!))
        let rectIntersects: Bool = visibleFrame.intersects(screenFrame)
        let isActionable: Bool? = app?.frame.contains(hitPoint)
        return rectIntersects && isActionable!
    }
    
    //MARK: Accessibility Measurement
    func isWDAccessible() -> Bool {
        if self.elementType == XCUIElementType.cell {
            if !isAccessibile() {
                let containerView: XCElementSnapshot? = children.first as? XCElementSnapshot
                if !(containerView?.isAccessibile())! {
                    return false
                }
            }
        }
        else if self.elementType != XCUIElementType.textField && self.elementType != XCUIElementType.secureTextField {
            if !isAccessibile() {
                return false
            }
        }
        
        var parentSnapshot: XCElementSnapshot? = parent
        while (parentSnapshot != nil) {
            if ((parentSnapshot?.isAccessibile())! && parentSnapshot?.elementType != XCUIElementType.table) {
                return false;
            }
            
            parentSnapshot = parentSnapshot?.parent
        }
        
        return true
    }

    func isAccessibile() -> Bool {
        return self.attributeValue(XCAXAIsElementAttribute)?.boolValue ?? false
    }
    
    func attributeValue(_ number:NSNumber) -> AnyObject? {
        let attributesResult = (XCAXClient_iOS.sharedClient() as! XCAXClient_iOS).attributes(forElementSnapshot: self, attributeList: [number])
        return attributesResult as AnyObject?
    }

}

