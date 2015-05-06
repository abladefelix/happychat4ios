//
//  ShareList.m
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ShareList.h"


@implementation ShareList

+(ShareList *)parseJson:(NSDictionary *)dic
{
    ShareList *shareList = [[ShareList alloc] init];
    shareList.count = [[dic objectForKey:@"count"] intValue];
    shareList.pagecount = [[dic objectForKey:@"pagecount"] intValue];
    NSArray *share_list = [dic objectForKey:@"list"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *shareDic in share_list) {
        Share *share = [Share parseJson:shareDic];
        [array addObject:share];
    }
    shareList.share_list = array;
    return shareList;
}

@end
