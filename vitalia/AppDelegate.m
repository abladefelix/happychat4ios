//
//  AppDelegate.m
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "TabbarController.h"
#import "SuperDB.h"
#import "BPush.h"
#import <SMS_SDK/SMS_SDK.h>
#import "WeiboApi.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>


#define SmsappKey @"25a64c839b5f"
#define SmsappSecret @"9a639150fcb464d9a1c1ab926648ca3f"
@interface AppDelegate () <WXApiDelegate, BPushDelegate>
{
    TabbarController *tab;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UITabBar appearance] setBarTintColor:UIColorFromRGB(0xffffff, 1.0)];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xfee101, 1.0)];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0x2f80ef, 1.0)];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColorFromRGB(0xa5a5a5, 1.0) } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColorFromRGB(0xfa6e21, 1.0) } forState:UIControlStateSelected];
    [SuperDB createDataFile];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tab = [[TabbarController alloc] init];
    self.window.rootViewController = tab;
    [self.window makeKeyAndVisible];
    [SMS_SDK registerApp:SmsappKey
              withSecret:SmsappSecret];
    [self initsharesdk];
    [self initBaiduPush:launchOptions];
    return YES;
}

-(void)initsharesdk
{
    [ShareSDK registerApp:ShareSDKKey];
    [ShareSDK connectSinaWeiboWithAppKey:WeiboKey
                               appSecret:WeiboSecret
                             redirectUri:@"https://api.weibo.com/oauth2/default.html"];
    [ShareSDK connectQQWithQZoneAppKey:QQAppID
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectWeChatWithAppId:WeChatAppID wechatCls:[WXApi class]];
    [WXApi registerApp:WeChatAppID];
}

-(void)initBaiduPush:(NSDictionary *)launchOptions
{
    // iOS8 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    [BPush registerChannel:launchOptions apiKey:@"HCV2ptdDRV6vWk52pYnWO4TP" pushMode:BPushModeDevelopment isDebug:NO];
    
    //    [BPush setupChannel:launchOptions];
    
    // 设置 BPush 的回调
    [BPush setDelegate:self];
    
    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        debugLog(@"从消息启动:%@",userInfo);
        [BPush handleNotification:userInfo];
    }
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
    [application registerForRemoteNotifications];
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken
{
    NSString *deviceToken = [NSString stringWithFormat:@"%@", pToken];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    setDeviceToken(deviceToken);
    [BPush registerDeviceToken:pToken];
    [BPush bindChannel];
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    debugLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App 收到推送的通知
    [BPush handleNotification:userInfo];
    
    debugLog(@"%@",userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    debugLog(@"%@",userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    if (tab != nil) {
        [tab setMessageBadge:1];
    }
    
}

#pragma mark Push Delegate
- (void)onMethod:(NSString*)method response:(NSDictionary*)data
{
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark url
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [self openQYURL:url];
    switch (getOauthType) {
        case WXOauthType:
            return [WXApi handleOpenURL:url delegate:self];
            break;
            
        default:
            return [ShareSDK handleOpenURL:url wxDelegate:self];
            break;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self openQYURL:url];
    switch (getOauthType) {
        case WXOauthType:
            return [WXApi handleOpenURL:url delegate:self];
            break;
            
        default:
            return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
            break;
    }
    
}

-(BOOL)openQYURL:(NSURL *)url
{
//    NSString *urlString = [url absoluteString];
//    NSString *regex1;
//    debugLog(@"%@",urlString);
//    if ([urlString hasSuffix:@"?isappinstalled=1"]) {
//        regex1 = @"pbwc://(.*)\\?isappinstalled=1";
//    }
//    else if ([urlString hasSuffix:@"?appinstall=1"]) {
//        regex1 = @"pbwc://(.*)\\?appinstall=1";
//    }
//    else
//        regex1 = @"pbwc://(.*)";
//    
//    NSString *pnCode = [urlString stringByMatching:regex1 capture:1];
//    if ([pnCode length] != 0 && isLogin) {
//        debugLog(@"%@",pnCode);
//        //        UIViewController *vc = [tabBarVC.viewControllers objectAtIndex:0];
//        //        if ([vc isKindOfClass:[HomeViewController class]]) {
//        //            [(HomeViewController *)vc performSelector:@selector(goMOMOKA:) withObject:pnCode afterDelay:0.3];
//        //        }
//        return YES;
//    }
//    else
//    {
        return NO;
//    }
}

#pragma mark weixin delegate
-(void)onReq:(BaseReq *)req
{
    
}

-(void)onResp:(BaseResp *)resp
{
    switch (resp.errCode) {
        case WXSuccess:
        {
            debugLog(@"%ld", getOauthType);
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [[NSNotificationCenter defaultCenter] postNotificationName:WechatLoginNotification object:authResp];
        }
            break;
            
        case WXErrCodeUserCancel:
            debugLog(@"aa");
            break;
    }
}

@end
