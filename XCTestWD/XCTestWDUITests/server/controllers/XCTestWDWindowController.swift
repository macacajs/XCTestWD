//
//  XCTestAlertViewCommand.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter

internal class XCTestWDWindowController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/window_handle", "get"), getWindow),
                (RequestRoute("/window_handles", "get"), getWindows),
                (RequestRoute("/window", "post"), setWindow),
                (RequestRoute("/window", "delete"), deleteWindow),
                (RequestRoute("/window/:windowHandle/size", "get"), getWindowSize),
                (RequestRoute("/window/:windowHandle/size", "post"), setWindowSize),
                (RequestRoute("/window/:windowHandle/maximize", "post"), maximize),
                (RequestRoute("/frame", "post"), setFrame)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func getWindow(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getWindow"))
    }
    
    internal static func getWindows(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getWindows"))
    }
    
    internal static func setWindow(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("setWindow"))
    }
    
    internal static func deleteWindow(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("deleteWindow"))
    }
    
    internal static func getWindowSize(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("getWindowSize"))
    }
    
    internal static func setWindowSize(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("setWindowSize"))
    }
    
    internal static func maximize(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("maximize"))
    }
    
    internal static func setFrame(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        return HttpResponse.ok(.html("setFrame"))
    }
    
}
