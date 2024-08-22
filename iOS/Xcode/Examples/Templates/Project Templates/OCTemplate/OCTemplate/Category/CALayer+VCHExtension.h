//
//  CALayer+VCHExtension.h
//  OCTemplate
//
//  Created by vchan on 2023/3/21.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (VCHExtension)

- (void)vch_setMaskBezierPathWithRoundedRect:(CGRect)rect
                           byRoundingCorners:(UIRectCorner)corners
                                 cornerRadii:(CGSize)cornerRadii;

@end

NS_ASSUME_NONNULL_END
