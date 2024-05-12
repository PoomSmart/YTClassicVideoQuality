#import <YouTubeHeader/ASDisplayNode.h>
#import <YouTubeHeader/ASNodeController.h>
#import <YouTubeHeader/ELMTouchCommandPropertiesHandler.h>
#import <YouTubeHeader/YTActionSheetDialogViewController.h>
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
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
    NSArray <MLFormat *> *newFormats = [self.redesignedController respondsToSelector:@selector(addRestrictedFormats:)] ? [self.redesignedController addRestrictedFormats:formats] : formats;
    %orig(newFormats);
}

- (void)dealloc {
    self.redesignedController = nil;
    %orig;
}

%end

static BOOL isQualitySelectionNode(ASDisplayNode *node) {
    if ([node.accessibilityIdentifier hasPrefix:@"id.elements.components.overflow_menu_item_"]) {
        NSString *label = node.accessibilityLabel;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+p" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:label options:0 range:NSMakeRange(0, label.length)];
        return match != nil;
    }
    return NO;
}

%hook ELMTouchCommandPropertiesHandler

- (void)handleTap {
    ASDisplayNode *node = [(ASNodeController *)[self valueForKey:@"_controller"] node];
    if (isQualitySelectionNode(node)) {
        YTActionSheetDialogViewController *vc = (YTActionSheetDialogViewController *)[node closestViewController];
        if ([vc isKindOfClass:%c(YTActionSheetDialogViewController)] && [vc.parentViewController isKindOfClass:%c(YTBottomSheetController)]) {
            id <YTResponder> sc = (id <YTResponder>)vc.delegate;
            id c = [sc parentResponder];
            if ([c isKindOfClass:%c(YTMainAppVideoPlayerOverlayViewController)]) {
                [c dismissViewControllerAnimated:YES completion:^{
                    [(YTMainAppVideoPlayerOverlayViewController *)c didPressVideoQuality:nil];
                }];
                return;
            }
        }
    }
    %orig;
}

%end
