//
//  ShareList.h
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Share.h"

@interface ShareList : NSObject

@property int count;
@property int pagecount;
@property (nonatomic, strong) NSArray *share_list;

@property (nonatomic, strong) NSString *currentType;

+(ShareList *)parseJson:(NSDictionary *)dic;
@end
