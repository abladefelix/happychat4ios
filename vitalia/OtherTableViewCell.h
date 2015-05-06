//
//  OtherTableViewCell.h
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@end
