//
//  VCHApp.m
//  OCTemplate
//
//  Created by vchan on 2023/4/3.
//

#import "VCHApp.h"

@implementation VCHApp

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self appearance];
        [self customInit];
    }
    return self;
}

- (void)appearance {
    //
    UIButton.appearance.adjustsImageWhenHighlighted = NO;
    //
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTintColor:[UIColor blackColor]];
    UIImage *image = [UIImage imageNamed:@"login_nav_back"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navigationBar.backIndicatorImage = image;
    navigationBar.backIndicatorTransitionMaskImage = image;
    [navigationBar setShadowImage:[UIImage new]];
    navigationBar.barTintColor = UIColor.whiteColor;
    navigationBar.translucent = NO;
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.shadowColor = UIColor.clearColor;
        appearance.backgroundColor = UIColor.whiteColor;
        navigationBar.scrollEdgeAppearance = appearance;
        navigationBar.standardAppearance = appearance;
    }
}

- (void)customInit {
    
}

@end
