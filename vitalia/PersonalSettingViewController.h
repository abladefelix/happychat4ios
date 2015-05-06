//
//  PersonalSettingViewController.h
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PersonalSettingViewControllerDelegate <NSObject>

-(void)logoutFromSetting;

@end

@interface PersonalSettingViewController : UIViewController

@property (nonatomic, assign) id<PersonalSettingViewControllerDelegate> delegate;

@end
