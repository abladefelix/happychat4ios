//
//  RegisterViewController.m
//  vitalia
//
//  Created by Donal on 15/3/11.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "RegexUtil.h"

@interface RegisterViewController () <UIAlertViewDelegate, UITextFieldDelegate, SecondViewControllerDelegate, BackButtonHandlerProtocol>
{
    CountryAndAreaCode* _data2;
    NSString* _str;
    NSMutableData* _data;
    int _state;
    NSString* _localPhoneNumber;
    
    NSString* _localZoneNumber;
    NSString* _appKey;
    NSString* _duid;
    NSString* _token;
    NSString* _appSecret;
    
    NSMutableArray* _areaArray;
    NSString* _defaultCode;
    NSString* _defaultCountryName;
    BOOL check;
}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    check = YES;
    UIView *padView1              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, self.mobileTextField.height)];
    self.mobileTextField.leftView            = padView1;
    self.mobileTextField.leftViewMode        = UITextFieldViewModeAlways;
    
    UIView *padView2              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, self.passwordTextField.height)];
    self.passwordTextField.leftView          = padView2;
    self.passwordTextField.leftViewMode      = UITextFieldViewModeAlways;
    
    UIView *padView3              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, self.codeTextField.height)];
    self.codeTextField.leftView          = padView3;
    self.codeTextField.leftViewMode      = UITextFieldViewModeAlways;
    
    UIImage *image = [UIImage imageNamed:@"btn_login_normal"];
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"btn_login_normal"] forState:UIControlStateNormal];
//    [self setTheLocalAreaCode];
//    _areaArray= [NSMutableArray array];
//    //获取支持的地区列表
//    [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array)
//     {
//         if (1==state)
//         {
//             NSLog(@"sucessfully get the area code");
//             //区号数据
//             _areaArray=[NSMutableArray arrayWithArray:array];
//         }
//         else if (0==state)
//         {
//             NSLog(@"failed to get the area code");
//         }
//         
//     }];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCountry:)];
//    [self.arreaCountryLabel addGestureRecognizer:tap];
    if (self.operationType == TYPE_FINDPASSWORD) {
        [self.registerButton setTitle:@"保存密码并登录" forState:UIControlStateNormal];
        self.checkButton.hidden = YES;
        self.tipLabel1.hidden = YES;
        self.tipLabel2.hidden = YES;
    }
}

-(BOOL)navigationShouldPopOnBackButton
{
    if (!self.codeButton.enabled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"验证码可能略有延迟,确定返回并重新开始?" delegate:self cancelButtonTitle:@"等待" otherButtonTitles:@"返回", nil];
        [alert show];
        return NO;
    }
    else {
        return YES;
    }
    
}

-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt=[locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode=[dictCodes objectForKey:tt];
//    self.areaCodeLabel.text=[NSString stringWithFormat:@"+%@",defaultCode];
//
//    NSString* defaultCountryName=[locale displayNameForKey:NSLocaleCountryCode value:tt];
//    _defaultCode=defaultCode;
//    _defaultCountryName=defaultCountryName;
//    debugLog(@"%@", defaultCountryName);
//
}

- (void)chooseCountry:(id)sender {
    SectionsViewController* country2=[[SectionsViewController alloc] init];
    country2.delegate=self;
    [country2 setAreaArray:_areaArray];
    [self.navigationController pushViewController:country2 animated:YES];
}

-(void)setSecondData:(CountryAndAreaCode *)data
{
//    _data2=data;
//    self.areaCodeLabel.text=[NSString stringWithFormat:@"%@",data.areaCode];
//    self.arreaCountryLabel.text = _data2.countryName ;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)registerOrResetPassword:(id)sender {
    if (self.operationType == TYPE_REGISTER) {
        [self registerUser];
    }
    else {
        [self resetPassword];
    }
}

-(void)registerUser
{
    NSString *mobile = self.mobileTextField.text;
    NSString *code = self.codeTextField.text;
    NSString *password = self.passwordTextField.text;
    int userType = 0;
    if ([RegexUtil isMobileNo:mobile]) {
        userType = 1;
    }
    if ([RegexUtil isEmail:mobile]) {
        userType = 2;
    }
    if (userType == 0) {
        debugLog(@"anything");
        return;
    }
    if (userType == 1) {
        [self registerUserAccount:mobile code:code password:password andType:@"mobile"];
    }
    else {
        [self registerUserAccount:mobile code:code password:password andType:@"email"];
    }
}

-(void)registerUserAccount:(NSString *)mobile code:(NSString *)code password:(NSString *)password andType:(NSString *)type
{
    [self.view endEditing:YES];
    [SVProgressHUD show];
    [[APIClient sharedInstance] registerByAccount:mobile
                                         withCode:code
                                     withPassword:password
                                         wityType:type
                                          Success:^(int errorCode, id model) {
                                              [SVProgressHUD dismiss];
                                              if (errorCode == 1) {
                                                  [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                                                  [self.delegate registerSuccess:mobile password:password];
                                              }
                                              else {
                                                  [SVProgressHUD showErrorWithStatus:model];
                                              }
                                          }
                                          failure:^(NSString *message) {
                                              
                                          }];
}

-(void)resetPassword
{
    NSString *mobile = self.mobileTextField.text;
    NSString *code = self.codeTextField.text;
    NSString *password = self.passwordTextField.text;
    [[APIClient sharedInstance] resetPasswordByMobile:mobile
                                             withCode:code
                                         withPassword:password
                                              Success:^(int errorCode, id model) {
        
                                              }
                                              failure:^(NSString *message) {
        
                                              }];
}

- (IBAction)applyCode:(id)sender {
    if (self.operationType == TYPE_REGISTER) {
        [self getRegisterSMSCode];
    }
    else {
        [self getResetPasswordSMSCode];
    }
}

-(void)getRegisterSMSCode
{
    if (![self.mobileTextField hasText]) {
        return;
    }
    NSString *mobile = self.mobileTextField.text;
    int userType = 0;
    if ([RegexUtil isMobileNo:mobile]) {
        userType = 1;
    }
    if ([RegexUtil isEmail:mobile]) {
        userType = 2;
    }
    if (userType == 0) {
        debugLog(@"anything");
        return;
    }
    if (userType == 1) {
        [self getVerifyCode:mobile andType:@"mobile"];
    }
    else {
        [self getVerifyCode:mobile andType:@"email"];
    }
}

-(void)getVerifyCode:(NSString *)mobile andType:(NSString *)type
{
    [SVProgressHUD show];
    [[APIClient sharedInstance] getVerifyCodeByMobile:mobile
                                                 type:type
                                              Success:^(int errorCode, id model) {
                                                  [SVProgressHUD dismiss];
                                                  if (errorCode == 1) {
                                                      [self.codeTextField becomeFirstResponder];
                                                      [self countDown];
                                                  }
                                                  else {
                                                      [SVProgressHUD showErrorWithStatus:model];
                                                  }
                                              }
                                              failure:^(NSString *message) {
                                                  [SVProgressHUD showErrorWithStatus:message];
                                              }];
}

-(void)getResetPasswordSMSCode
{
    if (![self.mobileTextField hasText]) {
        return;
    }
    NSString *mobile = self.mobileTextField.text;
    int userType = 0;
    if ([RegexUtil isMobileNo:mobile]) {
        userType = 1;
    }
    if ([RegexUtil isEmail:mobile]) {
        userType = 2;
    }
    if (userType == 0) {
        debugLog(@"anything");
        return;
    }
    [SVProgressHUD show];
    [[APIClient sharedInstance] getResetPasswordSMSCodeByMobile:mobile
                                                        Success:^(int errorCode, id model) {
                                                            [SVProgressHUD dismiss];
                                                            [self countDown];
                                                        }
                                                        failure:^(NSString *message) {
                                                            [SVProgressHUD showErrorWithStatus:message];
                                                        }];
}

- (IBAction)checkTrade:(id)sender {
    if (check) {
        check = NO;
        self.checkButton.selected = NO;
    }
    else {
        check = YES;
        self.checkButton.selected = YES;
    }
}

#pragma mark count down
-(void)countDown
{
    __block int timeout=60;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.codeButton.enabled = YES;
                [self.codeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
            });
        }else{
            int seconds = timeout % 60 == 0? 60 :(timeout % 60);
            NSString *redText = [NSString stringWithFormat:@"%.2d", seconds];
            NSString *strTime = [NSString stringWithFormat:@"(%@)重新获取", redText];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.codeButton.enabled = NO;
                [self.codeButton setTitle:strTime forState:UIControlStateNormal];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

#pragma mark alert delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

@end
