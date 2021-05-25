#import <Foundation/Foundation.h>

@interface YTVideoQualitySwitchOriginalController : NSObject
- (instancetype)initWithParentResponder:(id)responder;
@end

%hook YTVideoQualitySwitchControllerFactory

- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
	Class originalClass = %c(YTVideoQualitySwitchOriginalController);
	return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}

%end