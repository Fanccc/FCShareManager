//
//  FCShareManager.m
//  UM6_Use
//
//  Created by fanchuan on 16/10/28.
//  Copyright © 2016年 fanchuan. All rights reserved.
//

#import "FCShareManager.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <WXApi.h>

NSString *const UMAppKey = @"571735b267e58e087a000345";
NSString *const WeChatAppid = @"wxdc1e388c3822c80b";
NSString *const WeChatAppSecret = @"3baf1193c85774b3fd9d18447d76cab0";
NSString *const QQAppId = @"1105821097";
NSString *const QQAppKey = @"";
NSString *const SinaWBAppid = @"3921700954";
NSString *const SinaWBAppSecret = @"04b48b094faeb16683c32669824ebdad";
NSString *const SinaWBURL = @"https://sns.whalecloud.com/sina2/callback";

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
        
        [UMConfigure initWithAppkey:UMAppKey channel:nil];
        
        //打开日志
#ifdef DEBUG
        [UMConfigure setLogEnabled:YES];
#else
        [UMConfigure setLogEnabled:NO];
#endif
        
        //是否强制使用https
        [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
        
        NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
        
        //设置微信的appId和appKey
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WeChatAppid appSecret:WeChatAppSecret redirectURL:SinaWBURL];
        
        //设置分享到QQ互联的appId和appKey
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAppId  appSecret:QQAppKey redirectURL:@"http://mobile.umeng.com/social"];
        
        //设置新浪的appId和appKey
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:SinaWBAppid  appSecret:SinaWBAppSecret redirectURL:SinaWBURL];
    }
    return self;
}

- (void)shareWebMessage:(NSString *)url title:(NSString *)title desc:(NSString *)desc thumbImage:(id)thumbImage onVC:(UIViewController *)currentController success:(void(^)(id))success failed:(void(^)(NSError *))failed{
    UMSocialMessageObject *message = [self createMessageObjectForType:FCShareTypeWebPage url:url title:title desc:desc thumImage:thumbImage shareImage:nil uName:nil path:nil hdImageData:nil];
    [self shareMessageObject:message onVC:currentController success:success failed:failed];
}

- (void)shareMessageObject:(UMSocialMessageObject *)messageObject onVC:(UIViewController *)currentController success:(void (^)(id))success failed:(void (^)(NSError *))failed{
    if(!messageObject)return;
    
    __weak typeof(self) weakSelf = self;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf shareMessageObject:messageObject platform:platformType onVC:currentController success:success failed:failed];
    }];
}

- (void)shareMessageObject:(UMSocialMessageObject *)messageObject platform:(UMSocialPlatformType)platform onVC:(UIViewController *)currentController success:(void (^)(id))success failed:(void (^)(NSError *))failed{
    if(platform == UMSocialPlatformType_QQ){
        if(![self qqInstalled]){
            NSLog(@"您需要安装QQ才能继续分享");
            return;
        }
        
    }else if(platform == UMSocialPlatformType_WechatSession){
        if(![self wechatInstalled]){
            NSLog(@"您需要安装微信才能继续分享");
            return;
        }
    }
    [[UMSocialManager defaultManager] shareToPlatform:platform messageObject:messageObject currentViewController:currentController completion:^(id result, NSError *error) {
        if(error){
            !failed?:failed(error);
        }else{
            !success?:success(result);
        }
    }];
}

/**
 *  三方登录
 */
- (void)threeWithType:(UMSocialPlatformType)type vc:(UIViewController *)vc success:(void(^)(UMSocialUserInfoResponse *data))success failed:(void(^)(NSError *error))failed{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:type currentViewController:vc completion:^(id result, NSError *error) {
        if(!error){
            UMSocialUserInfoResponse *authresponse = result;
            !success?:success(authresponse);
        }else{
            !failed?:failed(error);
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


//============ 分享元素创建 ========//
- (UMSocialMessageObject *)createMessageObjectForType:(FCShareType)shareType url:(NSString *)url title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage shareImage:(id)shareImage uName:(NSString *)userName path:(NSString *)path hdImageData:(NSData *)hdImageData{
    UMSocialMessageObject *object = nil;
    switch (shareType) {
        case FCShareTypeWebPage:
            object = [self createWebPageObject:url title:title desc:desc thumImage:thumImage];
            break;
        case FCShareTypeImage:
            object = [self createImageObject:shareImage thumImage:thumImage];
            break;
        case FCShareTypeImageAndText:
            object = [self createImageAndTextObject:shareImage text:title thumImage:thumImage];
            break;
        case FCShareTypeMusic:
            object = [self createMusicObject:url title:title desc:desc thumImage:thumImage];
            break;
        case FCShareTypeVideo:
            object = [self createVideoObject:url title:title desc:desc thumImage:thumImage];
            break;
        case FCShareTypeText:
            object = [self createTextObjectTitle:title];
            break;
        case FCShareTypeMiniProgram:
            object = [self createMiniProgrameObjectTitle:title desc:desc thumbImage:thumImage webpageUrl:url userName:userName path:path hdImageData:hdImageData];
            break;
        default:{
            NSString *errorInfo = [NSString stringWithFormat:@"shareType == %ld , 这不是一个合理的分享类型",shareType];
            NSAssert(NO, errorInfo);
        }
            break;
    }
    return object;
}

/**
 网页链接分享对象
 */
- (UMSocialMessageObject *)createWebPageObject:(NSString *)webUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage{
    
    UMSocialMessageObject *messageObject = [self messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:thumImage];
    //设置网页地址
    shareObject.webpageUrl = webUrl;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    return messageObject;
}

/**
 图片对象
 */
- (UMSocialMessageObject *)createImageObject:(id)shareImage thumImage:(id)thumImage{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [self messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = thumImage;
    [shareObject setShareImage:shareImage];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    return messageObject;
}

/**
 图文对象 仅支持weibo
 */
- (UMSocialMessageObject *)createImageAndTextObject:(id)shareImage text:(NSString *)text thumImage:(id)thumImage{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [self messageObject];
    messageObject.text = text;

    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = thumImage;
    [shareObject setShareImage:shareImage];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    return messageObject;
}

/**
 音乐对象
 */
- (UMSocialMessageObject *)createMusicObject:(NSString *)musicUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [self messageObject];
    //创建音乐内容对象
    UMShareMusicObject *shareObject = [UMShareMusicObject shareObjectWithTitle:title descr:desc thumImage:thumImage];
    //设置音乐网页播放地址
    shareObject.musicUrl = musicUrl;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    return messageObject;
}

/**
 视频对象
 */
- (UMSocialMessageObject *)createVideoObject:(NSString *)videoUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [self messageObject];
    //创建视频内容对象
    UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:title descr:desc thumImage:thumImage];
    //设置视频网页播放地址
    shareObject.videoUrl = videoUrl;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    return messageObject;
}

/**
 纯文本
 */
- (UMSocialMessageObject *)createTextObjectTitle:(NSString *)title{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [self messageObject];
    //设置文本
    messageObject.text = title;
    return messageObject;
}

/**
 小程序
 */
- (UMSocialMessageObject *)createMiniProgrameObjectTitle:(NSString *)title desc:(NSString *)desc thumbImage:(id)thumbImage webpageUrl:(NSString *)webpageUrl userName:(NSString *)userName path:(NSString *)path hdImageData:(NSData *)hdImageData{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [self messageObject];
    UMShareMiniProgramObject *shareObject = [UMShareMiniProgramObject shareObjectWithTitle:title descr:desc thumImage:thumbImage];
    //兼容低版本url
    shareObject.webpageUrl = webpageUrl;
    shareObject.userName = userName;
    //页面路径
    shareObject.path = path;
    messageObject.shareObject = shareObject;
    shareObject.hdImageData = hdImageData;
    shareObject.miniProgramType = UShareWXMiniProgramTypeRelease; // 可选体验版和开发板
    return messageObject;
}


- (UMSocialMessageObject *)messageObject{
    return [UMSocialMessageObject messageObject];
}


@end
