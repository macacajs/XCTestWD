//
//  XCTestWDXPath.swift
//  XCTestWD
//
//  Created by zhaoy on 5/5/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import AEXML
import Fuzi

internal class XCTestWDXPath {
    
    //MARK: External API
    static let defaultTopDir = "top"
    
    
    static func findMatchesIn(_ root:XCElementSnapshot, _ xpathQuery:String) -> [XCElementSnapshot]? {
        
        var mapping = [String:XCElementSnapshot]()
        let documentXml = generateXMLPresentation(root,
                                                  nil,
                                                  nil,
                                                  defaultTopDir,
                                                  &mapping)?.xml
        
        if documentXml == nil {
            return nil
        }
        
        let document = try? XMLDocument(string: documentXml!, encoding:String.Encoding.utf8)
        let nodes = document?.xpath(xpathQuery)
        var results = [XCElementSnapshot]()
        
        for node in nodes! {
            if mapping[node.attr("private_indexPath")!] != nil {
                results.append(mapping[node.attr("private_indexPath")!]!)
            }
        }
        
        return results
    }
    
    //MARK: Internal Utils
    static func generateXMLPresentation(_ root:XCElementSnapshot, _ parentElement:AEXMLElement?, _ writingDocument:AEXMLDocument?, _ indexPath:String, _ mapping: inout [String:XCElementSnapshot]) -> AEXMLDocument? {
        
        let elementName = XCUIElementTypeTransformer.singleton.stringWithElementType(root.elementType)
        let currentElement = AEXMLElement(name:elementName)
        recordAttributeForElement(root, currentElement, indexPath)
        
        let document : AEXMLDocument!
        if parentElement == nil || writingDocument == nil {
            document = AEXMLDocument()
            document.addChild(currentElement)
        } else {
            document = writingDocument!
            parentElement?.addChild(currentElement)
        }
        
        var index = 0;
        for child in root.children {
            let childSnapshot = child as! XCElementSnapshot
            let childIndexPath = indexPath.appending(",\(index)")
            index += 1
            mapping[childIndexPath] = childSnapshot

            _ = generateXMLPresentation(childSnapshot, currentElement, document, childIndexPath, &mapping)
        }

        return document
    }

    static func recordAttributeForElement(_ snapshot:XCElementSnapshot, _ currentElement:AEXMLElement, _ indexPath:String?) {
        
        currentElement.attributes["type"] = XCUIElementTypeTransformer.singleton.stringWithElementType(snapshot.elementType)
        
        if snapshot.wdValue() != nil {
            let value = snapshot.wdValue()!
            if let str = value as? String {
                currentElement.attributes["value"] = str
            } else if let bin = value as? Bool {
                currentElement.attributes["value"] = bin ? "1":"0";
            } else {
                currentElement.attributes["value"] = (value as AnyObject).debugDescription
            }
        }
        
        if snapshot.wdName() != nil {
            currentElement.attributes["name"] = snapshot.wdName()!
        }
        
        if snapshot.wdLabel() != nil {
            currentElement.attributes["label"] = snapshot.wdLabel()!
        }
        
        currentElement.attributes["enabled"] = snapshot.isWDEnabled() ? "true":"false"
        
        let rect = snapshot.wdRect()
        for key in ["x","y","width","height"] {
            currentElement.attributes[key] = rect[key]!.description
        }
        
        if indexPath != nil {
            currentElement.attributes["private_indexPath"] = indexPath!
        }
    }
}
