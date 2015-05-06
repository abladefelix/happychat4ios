//
//  PhotoGroupTableViewController.h
//  super
//
//  Created by Donal on 14-7-31.
//  Copyright (c) 2014年 super. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoGroupTableViewControllerDelegate <NSObject>

-(void)getPhotos:(NSArray *)photos;

@end

@interface PhotoGroupTableViewController : UITableViewController

@property int MaxCount ;
@property (nonatomic, assign) id<PhotoGroupTableViewControllerDelegate> delegate;

@end
