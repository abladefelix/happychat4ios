//
//  ProfileEditViewController.m
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ProfileEditViewController.h"

@interface ProfileEditViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.valueTextField.delegate = self;
    if (self.editType == EditNickname) {
        self.valueTextField.text = getUserNickname;
    }
    else if (self.editType == EditMobile) {
        self.valueTextField.text = getUserPhone;
    }
    else {
        self.valueTextField.text = getUserEmail;
    }
    [self initBar];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"昵称";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveNickname)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

- (void)saveNickname {
    if (self.valueTextField.hasText) {
        NSString *nickname = self.valueTextField.text;
        [[APIClient sharedInstance] updateUserNickname:nickname
                                               Success:^(int errorCode, id model) {
                                                   if (errorCode == 1) {
                                                       setUserNickname(nickname);
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProfile" object:nil];
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                   }
                                               }
                                               failure:^(NSString *message) {
            
                                               }];
    }
}


@end
