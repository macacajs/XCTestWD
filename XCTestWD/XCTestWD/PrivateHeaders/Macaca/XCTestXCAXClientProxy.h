//
//  XCTestXCAXClientProxy.h
//  XCTestWD
//
//  Created by SamuelZhaoY on 5/4/19.
//  Copyright © 2019 XCTestWD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "XCElementSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

@interface XCTestXCAXClientProxy : NSObject

+ (instancetype)sharedClient;

- (NSArray<id> *)activeApplications;

- (id)systemApplication;

- (NSDictionary *)attributesForElement:(id )element
                            attributes:(NSArray *)attributes;

- (XCUIApplication *)monitoredApplicationWithProcessIdentifier:(int)pid;

@end

NS_ASSUME_NONNULL_END
