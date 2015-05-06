//
//  Comment.h
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, strong) NSString *  share_comment_id;
@property (nonatomic, strong) NSString *  media_type;
@property (nonatomic, strong) NSString *  user_id;
@property (nonatomic, strong) NSString *  share_id;
@property (nonatomic, strong) NSString *  share_comment_content;
@property (nonatomic, strong) NSString *  share_comment_time;
@property (nonatomic, strong) NSString *  user_name;
@property (nonatomic, strong) NSString *  avatar;
@property (nonatomic, strong) NSString *  parent_id;

@property (nonatomic, strong) NSArray * media_list;

@property int cellHeight;
@property int contentHeight;

+(Comment *)parseJson:(NSDictionary *)dic;

@end
