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
import CocoaLumberjackSwift

internal class XCTestWDTitleController: Controller {
    
    //MARK: Controller - Protocol
    static func routes() -> [(RequestRoute, RoutingCall)] {
        return [(RequestRoute("/title", "get"), title),
                (RequestRoute("/wd/hub/session/:sessionId/title", "get"), title)]
    }
    
    static func shouldRegisterAutomatically() -> Bool {
        return false
    }
    
    //MARK: Routing Logic Specification
    internal static func title(request: Swifter.HttpRequest) -> Swifter.HttpResponse {

        let session = XCTestWDSessionManager.singleton.checkDefaultSession()
        let application = session.application

        let elements = application?.descendants(matching: XCUIElement.ElementType.window).allElementsBoundByIndex

        if  elements == nil || elements?.count == 0 {
            DDLogDebug("\(XCTestWDDebugInfo.DebugLogPrefix) title, elements and element count")
            return XCTestWDResponse.response(session: nil, error: WDStatus.ElementNotVisible)
        }

        let window = elements![0]
        let navBar = window.descendants(matching: XCUIElement.ElementType.navigationBar).allElementsBoundByIndex.first
        window.fb_nativeResolve()
        let digest = window.digest(windowName: navBar?.identifier == nil ? "" : (navBar?.identifier)!)
        return XCTestWDResponse.response(session: nil, value: JSON(digest as Any))
    }
}
