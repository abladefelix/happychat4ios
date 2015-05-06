//
//  Banner.h
//  vitalia
//
//  Created by Donal on 15/4/9.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Banner : NSObject

@property (nonatomic, strong) NSString *baid;
@property (nonatomic, strong) NSString *dateline;
@property (nonatomic, strong) NSString *displayorder;
@property (nonatomic, strong) NSString *tid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;

+(Banner *)parseJson:(NSDictionary *)dic;

@end
