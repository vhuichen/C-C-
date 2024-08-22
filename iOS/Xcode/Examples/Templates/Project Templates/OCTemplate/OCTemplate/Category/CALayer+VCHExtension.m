//
//  CALayer+VCHExtension.m
//  OCTemplate
//
//  Created by vchan on 2023/3/21.
//

#import "CALayer+VCHExtension.h"

@implementation CALayer (VCHExtension)

- (void)vch_setMaskBezierPathWithRoundedRect:(CGRect)rect
                           byRoundingCorners:(UIRectCorner)corners
                                 cornerRadii:(CGSize)cornerRadii {
    if (@available(iOS 11.0, *)) {
        self.cornerRadius = cornerRadii.width;
        self.maskedCorners = (CACornerMask)corners;
    } else {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                       byRoundingCorners:corners
                                                             cornerRadii:cornerRadii];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = rect;
        maskLayer.path = maskPath.CGPath;
        self.mask = maskLayer;
    }
}

@end
