//
//  CommunityDetailViewController.m
//  vitalia
//
//  Created by Donal on 15/3/24.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CommunityDetailViewController.h"
#import "POP/POP.h"
#import "PubViewController.h"
#import "LoginViewController.h"
#import "LoadingWebView.h"
#import "SomeoneProfileViewController.h"
#import "MoreViewController.h"
#import "POP/POP.h"
#import "PresentingMoreAnimator.h"
#import "DismissingMoreAnimator.h"

@interface CommunityDetailViewController () <UIWebViewDelegate, POPAnimationDelegate, LoginViewControllerDelegate, MWPhotoBrowserDelegate, UIViewControllerTransitioningDelegate, LoadingWebViewDelegate, MoreViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *shareWebView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) LoadingWebView *loadingView;

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) NSString *shareUrl;

@end

@implementation CommunityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getshareBytid];
    [self loadWebview];
    [self.likeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeOrDislike)]];
    [self.replyButton.layer setBorderWidth:1];
    [self.replyButton.layer setBorderColor:UIColorFromRGB(0xd2d2d2, 1.0).CGColor];
    [self.replyButton.layer setCornerRadius:3];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPost:) name:@"CommentSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PostFailure:) name:@"CommentFailure" object:nil];
    self.loadingView = [[LoadingWebView alloc] init];
    self.loadingView.delegate = self;
    [self.view addSubview:self.loadingView];
    self.loadingView.hidden = YES;
    [self initBar];
}

-(void)initBar
{
//    titleLabel                             = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//    titleLabel.text                        = @"意大利原生活";
//    titleLabel.textAlignment               = NSTextAlignmentCenter;
//    titleLabel.backgroundColor             = [UIColor clearColor];
//    self.navigationItem.titleView          = titleLabel;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStyleDone target:self action:@selector(showMore)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CommentSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CommentFailure" object:nil];
}

-(void)showPost:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    debugLog(@"%@", dic);
    [self.shareWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadComment({pid:%@});", [dic objectForKey:@"pid"]]];
}

-(void)PostFailure:(NSNotification *)notification
{
    [SVProgressHUD showErrorWithStatus:notification.object];
}

-(void)getshareBytid
{
    [[APIClient sharedInstance] getShareByTid:self.threadId
                                      Success:^(int errorCode, id model) {
                                          if (errorCode == 1) {
                                              self.currentShare = model;
                                              [self initLikeView];
                                          }
                                      }
                                      failure:^(NSString *message) {
                                          
                                      }];
}

-(void)loadWebview
{
    self.shareUrl = [NSString stringWithFormat:@"%@&tid=%@", GYShareDetailURL, self.threadId];
    NSString *urlString = [NSString stringWithFormat:@"%@&tid=%@&platform=app&remote_cook=1", GYShareDetailURL, self.threadId];
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cook in cookies) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&c_a[%@]=%@", cook.name, cook.value]];
    }
    debugLog(@"%@", urlString);
    self.shareWebView.delegate = self;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.shareWebView loadRequest:request];
}

#pragma mark webview delegate begin
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingView.hidden = NO;
    [self.loadingView.loadingImageView startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingView.loadingImageView stopAnimating];
    self.loadingView.hidden = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@"*"];
    debugLog(@"%@", requestString);
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"vitalia:app"]) {
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"showImage"])
        {
            debugLog(@"%@", [components objectAtIndex:2]);
            [self didSelect:[components objectAtIndex:2]];
        }
        else if([(NSString *)[components objectAtIndex:1] isEqualToString:@"showReplyImage"])
        {
            [self didSelect:[components objectAtIndex:2]];
            debugLog(@"%@", [components objectAtIndex:2]);
        }
        else if([(NSString *)[components objectAtIndex:1] isEqualToString:@"replyPost"])
        {
            debugLog(@"%@", [components objectAtIndex:2]);
            [self replyPost:[components objectAtIndex:2]];
        }
        else if([(NSString *)[components objectAtIndex:1] isEqualToString:@"buyProduct"])
        {
            debugLog(@"%@", [components objectAtIndex:2]);
        }
        else if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"viewAuthor"]) {
            debugLog(@"%@", [components objectAtIndex:2]);
            [self enterOtherProfile:[components objectAtIndex:2]];
        }
        else if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"login"]) {
            [self enterLogin];
        }
        return NO;
    }
    return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.loadingView.hidden = NO;
    [self.loadingView.loadingImageView stopAnimating];
    self.loadingView.reloadImageView.hidden = NO;
}

#pragma mark webview delegate end

#pragma mark 点赞
-(void)initLikeView
{
    if (self.currentShare.is_saygood) {
        self.likeButton.selected = YES;
    }
    else {
        self.likeButton.selected = NO;
    }
    if ([self.currentShare.saygood intValue] == 0) {
        self.likeLabel.text = @"点赞";
    }
    else {
        self.likeLabel.text = self.currentShare.saygood;
    }
}

- (void)likeOrDislike{
    if (!isUserLogin) {
        [self enterLogin];
        return;
    }
    
    if (self.currentShare.is_saygood) {
        [self dislikeShare];
    }
    else {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(30.f, 30.f)];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        scaleAnimation.springBounciness = 18.0f;
        [self.likeButton.layer pop_addAnimation:scaleAnimation forKey:@"changesize"];
        [self likeShare];
    }
}

-(void)likeShare
{
    self.currentShare.is_saygood = YES;
    self.likeButton.selected = YES;
    self.currentShare.saygood = [NSString stringWithFormat:@"%i", ([self.currentShare.saygood intValue]+1)];
    [self initLikeView];
    [[APIClient sharedInstance] likeShareid:self.threadId
                                    Success:^(int errorCode, id model) {
        
                                    }
                                    failure:^(NSString *message) {
                                        self.currentShare.is_saygood = NO;
                                        self.likeButton.selected = NO;
                                        self.currentShare.saygood = [NSString stringWithFormat:@"%i", ([self.currentShare.saygood intValue]-1)];
                                        [self initLikeView];
                                    }];
}

-(void)dislikeShare
{
    self.currentShare.is_saygood = NO;
    self.likeButton.selected = NO;
    self.currentShare.saygood = [NSString stringWithFormat:@"%i", ([self.currentShare.saygood intValue]-1)];
    [self initLikeView];
    [[APIClient sharedInstance] dislikeShareid:self.threadId
                                       Success:^(int errorCode, id model) {
        
                                       }
                                       failure:^(NSString *message) {
                                           self.currentShare.is_saygood = YES;
                                           self.likeButton.selected = YES;
                                           self.currentShare.saygood = [NSString stringWithFormat:@"%i", ([self.currentShare.saygood intValue]+1)];
                                           [self initLikeView];
                                       }];
}

- (IBAction)replyShare:(id)sender {
    if(!isUserLogin ) {
        [self enterLogin];
        return;
    }
    PubViewController *vc = [[PubViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.operation = OPRATION_NEW;
    vc.type = TYPE_COMMENT;
    vc.tid = self.threadId;
    vc.commentId = @"";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)replyPost:(NSString *)pid
{
    if (!isUserLogin) {
        [self enterLogin];
        return;
    }
    PubViewController *vc = [[PubViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.operation = OPRATION_NEW;
    vc.type = TYPE_COMMENT;
    vc.tid = self.threadId;
    vc.commentId = pid;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterLogin
{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterOtherProfile:(NSString *)uid
{
    SomeoneProfileViewController *vc = [[SomeoneProfileViewController alloc] init];
    vc.uid = uid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark login delegate
-(void)loginByAccountSuccess:(User *)user
{
    [self loadWebview];
}

#pragma mark mwphoto  begin
-(void)didSelect:(NSString *)url
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
    self.photos = photos;
//    self.thumbs = thumbs;
    
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
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}
//
//- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
//    if (index < _thumbs.count)
//        return [_thumbs objectAtIndex:index];
//    return nil;
//}
//
////- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
////    MWPhoto *photo = [self.photos objectAtIndex:index];
////    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
////    return [captionView autorelease];
////}
//
////- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
////    NSLog(@"ACTION!");
////}
//
//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
//}
//
//- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
//    return [[_selections objectAtIndex:index] boolValue];
//}
//
////- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
////    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
////}
//
//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
//    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
//    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
//}
//
//- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
//    // If we subscribe to this method we must dismiss the view controller ourselves
//    NSLog(@"Did finish modal presentation");
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark more
-(void)showMore
{
    MoreViewController *vc = [MoreViewController new];
    vc.delegate = self;
    vc.transitioningDelegate = self;
    vc.url = self.shareUrl;
    vc.urlTitle = self.currentShare.subject;
    if (self.currentShare.imageArray.count != 0) {
        MediaObj *s = self.currentShare.imageArray[0];
        vc.imageUrl = s.media_url;
    }
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
    return [PresentingMoreAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingMoreAnimator new];
}

#pragma mark - Private Instance methods

#pragma mark reload web
-(void)reloadWeb
{
    debugLog(@"aa");
    self.loadingView.reloadImageView.hidden = YES;
    [self.loadingView.loadingImageView startAnimating];
    [self.shareWebView reload];
}

#pragma mark more delegate
-(void)favourit
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!isUserLogin) {
        [self enterLogin];
        return;
    }
    [SVProgressHUD show];
    [[APIClient sharedInstance] favouriteShareid:self.currentShare.tid
                                         Success:^(int errorCode, id model) {
                                             [SVProgressHUD showSuccessWithStatus:@"已收藏"];
                                         }
                                         failure:^(NSString *message) {
                                             [SVProgressHUD dismiss];
                                         }];
}

@end
