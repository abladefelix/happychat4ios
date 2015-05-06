//
//  DetailHeaderTableViewCell.h
//  vitalia
//
//  Created by Donal on 15/3/5.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailHeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cmtLabel;
@property (weak, nonatomic) IBOutlet UILabel *favourLabel;
@end
