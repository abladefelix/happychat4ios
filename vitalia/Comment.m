//
//  Comment.m
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "Comment.h"
#import "NSString+GTMNSString_HTML.h"

@implementation Comment

+(Comment *)parseJson:(NSDictionary *)dic
{
    Comment *comment = [[Comment alloc] init];
    comment.share_comment_id = [dic objectForKey:@"share_comment_id"];
    comment.media_type = [dic objectForKey:@"media_type"];
    comment.user_id = [dic objectForKey:@"user_id"];
    comment.share_id = [dic objectForKey:@"share_id"];
    comment.share_comment_content = [[dic objectForKey:@"share_comment_content"] gtm_stringByUnescapingFromHTML];
    comment.share_comment_time = [dic objectForKey:@"share_comment_time"];
    comment.user_name = [dic objectForKey:@"user_name"];
    comment.avatar = [dic objectForKey:@"avatar"];
    comment.parent_id = [dic objectForKey:@"parent_id"];
    
    NSString *mediaString = [[dic objectForKey:@"media_list"] gtm_stringByUnescapingFromHTML];
    NSData *data = [mediaString dataUsingEncoding:NSUTF8StringEncoding];
    id medias = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *media in medias) {
        MediaObj *mediaObj = [MediaObj parseJson:media];
        [array addObject:mediaObj];
    }
    comment.media_list = array;
    int contentHeight = [Tool getViewMinHeightWithUIFont:[UIFont systemFontOfSize:14] andText:comment.share_comment_content andFixedWidth:screenframe.size.width-85 minHeight:21];
    comment.cellHeight = 63+19+contentHeight;
    comment.contentHeight = contentHeight;
    return comment;
}

@end
