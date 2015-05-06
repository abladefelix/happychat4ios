//
//  MyShareViewController.m
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "MyShareViewController.h"
#import "CommunityZhiHuTableViewCell.h"
#import "MWPhotoBrowser.h"
#import "MJRefresh.h"
#import "CommunityDetailViewController.h"

@interface MyShareViewController ()
{
    NSMutableArray *shares;
    int tableviewDataState;
    int tableviewActionState;
    int currentPage;
}
@property (weak, nonatomic) IBOutlet UITableView *shareTableView;
@end

@implementation MyShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBar];
    shares = [NSMutableArray array];
    [self.shareTableView registerNib:[UINib nibWithNibName:@"CommunityZhiHuTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShareCell"];
    [self getMyShareListFromCache];
    [self.shareTableView addFooterWithTarget:self action:@selector(loadmoreShareList)];
    [self.shareTableView addHeaderWithTarget:self action:@selector(refreshShareList)];
    [self.shareTableView headerBeginRefreshing];

    
}

-(void)dealloc
{
    self.shareTableView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"我的文章";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
}

-(void)getMyShareListFromCache
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@-%@", ShareListUserCache, getUserID]]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ShareList *shareList = [ShareList parseJson:[dic objectForKey:@"data"]];
        [self handleData:shareList action:TABLEVIEW_ACTION_INIT];
    }
}

#pragma mark get sharelist begin
-(void)refreshShareList
{
    currentPage = 1;
    tableviewDataState = TABLEVIEW_DATA_LOADING;
    [self getshareList:@"1" withAction:TABLEVIEW_ACTION_REFRESH];
    [self.shareTableView setFooterHidden:NO];
}

-(void)loadmoreShareList
{
    if (tableviewDataState == TABLEVIEW_DATA_MORE) {
        currentPage ++;
        debugLog(@"%i", currentPage);
        [self getshareList:[NSString stringWithFormat:@"%i", currentPage] withAction:TABLEVIEW_ACTION_SCROLL];
    }
    else {
        [self.shareTableView footerEndRefreshing];
    }
}

-(void)getshareList:(NSString *)page withAction:(int)action
{
    [[APIClient sharedInstance] getSharelistByUserId:getUserID
                                        atPage:page
                                  withPageSize:@"20"
                                       Success:^(int errorCode, id model) {
                                           if (errorCode == 1) {
                                               ShareList *temp = (ShareList *)model;
                                               [self handleData:temp action:action];
                                           }
                                           else {
                                               [self.shareTableView headerEndRefreshing];
                                               [self.shareTableView footerEndRefreshing];
                                               if (action == TABLEVIEW_ACTION_SCROLL) {
                                                   currentPage--;
                                               }
                                           }
                                       }
                                       failure:^(NSString *message) {
                                           [self.shareTableView headerEndRefreshing];
                                           [self.shareTableView footerEndRefreshing];
                                           if (action == TABLEVIEW_ACTION_SCROLL) {
                                               currentPage--;
                                           }
                                       }];
}

-(void)handleData:(ShareList *)data action:(int)action
{
    switch (action) {
        case TABLEVIEW_ACTION_INIT:
            [shares removeAllObjects];
            [shares addObjectsFromArray:data.share_list];
            [self.shareTableView reloadData];
            break;
            
        case TABLEVIEW_ACTION_REFRESH:
            [self.shareTableView headerEndRefreshing];
            [shares removeAllObjects];
            [shares addObjectsFromArray:data.share_list];
            [self.shareTableView reloadData];
            break;
        case TABLEVIEW_ACTION_SCROLL:
            [self.shareTableView footerEndRefreshing];
            [shares addObjectsFromArray:data.share_list];
            [self.shareTableView reloadData];
            break;
        default:
            break;
    }
    if (currentPage >= data.pagecount) {
        tableviewDataState = TABLEVIEW_DATA_FULL;
        [self.shareTableView setFooterHidden:YES];
    }
    else {
        tableviewDataState = TABLEVIEW_DATA_MORE;
    }
    
    
}
#pragma mark get sharelist end

#pragma mark tableview delegate begin
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return shares.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    Share *share = shares[indexPath.row];
    return 86;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier = @"ShareCell";
    CommunityZhiHuTableViewCell *cell = (CommunityZhiHuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Share *share = shares[indexPath.row];
    cell.nameLabel.text = share.dateline;
    cell.titleLabel.text = share.subject;
    cell.commentCountLabel.text = share.replies;
    [cell setShare:share];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Share *share = shares[indexPath.row];
    CommunityDetailViewController *vc = [[CommunityDetailViewController alloc] init];
    vc.currentShare = share;
    vc.threadId = share.tid;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark tableview delegate end
#pragma mark scrollview delegate begin
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if((scrollView.contentOffset.y>(scrollView.contentSize.height-self.shareTableView.frame.size.height + TableViewDragUpHeight)) && tableviewDataState == TABLEVIEW_DATA_MORE)
    {
        if (!self.shareTableView.footerRefreshing) {
            [self.shareTableView footerBeginRefreshing];
        }
    }
}

@end
