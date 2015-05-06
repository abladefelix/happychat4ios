//
//  Share.m
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "Share.h"
#import "NSString+GTMNSString_HTML.h"

@implementation Share

+(Share *)parseJson:(NSDictionary *)dic
{
    Share *share = [[Share alloc] init];
    share.tid = [dic objectForKey:@"tid"];
    share.authorid = [dic objectForKey:@"authorid"];
    share.author = [dic objectForKey:@"author"];
    share.fid = [dic objectForKey:@"fid"];
    share.subject = [dic objectForKey:@"subject"];
    share.dateline = [dic objectForKey:@"dateline"];
    share.saygood = [dic objectForKey:@"saygood"] ;
    share.replies = [dic objectForKey:@"replies"];
    share.imagelist = [dic objectForKey:@"images"];
    share.is_favorite = [[dic objectForKey:@"is_favorite"] boolValue];
    share.is_saygood = [[dic objectForKey:@"is_saygood"] boolValue];
    share.digest = [dic objectForKey:@"digest"];
    share.displayorder = [dic objectForKey:@"displayorder"];
    NSArray *medias = [dic objectForKey:@"media_list"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *media in medias) {
        MediaObj *mediaObj = [MediaObj parseJson:media];
        [array addObject:mediaObj];
    }
    share.imageArray = array;
    if (share.imageArray.count > 0) {
        share.cellHeight = 75;
        share.titleWidth = 160.0/320 * screenframe.size.width;
    }
    else {
        share.cellHeight = 175;
        share.titleWidth = 260.0/320 * screenframe.size.width;
    }
    if (share.subject.length > 0) {
        share.contentHeight = [Tool getViewMaxHeightWithUIFont:[UIFont systemFontOfSize:16] andText:share.subject andFixedWidth:share.titleWidth maxHeight:44];
    }
    else {
        share.subject = @"真实体验分享";
        share.contentHeight = 44;
    }
    
    return share;
}

@end
