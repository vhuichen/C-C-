//
//  UIButton+VCHExtension.m
//  OCTemplate
//
//  Created by vchan on 2023/3/29.
//

#import "UIButton+VCHExtension.h"

typedef NS_ENUM(NSUInteger, VCHButtonStyle) {
    VCHButtonStyleTopImage,     // image在上，label在下
    VCHButtonStyleLeftImage,    // image在左，label在右
    VCHButtonStyleBottomImage,  // image在下，label在上
    VCHButtonStyleRightImage    // image在右，label在左
};

@implementation UIButton (VCHExtension)

- (void)vch_layoutWithTopImageAndSpace:(CGFloat)space {
    [self vch_layoutWithStyle:VCHButtonStyleTopImage space:space];
}

- (void)vch_layoutWithLeftImageAndSpace:(CGFloat)space {
    [self vch_layoutWithStyle:VCHButtonStyleLeftImage space:space];
}

- (void)vch_layoutWithBottomImageAndSpace:(CGFloat)space {
    [self vch_layoutWithStyle:VCHButtonStyleBottomImage space:space];
}

- (void)vch_layoutWithRightImageAndSpace:(CGFloat)space {
    [self vch_layoutWithStyle:VCHButtonStyleRightImage space:space];
}

- (void)vch_layoutWithStyle:(VCHButtonStyle)style space:(CGFloat)space {
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = self.titleLabel.intrinsicContentSize.width;
    CGFloat labelHeight = self.titleLabel.intrinsicContentSize.height;
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    CGFloat halfSpace = space / 2;
    
    switch (style) {
        case VCHButtonStyleTopImage: {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - halfSpace, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight - halfSpace, 0);
        } break;
        case VCHButtonStyleLeftImage: {
            imageEdgeInsets = UIEdgeInsetsMake(0, -halfSpace, 0, halfSpace);
            labelEdgeInsets = UIEdgeInsetsMake(0, halfSpace, 0, -halfSpace);
        } break;
        case VCHButtonStyleBottomImage: {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight - halfSpace, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight - halfSpace, -imageWith, 0, 0);
        } break;
        case VCHButtonStyleRightImage: {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + halfSpace, 0, -labelWidth - halfSpace);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith - halfSpace, 0, imageWith + halfSpace);
        } break;
    }
    
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

@end
