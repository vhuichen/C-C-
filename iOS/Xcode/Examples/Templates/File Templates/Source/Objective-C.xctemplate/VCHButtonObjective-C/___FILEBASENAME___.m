//___FILEHEADER___

#import "___FILEBASENAME___.h"

@implementation ___FILEBASENAMEASIDENTIFIER___

- (instancetype)initWithNormalTitle:(NSString *)normalTitle {
    if (self = [super init]) {
        [self initWithTitle:normalTitle];
    }
    return self;
}

- (void)initWithTitle:(NSString *)normalTitle {
    //self.backgroundColor = kRGB(0x4285F4);
    //self.titleLabel.font = kRegularFont(18);
    //[self setTitleColor:kRGB(0xFFFFFF) forState:UIControlStateNormal];
    [self setTitle:normalTitle forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.height / 2;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        //self.backgroundColor = kRGB(0x4285F4);
    } else {
        //self.backgroundColor = kRGB(0xAAC9FD);
    }
}

@end
