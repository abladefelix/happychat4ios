//
//  ThreadMessage.m
//  vitalia
//
//  Created by Donal on 15/3/30.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ThreadMessage.h"

@implementation ThreadMessage

+(ThreadMessage *)parseJson:(NSDictionary *)dic
{
    ThreadMessage *m = [[ThreadMessage alloc] init];
    m.isRead = [[dic objectForKey:@"isread"] intValue];
    m.authorid = [dic objectForKey:@"authorid"];
    m.author = [dic objectForKey:@"author"];
    m.note = [dic objectForKey:@"note"];
    m.dateline = [dic objectForKey:@"dateline"];
    m.avatar = [dic objectForKey:@"avatar"];
    m.tid = [dic objectForKey:@"tid"];
    m.type = [dic objectForKey:@"type"];
    m.url = [dic objectForKey:@"url"];
    m.contentHeight = [Tool getViewMinHeightWithUIFont:[UIFont systemFontOfSize:13] andText:m.note andFixedWidth:(480.0/640)*screenframe.size.width minHeight:0];
    m.cellHeight = 65 + m.contentHeight;
    return m;
}

@end
