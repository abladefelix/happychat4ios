//
//  CommunityZhiHuTableViewCell.m
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CommunityZhiHuTableViewCell.h"

@implementation CommunityZhiHuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.picImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setShare:(Share *)share
{
    self.currentShare = share;
    if (share.imageArray.count == 0) {
        self.picImageView.hidden = YES;
        self.titleLabel.left = 13;
        self.nameLabel.left = 13;
    }
    else {
        self.picImageView.hidden = NO;
        self.titleLabel.left = 119;
        self.nameLabel.left = 119;
        MediaObj *media = share.imageArray[0];
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:media.media_url]
                             placeholderImage:nil
                                      options:SDWebImageRetryFailed|SDWebImageLowPriority];
    }
    self.titleLabel.width = share.titleWidth;
    self.titleLabel.height = share.contentHeight;
    if ([share.displayorder intValue] > 0) {
        self.tagImageView.hidden = NO;
        [self.tagImageView setImage:[UIImage imageNamed:@"top"]];
    }
    else if ([share.digest intValue] > 0) {
        self.tagImageView.hidden = NO;
        [self.tagImageView setImage:[UIImage imageNamed:@"digest"]];
    }
    else {
        self.tagImageView.hidden = YES;
    }

}

-(void)tapImage
{
    [self.delegate didSelect:self.currentShare];
}

@end
