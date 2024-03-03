#import <YouTubeHeader/_ASDisplayView.h>
#import <YouTubeHeader/YTActionSheetDialogViewController.h>
#import <YouTubeHeader/YTResponder.h>
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

%hook _ASDisplayView

- (void)didMoveToWindow {
    %orig;
    ASDisplayNode *node = self.keepalive_node;
    if (![node.accessibilityIdentifier isEqualToString:@"id.elements.components.overflow_menu_item_Quality"]) return;
    YTActionSheetDialogViewController *vc = (YTActionSheetDialogViewController *)[node closestViewController];
    if (![vc isKindOfClass:%c(YTActionSheetDialogViewController)]) return;
    if (![vc.parentViewController isKindOfClass:%c(YTBottomSheetController)]) return;
    id <YTResponder> sc = (id <YTResponder>)vc.delegate;
    id c = [sc parentResponder];
    if (![c isKindOfClass:%c(YTMainAppVideoPlayerOverlayViewController)]) return;
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
            break;
        }
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:c action:@selector(didPressVideoQuality:)];
    [self addGestureRecognizer:tap];
}

%end
