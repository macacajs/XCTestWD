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
        return HttpResponse.ok(.html("findElement"))
    }
    
    internal static func findElements(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("findElements"))
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
