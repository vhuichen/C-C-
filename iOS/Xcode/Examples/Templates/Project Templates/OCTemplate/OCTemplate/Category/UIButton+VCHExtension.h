//
//  UIButton+VCHExtension.h
//  OCTemplate
//
//  Created by vchan on 2023/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (VCHExtension)

/// 必须要在设置了Frame或者约束后调用
- (void)vch_layoutWithTopImageAndSpace:(CGFloat)space;
- (void)vch_layoutWithLeftImageAndSpace:(CGFloat)space;
- (void)vch_layoutWithBottomImageAndSpace:(CGFloat)space;
- (void)vch_layoutWithRightImageAndSpace:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END
