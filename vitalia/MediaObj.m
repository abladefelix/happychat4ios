//
//  MediaObj.m
//  vitalia
//
//  Created by Donal on 15/3/4.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "MediaObj.h"

@implementation MediaObj

+(MediaObj *)parseJson:(NSDictionary *)dic
{
    MediaObj *media = [[MediaObj alloc] init];
    media.media_des = [dic objectForKey:@"media_des"];
    media.media_duration = [dic objectForKey:@"media_duration"];
    media.media_type = [dic objectForKey:@"media_type"];
    media.media_url = [dic objectForKey:@"media_url"];
    return media;
}

@end
