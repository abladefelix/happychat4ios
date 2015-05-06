//
//  MediaPubEdit.h
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MEDIA_TEXT @"0"
#define MEDIA_IMAGE @"1"
#define MEDIA_VIDEO @"2"

@interface MediaPubEdit : NSObject

@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) NSString *mediaContent;
@property (nonatomic, strong) NSString *mediaUrl;
@property (nonatomic, strong) NSString *duration;

@property (nonatomic, strong) NSString *qiniuKey;

@end
