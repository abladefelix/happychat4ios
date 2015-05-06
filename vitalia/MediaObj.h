//
//  MediaObj.h
//  vitalia
//
//  Created by Donal on 15/3/4.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaObj : NSObject

@property (nonatomic, strong) NSString * media_url;
@property (nonatomic, strong) NSString * media_type;
@property (nonatomic, strong) NSString * media_des;
@property (nonatomic, strong) NSString * media_duration;

+(MediaObj *)parseJson:(NSDictionary *)dic;

@end
