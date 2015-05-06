//
//  PicCollectionViewCell.m
//  vitalia
//
//  Created by Donal on 15/3/4.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "PicCollectionViewCell.h"

@implementation PicCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.picImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.picImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.picImageView];;
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

@end
