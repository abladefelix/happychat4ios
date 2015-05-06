//
//  OtherUser.m
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "OtherUser.h"

@implementation OtherUser

+(OtherUser *)parseJson:(NSDictionary *)dic
{
    OtherUser *user = [[OtherUser alloc] init];
    user.user_id = [dic objectForKey:@"user_id"];
    user.avatar = [dic objectForKey:@"avatar"];
    user.user_name = [dic objectForKey:@"user_name"];
    user.nickname = [dic objectForKey:@"nickname"];
    user.credits = [dic objectForKey:@"credits"];
    user.post_count = [dic objectForKey:@"post_count"];
    user.share_count = [dic objectForKey:@"share_count"];
    user.group = [dic objectForKey:@"group"];
    user.user_desc = [dic objectForKey:@"user_desc"];
    user.is_follow = [dic objectForKey:@"is_follow"];
    user.resideprovince = [dic objectForKey:@"resideprovince"];
    user.residecity = [dic objectForKey:@"residecity"];
    user.residecommunity = [dic objectForKey:@"residecommunity"];
    user.residesuite = [dic objectForKey:@"residesuite"];
    user.grouptitle = [dic objectForKey:@"group"];
    return user;
}

@end
