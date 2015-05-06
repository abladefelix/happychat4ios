//
//  MoreViewController.m
//  vitalia
//
//  Created by Donal on 15/4/2.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "MoreViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface MoreViewController ()
{
    AppDelegate *appDelegate;
}
@end

@implementation MoreViewController

- (void)viewDidLoad {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissMore:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)collectIt:(id)sender {
    [self.delegate favourit];
}
- (IBAction)wechatFriend:(id)sender {
    
    id<ISSContent> content = [ShareSDK content:self.content
                                defaultContent:nil
                                         image:[ShareSDK imageWithUrl:self.imageUrl]
                                         title:self.urlTitle
                                           url:self.url
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiSession
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            debugLog(@"aa");
                        }
                        else
                        {
                            debugLog(@"%@", error);
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle: @"知道了"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}
- (IBAction)timeline:(id)sender {
    id<ISSContent> content = [ShareSDK content:self.content
                                defaultContent:nil
                                         image:[ShareSDK imageWithUrl:self.imageUrl]
                                         title:self.urlTitle
                                           url:self.url
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiTimeline
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            debugLog(@"aa");
                        }
                        else
                        {
                            debugLog(@"%@", error);
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle: @"知道了"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}
- (IBAction)weibo:(id)sender {
    //自定义新浪微博分享菜单项
//    id<ISSShareActionSheetItem> sinaItem = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeSinaWeibo]
//                                                                              icon:[ShareSDK getClientIconWithType:ShareTypeSinaWeibo]
//                                                                      clickHandler:^{
//                                                                          [ShareSDK shareContent:publishContent
//                                                                                            type:ShareTypeSinaWeibo
//                                                                                     authOptions:nil
//                                                                                   statusBarTips:YES
//                                                                                          result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                                                                                              
//                                                                                              if (state == SSPublishContentStateSuccess)
//                                                                                              {
//                                                                                                  NSLog(@"success");
//                                                                                              }
//                                                                                              else if (state == SSPublishContentStateFail)
//                                                                                              {
//                                                                                                  if ([error errorCode] == -22003)
//                                                                                                  {
//                                                                                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                                                                                                                          message:[error errorDescription]
//                                                                                                                                                         delegate:nil
//                                                                                                                                                cancelButtonTitle:@"知道了"
//                                                                                                                                                otherButtonTitles:nil];
//                                                                                                      [alertView show];
//                                                                                                  }
//                                                                                              }
//                                                                                          }];
//                                                                      }];
    id<ISSContent> content = [ShareSDK content:self.content
                                defaultContent:self.content
                                         image:nil
                                         title:nil
                                           url:nil
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeText];
    
//    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
//                                                         allowCallback:YES
//                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
//                                                          viewDelegate:nil
//                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:content
                      type:ShareTypeSinaWeibo
               authOptions:nil
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            debugLog(@"aa");
                        }
                        else
                        {
                            debugLog(@"%ld", [error errorCode]);
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle: @"知道了"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}
- (IBAction)qq:(id)sender {
    id<ISSContent> content = [ShareSDK content:self.content
                                defaultContent:nil
                                         image:[ShareSDK imageWithUrl:self.imageUrl]
                                         title:self.urlTitle
                                           url:self.url
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:content
                      type:ShareTypeQQ
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            debugLog(@"aa");
                        }
                        else
                        {
                            debugLog(@"%@", error);
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle: @"知道了"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}


@end
