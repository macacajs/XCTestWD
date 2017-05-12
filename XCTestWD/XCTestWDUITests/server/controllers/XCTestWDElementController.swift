//
//  XCTestAlertViewCommand.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter

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
        let usage = request.params["using"]
        let value = request.params["value"]
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = request.session?.application ?? XCTestWDSessionManager.singleton.checkDefaultSession().application
        
        if application == nil || value == nil || usage == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let element = try? XCTestWDFindElementUtils.filterElement(usingText: usage!, withvalue: value!, underElement: application!)
        if element == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        return XCTestWDResponse.responseWithCacheElement(element!!, session.cache)
    }
    
    internal static func findElements(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let usage = request.params["using"]
        let value = request.params["value"]
        let session = request.session ?? XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = request.session?.application ?? XCTestWDSessionManager.singleton.checkDefaultSession().application
        
        if application == nil || value == nil || usage == nil {
            return XCTestWDResponse.response(session: nil, error: WDStatus.InvalidSelector)
        }
        
        let elements = try? XCTestWDFindElementUtils.filterElements(usingText: usage!, withValue: value!, underElement: application!, returnAfterFirstMatch: false)
        if elements == nil || elements.count == 0 {
            return XCTestWDResponse.response(session: nil, error: WDStatus.NoSuchElement)
        }
        
        return XCTestWDResponse.responsWithCacheElements(elements!!, session.cache)
    }
    
    internal static func setValue(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("setValue"))
    }
    
    internal static func click(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("click"))
    }
    
    internal static func getText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getText"))
    }
    
    internal static func clearText(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("clearText"))
    }
    
    internal static func isDisplayed(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("isDisplayed"))
    }
    
    internal static func getAttribute(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getAttribute"))
    }
    
    internal static func getProperty(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getProperty"))
    }
    
    internal static func getComputedCss(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getComputedCss"))
    }
    
    internal static func getRect(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getRect"))
    }
    
}
