//
//  User.m
//  vitalia
//
//  Created by Donal on 15/3/7.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "User.h"

@implementation User

+(User *)parseJson:(NSDictionary *)dic
{
    User *user = [[User alloc] init];
    user.user_id = [dic objectForKey:@"uid"];
    user.open_id = [dic objectForKey:@"open_id"];
    user.username = [dic objectForKey:@"username"];
    user.nickname = [dic objectForKey:@"nickname"];
    user.realname = [dic objectForKey:@"realname"];
    user.email = [dic objectForKey:@"email"];
    user.mobile = [dic objectForKey:@"mobile"];
    user.sex = [dic objectForKey:@"gender"];
    user.credits = [dic objectForKey:@"credits"];
    user.avatar = [dic objectForKey:@"avatar"];
    user.last_login_ip = [dic objectForKey:@"last_login_ip"];
    user.last_login_time = [dic objectForKey:@"last_login_time"];
    user.register_ip = [dic objectForKey:@"register_ip"];
    user.register_time = [dic objectForKey:@"register_time"];
    user.share_count = [dic objectForKey:@"share_count"];
    user.grouptitle = [dic objectForKey:@"grouptitle"];
    return user;
}

@end
