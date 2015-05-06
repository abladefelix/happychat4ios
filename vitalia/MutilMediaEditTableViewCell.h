//
//  MutilMediaEditTableViewCell.h
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPubEdit.h"

#import "SAMTextView.h"

@protocol MutilMediaEditTableViewCellDelegate <NSObject>

-(void)scroolToCellAtIndex:(NSInteger)index;
-(void)removeMediaAtIndex:(NSInteger)index;

@end

@interface MutilMediaEditTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet SAMTextView *picDesTextView;

@property (weak, nonatomic) IBOutlet SAMTextView *onlyTextView;

-(void)setMedia:(MediaPubEdit *)edit atIndex:(NSInteger)index;

@property (nonatomic, strong) MediaPubEdit *currentMedia;
@property NSInteger currentIndex;
@property (nonatomic, assign) id<MutilMediaEditTableViewCellDelegate> delegate;

-(void)textViewDidChange:(UITextView *)textView;
@end
