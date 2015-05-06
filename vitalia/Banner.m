//
//  Banner.m
//  vitalia
//
//  Created by Donal on 15/4/9.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "Banner.h"

@implementation Banner

+(Banner *)parseJson:(NSDictionary *)dic
{
    Banner *m = [[Banner alloc] init];
    m.baid = [dic objectForKey:@"baid"];
    m.dateline = [dic objectForKey:@"dateline"];
    m.displayorder = [dic objectForKey:@"displayorder"];
    m.tid = [dic objectForKey:@"tid"];
    m.title = [dic objectForKey:@"title"];
    m.url = [dic objectForKey:@"url"];
    return m;
}

@end
