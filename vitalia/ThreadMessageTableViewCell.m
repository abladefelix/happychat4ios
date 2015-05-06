//
//  ThreadMessageTableViewCell.m
//  vitalia
//
//  Created by Donal on 15/3/30.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ThreadMessageTableViewCell.h"

@implementation ThreadMessageTableViewCell

- (void)awakeFromNib {
    [self.isReadImageView setClipsToBounds:YES];
    [self.isReadImageView.layer setCornerRadius:5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
