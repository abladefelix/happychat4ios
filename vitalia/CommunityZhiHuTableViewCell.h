//
//  CommunityZhiHuTableViewCell.h
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommunityZhiHuTableViewCellDelegate <NSObject>

-(void)didSelect:(Share *)share;

@end

@interface CommunityZhiHuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView;

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@property (nonatomic, assign) id<CommunityZhiHuTableViewCellDelegate> delegate;

@property (nonatomic, strong) Share *currentShare;
-(void)setShare:(Share *)share;
@end
