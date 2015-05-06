//
//  MeTableViewController.m
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "MeTableViewController.h"
#import "MeAvatarTableViewCell.h"
#import "LoginViewController.h"
#import "DraftViewController.h"
#import "PersonalSettingViewController.h"
#import "MyShareViewController.h"
#import "SomeoneProfileViewController.h"
#import "MessageViewController.h"
#import "ProductViewController.h"
#import "TDBadgedCell.h"

@interface MeTableViewController () <LoginViewControllerDelegate, PersonalSettingViewControllerDelegate>
{
    
}
@end

@implementation MeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:@"LoginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfile) name:@"UpdateProfile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessageNum:) name:@"MessageNum" object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"MeAvatarTableViewCell" bundle:nil] forCellReuseIdentifier:@"AvatarCell"];
    if (isUserLogin) {
        [self getMyProfileFromCache];
    }
    [self initBar];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"我的";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0xff5400, 1.0)];
//    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xfee101, 1.0)];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0x2f80ef, 1.0)];
//    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xf8f9fb, 1.0)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateProfile" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageNum" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 98;
    }
    else {
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    if (indexPath.section == 0) {
        CellIdentifier = @"AvatarCell";
        MeAvatarTableViewCell *cell = (MeAvatarTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (isUserLogin) {
            cell.loginButton.hidden = YES;
            cell.avatarImageView.hidden = NO;
            cell.nicknameLabel.hidden = NO;
            cell.nicknameLabel.text = getUserNickname;
            cell.groupTitleLabel.hidden = NO;
            cell.groupTitleLabel.text = getUserGroupTitle;
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:getUserAvatar]
                                    placeholderImage:nil
                                             options:SDWebImageRefreshCached];
        }
        else {
            cell.loginButton.hidden = NO;
            cell.avatarImageView.hidden = YES;
            cell.nicknameLabel.hidden = YES;
            cell.groupTitleLabel.hidden = YES;
        }
        [cell.loginButton addTarget:self action:@selector(enterLogin) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else {
        CellIdentifier        = @"cell1";
        TDBadgedCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell1 == nil) {
            cell1 = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        if (indexPath.row == 0) {
            cell1.textLabel.text  = @"订单";
            [cell1.imageView setImage:[UIImage imageNamed:@"icon_order"]];
        }
        else if (indexPath.row == 1) {
            cell1.textLabel.text  = @"草稿箱";
            [cell1.imageView setImage:[UIImage imageNamed:@"icon_draftbox"]];
        }
        else if (indexPath.row == 2) {
            cell1.textLabel.text  = @"我的帖子";
            [cell1.imageView setImage:[UIImage imageNamed:@"icon_share"]];
        }
        else if (indexPath.row == 3){
            cell1.textLabel.text  = @"消息";
            [cell1.imageView setImage:[UIImage imageNamed:@"icon_message"]];
            if (isUserLogin) {
                cell1.badgeColor = [UIColor redColor];
                cell1.badgeLeftOffset = 8;
                NSString *n = getFriendDeg2;
                cell1.badgeString = n;
            }
            else {
               cell1.badgeString = 0;
            }
        }
        cell1.textLabel.font = [UIFont systemFontOfSize:15];
        return cell1;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                if (!isUserLogin) {
                    [self enterLogin];
                }
                else {
                    [self enterPersonalSetting];
                }
                break;
                
            case 1:
                if (!isUserLogin) {
                    [self enterLogin];
                    return;
                }
                break;
            case 2:
                    [self enterDraft];
                break;
                
            case 3:
                if (!isUserLogin) {
                    [self enterLogin];
                    return;
                }
                else {
                    [self enterMyShare];
                }
                break;
            case 4:
                if (!isUserLogin) {
                    [self enterLogin];
                    return;
                }
                else {
                    [self enterMessage];
                }
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                if (!isUserLogin) {
                    [self enterLogin];
                    return;
                }
                else {
                    [self enterOrder];
                }
                break;
            case 1:
                [self enterDraft];
                break;
                
            case 2:
                if (!isUserLogin) {
                    [self enterLogin];
                    return;
                }
                else {
                    [self enterMyShare];
                }
                break;
            case 3:
                if (!isUserLogin) {
                    [self enterLogin];
                    return;
                }
                else {
                    [self enterMessage];
                }
                break;
        }
    }
}

-(void)enterLogin
{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterOrder
{
    ProductViewController *vc =[[ProductViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.url = GYOrderURL;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterDraft
{
    DraftViewController *vc = [[DraftViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterPersonalSetting
{
    PersonalSettingViewController *vc = [[PersonalSettingViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterMyShare
{
    MyShareViewController *vc = [[MyShareViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterMessage
{
    TDBadgedCell *cell = (TDBadgedCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];
    cell.badgeString = nil;
    MessageViewController *vc = [[MessageViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)logout
{
    [[APIClient sharedInstance] logoutSuccess:^(int errorCode, id model) {
        setLogout;
        [self.tableView reloadData];
    }
                                      failure:^(NSString *message) {
        
    }];
}

#pragma mark LoginViewController delegate
- (void)reloadProfile  {
    [self.tableView reloadData];
}

-(void)loginSuccess:(NSNotification *)notification
{
    User *user = notification.object;
    [self loginByAccountSuccess:user];
}

-(void)loginByAccountSuccess:(User *)user
{
//    [self.navigationController popViewControllerAnimated:YES];
    setIsLogin;
    setUserNickname(user.nickname);
    setUserAvatar(user.avatar);
    setUserSign(user._sign);
    setUserID(user.user_id);
    setUserPhone(user.mobile);
    setUserEmail(user.email);
    setUserGender(user.sex);
    setUserGroupTitle(user.grouptitle);
    setUserCredit(user.credits);
    [self.tableView reloadData];
    [self getMyProfile];
}

-(void)getMyProfileFromCache
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@-%@", UserCache, getUserID]]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        User *user = [User parseJson:[dic objectForKey:@"data"]];
        setUserNickname(user.nickname);
        setUserAvatar(user.avatar);
        setUserID(user.user_id);
        setUserPhone(user.mobile);
        setUserEmail(user.email);
        setUserGender(user.sex);
        setUserGroupTitle(user.grouptitle);
        setUserCredit(user.credits);
        [self.tableView reloadData];
    }
    [self getMyProfile];
}

-(void)getMyProfile
{
    [[APIClient sharedInstance] getMyProfileSuccess:^(int errorCode, id model) {
        if (errorCode == 1) {
            User *user = model;
            setUserNickname(user.nickname);
            setUserAvatar(user.avatar);
            setUserID(user.user_id);
            setUserPhone(user.mobile);
            setUserEmail(user.email);
            setUserGender(user.sex);
            setUserGroupTitle(user.grouptitle);
            setUserCredit(user.credits);
            [self.tableView reloadData];
        }
        else {
        }
    }
                                            failure:^(NSString *message) {
        
    }];
}

#pragma mark profile setting delegate
-(void)logoutFromSetting
{
    [self.navigationController popViewControllerAnimated:YES];
    TDBadgedCell *cell = (TDBadgedCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];
    cell.badgeString = nil;
    [self logout];
}

-(void)reloadMessageNum:(NSNotification *)notification
{
    TDBadgedCell *cell = (TDBadgedCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];
    cell.badgeString = getFriendDeg2;
}

@end
