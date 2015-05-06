//
//  Share.h
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaObj.h"

@interface Share : NSObject

@property (nonatomic, strong) NSString * tid;
@property (nonatomic, strong) NSString * authorid;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSString * fid;

@property (nonatomic, strong) NSString * dateline;


@property (nonatomic, strong) NSString * author;

@property (nonatomic, strong) NSString * saygood;
@property (nonatomic, strong) NSString * replies;
@property (nonatomic, strong) NSString * displayorder;
@property (nonatomic, strong) NSString * digest;

@property BOOL is_saygood;
@property BOOL is_favorite;

@property (nonatomic, strong) NSString * imagelist;
@property (nonatomic, strong) NSArray *imageArray;

@property int cellHeight;
@property int contentHeight;
@property float titleWidth;

+(Share *)parseJson:(NSDictionary *)dic;




@end
