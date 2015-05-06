//
//  ThreadMessage.h
//  vitalia
//
//  Created by Donal on 15/3/30.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadMessage : NSObject

@property  int isRead;
@property (nonatomic, strong) NSString *  authorid;
@property (nonatomic, strong) NSString *  author;
@property (nonatomic, strong) NSString *  note;
@property (nonatomic, strong) NSString *  dateline;
@property (nonatomic, strong) NSString *  avatar;

@property (nonatomic, strong) NSString *  tid;
@property (nonatomic, strong) NSString *  type;
@property (nonatomic, strong) NSString *  url;

@property int cellHeight;
@property int contentHeight;

+(ThreadMessage *)parseJson:(NSDictionary *)dic;

@end
