//
//  BannerList.h
//  vitalia
//
//  Created by Donal on 15/4/9.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Banner.h"

@interface BannerList : NSObject

@property (nonatomic, strong) NSArray *list;


+(BannerList *)parseJson:(NSDictionary *)dic;

@end
