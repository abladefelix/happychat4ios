//
//  SomeoneProfileViewController.m
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "SomeoneProfileViewController.h"
#import "CommunityZhiHuTableViewCell.h"
#import "OtherTableViewCell.h"
#import "MJRefresh.h"
#import "CommunityDetailViewController.h"

@interface SomeoneProfileViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *shares;
    OtherUser *otherUser;

    int tableviewDataState;
    int tableviewActionState;
    int currentPage;
    
}
@property (weak, nonatomic) IBOutlet UITableView *otherTableView;
@end

@implementation SomeoneProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    shares = [NSMutableArray array];
    otherUser = [[OtherUser alloc] init];
    [self.otherTableView registerNib:[UINib nibWithNibName:@"CommunityZhiHuTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShareCell"];
    [self.otherTableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"AvatarCell"];
    [self initBar];
    [self getOtherProfileFromCache];
    [self getOtherShareListFromCache];
    [self.otherTableView addHeaderWithTarget:self action:@selector(refreshShareList)];
    [self.otherTableView headerBeginRefreshing];
    [self.otherTableView addFooterWithTarget:self action:@selector(loadmoreShareList)];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"详细资料";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
}

-(void)getOtherProfileFromCache
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@-%@", UserCache, self.uid]]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        otherUser = [OtherUser parseJson:[dic objectForKey:@"data"]];
        [self.otherTableView reloadData];
    }
}

-(void)getOtherShareListFromCache
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@-%@", ShareListUserCache, self.uid]]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ShareList *shareList = [ShareList parseJson:[dic objectForKey:@"data"]];
        [self handleData:shareList action:TABLEVIEW_ACTION_INIT];
    }
}

- (void)getOtherProfile
{
    [[APIClient sharedInstance] getOtherProfileByUid:self.uid
                                             Success:^(int errorCode, id model) {
                                                 if (errorCode == 1) {
                                                     otherUser = model;
                                                     [self.otherTableView reloadData];
                                                 }
                                             }
                                             failure:^(NSString *message) {
        
                                             }];
}

#pragma mark get sharelist begin
-(void)refreshShareList
{
    [self getOtherProfile];
    currentPage = 1;
    [self getshareList:@"1" withAction:TABLEVIEW_ACTION_REFRESH];
}

-(void)loadmoreShareList
{
    if (tableviewDataState == TABLEVIEW_DATA_MORE) {
        currentPage ++;
        debugLog(@"%i", currentPage);
        [self getshareList:[NSString stringWithFormat:@"%i", currentPage] withAction:TABLEVIEW_ACTION_SCROLL];
    }
    else {
        [self.otherTableView footerEndRefreshing];
    }
}

-(void)getshareList:(NSString *)page withAction:(int)action
{
    [[APIClient sharedInstance] getSharelistByUserId:self.uid
                                              atPage:page
                                        withPageSize:@"20"
                                             Success:^(int errorCode, id model) {
                                                 if (errorCode == 1) {
                                                     ShareList *temp = (ShareList *)model;
                                                     [self handleData:temp action:action];
                                                 }
                                                 else {
                                                     [self.otherTableView headerEndRefreshing];
                                                     [self.otherTableView footerEndRefreshing];
                                                 }
                                             }
                                             failure:^(NSString *message) {
                                                 [self.otherTableView headerEndRefreshing];
                                                 [self.otherTableView footerEndRefreshing];
                                             }];
}

-(void)handleData:(ShareList *)data action:(int)action
{
    switch (action) {
        case TABLEVIEW_ACTION_INIT:
            [shares removeAllObjects];
            [shares addObjectsFromArray:data.share_list];
            [self.otherTableView reloadData];
            break;
            
        case TABLEVIEW_ACTION_REFRESH:
            [self.otherTableView headerEndRefreshing];
            [shares removeAllObjects];
            [shares addObjectsFromArray:data.share_list];
            [self.otherTableView reloadData];
            break;
        case TABLEVIEW_ACTION_SCROLL:
            [self.otherTableView footerEndRefreshing];
            [shares addObjectsFromArray:data.share_list];
            [self.otherTableView reloadData];
            break;
        default:
            break;
    }
    if (currentPage >= data.count) {
        tableviewDataState = TABLEVIEW_DATA_FULL;
    }
    else {
        tableviewDataState = TABLEVIEW_DATA_MORE;
    }
    
    
}
#pragma mark get sharelist end

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 104;
    }
    else {
        return 86;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else {
        return 10;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        return shares.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    if (indexPath.section == 0) {
        CellIdentifier = @"AvatarCell";
        OtherTableViewCell *cell = (OtherTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:otherUser.avatar]
                                placeholderImage:nil
                                         options:SDWebImageRetryFailed|SDWebImageLowPriority];
        cell.nicknameLabel.text = otherUser.nickname;
        cell.groupTitleLabel.text = otherUser.grouptitle;
        return cell;
    }
    else {
        CellIdentifier = @"ShareCell";
        CommunityZhiHuTableViewCell *cell = (CommunityZhiHuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        Share *share = shares[indexPath.row];
        cell.nameLabel.text = share.dateline;
        cell.titleLabel.text = share.subject;
        cell.commentCountLabel.text = share.replies;
        [cell setShare:share];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        Share *share = shares[indexPath.row];
        CommunityDetailViewController *vc = [[CommunityDetailViewController alloc] init];
        vc.currentShare = share;
        vc.threadId = share.tid;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
