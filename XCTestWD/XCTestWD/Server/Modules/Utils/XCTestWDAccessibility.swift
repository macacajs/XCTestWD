//
//  XCUIElement+XCTestWDAccessibility.swift
//  XCTestWD
//
//  Created by zhaoy on 29/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import SwiftyJSON

func firstNonEmptyValue(_ value1:String?, _ value2:String?) -> String? {
    if value1 != nil && (value1?.count)! > 0 {
        return value1
    } else {
        return value2
    }
}

extension XCUIElement {
    
    func wdValue() -> Any! {
        var value = self.value
        if self.elementType == XCUIElement.ElementType.staticText {
            if self.value != nil {
                value = self.value
            } else {
                value = self.label
            }
        }
        if self.elementType == XCUIElement.ElementType.button {
            if let temp = self.value {
                if ((temp as? String)?.count) ?? 0 > 0 {
                    value = self.value
                } else {
                    value = self.isSelected
                }
            } else {
                value = self.isSelected
            }
        }
        if self.elementType == XCUIElement.ElementType.switch {
            value = (self.value as! NSString).doubleValue > 0
        }
        if self.elementType == XCUIElement.ElementType.textField ||
            self.elementType == XCUIElement.ElementType.textView ||
            self.elementType == XCUIElement.ElementType.secureTextField {
            if let temp = self.value {
                if let str = temp as? String {
                    if str.count > 0 {
                        value = self.value
                    } else {
                        value = self.placeholderValue
                    }
                } else {
                    value = self.value
                }
            } else {
                value = self.placeholderValue
            }
        }
        
        return value
    }
    
    
    func wdLabel() -> String {
        if self.elementType == XCUIElement.ElementType.textField {
            return self.label
        } else if self.label.count > 0 {
            return self.label
        } else {
            return ""
        }
    }
    
    func wdName() -> String? {
        let name = (firstNonEmptyValue(self.identifier, self.label))
        if name?.count == 0 {
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
        self.fb_nativeResolve()
        return self.fb_lastSnapshot()
    }
    
    //MARK: element query
    
    func descendantsMatchingXPathQuery(xpathQuery:String, returnAfterFirstMatch:Bool) -> [XCUIElement]? {
        
        let query = xpathQuery.replacingOccurrences(of: "XCUIElementTypeAny", with: "*")
        var matchSnapShots = XCTestWDXPath.findMatchesIn(self.fb_lastSnapshot(), query)
        
        if matchSnapShots == nil || matchSnapShots!.count == 0 {
            return [XCUIElement]()
        }
        
        if returnAfterFirstMatch {
            matchSnapShots = [matchSnapShots!.first!]
        }
        
        var matchingTypes = Set<XCUIElement.ElementType>()
        for snapshot in matchSnapShots! {
            matchingTypes.insert(XCUIElementTypeTransformer.singleton.elementTypeWithTypeName(snapshot.wdType()))
        }
        
        var map = [XCUIElement.ElementType:[XCUIElement]]()
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
        
        let query = self.descendants(matching: XCUIElement.ElementType.any).matching(identifier: accessibilityId);
        result.append(contentsOf: XCUIElement.extractMatchElementFromQuery(query: query, returnAfterFirstMatch: returnAfterFirstMatch))
        
        return result
    }
    
    func descendantsMatchingClassName(className:String, returnAfterFirstMatch:Bool) -> [XCUIElement]? {
        var result = [XCUIElement]()
        
        let type = XCUIElementTypeTransformer.singleton.elementTypeWithTypeName(className)
        if self.elementType == type || type == XCUIElement.ElementType.any {
            result.append(self);
            if returnAfterFirstMatch {
                return result
            }
        }
        
        let query = self.descendants(matching: type);
        result.append(contentsOf: XCUIElement.extractMatchElementFromQuery(query: query, returnAfterFirstMatch: returnAfterFirstMatch))
        
        return result
    }

    func descendantsMatching(Predicate predicate:NSPredicate, _ returnFirstMatch:Bool) -> [XCUIElement] {
        let formattedPredicate = NSPredicate.xctestWDformatSearch(predicate)
        var result:[XCUIElement] = []

        if formattedPredicate?.evaluate(with: self.fb_lastSnapshot) ?? false {
            if returnFirstMatch {
                return [self]
            }

            result.append(self)
        }

        let query = self.descendants(matching: XCUIElement.ElementType.any).matching(formattedPredicate!)

        if returnFirstMatch {
            result.append(query.element(boundBy: 0))
        } else {
            result.append(contentsOf: query.allElementsBoundByIndex)
        }

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
    
    open func customValue(forKey key: String) -> Any? {
        if key.lowercased().contains("enable") {
            return self.isEnabled
        } else if key.lowercased().contains("name") {
            return self.wdName() ?? ""
        } else if key.lowercased().contains("value") {
            return self.wdValue()
        } else if key.lowercased().contains("label") {
            return self.wdLabel()
        } else if key.lowercased().contains("type") {
            return self.wdType()
        } else if key.lowercased().contains("visible") {
            if self.fb_lastSnapshot() == nil {
                self.fb_nativeResolve()
            }
            return self.fb_lastSnapshot().isWDVisible()
        } else if key.lowercased().contains("access") {
            if self.fb_lastSnapshot() == nil {
                self.fb_nativeResolve()
            }
            return self.fb_lastSnapshot().isAccessibile()
        }
        
        return ""
    }
    
    open override func value(forUndefinedKey key: String) -> Any? {
        return ""
    }
    
    //MARK: Commands
    func tree() -> [String : AnyObject]? {
    
        self.fb_nativeResolve()
        
        return dictionaryForElement(self.fb_lastSnapshot())
    }
    
    func digest(windowName : String) -> String {
        let description = "\(windowName)_\(self.buttons.count)_\(self.textViews.count)_\(self.textFields.count)_\(self.otherElements.count)_\(self.descendants(matching:.any).count)_\(self.traits())"

        return description
    }
    
    func accessibilityTree() -> [String : AnyObject]? {
        self.fb_nativeResolve()
        let _ = self.query
        
        return accessibilityInfoForElement(self.fb_lastSnapshot())
    }
    
    //MARK: Private Methods
    func dictionaryForElement(_ snapshot:XCElementSnapshot) -> [String : AnyObject]? {
        var info = [String : AnyObject]()
        info["type"] = XCUIElementTypeTransformer.singleton.shortStringWithElementType(snapshot.elementType) as AnyObject?
        info["rawIndentifier"] = (snapshot.identifier.count > 0 ? snapshot.identifier : "") as AnyObject
        info["name"] = snapshot.wdName() as AnyObject? ?? "" as AnyObject
        info["value"] = snapshot.wdValue() as AnyObject? ?? "" as AnyObject
        info["label"] = snapshot.wdLabel() as AnyObject? ?? "" as AnyObject
        info["rect"] = snapshot.wdRect() as AnyObject
        info["frame"] = NSStringFromCGRect(snapshot.wdFrame()) as AnyObject
        info["isEnabled"] = snapshot.isWDEnabled() as AnyObject
        info["isVisible"] = snapshot.isWDVisible() as AnyObject
        
        // If block is not visible, return
        if info["isVisible"] as! Bool == false {
            return nil;
        }
        
        // If block is visible, iterate through all its children
        let childrenElements = snapshot.children
        
        if childrenElements != nil && childrenElements!.count > 0 {
            var children = [AnyObject]()
            for child in childrenElements! {
                if let temp = dictionaryForElement(child as! XCElementSnapshot) {
                    children.append(temp as AnyObject)
                }
            }
            
            if children.count > 0 {
                info["children"] = children as AnyObject
            }
        }
        
        return info
    }
    
    func accessibilityInfoForElement(_ snapshot:XCElementSnapshot) -> [String:AnyObject]? {
        let isAccessible = snapshot.isWDAccessible()
        let isVisible = snapshot.isWDVisible()
        
        var info = [String: AnyObject]()
        
        if isAccessible {
            if isVisible {
                info["value"] = snapshot.wdValue as AnyObject
                info["label"] = snapshot.wdLabel as AnyObject
            }
        }
        else {
            var children = [AnyObject]()
            let childrenElements = snapshot.children
            for childSnapshot in childrenElements! {
                let childInfo: [String: AnyObject] = self.accessibilityInfoForElement(childSnapshot as! XCElementSnapshot)!
                if childInfo.keys.count > 0{
                    children.append(childInfo as AnyObject)
                }
            }
            
            if children.count > 0 {
                info["children"] = children as AnyObject
            }
        }
        
        return info
    }
    
}

extension XCElementSnapshot {
    
    func wdValue() -> Any? {
        var value = self.value
        if self.elementType == XCUIElement.ElementType.staticText {
            if self.value != nil {
                value = self.value
            } else {
                value = self.label
            }
        }
        if self.elementType == XCUIElement.ElementType.button {
            if let temp = self.value {
                if ((temp as? String)?.count) ?? 0 > 0 {
                    value = self.value
                } else {
                    value = self.isSelected
                }
            } else {
                value = self.isSelected
            }
        }
        if self.elementType == XCUIElement.ElementType.switch {
            value = (self.value as! NSString).doubleValue > 0
        }
        if self.elementType == XCUIElement.ElementType.textField ||
            self.elementType == XCUIElement.ElementType.textView ||
            self.elementType == XCUIElement.ElementType.secureTextField {
            if let temp = self.value {
                if let str = temp as? String {
                    if str.count > 0 {
                        value = self.value
                    } else {
                        value = self.placeholderValue
                    }
                } else {
                    value = self.value
                }
            } else {
                value = self.placeholderValue
            }
        }
        
        return value
    }
    
    func wdLabel() -> String? {
        if self.elementType == XCUIElement.ElementType.textField {
            return self.label
        } else if self.label.count > 0 {
            return self.label
        } else {
            return ""
        }
    }
    
    func wdName() -> String? {
        let name = (firstNonEmptyValue(self.identifier, self.label))
        if name?.count == 0 {
            return ""
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
        
        let app: XCElementSnapshot? = rootElement() as! XCElementSnapshot?
        let screenSize: CGSize? = MathUtils.adjustDimensionsForApplication((app?.frame.size)!, (XCUIDevice.shared.orientation))
        let screenFrame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((screenSize?.width)!), height: CGFloat((screenSize?.height)!))
        
        if !visibleFrame.intersects(screenFrame) {
            return false;
        }
        
        return true
    }
    
    //MARK: Accessibility Measurement
    func isWDAccessible() -> Bool {
        if self.elementType == XCUIElement.ElementType.cell {
            if !isAccessibile() {
                let containerView: XCElementSnapshot? = children.first as? XCElementSnapshot
                if !(containerView?.isAccessibile())! {
                    return false
                }
            }
        }
        else if self.elementType != XCUIElement.ElementType.textField && self.elementType != XCUIElement.ElementType.secureTextField {
            if !isAccessibile() {
                return false
            }
        }
        
        var parentSnapshot: XCElementSnapshot? = parent
        while (parentSnapshot != nil) {
            if ((parentSnapshot?.isAccessibile())! && parentSnapshot?.elementType != XCUIElement.ElementType.table) {
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
        let attributesResult = (XCTestXCAXClientProxy.sharedClient() ).attributes(forElement: self, attributes: [number])
        return attributesResult as AnyObject?
    }
    
}

