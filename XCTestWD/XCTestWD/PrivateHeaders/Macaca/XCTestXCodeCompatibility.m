#import "XCTestXCodeCompatibility.h"

#import "XCUIElementQuery.h"

@implementation XCUIElement (XCTestWD)

- (void)fb_nativeResolve
{
  if ([self respondsToSelector:@selector(resolve)]) {
    [self resolve];
    return;
  }
  if ([self respondsToSelector:@selector(resolveOrRaiseTestFailure)]) {
    @try {
      [self resolveOrRaiseTestFailure];
    } @catch (NSException *e) {
      NSLog(@"Failure while resolving '%@': %@", self.description, e.reason);
    }
    return;
  }
}

- (XCElementSnapshot *)fb_lastSnapshot
{
  return [self.query fb_elementSnapshotForDebugDescription];
}

@end

@implementation XCUIElementQuery (XCTestWD)

- (XCUIElement *)fb_firstMatch
{
  if (!self.element.exists) {
    return nil;
  }
  return self.allElementsBoundByAccessibilityElement.firstObject;
}

- (XCElementSnapshot *)fb_elementSnapshotForDebugDescription
{
  if ([self respondsToSelector:@selector(elementSnapshotForDebugDescription)]) {
    return [self elementSnapshotForDebugDescription];
  }
  if ([self respondsToSelector:@selector(elementSnapshotForDebugDescriptionWithNoMatchesMessage:)]) {
    return [self elementSnapshotForDebugDescriptionWithNoMatchesMessage:nil];
  }
  return nil;
}

@end
