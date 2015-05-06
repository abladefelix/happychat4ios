//
//  LoginViewController.m
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "RegexUtil.h"

@interface LoginViewController () <RegisterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

-(void)setUI
{
    UIView *padView1              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, self.accountTextField.height)];
    self.accountTextField.leftView            = padView1;
    self.accountTextField.leftViewMode        = UITextFieldViewModeAlways;
    
    UIView *padView2              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, self.passwordTextField.height)];
    self.passwordTextField.leftView          = padView2;
    self.passwordTextField.leftViewMode      = UITextFieldViewModeAlways;
    
    UIImage *image = [UIImage imageNamed:@"btn_login_normal"];
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"btn_login_normal"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    if (account.length == 0) {
        return;
    }
    if (password.length == 0) {
        return;
    }
//    int userType = 0;
//    if ([RegexUtil isMobileNo:account]) {
//        userType = 1;
//    }
//    if ([RegexUtil isEmail:account]) {
//        userType = 2;
//    }
//    if (userType == 0) {
//        debugLog(@"anything");
//        return;
//    }
    [SVProgressHUD showWithStatus:@"登录中..."];
    [[APIClient sharedInstance] loginBy:account
                                    and:password
                                Success:^(int errorCode, id model) {
                                    [SVProgressHUD dismiss];
                                    if (errorCode == 1) {
                                        
                                        [self saveCookies];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:model userInfo:nil];
                                        if (self.delegate) {
                                            [self.delegate loginByAccountSuccess:model];
                                        }
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }
                                    else {
                                        [SVProgressHUD showErrorWithStatus:model];
                                    }
                                }
                                failure:^(NSString *message) {
                                    [SVProgressHUD showErrorWithStatus:message];
                                }];
}

- (IBAction)goRegister:(id)sender {
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    vc.operationType = TYPE_REGISTER;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)findPassword:(id)sender {
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    vc.operationType = TYPE_FINDPASSWORD;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
}

-(void)registerSuccess:(NSString *)account password:(NSString *)password
{
    [self.navigationController popViewControllerAnimated:YES];
    self.accountTextField.text = account;
    self.passwordTextField.text = password;
}
@end
