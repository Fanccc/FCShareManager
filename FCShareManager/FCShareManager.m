//
//  FCShareManager.m
//  UM6_Use
//
//  Created by fanchuan on 16/10/28.
//  Copyright © 2016年 fanchuan. All rights reserved.
//

#import "FCShareManager.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"

NSString *const UMAppKey = @"";
NSString *const WeChatAppid = @"";
NSString *const WeChatAppSecret = @"";
NSString *const QQAppId = @"";
NSString *const QQAppKey = @"";
NSString *const SinaWBAppid = @"";
NSString *const SinaWBAppSecret = @"";
NSString *const SinaWBURL = @"";

@interface FCShareManager ()

@end

@implementation FCShareManager

/**
 *  Init
 */
+ (FCShareManager *)sharedInstance{
    static FCShareManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FCShareManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    if(self = [super init]){
        //打开日志
        [[UMSocialManager defaultManager] openLog:NO];
        //设置友盟appkey
        [[UMSocialManager defaultManager] setUmSocialAppkey:UMAppKey];
        [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
        
        NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
        
        //设置微信的appId和appKey
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WeChatAppid appSecret:WeChatAppSecret redirectURL:SinaWBURL];
        
        //设置分享到QQ互联的appId和appKey
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAppId  appSecret:QQAppKey redirectURL:SinaWBURL];
        
        //设置新浪的appId和appKey
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:SinaWBAppid  appSecret:SinaWBAppSecret redirectURL:SinaWBURL];
    }
    return self;
}


/**
 *  有UI分享
 */
-(void)shareUrl:(NSString* )url
     shareTitle:(NSString* )shareTitle
      shareText:(NSString* )shareText
     shareImage:(id)shareImageURL
           OnVC:(UIViewController *)controller
        success:(void(^)())success{
    
    __weak typeof(self) weakSelf = self;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [weakSelf noHaveUIShareUrl:url shareTitle:shareTitle shareText:shareText shareImage:shareImageURL OnVC:controller type:platformType success:success];
    }];
}


/**
 *  无UI分享,调用底层方法
 */
- (void)noHaveUIShareUrl:(NSString *)url shareTitle:(NSString* )shareTitle shareText:(NSString* )shareText shareImage:(id)shareImageURL OnVC:(UIViewController *)controller type:(UMSocialPlatformType)type success:(void(^)())success{
    
    if(type == UMSocialPlatformType_QQ){
        if(![self qqInstalled]){
            NSLog(@"您需要安装QQ才能继续分享");
            return;
        }
        
    }else if(type == UMSocialPlatformType_WechatSession){
        if(![self wechatInstalled]){
            NSLog(@"您需要安装wechat才能继续分享");
            return;
        }
    }
    
    UMSocialMessageObject *object = [self setMessageObjectWithUrl:url shareTitle:shareTitle shareText:shareText shareImage:shareImageURL];
    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:object currentViewController:controller completion:^(id result, NSError *error) {
        NSString *message = nil;
        if (!error) {
            message = [NSString stringWithFormat:@"分享成功"];
            if(success){
                success();
            }
        }
        else{
            if (error) {
                message = [NSString stringWithFormat:@"失败原因Code: %d\n",(int)error.code];
            }
            else{
                message = [NSString stringWithFormat:@"分享失败"];
            }
            NSLog(@"%@",message);
        }
    }];
}

- (UMSocialMessageObject *)setMessageObjectWithUrl:(NSString *)url shareTitle:(NSString* )shareTitle shareText:(NSString* )shareText shareImage:(id)shareImageURL{
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareText thumImage:shareImageURL];
    [shareObject setWebpageUrl:url];
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    messageObject.shareObject = shareObject;
    return messageObject;
}


/**
 *  三方登录
 */
- (void)threeWithType:(UMSocialPlatformType)type vc:(UIViewController *)vc success:(void(^)(UMSocialUserInfoResponse *data))success failed:(void(^)(NSString *msg))failed{
    
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:type currentViewController:vc completion:^(id result, NSError *error) {
        if(!error){
            UMSocialUserInfoResponse *authresponse = result;
            if(success){
                success(authresponse);
            }
        }else{
            NSString *message = [NSString stringWithFormat:@"result: %d",(int)error.code];
            if(failed){
                failed(message);
            }
        }
    }];
}

/**
 *  移除授权
 */
- (void)removeAuth{
    [[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_QQ completion:nil];
    [[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_WechatSession completion:nil];
    [[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_Sina completion:nil];
}


/**
 *  校验微信是否安装
 */
- (BOOL)wechatInstalled{
    return [WXApi isWXAppInstalled];
}


/**
 *  校验QQ是否安装
 */
- (BOOL)qqInstalled{
    return [QQApiInterface isQQInstalled];
}


@end
