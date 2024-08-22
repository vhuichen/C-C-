//
//  UIScreen+VCHExtension.m
//  OCTemplate
//
//  Created by vchan on 2023/3/21.
//

#import "UIScreen+VCHExtension.h"

@implementation UIScreen (VCHExtension)

- (UIEdgeInsets)vch_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    } else {
        return UIEdgeInsetsMake(20, 0, 0, 0);
    }
}

@end
