//
//  CommentList.m
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CommentList.h"

@implementation CommentList


+(CommentList *)parseJson:(NSDictionary *)dic
{
    CommentList *comment_list = [[CommentList alloc] init];
    comment_list.next_cursor = [dic objectForKey:@"next_cursor"];
    comment_list.previous_cursor = [dic objectForKey:@"previous_cursor"];
    NSArray *share_comment_list = [dic objectForKey:@"share_comment_list"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *commentDic in share_comment_list) {
        Comment *share = [Comment parseJson:commentDic];
        [array addObject:share];
    }
    comment_list.share_comment_list = array;
    return comment_list;
}

@end
