//
//  RegisterViewController.h
//  vitalia
//
//  Created by Donal on 15/3/11.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionsViewController.h"

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>

#define TYPE_REGISTER 0
#define TYPE_FINDPASSWORD 1

@protocol RegisterViewControllerDelegate <NSObject>

-(void)registerSuccess:(NSString *)account password:(NSString *)password;
-(void)findPasswordSuccess;

@end

@interface RegisterViewController : UIViewController

@property int operationType;

@property (weak, nonatomic) IBOutlet UIButton *codeButton;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel2;

@property (nonatomic, assign) id<RegisterViewControllerDelegate> delegate;
@end
