//
//  XCTestXCAXClientProxy.m
//  XCTestWD
//
//  Created by SamuelZhaoY on 5/4/19.
//  Copyright © 2019 XCTestWD. All rights reserved.
//

#import "XCTestXCAXClientProxy.h"

#import "XCAXClient_iOS.h"
#import "XCUIDevice.h"

static id XCTestAXClient = nil;

@implementation XCTestXCAXClientProxy

+ (instancetype)sharedClient
{
    static XCTestXCAXClientProxy *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        if ([XCAXClient_iOS.class respondsToSelector:@selector(sharedClient)]) {
            XCTestAXClient = [XCAXClient_iOS sharedClient];
        } else {
            XCTestAXClient = [XCUIDevice.sharedDevice accessibilityInterface];
        }
    });
    return instance;
}

- (NSArray<id> *)activeApplications
{
    return [XCTestAXClient activeApplications];
}

- (id)systemApplication
{
    return [XCTestAXClient systemApplication];
}

- (NSDictionary *)attributesForElement:(id )element
                            attributes:(NSArray *)attributes
{
    if ([XCTestAXClient respondsToSelector:@selector(attributesForElement:attributes:error:)]) {
        NSError *error = nil;
        NSDictionary* result = [XCTestAXClient attributesForElement:element
                                                         attributes:attributes
                                                              error:&error];
        return result;
    }
    return [XCTestAXClient attributesForElement:element attributes:attributes];
}

- (XCUIApplication *)monitoredApplicationWithProcessIdentifier:(int)pid
{
    return [[XCTestAXClient applicationProcessTracker] monitoredApplicationWithProcessIdentifier:pid];
}

@end
