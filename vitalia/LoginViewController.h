//
//  LoginViewController.h
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate <NSObject>

-(void)loginByAccountSuccess:(User *)user;

@end

@interface LoginViewController : UIViewController

@property (nonatomic, assign) id<LoginViewControllerDelegate> delegate;

@end
