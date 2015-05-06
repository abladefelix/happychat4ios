//
//  PersonalSettingViewController.m
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "PersonalSettingViewController.h"
#import "AvatarSettingTableViewCell.h"
#import "InfoSettingTableViewCell.h"
#import "LogoutTableViewCell.h"
#import "ProfileEditViewController.h"
#import "QiniuSimpleUploader.h"
#import "QiniuPutPolicy.h"
#import "GenderEditTableViewController.h"

@interface PersonalSettingViewController () <UITableViewDataSource, UITableViewDelegate, QiniuUploadDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    QiniuSimpleUploader *sUploader;
}
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@end

@implementation PersonalSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBar];
    [self.settingTableView registerNib:[UINib nibWithNibName:@"AvatarSettingTableViewCell" bundle:nil] forCellReuseIdentifier:@"AvatarCell"];
    [self.settingTableView registerNib:[UINib nibWithNibName:@"InfoSettingTableViewCell" bundle:nil] forCellReuseIdentifier:@"InfoCell"];
    [self.settingTableView registerNib:[UINib nibWithNibName:@"LogoutTableViewCell" bundle:nil] forCellReuseIdentifier:@"LogoutCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfile) name:@"UpdateProfile" object:nil];
    QiniuPutPolicy *policy = [QiniuPutPolicy new];
    policy.scope = QiNiuBucket;
    sUploader = [QiniuSimpleUploader uploaderWithToken:[policy makeToken:QiNiuAccessKey secretKey:QiNiuSecertKey]];
    sUploader.delegate = self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateProfile" object:nil];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"个人信息";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
}

- (void)reloadProfile  {
    [self.settingTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 100;
    }
    else if (indexPath.section == 1) {
        return 54;
    }
    else {
        return 54;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 5;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    if (indexPath.section == 0) {
        CellIdentifier = @"AvatarCell";
        AvatarSettingTableViewCell *cell = (AvatarSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:getUserAvatar]
                                placeholderImage:nil
                                         options:SDWebImageRefreshCached];
        return cell;
    }
    else if (indexPath.section == 1) {
        CellIdentifier = @"InfoCell";
        InfoSettingTableViewCell *cell = (InfoSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.infoLabel.text = @"呢称";
            cell.valueLabel.text = getUserNickname;
        }
        else if (indexPath.row == 1) {
            cell.infoLabel.text = @"性别";
            cell.valueLabel.text = [getUserGender intValue]==1?@"男":@"女";
        }
        else if (indexPath.row == 2) {
            cell.infoLabel.text = @"手机";
            cell.valueLabel.text = getUserPhone;
        }
        else if (indexPath.row == 3) {
            cell.infoLabel.text = @"邮箱";
            cell.valueLabel.text = getUserEmail;
        }
        else {
            cell.infoLabel.text = @"等级";
            cell.valueLabel.text = getUserGroupTitle;
        }
        return cell;
    }
    else {
        CellIdentifier = @"LogoutCell";
        LogoutTableViewCell *cell = (LogoutTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self showAvatarActionsheet];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self enterProfileEdit:EditNickname];
        }
        else if (indexPath.row == 1) {
            [self enterGenderEdit];
        }
        else if (indexPath.row == 2) {
//            [self enterProfileEdit:EditMobile];
        }
        else if (indexPath.row == 3) {
//            [self enterProfileEdit:EditEmail];
        }
        else {
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定注销本账号吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

-(void)enterProfileEdit:(int)type
{
    ProfileEditViewController *vc = [[ProfileEditViewController alloc] init];
    vc.editType = type;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterGenderEdit
{
    GenderEditTableViewController *vc = [[GenderEditTableViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark uialertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self.delegate logoutFromSetting];
    }
}

#pragma mark show avatar actionsheet
-(void)showAvatarActionsheet
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"图库", nil];
    action.tag = 1;
    [action showInView:self.view];
}

#pragma mark actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 1:
        {
            if(buttonIndex == 0)
            {
                [self OpenCanmera];
            }
            else if(buttonIndex ==1)
            {
                [self OpenPhoLibray];
            }
        }
            break;
    }
}

//打开照相
-(void)OpenCanmera
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

//打开图片库
-(void)OpenPhoLibray
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    int width = image.size.width;
    int height = image.size.height;
    int contentImageHeight = height * 200 / width;
    UIImage *imageResize = [Tool imageWithImageSimple:image scaledToSize:CGSizeMake(200, contentImageHeight)];
    [self performSelector:@selector(saveImage:) withObject:imageResize afterDelay:0.2];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image
{
    long a = [[NSDate date] timeIntervalSince1970];
    NSString *imagePath = [Tool imageSavedPath:[NSString stringWithFormat:@"%ld.png", a]];
    BOOL isSaveSuccess = [Tool saveToDocument:image withFilePath:imagePath];
    AvatarSettingTableViewCell *cell = (AvatarSettingTableViewCell *)[self.settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.avatarImageView setImage:image];
    if (isSaveSuccess) {
//        [sUploader uploadFile:imagePath key:[NSString stringWithFormat:@"%ld.png", a] extra:nil];
        [self saveAvatar:imagePath];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"保存图片失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)uploadProgressUpdated:(NSString *)filePath percent:(float)percent
{
    [SVProgressHUD showProgress:percent];
}

-(void)uploadSucceeded:(NSString *)filePath ret:(NSDictionary *)ret
{
    debugLog(@"%@", ret);
    [SVProgressHUD showSuccessWithStatus:@""];
    NSString *key = [NSString stringWithFormat:@"%@/%@", QINIU_PREFIX, [ret objectForKey:@"key"]];
    setUserAvatar(key);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProfile" object:nil];
}

-(void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    [SVProgressHUD dismiss];
    debugLog(@"%@", error.description);
    [SVProgressHUD showErrorWithStatus:@""];
}

-(void)saveAvatar:(NSString *)imagePath
{
    [[APIClient sharedInstance] updateUserAvatar:@""
                                         filePah:imagePath
                                        progress:^(float percent) {
                                            [SVProgressHUD showProgress:percent];
                                        }
                                         Success:^(int errorCode, id model) {
                                             if (errorCode == 1) {
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProfile" object:nil];
                                                 debugLog(@"%@",[[SDWebImageManager sharedManager]cacheKeyForURL:[NSURL URLWithString:getUserAvatar]]);
                                                 [[SDImageCache sharedImageCache] removeImageForKey:[[SDWebImageManager sharedManager]cacheKeyForURL:[NSURL URLWithString:getUserAvatar]]];
                                                 [SVProgressHUD showSuccessWithStatus:model];
                                             }
                                             else {
                                                 [SVProgressHUD showErrorWithStatus:model];
                                             }
                                         }
                                         failure:^(NSString *message) {
                                             [SVProgressHUD showErrorWithStatus:message];
                                         }];

}

@end
