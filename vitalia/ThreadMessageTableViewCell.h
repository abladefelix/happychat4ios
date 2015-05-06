//
//  ThreadMessageTableViewCell.h
//  vitalia
//
//  Created by Donal on 15/3/30.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreadMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *isReadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *dividerImageView;
@end
