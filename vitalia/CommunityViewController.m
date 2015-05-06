//
//  CommunityViewController.m
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CommunityViewController.h"
#import "CommunityZhiHuTableViewCell.h"
#import "ShareDetailViewController.h"
#import "MWPhotoBrowser.h"
#import "MJRefresh.h"
#import "SlideMenu.h"
#import "PubViewController.h"
#import "SidebarViewController.h"
#import "SomeTypeViewController.h"
#import "CommunityDetailViewController.h"
#import "LoginViewController.h"
#import "MoreCell.h"
#import "ImagePlayerView.h"
#import "CreditView.h"
#import "CreditViewController.h"
#import "POP/POP.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"

@interface CommunityViewController () <UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, SidebarViewControllerDelegate, ImagePlayerViewDelegate, UIViewControllerTransitioningDelegate, CommunityZhiHuTableViewCellDelegate>
{
    NSMutableArray *_selections;
    NSMutableArray *shares;
    int tableviewDataState;
    int tableviewActionState;
    int currentPage;
    
    NSString *shareType;
    UILabel *titleLabel;
    NSArray *imageURLs;
    
    NSMutableArray *banners;
}
@property (weak, nonatomic) IBOutlet UIButton *signButton;
@property (strong, nonatomic) IBOutlet ImagePlayerView *adsView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (weak, nonatomic) IBOutlet UITableView *shareTableView;
@property (nonatomic, retain) SidebarViewController* sidebarVC;

@end

@implementation CommunityViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DisplaySign" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addcredits" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displaySign) name:@"DisplaySign" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addcredits:) name:@"addcredits" object:nil];
    [self initBar];
    shareType = @"0";
    shares = [NSMutableArray array];
    banners = [NSMutableArray array];
    [self.shareTableView registerNib:[UINib nibWithNibName:@"CommunityZhiHuTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShareCell"];
    [self.shareTableView addFooterWithTarget:self action:@selector(loadmoreShareList)];
    [self.shareTableView addHeaderWithTarget:self action:@selector(refreshShareList)];
    [self.shareTableView headerBeginRefreshing];
    [self getShareListFromCacheByFid:shareType];
    self.sidebarVC = [[SidebarViewController alloc] init];
    [self.sidebarVC setBgRGB:0x000000];
    self.sidebarVC.delegate = self;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.sidebarVC.view];
    self.sidebarVC.view.frame  = self.view.frame;
    UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToPresentSlideMenu:)];
    [swipeGesture delaysTouchesBegan];
    [self.view addGestureRecognizer:swipeGesture];
    [self initAdView];
    [self getBannerFromCache];
}

-(void)initBar
{
    titleLabel                             = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"意大利原生活";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_pubshare_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(pubShare)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sidebar_menu"] style:UIBarButtonItemStyleDone target:self action:@selector(showSlideMenu)];
    self.navigationItem.leftBarButtonItem = leftButton;
    debugLog(@"%f",screenframe.size.height);
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

-(void)displaySign
{
    self.signButton.hidden = NO;
}

#pragma mark 发布
-(void)pubShare
{
    if(!isUserLogin ) {
        [self enterLogin];
        return;
    }
    PubViewController *vc = [[PubViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.operation = OPRATION_NEW;
    vc.type = TYPE_SHARE;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 登录
-(void)enterLogin
{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 侧边栏
-(void)showSlideMenu
{
    [self.sidebarVC showHideSidebar];
}

#pragma mark UISwipeGestureRecognizer
-(void)swipeToPresentSlideMenu:(UIPanGestureRecognizer *)recognizer
{
    [self.sidebarVC panDetected:recognizer];
}

#pragma mark 读取文章列表缓存
-(void)getShareListFromCacheByFid:(NSString *)fid
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:[NSString stringWithFormat:@"%@-%@", ShareListCache, fid]]];
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
    [self getshareList:@"1" withAction:TABLEVIEW_ACTION_REFRESH];
    [self.shareTableView setFooterHidden:NO];
}

-(void)loadmoreShareList
{
    if (tableviewDataState == TABLEVIEW_DATA_MORE) {
        currentPage ++;
        [self getshareList:[NSString stringWithFormat:@"%i", currentPage] withAction:TABLEVIEW_ACTION_SCROLL];
    }
    else {
        [self.shareTableView footerEndRefreshing];
    }
}

-(void)getshareList:(NSString *)page withAction:(int)action
{
    [[APIClient sharedInstance] getSharelistBy:shareType
                                        atPage:page
                                  withPageSize:@"20"
                                       Success:^(int errorCode, id model) {
                                           if (errorCode == 1) {
                                               ShareList *temp = (ShareList *)model;
                                               if ([shareType isEqualToString:temp.currentType]) {
                                                  [self handleData:temp action:action];
                                               }
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
            break;
            
        case TABLEVIEW_ACTION_REFRESH:
            [self.shareTableView headerEndRefreshing];
            [shares removeAllObjects];
            [shares addObjectsFromArray:data.share_list];
            break;
        case TABLEVIEW_ACTION_SCROLL:
            [self.shareTableView footerEndRefreshing];
            [shares addObjectsFromArray:data.share_list];
            
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
    tableviewActionState = TABLEVIEW_ACTION_NORMAL;
    [self.shareTableView reloadData];
}
#pragma mark get sharelist end

#pragma mark tableview delegate begin
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return shares.count;
    }
    else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 86;
    }
    else {
        return 50;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier = @"ShareCell";
//    CommunityTableViewCell *cell = (CommunityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    Share *share = shares[indexPath.row];
//    cell.nicknameLabel.text = share.user_name;
//    cell.contentLabel.text = share.share_title;
//    cell.timeLabel.text = [Tool phplong2Data:share.share_time];
//    if (share.contentHeight > 20) {
//        cell.contentLabel.top = 8;
//    }
//    else {
//        cell.contentLabel.top = 18;
//    }
//    cell.contentLabel.height = share.contentHeight;
//    cell.timeLabel.top = cell.contentLabel.top + cell.contentLabel.height;
//    if (share.media_list.count == 0) {
//        cell.picView.hidden = YES;
//        cell.picIndicator.hidden = YES;
//    }
//    else {
//        cell.picView.hidden = NO;
//        cell.picIndicator.hidden = NO;
//        float maxWidth = 10 + 90 * share.media_list.count + 10 * (share.media_list.count-1);
//        cell.picCollectionView.width = maxWidth>cell.picView.width? cell.picView.width : maxWidth;
//    }
//    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:share.avatar]
//                            placeholderImage:nil
//                                     options:SDWebImageRetryFailed|SDWebImageLowPriority];
//    [cell setShare:share];
//    cell.delegate = self;
    if (indexPath.section == 0) {
        CommunityZhiHuTableViewCell *cell = (CommunityZhiHuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        Share *share = shares[indexPath.row];
        cell.nameLabel.text = [NSString stringWithFormat:@"by %@", share.author];
        cell.titleLabel.text = share.subject;
        cell.commentCountLabel.text = share.replies;
        [cell setShare:share];
        cell.delegate = self;
        return cell;
    }
    else {
        CellIdentifier = @"MoreCell";
        MoreCell *cell = (MoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell  = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (tableviewDataState == TABLEVIEW_DATA_EMPTY) {
            [cell.loadingIndicator setHidden:YES];
            [cell.loadingIndicator stopAnimating];
        }
        else if (tableviewDataState == TABLEVIEW_DATA_ERROR) {
            [cell.loadingLabel setText:@"网络不给力哦!"];
            [cell.loadingIndicator setHidden:YES];
            [cell.loadingIndicator stopAnimating];
        }
        else if (tableviewDataState == TABLEVIEW_DATA_MORE && tableviewActionState == TABLEVIEW_ACTION_NORMAL) {
            cell.loadingLabel.text = @"更多";
            [cell.loadingIndicator setHidden:YES];
            [cell.loadingIndicator stopAnimating];
        }
        else if (tableviewDataState == TABLEVIEW_DATA_LOADING && TABLEVIEW_ACTION_SCROLL == tableviewActionState) {
            cell.loadingLabel.text = @"加载中...";
            [cell.loadingIndicator setHidden:NO];
            [cell.loadingIndicator startAnimating];
        }
        else if (TABLEVIEW_DATA_NORMAL == tableviewDataState && TABLEVIEW_ACTION_INIT == tableviewActionState) {
            cell.loadingLabel.text = @"加载中...";
            [cell.loadingIndicator setHidden:NO];
            [cell.loadingIndicator startAnimating];
        }
        return cell;
    }
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
#pragma mark scrollview delegate end

#pragma mark CommunityTableViewCell delegate begin
-(void)didSelect:(Share *)share
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    
    for (MediaObj *m in share.imageArray) {
        [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:m.media_url]]];
        [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:m.media_url]]];
    }
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}
#pragma mark CommunityTableViewCell delegate end

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark sidebarviewcontroller delegate
-(void)showShareType:(NSString *)type name:(NSString *)name
{
//    SomeTypeViewController *vc = [[SomeTypeViewController alloc] init];
//    vc.shareTitle = name;
//    vc.shareType = type;
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
    if ([type isEqualToString:@"1"]) {
        type = @"0";
    }
    tableviewDataState = TABLEVIEW_DATA_LOADING;
    [self.shareTableView setFooterHidden:YES];
    shareType = type;
    [shares removeAllObjects];
    [self.shareTableView reloadData];
    [self getShareListFromCacheByFid:shareType];
    [self.shareTableView headerBeginRefreshing];
    
    titleLabel.text = name;
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    return banners.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index
{
    Banner *ban = banners[index];
    [imageView sd_setImageWithURL:[NSURL URLWithString:ban.url]
                 placeholderImage:nil
                          options:SDWebImageRetryFailed ];
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index
{
    Banner *ban = banners[index];
    CommunityDetailViewController *vc = [[CommunityDetailViewController alloc] init];
    vc.currentShare = nil;
    vc.threadId = ban.tid;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (IBAction)signName:(id)sender {
    self.signButton.hidden = YES;
    [SVProgressHUD show];
    [[APIClient sharedInstance] signInSuccess:^(int errorCode, id model) {
        [SVProgressHUD dismiss];
        if (errorCode == 1) {

        }
        else {
            self.signButton.hidden = NO;
        }
    } failure:^(NSString *message) {
        [SVProgressHUD dismiss];
        self.signButton.hidden = NO;
    }];
}

-(void)addcredits:(NSNotification *)notification
{
    [self performSelector:@selector(presentCredit:) withObject:notification.object afterDelay:0.5];
}

-(void)presentCredit:(NSString *)credit
{
    CreditViewController *vc = [CreditViewController new];
    vc.transitioningDelegate = self;
    vc.credits = credit;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:vc
                                            animated:YES
                                          completion:NULL];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}

#pragma mark banner
-(void)getBannerFromCache
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:BannerCache]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        BannerList *blist = [BannerList parseJson:dic];
        [self handleBan:blist];
    }
    [self getBanner];
}

-(void)getBanner
{
    [[APIClient sharedInstance] getBannersuccess:^(int errorCode, id model) {
        if (errorCode == 1) {
            [self handleBan:model];
        }
    } failure:^(NSString *message) {
        
    }];
}

-(void)initAdView
{
    self.adsView.width = screenframe.size.width;
    self.adsView.height = 332.0*screenframe.size.width/640;
    self.shareTableView.tableHeaderView = self.adsView;
    
    self.adsView.imagePlayerViewDelegate = self;
    self.adsView.scrollInterval = 5.0f;
    self.adsView.autoScroll = YES;
    self.adsView.pageControlPosition = ICPageControlPosition_BottomCenter;
    self.adsView.hidePageControl = NO;
}

-(void)handleBan:(BannerList *)data
{
    [banners removeAllObjects];
    [banners addObject:[data.list lastObject]];
    [banners addObjectsFromArray:data.list];
    [banners addObject:data.list[0]];
    [self.adsView reloadData];
}
@end
