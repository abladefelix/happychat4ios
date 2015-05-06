//
//  MessageViewController.m
//  vitalia
//
//  Created by Donal on 15/3/30.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "MessageViewController.h"
#import "MJRefresh.h"
#import "ThreadMessageTableViewCell.h"
#import "CommunityDetailViewController.h"
#import "ProductViewController.h"

@interface MessageViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray *threadMessages;
    int threadTableviewDataState;
    int threadTableviewActionState;
    int threadCurrentPage;
    
    NSMutableArray *systemMessages;
    int systemTableviewDataState;
    int systemTableviewActionState;
    int systemCurrentPage;
}
@property (weak, nonatomic) IBOutlet UIButton *threadButton;
@property (weak, nonatomic) IBOutlet UIButton *systemButton;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UITableView *threadTableView;
@property (strong, nonatomic) UITableView *systemTableView;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    threadCurrentPage = 1;
    systemCurrentPage = 1;
    threadMessages = [NSMutableArray array];
    systemMessages = [NSMutableArray array];
    self.mainScrollView.delegate = self;
    self.mainScrollView.scrollsToTop = NO;
    [self.mainScrollView setContentSize:CGSizeMake(screenframe.size.width*2, 0)];
    self.systemTableView = [[UITableView alloc] initWithFrame:CGRectMake(screenframe.size.width, 0, screenframe.size.width, self.mainScrollView.height)];
    self.systemTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mainScrollView addSubview:self.systemTableView];
    [self initBar];
    [self.threadTableView registerNib:[UINib nibWithNibName:@"ThreadMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"ThreadMessageCell"];
    [self.threadTableView addHeaderWithTarget:self action:@selector(refreshThreadMessageList)];
    [self.threadTableView addFooterWithTarget:self action:@selector(loadmoreThreadMessageList)];
//    [self.threadTableView headerBeginRefreshing];
    [self getThreadMessageListFromCache];
    [self initButton];
    
    self.systemTableView.delegate = self;
    self.systemTableView.dataSource = self;
    [self.systemTableView registerNib:[UINib nibWithNibName:@"ThreadMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"SystemMessageCell"];
    [self.systemTableView addHeaderWithTarget:self action:@selector(refreshSystemMessageList)];
    [self.systemTableView addFooterWithTarget:self action:@selector(loadmoreSystemMessageList)];
//    [self.systemTableView headerBeginRefreshing];
    [self.systemTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self getSystemMessageListFromCache];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"消息";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
}

-(void)initButton
{
    [self.threadButton.layer setBorderWidth:1];
    [self.threadButton.layer setBorderColor:UIColorFromRGB(0x00b7ee, 1).CGColor];
    [self.threadButton setTitleColor:UIColorFromRGB(0x00b7ee, 1) forState:UIControlStateNormal];
    [self.threadButton setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateHighlighted];
    [self.threadButton setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateSelected];
    [self.threadButton setBackgroundColor:UIColorFromRGB(0x00b7ee, 1)];
    [self.threadButton setSelected:YES];
    
    [self.systemButton.layer setBorderWidth:1];
    [self.systemButton.layer setBorderColor:UIColorFromRGB(0x00b7ee, 1).CGColor];
    [self.systemButton setTitleColor:UIColorFromRGB(0x00b7ee, 1) forState:UIControlStateNormal];
    [self.systemButton setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateHighlighted];
    [self.systemButton setTitleColor:UIColorFromRGB(0xffffff, 1) forState:UIControlStateSelected];
    [self.systemButton setBackgroundColor:UIColorFromRGB(0xffffff, 1)];
}

- (IBAction)showComment:(id)sender {
    self.systemTableView.scrollsToTop = NO;
    self.threadTableView.scrollsToTop = YES;
    [self.threadButton setBackgroundColor:UIColorFromRGB(0x00b7ee, 1)];
    [self.systemButton setBackgroundColor:UIColorFromRGB(0xffffff, 1)];
    self.threadButton.selected = YES;
    self.systemButton.selected = NO;
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (IBAction)showSystem:(id)sender {
    self.systemTableView.scrollsToTop = YES;
    self.threadTableView.scrollsToTop = NO;
    [self.systemButton setBackgroundColor:UIColorFromRGB(0x00b7ee, 1)];
    [self.threadButton setBackgroundColor:UIColorFromRGB(0xffffff, 1)];
    self.threadButton.selected = NO;
    self.systemButton.selected = YES;
    [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.width, 0) animated:NO];
}
#pragma mark thread message
-(void)getThreadMessageListFromCache
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@", ThreadMessageCache]]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ThreadMessageList *mList = [ThreadMessageList parseJson:[dic objectForKey:@"data"]];
        [self handleData:mList action:TABLEVIEW_ACTION_INIT];
    }
}

-(void)refreshThreadMessageList
{
    threadCurrentPage = 1;
    threadTableviewDataState = TABLEVIEW_DATA_LOADING;
    [self getThreadMessageList:@"1" withAction:TABLEVIEW_ACTION_REFRESH];
    [self.threadTableView setFooterHidden:NO];
}

-(void)loadmoreThreadMessageList
{
    if (threadTableviewDataState == TABLEVIEW_DATA_MORE) {
        threadCurrentPage ++;
        [self getThreadMessageList:[NSString stringWithFormat:@"%i", threadCurrentPage] withAction:TABLEVIEW_ACTION_SCROLL];
    }
    else {
        [self.threadTableView footerEndRefreshing];
    }
}

-(void)getThreadMessageList:(NSString *)page withAction:(int)action
{
    [[APIClient sharedInstance] getMyPostMessageAtPage:page
                                              pageSize:@"20"
                                               Success:^(int errorCode, id model) {
                                                    if (errorCode == 1) {
                                                        ThreadMessageList *temp = (ThreadMessageList *)model;
                                                        [self handleData:temp action:action];
                                                    }
                                                    else {
                                                        [self.threadTableView headerEndRefreshing];
                                                        [self.threadTableView footerEndRefreshing];
                                                        if (action == TABLEVIEW_ACTION_SCROLL) {
                                                            threadCurrentPage--;
                                                        }
                                                    }
                                               }
                                               failure:^(NSString *message) {
                                                    [self.threadTableView headerEndRefreshing];
                                                    [self.threadTableView footerEndRefreshing];
                                                    if (action == TABLEVIEW_ACTION_SCROLL) {
                                                        threadCurrentPage--;
                                                    }
                                               }];

}

-(void)handleData:(ThreadMessageList *)data action:(int)action
{
    switch (action) {
        case TABLEVIEW_ACTION_INIT:
            [threadMessages removeAllObjects];
            [threadMessages addObjectsFromArray:data.list];
            [self.threadTableView reloadData];
            break;
            
        case TABLEVIEW_ACTION_REFRESH:
            [self.threadTableView headerEndRefreshing];
            [threadMessages removeAllObjects];
            [threadMessages addObjectsFromArray:data.list];
            [self.threadTableView reloadData];
            break;
        case TABLEVIEW_ACTION_SCROLL:
            [self.threadTableView footerEndRefreshing];
            [threadMessages addObjectsFromArray:data.list];
            [self.threadTableView reloadData];
            break;
        default:
            break;
    }
    if (threadCurrentPage >= data.pagecount) {
        threadTableviewDataState = TABLEVIEW_DATA_FULL;
        [self.threadTableView setFooterHidden:YES];
    }
    else {
        threadTableviewDataState = TABLEVIEW_DATA_MORE;
    }
    
    
}
#pragma mark 个人消息 end

#pragma mark 系统消息 message
-(void)getSystemMessageListFromCache
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@", SystemMessageCache]]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ThreadMessageList *mList = [ThreadMessageList parseJson:[dic objectForKey:@"data"]];
        [self handleSystemData:mList action:TABLEVIEW_ACTION_INIT];
    }
}

-(void)refreshSystemMessageList
{
    systemCurrentPage = 1;
    systemTableviewDataState = TABLEVIEW_DATA_LOADING;
    [self getSystemMessageList:@"1" withAction:TABLEVIEW_ACTION_REFRESH];
    [self.systemTableView setFooterHidden:NO];
}

-(void)loadmoreSystemMessageList
{
    if (systemTableviewDataState == TABLEVIEW_DATA_MORE) {
        systemCurrentPage ++;
        [self getSystemMessageList:[NSString stringWithFormat:@"%i", systemCurrentPage] withAction:TABLEVIEW_ACTION_SCROLL];
    }
    else {
        [self.systemTableView footerEndRefreshing];
    }
}

-(void)getSystemMessageList:(NSString *)page withAction:(int)action
{
    [[APIClient sharedInstance] getSystemMessageAtPage:page
                                              pageSize:@"20"
                                               Success:^(int errorCode, id model) {
                                                   if (errorCode == 1) {
                                                       ThreadMessageList *temp = (ThreadMessageList *)model;
                                                       debugLog(@"%ld",temp.list.count);
                                                       [self handleSystemData:temp action:action];
                                                   }
                                                   else {
                                                       [self.systemTableView headerEndRefreshing];
                                                       [self.systemTableView footerEndRefreshing];
                                                       if (action == TABLEVIEW_ACTION_SCROLL) {
                                                           systemCurrentPage--;
                                                       }
                                                   }
                                               }
                                               failure:^(NSString *message) {
                                                   [self.systemTableView headerEndRefreshing];
                                                   [self.systemTableView footerEndRefreshing];
                                                   if (action == TABLEVIEW_ACTION_SCROLL) {
                                                       systemCurrentPage--;
                                                   }
                                               }];
    
}

-(void)handleSystemData:(ThreadMessageList *)data action:(int)action
{
    switch (action) {
        case TABLEVIEW_ACTION_INIT:
            [systemMessages removeAllObjects];
            [systemMessages addObjectsFromArray:data.list];
            [self.systemTableView reloadData];
            break;
            
        case TABLEVIEW_ACTION_REFRESH:
            [self.systemTableView headerEndRefreshing];
            [systemMessages removeAllObjects];
            [systemMessages addObjectsFromArray:data.list];
            [self.systemTableView reloadData];
            break;
        case TABLEVIEW_ACTION_SCROLL:
            [self.systemTableView footerEndRefreshing];
            [systemMessages addObjectsFromArray:data.list];
            [self.systemTableView reloadData];
            break;
        default:
            break;
    }
    if (systemCurrentPage >= data.pagecount) {
        systemTableviewDataState = TABLEVIEW_DATA_FULL;
        [self.systemTableView setFooterHidden:YES];
    }
    else {
        systemTableviewDataState = TABLEVIEW_DATA_MORE;
    }
}
#pragma mark 系统消息 end

#pragma mark tableview delegate begin
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.systemTableView) {
        return systemMessages.count;
    }
    else {
        return threadMessages.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.systemTableView) {
        ThreadMessage *tMessage = systemMessages[indexPath.row];
        return tMessage.cellHeight;
    }
    else {
        ThreadMessage *tMessage = threadMessages[indexPath.row];
        return tMessage.cellHeight;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.systemTableView) {
        static NSString *CellIdentifier;
        CellIdentifier = @"SystemMessageCell";
        ThreadMessageTableViewCell *cell = (ThreadMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        ThreadMessage *tMessage = systemMessages[indexPath.row];
        cell.nicknameLabel.text = tMessage.author.length>0?tMessage.author:@"系统通知";
        cell.timeLabel.text = tMessage.dateline;
        cell.contentLabel.text = tMessage.note;
        cell.contentLabel.height = tMessage.contentHeight;
        [cell.avatarImageVIew sd_setImageWithURL:[NSURL URLWithString:getUserAvatar]
                                placeholderImage:nil
                                         options:SDWebImageRetryFailed|SDWebImageRefreshCached];
        cell.dividerImageView.top = tMessage.cellHeight-1;
        cell.isReadImageView.hidden = NO;
        if (tMessage.isRead == 1) {
            cell.isReadImageView.hidden = YES;
        }
        return cell;
    }
    else {
        static NSString *CellIdentifier;
        CellIdentifier = @"ThreadMessageCell";
        ThreadMessageTableViewCell *cell = (ThreadMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        ThreadMessage *tMessage = threadMessages[indexPath.row];
        cell.nicknameLabel.text = tMessage.author;
        cell.timeLabel.text = tMessage.dateline;
        cell.contentLabel.text = tMessage.note;
        cell.contentLabel.height = tMessage.contentHeight;
        [cell.avatarImageVIew sd_setImageWithURL:[NSURL URLWithString:getUserAvatar]
                                placeholderImage:nil
                                         options:SDWebImageRetryFailed|SDWebImageRefreshCached];
        cell.dividerImageView.top = tMessage.cellHeight-1;
        cell.isReadImageView.hidden = NO;
        if (tMessage.isRead == 1) {
            cell.isReadImageView.hidden = YES;
        }
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.systemTableView) {
        ThreadMessage *tMessage = systemMessages[indexPath.row];
        if (tMessage.url == nil) {
            return;
        }
        ProductViewController *vc = [[ProductViewController alloc] init];
        vc.url = tMessage.url;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        debugLog(@"%@", tMessage.url);
    }
    else {
        ThreadMessage *tMessage = threadMessages[indexPath.row];
        CommunityDetailViewController *vc = [[CommunityDetailViewController alloc] init];
        vc.currentShare = nil;
        vc.threadId = tMessage.tid;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];

    }
}

#pragma mark tableview delegate end

#pragma mark scrollview delegate begin
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.threadTableView) {
        if((scrollView.contentOffset.y>(scrollView.contentSize.height-self.threadTableView.frame.size.height + TableViewDragUpHeight)) && threadTableviewDataState == TABLEVIEW_DATA_MORE)
        {
            if (!self.threadTableView.footerRefreshing) {
                [self.threadTableView footerBeginRefreshing];
            }
        }
    }
    if (scrollView == self.systemTableView) {
        if((scrollView.contentOffset.y>(scrollView.contentSize.height-self.systemTableView.frame.size.height + TableViewDragUpHeight)) && systemTableviewDataState == TABLEVIEW_DATA_MORE)
        {
            if (!self.systemTableView.footerRefreshing) {
                [self.systemTableView footerBeginRefreshing];
            }
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.mainScrollView) {
        debugLog(@"aa");
        CGFloat pagewidth = self.mainScrollView.frame.size.width;
        int currentPage = floor((self.mainScrollView.contentOffset.x - pagewidth/ 3) / pagewidth) + 1;
        [self changeButtonState:currentPage];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

#pragma mark three button
-(void)changeButtonState:(int)currentPage
{
    switch (currentPage) {
        case 0:
            self.threadButton.selected = YES;
            self.systemButton.selected    = NO;
            break;
        case 1:
            self.threadButton.selected = NO;
            self.systemButton.selected    = YES;
            break;
    }
}

@end
