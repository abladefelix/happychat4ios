//
//  DetailHeaderTableViewCell.m
//  vitalia
//
//  Created by Donal on 15/3/5.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "DetailHeaderTableViewCell.h"

@implementation DetailHeaderTableViewCell

- (void)awakeFromNib {
    [self.avatarImageView setClipsToBounds:YES];
    [self.avatarImageView setUserInteractionEnabled:YES];
    [self.avatarImageView.layer setCornerRadius:22];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
