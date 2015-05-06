//
//  User.h
//  vitalia
//
//  Created by Donal on 15/3/7.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString * user_id;
@property (nonatomic, strong) NSString * open_id;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * realname;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * mobile;
@property (nonatomic, strong) NSString * sex;
@property (nonatomic, strong) NSString * credits;
@property (nonatomic, strong) NSString * avatar;
@property (nonatomic, strong) NSString * last_login_time;
@property (nonatomic, strong) NSString * last_login_ip;
@property (nonatomic, strong) NSString * register_time;
@property (nonatomic, strong) NSString * register_ip;
@property (nonatomic, strong) NSString * _sign;
@property (nonatomic, strong) NSString *grouptitle;

@property (nonatomic, strong) NSString * share_count;

+(User *)parseJson:(NSDictionary *)dic;

@end
