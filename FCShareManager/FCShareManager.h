//
//  FCShareManager.h
//  UM6_Use
//
//  Created by fanchuan on 16/10/28.
//  Copyright © 2016年 fanchuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import <UMCommon/UMCommon.h>

typedef NS_ENUM(NSInteger, FCShareType){
    FCShareTypeWebPage,  //网页
    FCShareTypeImage,  //图片
    FCShareTypeImageAndText, //图文
    FCShareTypeMusic, //音乐
    FCShareTypeVideo, //视频
    FCShareTypeText, //文本
    FCShareTypeMiniProgram //小程序
};

@interface FCShareManager : NSObject

/**
 *  Init
 */
+ (FCShareManager *)sharedInstance;

/**
 * 分享WebPage 平常可能绝大多数均为网页分享
 */
- (void)shareWebMessage:(NSString *)url title:(NSString *)title desc:(NSString *)desc thumbImage:(id)thumbImage onVC:(UIViewController *)currentController success:(void(^)(id))success failed:(void(^)(NSError *))failed;

/**
 * 使用umeng提供的UI
 */
- (void)shareMessageObject:(UMSocialMessageObject *)messageObject onVC:(UIViewController *)currentController success:(void(^)(id))success failed:(void(^)(NSError *))failed;
/**
 * 指定平台分享,不使用umeng提供的UI
 */
- (void)shareMessageObject:(UMSocialMessageObject *)messageObject platform:(UMSocialPlatformType)platform onVC:(UIViewController *)currentController success:(void (^)(id))success failed:(void (^)(NSError *))failed;

/**
 *  三方登录
 */
- (void)threeWithType:(UMSocialPlatformType)type vc:(UIViewController *)vc success:(void(^)(UMSocialUserInfoResponse *data))success failed:(void(^)(NSError *error))failed;

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

#pragma mark - create message object

/**
 根据type生成指定 message object
 @param shareType FCShareType
 @param url 网页/音乐/视频/小程序低版本兼容 url
 @param title 标题 / 纯文本分享时的内容
 @param desc 描述
 @param thumImage 缩略图
 @param shareImage 分享纯图片时的图片
 @param userName userName
 @param path 页面路径
 @param hdImageData 小程序新版本的预览图 < 128k
 @return messageObject
 */
- (UMSocialMessageObject *)createMessageObjectForType:(FCShareType)shareType url:(NSString *)url title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage shareImage:(id)shareImage uName:(NSString *)userName path:(NSString *)path hdImageData:(NSData *)hdImageData;

//网页
- (UMSocialMessageObject *)createWebPageObject:(NSString *)webUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage;
//图片
- (UMSocialMessageObject *)createImageObject:(id)shareImage thumImage:(id)thumImage;
//图文(仅限微博)
- (UMSocialMessageObject *)createImageAndTextObject:(id)shareImage text:(NSString *)text thumImage:(id)thumImage;
//音乐
- (UMSocialMessageObject *)createMusicObject:(NSString *)musicUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage;
//视频
- (UMSocialMessageObject *)createVideoObject:(NSString *)videoUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage;
//纯文本
- (UMSocialMessageObject *)createTextObjectTitle:(NSString *)title;

/**
 小程序

 @param title title
 @param desc desc
 @param thumbImage thumbImage
 @param webpageUrl 低版本url
 @param userName userName
 @param path 页面路径
 @param hdImageData 小程序新版本的预览图 < 128k
 @return UMSocialMessageObject
 */
- (UMSocialMessageObject *)createMiniProgrameObjectTitle:(NSString *)title desc:(NSString *)desc thumbImage:(id)thumbImage webpageUrl:(NSString *)webpageUrl userName:(NSString *)userName path:(NSString *)path hdImageData:(NSData *)hdImageData;

@end
