//
//  CommunityTableViewCell.h
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Share.h"

@protocol CommunityTableViewCellDelegate <NSObject>

-(void)didSelect:(Share *)share atIndex:(NSInteger)index;

@end

@interface CommunityTableViewCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *picView;

@property (weak, nonatomic) IBOutlet UICollectionView *picCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *picIndicator;
@property (nonatomic, assign) id<CommunityTableViewCellDelegate> delegate;

@property (nonatomic, strong) Share *currentShare;
-(void)setShare:(Share *)share;

@end
