#import <YouTubeHeader/ASDisplayNode.h>
#import <YouTubeHeader/ASNodeController.h>
#import <YouTubeHeader/ASTextNode.h>
#import <YouTubeHeader/ELMTouchCommandPropertiesHandler.h>
#import <YouTubeHeader/YTActionSheetAction.h>
#import <YouTubeHeader/YTActionSheetDialogViewController.h>
#import <YouTubeHeader/YTIMenuItemSupportedRenderers.h>
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
#import <YouTubeHeader/YTModuleEngagementPanelViewController.h>
#import <YouTubeHeader/YTResponder.h>
#import <YouTubeHeader/YTVideoQualitySwitchOriginalController.h>
#import <YouTubeHeader/YTVideoQualitySwitchRedesignedController.h>
#import <YouTubeHeader/YTWatchViewController.h>

@interface YTVideoQualitySwitchOriginalController (YTClassicVideoQuality)
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
    NSArray *yogaChildren = node.yogaChildren;
    if (yogaChildren.count == 2 && [[yogaChildren lastObject] isKindOfClass:%c(ASTextNode)]) {
        ASDisplayNode *parent = node.yogaParent, *previousParent;
        do {
            previousParent = parent;
            parent = parent.yogaParent;
        } while (parent && parent.yogaChildren.count != 5);
        return parent && parent.yogaChildren.count == 5 && parent.yogaChildren[3] == previousParent;
    }
    return NO;
}

%hook ELMTouchCommandPropertiesHandler

- (void)handleTap {
    ASDisplayNode *node = [(ASNodeController *)[self valueForKey:@"_controller"] node];
    if (isQualitySelectionNode(node)) {
        UIViewController *vc = [node closestViewController];
        if ([vc isKindOfClass:(%c(YTAppCollectionViewController))]) {
            do {
                vc = vc.parentViewController;
            } while (vc && ![vc isKindOfClass:%c(YTModuleEngagementPanelViewController)]);
            if ([vc isKindOfClass:%c(YTModuleEngagementPanelViewController)]) {
                do {
                    vc = vc.parentViewController;
                } while (vc && ![vc isKindOfClass:%c(YTWatchViewController)]);
                if ([vc isKindOfClass:%c(YTWatchViewController)]) {
                    YTPlayerViewController *pvc = ((YTWatchViewController *)vc).playerViewController;
                    id c = [pvc activeVideoPlayerOverlay];
                    if ([c isKindOfClass:%c(YTMainAppVideoPlayerOverlayViewController)]) {
                        [c dismissViewControllerAnimated:YES completion:^{
                            [c didPressVideoQuality:nil];
                        }];
                        return;
                    }
                }
            }
        }
    }
    %orig;
}

%end

%hook YTMenuController

- (NSMutableArray <YTActionSheetAction *> *)actionsForRenderers:(NSMutableArray <YTIMenuItemSupportedRenderers *> *)renderers fromView:(UIView *)fromView entry:(id)entry shouldLogItems:(BOOL)shouldLogItems firstResponder:(id)firstResponder {
    NSUInteger index = [renderers indexOfObjectPassingTest:^BOOL(YTIMenuItemSupportedRenderers *renderer, NSUInteger idx, BOOL *stop) {
        YTIMenuItemSupportedRenderersElementRendererCompatibilityOptionsExtension *extension = (YTIMenuItemSupportedRenderersElementRendererCompatibilityOptionsExtension *)[renderer.elementRenderer.compatibilityOptions messageForFieldNumber:396644439];
        BOOL isVideoQuality = [extension.menuItemIdentifier isEqualToString:@"menu_item_video_quality"];
        if (isVideoQuality) *stop = YES;
        return isVideoQuality;
    }];
    NSMutableArray <YTActionSheetAction *> *actions = %orig;
    if (index != NSNotFound) {
        YTActionSheetAction *action = actions[index];
        action.handler = ^{
            [firstResponder didPressVideoQuality:fromView];
        };
        UIView *elementView = [action.button valueForKey:@"_elementView"];
        elementView.userInteractionEnabled = NO;
    }
    return actions;
}

%end
