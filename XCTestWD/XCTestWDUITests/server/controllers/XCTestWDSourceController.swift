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

internal class XCTestWDSourceController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/session/:sessionId/source", "get"), source),
                (RequestRoute("/source", "get"), sourceWithoutSession),
                (RequestRoute("/session/:sessionId/accessibleSource", "get"), accessiblitySource),
                (RequestRoute("/accessibleSource", "get"), accessiblitySourceWithoutSession)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func source(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let temp = request.session?.application.tree()
        return XCTestWDResponse.response(session: request.session, value: JSON(temp!))
    }
    
    internal static func sourceWithoutSession(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let temp = XCTestWDSession.activeApplication()?.tree()
        return XCTestWDResponse.response(session: request.session, value: JSON(temp!))
    }
    
    internal static func accessiblitySource(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let temp = request.session?.application.accessibilityTree()
        return XCTestWDResponse.response(session: request.session, value: JSON(temp!))
    }
    
    internal static func accessiblitySourceWithoutSession(request: Swifter.HttpRequest) -> Swifter.HttpResponse {
        let temp = XCTestWDSession.activeApplication()?.accessibilityTree()
        XCTestWDXPath.findMatchesIn(XCTestWDSession.activeApplication()?.lastSnapshot() as! XCElementSnapshot, "//Other")
        return XCTestWDResponse.response(session: request.session, value: JSON(temp!))
    }
}
