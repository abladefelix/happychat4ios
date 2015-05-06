//
//  ThreadMessageList.m
//  vitalia
//
//  Created by Donal on 15/3/30.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ThreadMessageList.h"

@implementation ThreadMessageList

+(ThreadMessageList *)parseJson:(NSDictionary *)dic
{
    ThreadMessageList *mList = [[ThreadMessageList alloc] init];
    mList.count = [[dic objectForKey:@"count"] intValue];
    mList.pagecount = [[dic objectForKey:@"pagecount"] intValue];
    mList.newscount = [[dic objectForKey:@"newscount"] intValue];
    NSArray *list = [dic objectForKey:@"list"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in list) {
        ThreadMessage *share = [ThreadMessage parseJson:dic];
        [array addObject:share];
    }
    mList.list = array;
    return mList;
}

@end
