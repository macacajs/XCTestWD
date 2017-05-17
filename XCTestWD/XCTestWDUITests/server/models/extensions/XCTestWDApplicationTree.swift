//
//  XCTestWDApplicationTree.swift
//  XCTestWD
//
//  Created by zhaoy on 5/5/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import SwiftyJSON

extension XCUIApplication {

    func mainWindowSnapshot() -> XCElementSnapshot? {
        let mainWindows = (self.lastSnapshot() as! XCElementSnapshot).descendantsByFiltering { (snapshot) -> Bool in
            return snapshot?.isMainWindow ?? false
        }
        return mainWindows?.last
    }

    //MARK: Commands
    func tree() -> [String : AnyObject]? {
        if self.lastSnapshot == nil {
            self.resolve()
        }
        
        return dictionaryForElement(self.lastSnapshot)
    }
    
    func accessibilityTree() -> [String : AnyObject]? {
        
        if self.lastSnapshot == nil {
            let _ = self.query()
            self.resolve()
        }
        
        return accessibilityInfoForElement(self.lastSnapshot)
    }
    
    //MARK: Private Methods
    func dictionaryForElement(_ snapshot:XCElementSnapshot) -> [String : AnyObject]? {
        var info = [String : AnyObject]()
        info["type"] = XCUIElementTypeTransformer.singleton.shortStringWithElementType(snapshot.elementType) as AnyObject?
        info["rawIndentifier"] = snapshot.identifier.characters.count > 0 ? snapshot.identifier as AnyObject : nil
        info["name"] = snapshot.wdName() as AnyObject? ?? nil
        info["value"] = snapshot.wdValue() as AnyObject? ?? nil
        info["rect"] = snapshot.wdRect() as AnyObject
        info["frame"] = NSStringFromCGRect(snapshot.wdFrame()) as AnyObject
        info["isEnabled"] = snapshot.isWDEnabled() as AnyObject
        info["isVisible"] = snapshot.isWDEnabled() as AnyObject
        
        let childrenElements = snapshot.children
        if childrenElements != nil && childrenElements!.count > 0 {
            var children = [AnyObject]()
            for child in childrenElements! {
                children.append(dictionaryForElement(child as! XCElementSnapshot) as AnyObject)
            }
            
            info["children"] = children as AnyObject
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
