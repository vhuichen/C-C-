//___FILEHEADER___

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ___FILEBASENAME___ : NSObject

/// 单例是为了缓存变量
+ (instancetype)shareInstance;

- (void)preLogin;

- (void)presentAuthUIFrom:(UIViewController *)root
                 callback:(void(^)(BOOL isSuccess, NSString *token, id error))callback;

@end

NS_ASSUME_NONNULL_END
