//
//  BannerList.m
//  vitalia
//
//  Created by Donal on 15/4/9.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "BannerList.h"

@implementation BannerList

+(BannerList *)parseJson:(NSDictionary *)dic
{
    BannerList *mList = [[BannerList alloc] init];
    NSArray *list = [dic objectForKey:@"data"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in list) {
        Banner *share = [Banner parseJson:dic];
        [array addObject:share];
    }
    mList.list = array;
    return mList;
}

@end
