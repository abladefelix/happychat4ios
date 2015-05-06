//
//  ThreadMessageList.h
//  vitalia
//
//  Created by Donal on 15/3/30.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadMessage.h"

@interface ThreadMessageList : NSObject

@property int count;
@property int pagecount;
@property (nonatomic, strong) NSArray *list;
@property int newscount;


+(ThreadMessageList *)parseJson:(NSDictionary *)dic;

@end
