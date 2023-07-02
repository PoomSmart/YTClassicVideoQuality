#import "../YouTubeHeader/YTVideoQualitySwitchOriginalController.h"

BOOL makeItFake = NO;

%hook YTVersionUtils

+ (NSString *)appVersion {
    return makeItFake ? @"18.18.2" : %orig;
}

%end

%hook YTVideoQualitySwitchControllerFactory

- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    makeItFake = YES;
    return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
    makeItFake = NO;
}

%end
