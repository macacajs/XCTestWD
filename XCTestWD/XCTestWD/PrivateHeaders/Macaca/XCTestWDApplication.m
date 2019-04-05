//
//  XCTestWDApplication.m
//  XCTestWDUITests
//
//  Created by zhaoy on 24/9/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

#import "XCTestWDApplication.h"
#import "XCUIApplication.h"
#import "XCTestXCAXClientProxy.h"

@implementation XCTestWDApplication

+ (XCUIApplication*)activeApplication
{
    id activeApplicationElement = ((NSArray*)[[XCTestXCAXClientProxy sharedClient] activeApplications]).lastObject;
    
    if (!activeApplicationElement) {
        activeApplicationElement = ((XCTestXCAXClientProxy*)[XCTestXCAXClientProxy sharedClient]).systemApplication;
    }

    XCUIApplication* application = [XCTestWDApplication createByPID:[[activeApplicationElement valueForKey:@"processIdentifier"] intValue]];

    if (application.state != XCUIApplicationStateRunningForeground) {
        application = [[XCUIApplication alloc] initPrivateWithPath:nil bundleID:@"com.apple.springboard"];
    }

    [application query];
    return application;
}

+ (XCUIApplication*)createByPID:(pid_t)pid
{
    if ([XCUIApplication respondsToSelector:@selector(appWithPID:)]) {
         return [XCUIApplication appWithPID:pid];
    }
    
    if ([XCUIApplication respondsToSelector:@selector(applicationWithPID:)]) {
        return [XCUIApplication applicationWithPID:pid];
    }
    
    return [[XCTestXCAXClientProxy sharedClient] monitoredApplicationWithProcessIdentifier:pid];
}

@end
