//
//  XCTestWebDriverServer.swift
//  XCTestWebdriver
//
//  Created by zhaoy on 21/4/17.
//  Copyright © 2017 XCTestWebdriver. All rights reserved.
//

import Foundation
import Swifter

struct XCTestWDConst {
  static let defaultPort = in_port_t(8088)
}

public class XCTestWDServer {
  
  private let server = HttpServer()
  
  internal func startServer() {
    do {
      print("-------starting http server:------")
      try server.start(XCTestWDConst.defaultPort)
      registerRouters()
        
      XCUIApplication().terminate()
      print("XCTestWDSetup->http://localhost:\(try! server.port())<-XCTestWDSetup")
      RunLoop.main.run()
    } catch {
      print("Server start error: \(error)")
    }
  }
  
  private func registerRouters() {
    
    var controllers = [Controller]()
    
    controllers.append(XCTestWDActionsController())
    controllers.append(XCTestWDAlertController())
    controllers.append(XCTestWDContextController())
    controllers.append(XCTestWDElementController())
    controllers.append(XCTestWDExecuteController())
    controllers.append(XCTestWDKeysController())
    controllers.append(XCTestWDScreenshotController())
    controllers.append(XCTestWDSessionController())
    controllers.append(XCTestWDSourceController())
    controllers.append(XCTestWDStatusController())
    controllers.append(XCTestWDTimeoutController())
    controllers.append(XCTestWDTitleController())
    controllers.append(XCTestWDElementController())
    controllers.append(XCTestWDWindowController())

    for controller in controllers {
      let routes = type(of: controller).routes()
      for i in 0...routes.count - 1 {
        let (router, requestHandler) = routes[i]
        var routeMethod: HttpServer.MethodRoute?
        
        switch router.verb {
        case "post","POST":
          routeMethod = server.POST
          break
        case "get","GET":
          routeMethod = server.GET
          break
        case "put", "PUT":
          routeMethod = server.PUT
          break
        case "delete", "DELETE":
          routeMethod = server.DELETE
          break
        case "update", "UPDATE":
          routeMethod = server.UPDATE
          break
        default:
          routeMethod = nil
          break
        }
        
        routeMethod?[router.path] = RouteOnMain(requestHandler)
      }
    }
  }
}
