//
//  TabbarController.m
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "TabbarController.h"
#import "CRNavigationController.h"
#import "CommunityViewController.h"
#import "MeTableViewController.h"
#import "SlideMenu.h"
#import "QiniuPutPolicy.h"
#import "SuperDB.h"
#import "MediaPubEdit.h"
#import "QiniuSimpleUploader.h"
#import "CreditView.h"
#import "ShoppingMallViewController.h"
#import "PubViewController.h"
#import "BPush.h"
#import "CreditViewController.h"
#import "POP/POP.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"

@interface TabbarController() <QiniuUploadDelegate, UITabBarControllerDelegate, UIViewControllerTransitioningDelegate>
{
    NSString *pubHash;
    QiniuSimpleUploader *sUploader;
    QiniuPutPolicy *policy;
    NSMutableArray *fileArray;
    NSMutableArray *newMediaArray;
    
    BOOL isUpload;
    NSDictionary *draft;
    int currentFileIndex;
    int allFileCount;
    CreditView *creditView;
    
    int threadNum;
    int systemNum;
    int allNum;
}

@end

@implementation TabbarController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    
    [self prepareVC];
    [self getShareType];
    newMediaArray = [NSMutableArray array];
    fileArray = [NSMutableArray array];
    isUpload = NO;
    policy = [QiniuPutPolicy new];
    policy.scope = QiNiuBucket;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDraft:) name:@"draft" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:@"LoginSuccess" object:nil];
    if (isUserLogin) {
        [self loginSuccess:nil];
    }
}

-(void)loginSuccess:(NSNotification *)notification
{
    [self loadCookies];
    [self getSystemMessageList:@"1"];
    [self getThreadMessageList:@"1"];
    [self checkSign];
    [self setPush];
}

-(void)setPush
{
    [[APIClient sharedInstance] setPushUid:[BPush getUserId]
                                   success:^(int errorCode, id model) {
                                       
                                   }
                                   failure:^(NSString *message) {
                                       
                                   }];
}

- (void)loadCookies{
    
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"draft" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccess" object:nil];
}

-(void)prepareVC
{
    CommunityViewController *vc1        = [[CommunityViewController  alloc] init];
    CRNavigationController *navCommunity = [[CRNavigationController alloc] initWithRootViewController:vc1];
    
    ShoppingMallViewController *vcmall= [[ShoppingMallViewController  alloc] init];
    CRNavigationController *navShop = [[CRNavigationController alloc] initWithRootViewController:vcmall];
    
    MeTableViewController *vc2= [[MeTableViewController  alloc] init];
    CRNavigationController *navMe = [[CRNavigationController alloc] initWithRootViewController:vc2];
    
    self.viewControllers = [[NSArray alloc] initWithObjects:navCommunity, navShop, navMe, nil];
    
    navCommunity.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                          image:[[UIImage imageNamed:@"icon_tabbar_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                  selectedImage:[[UIImage imageNamed:@"icon_tabbar_home_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    navShop.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"商城"
                                                     image:[[UIImage imageNamed:@"icon_tabbar_shoppingmall_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                             selectedImage:[[UIImage imageNamed:@"icon_tabbar_shoppingmall_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    navMe.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                            image:[[UIImage imageNamed:@"icon_tabbar_personal_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[[UIImage imageNamed:@"icon_tabbar_personal_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

#pragma mark 监听vc发来的文章上传
-(void)getDraft:(NSNotification *)notification
{
    if (isUpload) {
        return;
    }
    isUpload = YES;
    NSString *draftId = notification.object;
    draft = [SuperDB getPubDraftByID:draftId];
    if (draft != nil) {
        if ([[draft objectForKey:@"file_state"] isEqualToString:@"1"]) {
            [self getPubHash];
            return;
        }
        [fileArray removeAllObjects];
        NSString *jsonString = [draft objectForKey:@"json"];
        id json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        for (NSDictionary *dic in json) {
            MediaPubEdit *m = [[MediaPubEdit alloc] init];
            m.mediaType = [dic objectForKey:@"media_type"];
            m.mediaContent = [dic objectForKey:@"media_content"];
            m.mediaUrl = [dic objectForKey:@"media_url"];
            m.duration = [dic objectForKey:@"duration"];
            m.qiniuKey = [dic objectForKey:@"qiniuKey"];
            if ([m.mediaType isEqualToString:MEDIA_IMAGE]) {
                [fileArray addObject:m];
            }
        }
    }
    if (sUploader == nil) {
        sUploader = [QiniuSimpleUploader uploaderWithToken:[policy makeToken:QiNiuAccessKey secretKey:QiNiuSecertKey]];
        sUploader.delegate = self;
    }
    if (fileArray.count > 0) {
        allFileCount = (int)fileArray.count;
        currentFileIndex = 1;
        MediaPubEdit *m = [fileArray lastObject];
        sUploader.token = [policy makeToken:QiNiuAccessKey secretKey:QiNiuSecertKey];
        [sUploader uploadFile:m.mediaUrl key:m.qiniuKey extra:nil];
    }
    else {
        [self getPubHash];
    }
}

#pragma mark qiniu delegate
-(void)uploadProgressUpdated:(NSString *)filePath percent:(float)percent
{
    debugLog(@"%f", (percent*currentFileIndex*100.0)/(allFileCount*100));
    [SVProgressHUD showProgress:(percent*currentFileIndex*100.0)/(allFileCount*100)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadShareProgress" object:[NSString stringWithFormat:@"%.0f%%", (percent*currentFileIndex*100.0)/(allFileCount*100)*100] userInfo:draft];
}

-(void)uploadSucceeded:(NSString *)filePath ret:(NSDictionary *)ret
{
    debugLog(@"%@", ret);
    [fileArray removeLastObject];
    
    if (fileArray.count > 0) {
        currentFileIndex++;
        MediaPubEdit *m = [fileArray lastObject];
        sUploader.token = [policy makeToken:QiNiuAccessKey secretKey:QiNiuSecertKey];
        [sUploader uploadFile:m.mediaUrl key:m.qiniuKey extra:nil];
    }
    else {
        [SVProgressHUD dismiss];
        [SuperDB updateDraftFileUploadedBy:[draft objectForKey:@"draftid"]];
        [self getPubHash];
    }
}

-(void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    [SVProgressHUD dismiss];
    debugLog(@"%@",error);
    isUpload = NO;
}

-(void)getPubHash
{
    [[APIClient sharedInstance] getPubHashSuccess:^(int errorCode, id model) {
        if (errorCode == 1) {
            pubHash = model;
            [self pubShare];
        }
    }
                                          failure:^(NSString *message) {
        isUpload = NO;
                                          }];
}

-(void)pubShare
{
    int is_comment = [[draft objectForKey:@"is_comment"] intValue];
    if (is_comment == TYPE_COMMENT) {
        NSString *tid = [draft objectForKey:@"tid"];
        NSString *commentid = [draft objectForKey:@"commentid"];
        [[APIClient sharedInstance] pubCommentToTid:tid
                                                pid:commentid
                                        withMessage:[draft objectForKey:@"html"]
                                       withFormHash:pubHash
                                            Success:^(int errorCode, id model) {
                                                isUpload = NO;
                                                if (errorCode == 1) {
                                                    [SuperDB updateDraftPubedBy:[draft objectForKey:@"draftid"]];
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentSuccess" object:nil userInfo:model];
                                                }
                                                else {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentFailure" object:model userInfo:nil];
                                                }
                                            }
                                            failure:^(NSString *message) {
                                                isUpload = NO;
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentFailure" object:message userInfo:nil];
                                            }];
    }
    else {
        [[APIClient sharedInstance] pubSubject:[draft objectForKey:@"title"]
                                   withMessage:[draft objectForKey:@"html"]
                                  withFormHash:pubHash
                                       Success:^(int errorCode, id model) {
                                           isUpload = NO;
                                           if (errorCode == 1) {
                                               [SuperDB updateDraftPubedBy:[draft objectForKey:@"draftid"]];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadShareSuccess" object:nil userInfo:draft];
                                           }
                                       }
                                       failure:^(NSString *message) {
                                           isUpload = NO;
                                       }];
    }
}

#pragma mark check sign
-(void)checkSign
{
    [[APIClient sharedInstance] checkSignSuccess:^(int errorCode, id model) {
        if (errorCode == 1) {
            if ([model intValue] == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplaySign" object:model userInfo:nil];
            }
        }
    } failure:^(NSString *message) {
        
    }];
}

#pragma mark get share type
-(void)getShareType
{
    [[APIClient sharedInstance] getShareTypeSuccess:^(int errorCode, id model) {
        if (errorCode == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ShareTypeCache object:nil];
        }
                                            }
                                            failure:^(NSString *message) {
        
                                            }];
}

#pragma mark 消息
-(void)getThreadMessageList:(NSString *)page
{
    [[APIClient sharedInstance] getMyPostMessageAtPage:page
                                              pageSize:@"20"
                                               Success:^(int errorCode, id model) {
                                                   if (errorCode == 1) {
                                                       ThreadMessageList *temp = (ThreadMessageList *)model;
                                                       allNum += temp.newscount;
                                                       if (allNum == 0) {
                                                           return;
                                                       }
                                                       [self setMessageBadge:allNum];
                                                   }
                                               }
                                               failure:^(NSString *message) {
                                               }];
    
}

-(void)getSystemMessageList:(NSString *)page
{
    [[APIClient sharedInstance] getSystemMessageAtPage:page
                                              pageSize:@"20"
                                               Success:^(int errorCode, id model) {
                                                   if (errorCode == 1) {
                                                       ThreadMessageList *temp = (ThreadMessageList *)model;
                                                       allNum += temp.newscount;
                                                       if (allNum == 0) {
                                                           return;
                                                       }
                                                       [self setMessageBadge:allNum];
                                                   }
                                                   else {
                                                   }
                                               }
                                               failure:^(NSString *message) {
                                               }];
    
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[[tabBarController.viewControllers objectAtIndex:2] tabBarItem] setBadgeValue:nil];
}

-(void)setMessageBadge:(int)num
{
    NSString *n = [NSString stringWithFormat:@"%i", num];
    setFriendDeg2(n);
    [[[self.viewControllers objectAtIndex:2] tabBarItem] setBadgeValue:n];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageNum" object:nil];
}

@end
