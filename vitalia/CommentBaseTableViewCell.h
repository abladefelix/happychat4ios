//
//  CommentBaseTableViewCell.h
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentBaseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cmtLabel;

@property (weak, nonatomic) IBOutlet UIView *baseView;
@end
