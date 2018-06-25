//
//  AppDelegate.m
//  FCShareManager
//
//  Created by fanchuan on 2017/9/25.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "AppDelegate.h"
#import "FCShareManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //init
    [FCShareManager sharedInstance];
    
    return YES;
}

@end
