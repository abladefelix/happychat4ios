//
//  CommunityTableViewCell.m
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CommunityTableViewCell.h"
#import "PicCollectionViewCell.h"
#import "MediaObj.h"


@implementation CommunityTableViewCell

- (void)awakeFromNib {
    self.picCollectionView.scrollsToTop = NO;
    self.picCollectionView.dataSource = self;
    self.picCollectionView.delegate = self;
    [self.picCollectionView registerClass:[PicCollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    [self.avatarImageView setClipsToBounds:YES];
    [self.avatarImageView setUserInteractionEnabled:YES];
    [self.avatarImageView.layer setCornerRadius:22];
    
    UIImage *image = [UIImage imageNamed:@"pic_indicator.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 100, 0, 0);
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.picIndicator setImage:image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setShare:(Share *)share
{
    self.currentShare = share;
    [self.picCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
//    return self.currentShare.media_list.count;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    PicCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
//    MediaObj *media = self.currentShare.media_list[indexPath.row];
//    [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:media.media_url]
//                         placeholderImage:nil
//                                  options:SDWebImageRetryFailed|SDWebImageLowPriority];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.delegate didSelect:self.currentShare atIndex:indexPath.row];
}

@end
