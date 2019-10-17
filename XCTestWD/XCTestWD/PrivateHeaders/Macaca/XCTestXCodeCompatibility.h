#import <XCTestWD/XCUIElement.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCUIElement (XCTestWD)

- (void)fb_nativeResolve;

- (XCElementSnapshot *)fb_lastSnapshot;

@end

@interface XCUIElementQuery (XCTestWD)

/* Performs short-circuit UI tree traversion in iOS 11+ to get the first element matched by the query. Equals to nil if no matching elements are found */
@property(nullable, readonly) XCUIElement *fb_firstMatch;

/**
 Retrieves the snapshot for the given element

 @returns The resolved snapshot
 */
- (XCElementSnapshot *)fb_elementSnapshotForDebugDescription;

@end


NS_ASSUME_NONNULL_END
