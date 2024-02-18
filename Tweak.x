#import <YouTubeHeader/YTVideoQualitySwitchOriginalController.h>
#import <YouTubeHeader/YTVideoQualitySwitchRedesignedController.h>

@interface YTVideoQualitySwitchOriginalController (Addition)
@property (retain, nonatomic) YTVideoQualitySwitchRedesignedController *redesignedController;
@end

%hook YTIMediaQualitySettingsHotConfig

%new(B@:)
- (BOOL)enableQuickMenuVideoQualitySettings { return NO; }

%end

%hook YTVideoQualitySwitchOriginalController

%property (retain, nonatomic) YTVideoQualitySwitchRedesignedController *redesignedController;

- (void)setUserSelectableFormats:(NSArray <MLFormat *> *)formats {
    if (self.redesignedController == nil)
        self.redesignedController = [[%c(YTVideoQualitySwitchRedesignedController) alloc] initWithServiceRegistryScope:nil parentResponder:nil];
    [self.redesignedController setValue:[self valueForKey:@"_video"] forKey:@"_video"];
    %orig([self.redesignedController addRestrictedFormats:formats]);
}

- (void)dealloc {
    self.redesignedController = nil;
    %orig;
}

%end