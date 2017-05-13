//
//  XCTestAlertViewCommand.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter
import SwiftyJSON

internal class XCTestWDElementController: Controller {
  
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/element", "post"), findElement),
                (RequestRoute("/elements", "post"), findElements),
                (RequestRoute("/element/:elementId/element", "post"), findElement),
                (RequestRoute("/element/:elementId/elements", "post"), findElements),
                (RequestRoute("/element/:elementId/value", "post"), setValue),
                (RequestRoute("/element/:elementId/click", "post"), click),
                (RequestRoute("/element/:elementId/text", "get"), getText),
                (RequestRoute("/element/:elementId/clear", "post"), clearText),
                (RequestRoute("/element/:elementId/displayed", "get"), isDisplayed),
                (RequestRoute("/element/:elementId/attribute/:name", "get"), getAttribute),
                (RequestRoute("/element/:elementId/property/:name", "get"), getProperty),
                (RequestRoute("/element/:elementId/css/:propertyName", "get"), getComputedCss),
                (RequestRoute("/element/:elementId/rect", "get"), getRect)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func findElement(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let usage = request.jsonBody["using"].string
        let value = request.jsonBody["value"].string
        let uuid  = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = request.session?.application ?? XCTestWDSessionManager.singleton.checkDefaultSession().application
        
        // Check if UUID is specified in request
        var root:XCUIElement? = application
        if uuid != nil {
            root = session.cache.elementForUUID(uuid)
        }
        
        if value == nil || usage == nil || root == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let element = try? XCTestWDFindElementUtils.filterElement(usingText: usage!, withvalue: value!, underElement: application!)
        
        if let element = element {
            if let element = element {
                return XCTestWDResponse.responseWithCacheElement(element, session.cache)
            }
        }
    
        return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
    }
    
    internal static func findElements(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let usage = request.jsonBody["using"].string
        let value = request.jsonBody["value"].string
        let uuid  = request.elementId
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = request.session?.application ?? XCTestWDSessionManager.singleton.checkDefaultSession().application
        
        // Check if UUID is specified in request
        var root:XCUIElement? = application
        if uuid != nil {
            root = session.cache.elementForUUID(uuid)
        }
        
        if value == nil || usage == nil || root == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let elements = try? XCTestWDFindElementUtils.filterElements(usingText: usage!, withValue: value!, underElement: root!, returnAfterFirstMatch: false)
        
        if let elements = elements {
            if let elements = elements {
                return XCTestWDResponse.responsWithCacheElements(elements, session.cache)
            }
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
    }
    
    internal static func setValue(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        let value = request.jsonBody["value"].string

        if value == nil || elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        if element?.elementType == XCUIElementType.pickerWheel {
            element?.adjust(toPickerWheelValue: value!)
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        if element?.elementType == XCUIElementType.slider {
            element?.adjust(toNormalizedSliderPosition: CGFloat((value! as NSString).floatValue))
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        element?.tap()
        if element?.hasKeyboardFocus == true {
            element?.typeText(value!)
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }

        return XCTestWDResponse.response(session: nil, error: WDStatus.ElementIsNotSelectable)
    }
    
    internal static func click(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        element?.tap()
        return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
    }
    
    internal static func getText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        let text:String = firstNonEmptyValue(element?.wdName(), element?.wdLabel()) as? String ?? ""
        return XCTestWDResponse.response(session: session, value: JSON(text))
    }
    
    internal static func clearText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        element?.tap()
        if element?.hasKeyboardFocus == true {
            element?.typeText(value!)
            return XCTestWDResponse.response(session: nil, error: WDStatus.Success)
        }
        
        return XCTestWDResponse.response(session: nil, error: WDStatus.ElementIsNotSelectable)
    }
    
    internal static func isDisplayed(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }

        if element?.lastSnapshot == nil {
            element?.resolve()
        }
        
        return XCTestWDResponse.response(session: session, value: JSON(element?.lastSnapshot.isWDVisible() as Any))
    }
    
    internal static func getAttribute(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        let attributeName = request.params["name"]
        
        if elementId == nil || attributeName == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }

        let value = element?.value(forKey: (attributeName?.capitalized)!)
        return XCTestWDResponse.response(session: session, value: JSON(value))
    }
    
    internal static func getRect(request: Swifter.HttpRequest) -> Swifter.HttpResponse {

        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        let attributeName = request.params["name"]
        
        if elementId == nil || attributeName == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }

        return XCTestWDResponse.response(session: session, value: JSON(element?.wdRect()))
    }
    
    //MARK: WEB impl methods
    internal static func getProperty(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getProperty"))
    }
    
    internal static func getComputedCss(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getComputedCss"))
    }
    
    private static func checkRequestValid(request: Swifter.HttpRequest) -> Swifter.HttpResponse? {
        let elementId = request.elementId
        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let element = session.cache.elementForUUID(elementId)
        
        if elementId == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        return nil
    }
    
}
