#import <Foundation/Foundation.h>

@interface GIMMe
- (instancetype)allocOf:(Class)cls;
@end

@interface YTVideoQualitySwitchControllerFactory : NSObject
- (GIMMe *)gimme;
@end

@interface YTVideoQualitySwitchOriginalController : NSObject
- (instancetype)initWithParentResponder:(id)responder;
@end

%hook YTVideoQualitySwitchControllerFactory

- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
	Class originalClass = %c(YTVideoQualitySwitchOriginalController);
	return originalClass ? [(YTVideoQualitySwitchOriginalController *)[[self gimme] allocOf:originalClass] initWithParentResponder:responder] : %orig;
}

%end