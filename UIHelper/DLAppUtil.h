//
//  DLAppUtil.h
//  qunyou
//
//  Created by Donal on 14-3-13.
//  Copyright (c) 2014年 vikaa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHAlertView.h"
#import "OHActionSheet.h"
#import "Tool.h"
#import "NSString+Wrapper.h"
#import "UIView+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "APIClient.h"
#import "SVProgressHUD.h"
#import "MWPhotoBrowser.h"

@interface DLAppUtil : NSObject
#define WMAppID @"1-20178-d86ca85fa3bf8db970f11a9fb89f49af"
#define WMSECRET @"e468cf291e106ac6c9460395b8b105ab"

#define ShareSDKKey @"e6dd91c2c20"
#define WeChatAppID @"wx390b4c68b74d2256"
#define WeChatSECRET @"5e82c2ffa4713b76e79fa1e7af1cf14d"

#define TENCENT_AKEY @"801470875"
#define TENCENT_SKEY @"71b3835c265008540e5c93d1b33a0d13"

//QQ
#define QQAppID @"101008107"
#define QQAppKey @"981895697a8193379d84538afb40adb2"

//Sina KEY
#define WeiboKey @"1110718262"
#define WeiboSecret  @"eef44990967a9e73e4b4c2627f63bc53"

#define ChatNewMsgNotifaction @"ChatNewMsgNotifaction"
#define ChatUpdateMsgNotifaction @"ChatUpdateMsgNotifaction"

#define ReLoginNotification @"ReLoginNotification"

#define PutActivitySucNotification @"PutActivitySucNotification"
#define PutPhonebookSucNotification @"PutPhonebookSucNotification"
#define PutCardNotification @"PutCardNotification"

#define HideAddSomethingViewNotification @"HideAddSomethingViewNotification"

#define WechatLoginNotification @"WechatLoginNotification"
//FMDB
#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__);} }
#define DATABASE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]stringByAppendingString:[NSString stringWithFormat:@"/%@.db", @"draft"]]

#ifdef DEBUG
//调试模式
#define debugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

//发布模式
#else

#define debugLog(...)

#endif

#define UIColorFromRGB(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]
#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define CURRENT_SYS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define isGuided [[NSUserDefaults standardUserDefaults] boolForKey:IsGuide]
#define setIsGuided [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsGuide];[[NSUserDefaults standardUserDefaults] synchronize];
#define setNotGuided [[NSUserDefaults standardUserDefaults] setBool:No forKey:IsGuide];[[NSUserDefaults standardUserDefaults] synchronize];

#define setBaiduPushType(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:BaiduPushType];[[NSUserDefaults standardUserDefaults] synchronize];
#define getBaiduPushType [[NSUserDefaults standardUserDefaults] objectForKey:BaiduPushType]

#define setBaiduUserID(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:BaiduChannelId];[[NSUserDefaults standardUserDefaults] synchronize];
#define getBaiduUserID [[NSUserDefaults standardUserDefaults] objectForKey:BaiduChannelId]

#define setBaiduChannelID(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:BaiduUserId];[[NSUserDefaults standardUserDefaults] synchronize];
#define getBaiduChannelID [[NSUserDefaults standardUserDefaults] objectForKey:BaiduUserId]

#define IsNetwork [[NSUserDefaults standardUserDefaults] boolForKey:IsNetworking]
#define setIsNetwork(work) [[NSUserDefaults standardUserDefaults] setBool:work forKey:IsNetworking];[[NSUserDefaults standardUserDefaults] synchronize];

#define isUserLogin [[NSUserDefaults standardUserDefaults] boolForKey:IsUserLogin]
#define setIsLogin [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsUserLogin];[[NSUserDefaults standardUserDefaults] synchronize];
#define setLogout [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:IsUserLogin];[[NSUserDefaults standardUserDefaults] synchronize];

#define setUserID(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserID];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserID [[NSUserDefaults standardUserDefaults] objectForKey:APPUserID]

#define setUserAvatar(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserAvatar];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserAvatar [[NSUserDefaults standardUserDefaults] objectForKey:APPUserAvatar]

#define setUserNickname(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserNickname];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserNickname [[NSUserDefaults standardUserDefaults] objectForKey:APPUserNickname]

#define setUserSign(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserSign];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserSign [[NSUserDefaults standardUserDefaults] objectForKey:APPUserSign]

#define setUserHash(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserHash];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserHash [[NSUserDefaults standardUserDefaults] objectForKey:APPUserHash]

#define setDeviceToken(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:DeviceToken];[[NSUserDefaults standardUserDefaults] synchronize];
#define getDeviceToken [[NSUserDefaults standardUserDefaults] objectForKey:DeviceToken]

#define setOauthType(oauthType) [[NSUserDefaults standardUserDefaults] setInteger:oauthType forKey:OauthType];[[NSUserDefaults standardUserDefaults] synchronize];
#define getOauthType [[NSUserDefaults standardUserDefaults] integerForKey:OauthType]

#define setQiniuToken(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:QiniuToken];[[NSUserDefaults standardUserDefaults] synchronize];
#define getQiniuToken [[NSUserDefaults standardUserDefaults] objectForKey:QiniuToken]

#define setFriendDeg2(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:FriendDeg2];[[NSUserDefaults standardUserDefaults] synchronize];
#define getFriendDeg2 [[NSUserDefaults standardUserDefaults] objectForKey:FriendDeg2]

#define setUserCode(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:APPUserCode];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserCode [[NSUserDefaults standardUserDefaults] objectForKey:APPUserCode]

#define setUserPhone(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:UserPhone];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserPhone [[NSUserDefaults standardUserDefaults] objectForKey:UserPhone]

#define setUserEmail(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:UserEmail];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserEmail [[NSUserDefaults standardUserDefaults] objectForKey:UserEmail]

#define setUserGender(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:UserGender];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserGender [[NSUserDefaults standardUserDefaults] objectForKey:UserGender]

#define setUserGroupTitle(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:UserGroupTitle];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserGroupTitle [[NSUserDefaults standardUserDefaults] objectForKey:UserGroupTitle]

#define setUserCredit(user) [[NSUserDefaults standardUserDefaults] setObject:(user) forKey:UserCredit];[[NSUserDefaults standardUserDefaults] synchronize];
#define getUserCredit [[NSUserDefaults standardUserDefaults] objectForKey:UserCredit]

//nsuserdefault key
#define IsGuide @"isGuide"
#define BaiduPushType @"BaiduPushType"
#define BaiduUserId @"BaiduUserId"
#define BaiduChannelId @"BaiduChannelId"
#define IsNetworking @"IsNetwork"
#define IsUserLogin @"isUserLogin"
#define APPUserID @"app.user.id"
#define APPUserAvatar @"app.user.avatar"
#define APPUserNickname @"app.user.nickname"
#define APPUserSign @"app.user.sign"
#define APPUserHash @"app.user.hash"
#define APPUserCode @"app.user.code"
#define OauthType @"OauthType"
#define DeviceToken @"DeviceToken"
#define QiniuToken @"QiniuToken"
#define FriendDeg2 @"FriendDeg2"
#define UserPhone @"app.user.phone"
#define UserEmail @"app.user.email"
#define UserGender @"app.user.gender"
#define UserGroupTitle @"app.user.grouptitle"
#define UserCredit @"app.user.credit"

//TABLEVIEW SCROLL STATE
#define TABLEVIEW_ACTION_NORMAL 0
#define TABLEVIEW_ACTION_INIT 1
#define TABLEVIEW_ACTION_REFRESH 2
#define TABLEVIEW_ACTION_SCROLL 3
//TABLEVIEW DATA STATE
#define TABLEVIEW_DATA_NORMAL 0
#define TABLEVIEW_DATA_MORE 1
#define TABLEVIEW_DATA_LOADING 2
#define TABLEVIEW_DATA_FULL 3
#define TABLEVIEW_DATA_EMPTY 4
#define TABLEVIEW_DATA_ERROR 5

#define PageCount 10

#define TableViewDragUpHeight 50

#define ButtonEnLargeEdge 40

#define StatusBarHeight 20
#define screenframe [[UIScreen mainScreen] bounds]

//oauth type
#define WXOauthType 1
#define ShareOauthType 2

#define QiNiuAccessKey @"doC5UjxNcVK62D-cAjC_XGdEL_cTQZtRq-Mzu6DE"
#define QiNiuSecertKey @"6fMp0gZX4K9V7QQEDH1PMrtgJ__T-ksFkIztRh-a"
#define QiNiuBucket @"ginye"
#define QINIU_PREFIX @"http://7u2qq8.com1.z0.glb.clouddn.com/"

@end
