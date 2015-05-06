//
//  OtherUser.h
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherUser : NSObject

@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *credits;
@property (nonatomic, strong) NSString *share_count;
@property (nonatomic, strong) NSString *post_count;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *user_desc;
@property (nonatomic, strong) NSString *is_follow;
@property (nonatomic, strong) NSString *resideprovince;
@property (nonatomic, strong) NSString *residecity;
@property (nonatomic, strong) NSString *residedist;
@property (nonatomic, strong) NSString *residecommunity;
@property (nonatomic, strong) NSString *residesuite;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *grouptitle;

+(OtherUser *)parseJson:(NSDictionary *)dic;
@end
