//___FILEHEADER___

#import "___FILEBASENAME___.h"
#import <TXLoginoauthSDK/TXLoginoauthSDK.h>
#import "FCBUITool.h"
#import "FCBDefine.h"
#import "FCBAccountLoginController.h"

@interface ___FILEBASENAME___ ()

@property (nonatomic, assign) BOOL isPreLoginSuccess;
@property (nonatomic, weak) UIViewController *rootVC;

@end

@implementation ___FILEBASENAME___

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [TXLoginOauthSDK initLoginWithId:@"1400579514"];
    }
    return self;
}

- (void)preLogin {
    self.isPreLoginSuccess = NO;
    //预加载
    [TXLoginOauthSDK preLoginWithBack:^(NSDictionary *resultDic) {
        NSInteger preResultCode = [resultDic[@"preResultCode"] intValue];;
        NSInteger resultCode = [resultDic[@"resultCode"] intValue];;
        if (preResultCode == 10000 && resultCode == 103000) {
            self.isPreLoginSuccess = YES;
        }
        NSLog(@"vhuichen preLogin %@", resultDic);
    } failBlock:^(id error) {
        NSLog(@"vhuichen preLogin %@", error);
    }];
}

- (void)presentAuthUIFrom:(UIViewController *)root callback:(void (^)(BOOL, NSString *, id))callback {
    if (!self.isPreLoginSuccess) {
        NSLog(@"vhuichen isPreLoginSuccess = NO");
        callback ? callback(NO, nil, nil) : nil;
        return;
    }
    self.rootVC = root;
    TXLoginUIModel *uiModel = [self loginUIModel];
    [TXLoginOauthSDK loginWithController:root andUIModel:uiModel successBlock:^(NSDictionary *resultDic) {
        if ([resultDic[@"loginResultCode"] isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback ? callback(YES, resultDic[@"token"], nil) : nil;
            });
        }
    } failBlock:^(id error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback ? callback(NO, nil, error) : nil;
        });
    }];
}

- (TXLoginUIModel *)loginUIModel {
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    
    UIEdgeInsets safeAreaInsets = [FCBUITool safeAreaInsets];
    
    TXLoginUIModel *uiModel = [TXLoginUIModel new];
    
    /**状态栏设置*/
    uiModel.statusBarStyle = UIStatusBarStyleDefault;
    
    /**logo的图片设置*/
    [uiModel setIconImage:[UIImage imageNamed:@"app_logo"]];     //应用logo
    [uiModel setLogoFrame:CGRectMake((width - 65)/2.0, 127 + safeAreaInsets.top, 65.0, 65.0)];/**LOGO图片frame*/
    [uiModel setLogoHidden:NO];//LOGO图片是否隐藏,默认显示 NO
    
    /**手机号码相关设置*/
    [uiModel setNumberOffsetX:@0];
    CGFloat numberOffsetY = height - 39.5 - 222 - safeAreaInsets.top;
    [uiModel setTxMobliNumberOffsetY:@(numberOffsetY)];
    [uiModel setNumberTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithRed:54/255.0 green:69/255.0 blue:93/255.0 alpha:1/1.0],
        NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:28]
    }];
    
    /**品牌logo 相关属性*/
    [uiModel setSloganHidden:YES];
    
    /**登录按钮相关*/
    [uiModel setLogBtnText: [[NSAttributedString alloc] initWithString:@"本机号码一键登录" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:16]}]];
    [uiModel setLogBtnHeight:47.0];
    UIImage *loginBtnImg = [self createImageWithColor:[UIColor colorWithRed:66/255.0 green:133/255.0 blue:244/255.0 alpha:1/1.0] andSize:CGSizeMake(width, 47)];
    loginBtnImg = [self generateCornerRadiusImage:loginBtnImg cornerRadius:47 * 0.5];
    [uiModel setLoginBtnImgs:@[loginBtnImg, loginBtnImg, loginBtnImg]];
    CGFloat logBtnOffsetY = height - 47 - 286 - safeAreaInsets.top;
    [uiModel setLogBtnOffsetY:logBtnOffsetY];
    
    /**底部协议复选框设置*/
    [uiModel setCheckBoxWH:26.f];//修改隐私复选框的大小，联通和移动可用
    [uiModel setCheckedImg:[UIImage imageNamed:@"login_checkbox_checked"]];
    [uiModel setUncheckedImg:[UIImage imageNamed:@"login_checkbox_unchecked"]];
    [uiModel setAgreementOn:NO];
    uiModel.checkTipText = @"请勾选同意后再登陆";
    
    /**底部协议相关设置*/
    [uiModel setPrivacyColor: [UIColor colorWithRed:66/255.0 green:133/255.0 blue:244/255.0 alpha:1/1.0]];
    NSString *strappPrivacy = [NSString stringWithFormat:@"登录即代表您已阅读并同意《FinClip服务协议》《隐私政策》及&&默认&&"];
    [uiModel setPrivacyTextFont:[UIFont fontWithName:@"PingFangSC-Regular" size:13]];
    [uiModel setPrivacyTextColor:[UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1/1.0]];
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"《FinClip服务协议》" attributes:@{NSLinkAttributeName:kAgreementLink}];
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"《隐私政策》" attributes:@{NSLinkAttributeName:kPolicyLink}];
    [uiModel setAppPrivacyDemo:strappPrivacy];
    // 隐私条款:数组对象
    uiModel.appPrivacy = @[str1, str2];
    uiModel.privacyLabelOffsetY = 60 + safeAreaInsets.bottom + 3;
    uiModel.appPrivacyOriginLR = @[@(20), @(20)];
    
    [uiModel setPresentAnimated:YES];//弹出是否动画
    [uiModel setPresentType:RICHPresentationDirectionBottom];//页面弹出模式设置
    
    [uiModel setWebNavColor:[UIColor whiteColor]];
    [uiModel setWebNavTitleAttrs:@{NSForegroundColorAttributeName:  [UIColor colorWithRed:3/255.0 green:13/255.0 blue:30/255.0 alpha:1/1.0], NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size:17]}];
    [uiModel setWebNavReturnImg:[UIImage imageNamed:@"login_nav_close"]];
    
    /**创建自定义view*/
    CGFloat status = [[UIApplication sharedApplication] statusBarFrame].size.height;
    UIView *navBackView = [[UIView alloc]initWithFrame:CGRectMake(0, status, width, 44)];
    navBackView.backgroundColor = [UIColor clearColor];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(12, 0, 32, 32);
    [closeBtn setImage:[UIImage imageNamed:@"login_nav_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [navBackView addSubview:closeBtn];
    
    [uiModel setCustomTopLoginView:navBackView];
    
    [uiModel setIfCreateCustomView:YES];
    UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    otherBtn.frame = CGRectMake((width - 120) * 0.5, 353 + safeAreaInsets.top, 120, 21);
    [otherBtn setTitle:@"使用其他号码登录" forState:UIControlStateNormal];
    [otherBtn setTitleColor:[UIColor colorWithRed:136/255.0 green:140/255.0 blue:147/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [otherBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    [otherBtn addTarget:self action:@selector(otherLogin) forControlEvents:UIControlEventTouchUpInside];
    [uiModel setCustomOtherLoginView:otherBtn];
    
    return uiModel;
}

- (void)close {
    [TXLoginOauthSDK delectScrip];
    [self.rootVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)otherLogin {
    [TXLoginOauthSDK delectScrip];
    [self.rootVC dismissViewControllerAnimated:YES completion:^{
        FCBAccountLoginController *vc = [[FCBAccountLoginController alloc] init];
        [self.rootVC.navigationController pushViewController:vc animated:YES];
    }];
}


/// 纯色转图片
/// @param color 颜色
/// @param size 图片尺寸
- (UIImage *)createImageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

/// UIImage加圆角
/// @param original 图片
/// @param cornerRadius 圆角
- (UIImage *)generateCornerRadiusImage:(UIImage *)original cornerRadius:(CGFloat)cornerRadius {
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0.0, 0.0, original.size.width, original.size.height);
    CGContextAddPath(ctx, [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius].CGPath);
    CGContextClip(ctx);
    [original drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)image:(UIImage *)image color:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


@end
