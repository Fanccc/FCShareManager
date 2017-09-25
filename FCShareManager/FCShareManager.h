//
//  FCShareManager.h
//  UM6_Use
//
//  Created by fanchuan on 16/10/28.
//  Copyright © 2016年 fanchuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>

/**
 *  UM6+
 */
@interface FCShareManager : NSObject

/**
 *  Init
 */
+ (FCShareManager *)sharedInstance;

/**
 *  有UI分享
 */
- (void)shareUrl:(NSString* )url
      shareTitle:(NSString* )shareTitle
       shareText:(NSString* )shareText
      shareImage:(id)shareImageURL
            OnVC:(UIViewController *)controller
         success:(void(^)())success;

/**
 *  无UI分享,调用底层方法
 */
- (void)noHaveUIShareUrl:(NSString *)url shareTitle:(NSString* )shareTitle shareText:(NSString* )shareText shareImage:(id)shareImageURL OnVC:(UIViewController *)controller type:(UMSocialPlatformType)type success:(void(^)())success;

/**
 *  三方登录
 */
- (void)threeWithType:(UMSocialPlatformType)type vc:(UIViewController *)vc success:(void(^)(UMSocialUserInfoResponse *data))success failed:(void(^)(NSString *msg))failed;

/**
 *  移除授权
 */
- (void)removeAuth;

/**
 *  校验微信是否安装
 */
- (BOOL)wechatInstalled;

/**
 *  校验QQ是否安装
 */
- (BOOL)qqInstalled;



@end
