//
//  CommentList.h
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

@interface CommentList : NSObject

@property (nonatomic, strong) NSString *next_cursor;
@property (nonatomic, strong) NSString *previous_cursor;
@property (nonatomic, strong) NSArray *share_comment_list;

+(CommentList *)parseJson:(NSDictionary *)dic;
@end
