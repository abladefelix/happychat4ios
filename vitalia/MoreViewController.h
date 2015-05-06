//
//  MoreViewController.h
//  vitalia
//
//  Created by Donal on 15/4/2.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreViewControllerDelegate  <NSObject>

-(void)favourit;

@end

@interface MoreViewController : UIViewController

@property (nonatomic, strong) NSString *tid;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *urlTitle;

@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, assign) id<MoreViewControllerDelegate> delegate;

@end
