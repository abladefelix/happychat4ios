//
//  APIClient.m
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "APIClient.h"


@implementation APIClient

+ (id)sharedInstance{
    static APIClient *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:GYAPIURL]];
    });
    return _sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:self.responseSerializer.acceptableContentTypes];
        [contentTypes addObject:@"text/html"];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        responseSerializer.acceptableContentTypes = contentTypes;
        AFHTTPRequestSerializer *request =  [AFHTTPRequestSerializer serializer];
        [request setTimeoutInterval:120];
        [self setRequestSerializer:request];
        [self setResponseSerializer:responseSerializer];

    }
    return self;
}

- (NSMutableDictionary *)defaultGetParameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    return parameters;
}

-(void)saveCache:(NSData *)data pathName:(NSString *)pathName
{
    [data writeToFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@", pathName]] atomically:YES];
}

-(void)addCredits:(NSDictionary *)dic
{
    NSDictionary *addcredits = [[dic objectForKey:@"data"] objectForKey:@"addcredits"];
    debugLog(@"%@", addcredits);
    if ([[[[dic objectForKey:@"data"] objectForKey:@"addcredits"] objectForKey:@"result"] intValue] == 1) {
        int value = [[[[[dic objectForKey:@"data"] objectForKey:@"addcredits"] objectForKey:@"credicts"] objectForKey:@"extcredits2"] intValue];
        debugLog(@"%i", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addcredits" object:[NSString stringWithFormat:@"%i", value]];
    }
}

#pragma mark user begin
-(void)loginBy:(NSString *)account
           and:(NSString *)password
       Success:(void (^)(int errorCode, id model) )success
       failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:account forKey:@"username"];
    [parameters setValue:password forKey:@"password"];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"login" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     User *user = [User parseJson:[dic objectForKey:@"data"]];
                                     success(1, user);
                                     [self addCredits:dic];
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)logoutSuccess:(void (^)(int errorCode, id model) )success
             failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"logout" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)getVerifyCodeByMobile:(NSString *)mobile
                        type:(NSString *)type
                          Success:(void (^)(int errorCode, id model) )success
                          failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:mobile forKey:@"input"];
    [parameters setValue:type forKey:@"type"];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"verifycode" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] isEqual: @"1"]) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)registerByAccount:(NSString *)mobile
                withCode:(NSString *)code
            withPassword:(NSString *)password
                wityType:(NSString *)type
                 Success:(void (^)(int errorCode, id model) )success
                 failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:mobile forKey:@"input"];
    [parameters setValue:password forKey:@"password"];
    [parameters setValue:code forKey:@"code"];
    [parameters setValue:type forKey:@"type"];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"register" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     [self addCredits:dic];
                                     User *user = [User parseJson:[dic objectForKey:@"data"]];
                                     success(1, user);
                                     
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)getResetPasswordSMSCodeByMobile:(NSString *)mobile
                          Success:(void (^)(int errorCode, id model) )success
                          failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:mobile forKey:@"mobile"];
    [[APIClient sharedInstance] POST:@"user/index/resetPwdSendSMSidentifyingCode"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] isEqual: @"1"]) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)resetPasswordByMobile:(NSString *)mobile
                    withCode:(NSString *)code
                withPassword:(NSString *)password
                     Success:(void (^)(int errorCode, id model) )success
                     failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:mobile forKey:@"mobile"];
    [parameters setValue:password forKey:@"password"];
    [parameters setValue:code forKey:@"identifying_code"];
    [[APIClient sharedInstance] POST:@"user/index/resetUserPassword"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] isEqual: @"1"]) {
                                     User *user = [User parseJson:[dic objectForKey:@"data"]];
                                     success(1, user);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)getMyProfileSuccess:(void (^)(int errorCode, id model) )success
                   failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"profile" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     [self saveCache:[Tool jsonFromObject:dic] pathName:[NSString stringWithFormat:@"%@-%@", UserCache, getUserID]];
                                     User *user = [User parseJson:[dic objectForKey:@"data"]];
                                     success(1, user);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)getOtherProfileByUid:(NSString *)uid
                    Success:(void (^)(int errorCode, id model) )success
                    failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"userinfo" forKey:@"act"];
    [parameters setValue:uid forKey:@"uid"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     [self saveCache:[Tool jsonFromObject:dic] pathName:[NSString stringWithFormat:@"%@-%@", UserCache, uid]];
                                     OtherUser *user = [OtherUser parseJson:[dic objectForKey:@"data"]];
                                     
                                     success(1, user);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}


-(void)updateUserNickname:(NSString *)nickname
                  Success:(void (^)(int errorCode, id model) )success
                  failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"profile" forKey:@"act"];
    [parameters setValue:@"1" forKey:@"profilesubmit"];
    [parameters setValue:nickname forKey:@"nickname"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)updateUserAvatar:(NSString *)avatar
                filePah:(NSString *)path
               progress:(void (^)(float percent))progressBlock
                Success:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"uploadavatar" forKey:@"act"];
    [parameters setValue:@"byte" forKey:@"uploadtype"];
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:path], 1.0);
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
               [formData appendPartWithFormData:imageData name:@"Filedata"];
                             }
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, [dic objectForKey:@"msg"]);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);

                             }];
    [[APIClient sharedInstance] setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        progressBlock((float)totalBytesSent / (float)totalBytesExpectedToSend);
    }];
}

-(void)updateUserGender:(NSString *)gender
                Success:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"profile" forKey:@"act"];
    [parameters setValue:@"1" forKey:@"profilesubmit"];
    [parameters setValue:gender forKey:@"gender"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}
#pragma mark user end

#pragma mark share list begin
-(void)getShareTypeSuccess:(void (^)(int errorCode, id model) )success
                   failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"catlist" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     [self saveCache:[Tool jsonFromObject:dic] pathName:ShareTypeCache];
                                     success(1, [dic objectForKey:@"data"]);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

-(void)getSharelistBy:(NSString *)fid
               atPage:(NSString *)page
         withPageSize:(NSString *)pageSize
              Success:(void (^)(int errorCode, id model) )success
              failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"list" forKey:@"act"];
    [parameters setValue:fid forKey:@"fid"];
    [parameters setValue:page forKey:@"page"];
    [parameters setValue:pageSize forKey:@"pagesize"];
    [[APIClient sharedInstance] GET:@"app.php"
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                NSDictionary *dic = (NSDictionary *)responseObject;
                                if ([[dic objectForKey:@"result"] intValue] == 1) {
                                    if ([page isEqualToString:@"1"]) {
                                        [self saveCache:[Tool jsonFromObject:dic] pathName:[NSString stringWithFormat:@"%@-%@", ShareListCache, fid]];
                                    }
                                    ShareList *shareList = [ShareList parseJson:[dic objectForKey:@"data"]];
                                    shareList.currentType = fid;
                                    success(1, shareList);
                                }
                                else {
                                    success([[dic objectForKey:@"result"] intValue], nil);
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, NSError *error) {
                                debugLog(@"%@", error.description);
                                failure(error.description);
                            }];
}

-(void)getSharelistByUserId:(NSString *)userid
                     atPage:(NSString *)page
               withPageSize:(NSString *)pageSize
                    Success:(void (^)(int errorCode, id model) )success
                    failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"list" forKey:@"act"];
    [parameters setValue:userid forKey:@"uid"];
    [parameters setValue:page forKey:@"page"];
    [parameters setValue:pageSize forKey:@"pagesize"];
    [[APIClient sharedInstance] GET:@"app.php"
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                NSDictionary *dic = (NSDictionary *)responseObject;
                                if ([[dic objectForKey:@"result"] intValue] == 1) {
                                    if ([page isEqualToString:@"1"]) {
                                        [self saveCache:[Tool jsonFromObject:dic] pathName:[NSString stringWithFormat:@"%@-%@", ShareListUserCache, userid]];
                                    }
                                    ShareList *shareList = [ShareList parseJson:[dic objectForKey:@"data"]];
                                    success(1, shareList);
                                }
                                else {
                                    success([[dic objectForKey:@"result"] intValue], nil);
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, NSError *error) {
                                debugLog(@"%@", error.description);
                                failure(error.description);
                            }];
}

-(void)getTopSharelistatPage:(NSString *)page
                withPageSize:(NSString *)pageSize
                     Success:(void (^)(int errorCode, id model) )success
                     failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"list" forKey:@"act"];
    [parameters setValue:@"true" forKey:@"top"];
    [parameters setValue:page forKey:@"page"];
    [parameters setValue:pageSize forKey:@"pagesize"];
    [[APIClient sharedInstance] GET:@"app.php"
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                NSDictionary *dic = (NSDictionary *)responseObject;
                                if ([[dic objectForKey:@"result"] intValue] == 1) {
                                    if ([page isEqualToString:@"1"]) {
                                        [self saveCache:[Tool jsonFromObject:dic] pathName:ShareListTopCache];
                                    }
                                    ShareList *shareList = [ShareList parseJson:[dic objectForKey:@"data"]];
                                    success(1, shareList);
                                }
                                else {
                                    success([[dic objectForKey:@"result"] intValue], nil);
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, NSError *error) {
                                debugLog(@"%@", error.description);
                                failure(error.description);
                            }];
}

-(void)getShareByTid:(NSString *)tid
             Success:(void (^)(int errorCode, id model) )success
             failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"detail" forKey:@"act"];
    [parameters setValue:@"yes" forKey:@"detail"];
    [parameters setValue:tid forKey:@"tid"];
    [[APIClient sharedInstance] GET:@"app.php"
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                NSDictionary *dic = (NSDictionary *)responseObject;
                                debugLog(@"%@", dic);
                                if ([[dic objectForKey:@"result"] intValue] == 1) {
                                    [self saveCache:[Tool jsonFromObject:dic] pathName:[NSString stringWithFormat:@"%@-%@",SingleShareCache, tid]];
                                    Share *share = [Share parseJson:[dic objectForKey:@"data"]];
                                    success(1, share);
                                }
                                else {
                                    success([[dic objectForKey:@"result"] intValue], nil);
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, NSError *error) {
                                debugLog(@"%@", error.description);
                                failure(error.description);
                            }];
}
#pragma mark share list end

#pragma mark 发布
-(void)getPubHashSuccess:(void (^)(int errorCode, id model) )success
                 failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"gethash" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, [dic objectForKey:@"data"]);
                                     
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)pubSubject:(NSString *)subject
      withMessage:(NSString *)message
     withFormHash:(NSString *)hash
          Success:(void (^)(int errorCode, id model) )success
          failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"post" forKey:@"act"];
    [parameters setValue:hash forKey:@"formhash"];
    [parameters setValue:subject forKey:@"subject"];
    [parameters setValue:message forKey:@"message"];
    [[APIClient sharedInstance] POST:@"app.php"
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                NSDictionary *dic = (NSDictionary *)responseObject;
                                debugLog(@"%@", dic);
                                if ([[dic objectForKey:@"result"] intValue] == 1) {
                                    success(1, nil);
                                    [self addCredits:dic];
                                }
                                else {
                                    success([[dic objectForKey:@"result"] intValue], nil);
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, NSError *error) {
                                debugLog(@"%@", error.description);
                                failure(error.description);
                            }];
}

#pragma mark 点赞
-(void)likeShareid:(NSString *)shareid
           Success:(void (^)(int errorCode, id model) )success
           failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"saygood" forKey:@"act"];
    [parameters setValue:shareid forKey:@"id"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)dislikeShareid:(NSString *)shareid
              Success:(void (^)(int errorCode, id model) )success
              failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"saygood" forKey:@"act"];
    [parameters setValue:@"delete" forKey:@"op"];
    [parameters setValue:shareid forKey:@"id"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

#pragma mark 收藏
-(void)favouriteShareid:(NSString *)shareid
                Success:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"favorite" forKey:@"act"];
    [parameters setValue:shareid forKey:@"id"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)disfavouriteShareid:(NSString *)shareid
                   Success:(void (^)(int errorCode, id model) )success
                   failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"favorite" forKey:@"act"];
    [parameters setValue:@"delete" forKey:@"op"];
    [parameters setValue:shareid forKey:@"id"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)getFavouriteShareListAtPage:(NSString *)page
                      withPageSize:(NSString *)pageSize
                           Success:(void (^)(int errorCode, id model) )success
                           failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"space" forKey:@"mod"];
    [parameters setValue:@"favorite" forKey:@"act"];
    [parameters setValue:@"thread" forKey:@"type"];
    [parameters setValue:page forKey:@"page"];
    [parameters setValue:pageSize forKey:@"pagesize"];
    [[APIClient sharedInstance] GET:@"app.php"
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                NSDictionary *dic = (NSDictionary *)responseObject;
                                if ([[dic objectForKey:@"result"] intValue] == 1) {
                                    ShareList *shareList = [ShareList parseJson:[dic objectForKey:@"data"]];
                                    success(1, shareList);
                                }
                                else {
                                    success([[dic objectForKey:@"result"] intValue], nil);
                                }
                            }
                            failure:^(NSURLSessionDataTask *task, NSError *error) {
                                debugLog(@"%@", error.description);
                                failure(error.description);
                            }];
}

#pragma mark comment list begin
-(void)getCommentFrom:(NSString *)shareId
                maxId:(NSString *)maxId
              sinceId:(NSString *)sinceId
              Success:(void (^)(int errorCode, id model) )success
              failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:shareId forKey:@"share_id"];
    if (maxId.length > 0) {
        [parameters setValue:maxId forKey:@"max_id"];
    }
    if (sinceId.length > 0) {
        [parameters setValue:sinceId forKey:@"since_id"];
    }
    [[APIClient sharedInstance] POST:@"community/sharecomment/commentList"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] isEqual: @"1"]) {
                                     CommentList *commentList = [CommentList parseJson:[dic objectForKey:@"data"]];
                                     success(1, commentList);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], nil);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 failure(error.description);
                             }];
}

#pragma mark 发送评论
-(void)pubCommentToTid:(NSString *)tid
                   pid:(NSString *)pid
           withMessage:(NSString *)message
          withFormHash:(NSString *)hash
               Success:(void (^)(int errorCode, id model) )success
               failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"reply" forKey:@"act"];
    [parameters setValue:hash forKey:@"formhash"];
    [parameters setValue:tid forKey:@"tid"];
    [parameters setValue:pid forKey:@"pid"];
    [parameters setValue:message forKey:@"message"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, [dic objectForKey:@"data"]);
                                     [self addCredits:dic];
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

#pragma mark 消息
-(void)getMyPostMessageAtPage:(NSString *)page
                     pageSize:(NSString *)pageSize
                      Success:(void (^)(int errorCode, id model) )success
                      failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"space" forKey:@"mod"];
    [parameters setValue:@"message" forKey:@"act"];
    [parameters setValue:@"notice" forKey:@"do"];
    [parameters setValue:page forKey:@"page"];
    [parameters setValue:pageSize forKey:@"pagesize"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     if ([page isEqualToString:@"1"]) {
                                         [self saveCache:[Tool jsonFromObject:dic] pathName:ThreadMessageCache];
                                     }
                                     ThreadMessageList *mList = [ThreadMessageList parseJson:[dic objectForKey:@"data"]];
                                     success(1, mList);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)getSystemMessageAtPage:(NSString *)page
                     pageSize:(NSString *)pageSize
                      Success:(void (^)(int errorCode, id model) )success
                      failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"space" forKey:@"mod"];
    [parameters setValue:@"message" forKey:@"act"];
    [parameters setValue:@"notice" forKey:@"do"];
    [parameters setValue:@"system" forKey:@"view"];
    [parameters setValue:page forKey:@"page"];
    [parameters setValue:pageSize forKey:@"pagesize"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     if ([page isEqualToString:@"1"]) {
                                         [self saveCache:[Tool jsonFromObject:dic] pathName:SystemMessageCache];
                                     }
                                     ThreadMessageList *mList = [ThreadMessageList parseJson:[dic objectForKey:@"data"]];
                                     success(1, mList);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

#pragma mark 签到
-(void)checkSignSuccess:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"signin" forKey:@"act"];
    [parameters setValue:@"checksign" forKey:@"do"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@",dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, [NSString stringWithFormat:@"%i", [[dic objectForKey:@"data"] intValue]]);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)signInSuccess:(void (^)(int errorCode, id model) )success
             failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"signin" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     if ([[[dic objectForKey:@"data"] objectForKey:@"result"] intValue] == 1) {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"addcredits" object:[NSString stringWithFormat:@"%i", [[[[dic objectForKey:@"data"] objectForKey:@"credicts"] objectForKey:@"extcredits2"] intValue]]];
                                         success(1, [NSString stringWithFormat:@"%i", [[[[dic objectForKey:@"data"] objectForKey:@"credicts"] objectForKey:@"extcredits2"] intValue]]);
                                     }
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)setPushUid:(NSString *)uid
          success:(void (^)(int errorCode, id model) )success
          failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"member" forKey:@"mod"];
    [parameters setValue:@"setpushuid" forKey:@"act"];
    [parameters setValue:uid forKey:@"baidupush_uid"];
    [parameters setValue:@"0" forKey:@"baidupush_platform"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 debugLog(@"%@", dic);
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     success(1, nil);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}

-(void)getBannersuccess:(void (^)(int errorCode, id model) )success
                failure:(void (^)(NSString *message) )failure
{
    NSMutableDictionary *parameters = [self defaultGetParameters];
    [parameters setValue:@"forum" forKey:@"mod"];
    [parameters setValue:@"banner" forKey:@"act"];
    [[APIClient sharedInstance] POST:@"app.php"
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSDictionary *dic = (NSDictionary *)responseObject;
                                 if ([[dic objectForKey:@"result"] intValue] == 1) {
                                     [self saveCache:[Tool jsonFromObject:dic] pathName:BannerCache];
                                     BannerList *data = [BannerList parseJson:dic];
                                     success(1, data);
                                 }
                                 else {
                                     success([[dic objectForKey:@"result"] intValue], [dic objectForKey:@"msg"]);
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 debugLog(@"%@", error.description);
                                 failure(error.description);
                             }];
}
@end
