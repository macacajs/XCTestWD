//
//  XCTestWDReponse.swift
//  XCTestWD
//
//  Created by zhaoy on 24/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation
import SwiftyJSON
import Swifter

internal class XCTestWDResponse {
    
    //MARK: Model & Constructor
    private var sessionId:String!
    private var status:WDStatus!
    private var value:JSON?
    
    private init(_ sessionId:String, _ status:WDStatus, _ value:JSON?) {
        self.sessionId = sessionId
        self.status = status
        self.value = value ?? JSON("")
    }
    
    private func response() -> HttpResponse {
        let response : JSON = ["sessionId":self.sessionId,
                               "status":self.status.rawValue,
                               "value":self.value as Any]
        let rawString = response.rawString()?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        return rawString != nil ? HttpResponse.ok(.text(rawString!)) : HttpResponse.internalServerError
    }
    
    //MARK: Utils
    static func response(session:XCTestWDSession?, value:JSON?) -> HttpResponse {
        return XCTestWDResponse(session?.identifier ?? "", WDStatus.Success, value ?? JSON("")).response()
    }
    
    static func response(session:XCTestWDSession? ,error:WDStatus) -> HttpResponse {
        return XCTestWDResponse(session?.identifier ?? "", error, nil).response()
    }
    
    //MARK: Factory for Error Code
    
}
