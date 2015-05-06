//
//  APIClient.h
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "ShareList.h"
#import "CommentList.h"
#import "User.h"
#import "OtherUser.h"
#import "ThreadMessageList.h"
#import "BannerList.h"

#ifdef DEBUG

#define GYAPIURL     @"http://192.168.1.58/"
#define GYBASEURL    @"http://192.168.1.58"

#else

#define GYAPIURL     @"http://120.25.208.137/"
#define GYBASEURL    @"http://120.25.208.137"

#endif


#define GYShareDetailURL   [NSString stringWithFormat:@"%@/forum.php?mod=viewthread&mobile=2", GYBASEURL]

#define GYMallURL   [NSString stringWithFormat:@"%@/forum.php?mod=product&action=list&platform=app", GYBASEURL]

#define GYOrderURL [NSString stringWithFormat:@"%@/forum.php?mod=order&action=myorder&platform=app", GYBASEURL]

#define ShareTypeCache @"share-type"
#define ShareListCache @"share-list"
#define ShareListUserCache @"share-user"
#define ShareListTopCache @"share-top"
#define SingleShareCache @"share-single"

#define ThreadMessageCache @"message-thread"
#define SystemMessageCache @"message-system"

#define UserCache @"user"

#define BannerCache @"banner"

@interface APIClient : AFHTTPSessionManager

+ (id)sharedInstance;

#pragma mark user begin
-(void)loginBy:(NSString *)account
           and:(NSString *)password
       Success:(void (^)(int errorCode, id model) )success
       failure:(void (^)(NSString *message) )failure;

-(void)logoutSuccess:(void (^)(int errorCode, id model) )success
             failure:(void (^)(NSString *message) )failure;

-(void)getVerifyCodeByMobile:(NSString *)mobile
                        type:(NSString *)type
                     Success:(void (^)(int errorCode, id model) )success
                     failure:(void (^)(NSString *message) )failure;

-(void)registerByAccount:(NSString *)mobile
                withCode:(NSString *)code
            withPassword:(NSString *)password
                wityType:(NSString *)type
                 Success:(void (^)(int errorCode, id model) )success
                 failure:(void (^)(NSString *message) )failure;

-(void)getResetPasswordSMSCodeByMobile:(NSString *)mobile
                               Success:(void (^)(int errorCode, id model) )success
                               failure:(void (^)(NSString *message) )failure;

-(void)resetPasswordByMobile:(NSString *)mobile
                    withCode:(NSString *)code
                withPassword:(NSString *)password
                     Success:(void (^)(int errorCode, id model) )success
                     failure:(void (^)(NSString *message) )failure;

-(void)getMyProfileSuccess:(void (^)(int errorCode, id model) )success
                   failure:(void (^)(NSString *message) )failure;

-(void)getOtherProfileByUid:(NSString *)uid
                    Success:(void (^)(int errorCode, id model) )success
                    failure:(void (^)(NSString *message) )failure;

-(void)updateUserNickname:(NSString *)nickname
                  Success:(void (^)(int errorCode, id model) )success
                  failure:(void (^)(NSString *message) )failure;

-(void)updateUserAvatar:(NSString *)avatar
                filePah:(NSString *)path
               progress:(void (^)(float percent))progressBlock
                Success:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure;

-(void)updateUserGender:(NSString *)gender
                Success:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure;

#pragma mark share
-(void)getShareTypeSuccess:(void (^)(int errorCode, id model) )success
                   failure:(void (^)(NSString *message) )failure;

-(void)getSharelistBy:(NSString *)fid
               atPage:(NSString *)page
         withPageSize:(NSString *)pageSize
              Success:(void (^)(int errorCode, id model) )success
              failure:(void (^)(NSString *message) )failure;

-(void)getSharelistByUserId:(NSString *)userid
                     atPage:(NSString *)page
               withPageSize:(NSString *)pageSize
                    Success:(void (^)(int errorCode, id model) )success
                    failure:(void (^)(NSString *message) )failure;

-(void)getTopSharelistatPage:(NSString *)page
                withPageSize:(NSString *)pageSize
                     Success:(void (^)(int errorCode, id model) )success
                     failure:(void (^)(NSString *message) )failure;

-(void)getShareByTid:(NSString *)tid
             Success:(void (^)(int errorCode, id model) )success
             failure:(void (^)(NSString *message) )failure;

#pragma mark 发布
-(void)getPubHashSuccess:(void (^)(int errorCode, id model) )success
                 failure:(void (^)(NSString *message) )failure;

-(void)pubSubject:(NSString *)subject
      withMessage:(NSString *)message
     withFormHash:(NSString *)hash
          Success:(void (^)(int errorCode, id model) )success
          failure:(void (^)(NSString *message) )failure;

#pragma mark 点赞
-(void)likeShareid:(NSString *)shareid
           Success:(void (^)(int errorCode, id model) )success
           failure:(void (^)(NSString *message) )failure;

-(void)dislikeShareid:(NSString *)shareid
              Success:(void (^)(int errorCode, id model) )success
              failure:(void (^)(NSString *message) )failure;

#pragma mark 收藏
-(void)favouriteShareid:(NSString *)shareid
                Success:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure;

-(void)disfavouriteShareid:(NSString *)shareid
                   Success:(void (^)(int errorCode, id model) )success
                   failure:(void (^)(NSString *message) )failure;

-(void)getFavouriteShareListAtPage:(NSString *)page
                      withPageSize:(NSString *)pageSize
                           Success:(void (^)(int errorCode, id model) )success
                           failure:(void (^)(NSString *message) )failure;

#pragma mark 评论
-(void)getCommentFrom:(NSString *)shareId
                maxId:(NSString *)maxId
              sinceId:(NSString *)sinceId
              Success:(void (^)(int errorCode, id model) )success
              failure:(void (^)(NSString *message) )failure;

-(void)pubCommentToTid:(NSString *)tid
                   pid:(NSString *)pid
           withMessage:(NSString *)message
          withFormHash:(NSString *)hash
               Success:(void (^)(int errorCode, id model) )success
               failure:(void (^)(NSString *message) )failure;

#pragma mark 消息
-(void)getMyPostMessageAtPage:(NSString *)page
                     pageSize:(NSString *)pageSize
                      Success:(void (^)(int errorCode, id model) )success
                      failure:(void (^)(NSString *message) )failure;

-(void)getSystemMessageAtPage:(NSString *)page
                     pageSize:(NSString *)pageSize
                      Success:(void (^)(int errorCode, id model) )success
                      failure:(void (^)(NSString *message) )failure;

#pragma mark 签到
-(void)checkSignSuccess:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure;

-(void)signInSuccess:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure;

#pragma mark push id
-(void)setPushUid:(NSString *)uid
          success:(void (^)(int errorCode, id model) )success
          failure:(void (^)(NSString *message) )failure;

#pragma mark banner
-(void)getBannersuccess:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure;
@end
