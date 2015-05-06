//
//  AvatarSettingTableViewCell.m
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "AvatarSettingTableViewCell.h"

@implementation AvatarSettingTableViewCell

- (void)awakeFromNib {
    [self.avatarImageView setClipsToBounds:YES];
    [self.avatarImageView setUserInteractionEnabled:YES];
    [self.avatarImageView.layer setCornerRadius:40];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
