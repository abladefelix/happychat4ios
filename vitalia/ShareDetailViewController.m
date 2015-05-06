//
//  ShareDetailViewController.m
//  vitalia
//
//  Created by Donal on 15/3/4.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ShareDetailViewController.h"
#import "DetailWebViewTableViewCell.h"
#import "DetailHeaderTableViewCell.h"
#import "CommentViewController.h"

@interface ShareDetailViewController() <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UITextViewDelegate>
{
    float webviwHeight;
    int titleHeight;
    int toolbarTop;
    int defaultTableViewHeight;
}
@property (weak, nonatomic) IBOutlet UITextView *cmtTextView;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnEnterComment;
@end

@implementation ShareDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
//    titleHeight = [Tool getViewMinHeightWithUIFont:[UIFont systemFontOfSize:16] andText:self.currentShare.share_title andFixedWidth:screenframe.size.width-20 minHeight:21];
//    [self initTableView];
//    [self performSelector:@selector(loadWebview)
//               withObject:nil
//               afterDelay:0.1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)initTableView
{
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
    [self.detailTableView registerNib:[UINib nibWithNibName:@"DetailWebViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"WebCell"];
//    [self.detailTableView registerNib:[UINib nibWithNibName:@"DetailHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"HeaderCell"];
    [self.cmtTextView.layer setBorderColor:UIColorFromRGB(0xcccccc, 1.0).CGColor];
    [self.cmtTextView.layer setBorderWidth:1];
    [self.toolbarView.layer setBorderColor:UIColorFromRGB(0xd9d9d9, 1.0).CGColor];
    [self.toolbarView.layer setBorderWidth:1];
    self.cmtTextView.delegate = self;
    self.cmtTextView.scrollsToTop = NO;
    defaultTableViewHeight = self.detailTableView.height;
}

- (IBAction)enterCommentViewController:(id)sender {
    CommentViewController *vc = [[CommentViewController alloc] init];
    vc.currentShare = self.currentShare;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark loadwebview
-(void)loadWebview
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
    DetailWebViewTableViewCell *cell = (DetailWebViewTableViewCell *)[self.detailTableView cellForRowAtIndexPath:index];
    cell.detailWebView.delegate = self;
    [cell.detailWebView.scrollView setScrollEnabled:NO];
    [cell.detailWebView.scrollView setBounces:NO];
    cell.detailWebView.scrollView.scrollsToTop = NO;
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?share_id=%@&platform=app", GYSHAREURL, self.currentShare.share_id]];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//    [cell.detailWebView loadRequest:request];
}

#pragma mark listen keyboard
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary*info=[notification userInfo];
    CGSize kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    //在这里调整UI位置
    [self adjustToolbarViewByKeyboard:kbSize.height];
    self.btnEnterComment.hidden = YES;
}

-(void)keyboardWillHide:(NSNotification*)notification{
    self.toolbarView.bottom = screenframe.size.height;
    self.toolbarView.height = 43;
    self.toolbarView.top = self.toolbarView.bottom - self.toolbarView.height;
    self.cmtTextView.height = 30;
    [self setTableViewInsetsWithBottomValue:defaultTableViewHeight
     - self.toolbarView.frame.origin.y];
}

-(void)adjustToolbarViewByKeyboard:(float)height
{
    self.toolbarView.bottom = screenframe.size.height - height;
    toolbarTop = self.toolbarView.bottom - self.toolbarView.height;
    self.cmtTextView.width = screenframe.size.width - 20;
    [self setTableViewInsetsWithBottomValue:defaultTableViewHeight
     - self.toolbarView.frame.origin.y];
}

-(void)adjustToolbarViewByTextView:(UITextView *)textView
{
    int height = [Tool getViewMinHeightWithUIFont:[UIFont systemFontOfSize:16] andText:textView.text andFixedWidth:screenframe.size.width-20 minHeight:30]+10;
    if (height < 140) {
        int relativeHeight = height - 30;
        self.toolbarView.height = 43 + relativeHeight;
        self.cmtTextView.height = 30 + relativeHeight;
        self.toolbarView.top = toolbarTop - relativeHeight;
        self.toolbarView.bottom = self.toolbarView.top + self.toolbarView.height;
        [UIView commitAnimations];
        [self setTableViewInsetsWithBottomValue:defaultTableViewHeight
         - self.toolbarView.frame.origin.y];
    }
}

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.detailTableView.contentInset = insets;
    self.detailTableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    
    insets.bottom = bottom;
    
    return insets;
}

#pragma mark textview delegate begin
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.cmtTextView.text = @"";
    self.cmtTextView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(self.cmtTextView.text.length == 0){
        self.cmtTextView.textColor = [UIColor lightGrayColor];
        self.cmtTextView.text = @"";
        return;
    }
    [self adjustToolbarViewByTextView:textView];
//    NSRange myRange=NSMakeRange(self.cmtTextView.text.length, 0);
//    [self.cmtTextView scrollRangeToVisible:myRange];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.toolbarView.bottom = screenframe.size.height;
    self.toolbarView.height = 43;
    //    self.toolbarView.top = self.toolbarView.bottom - self.toolbarView.height;
    self.cmtTextView.height = 30;
    self.btnEnterComment.hidden = NO;
    self.cmtTextView.width = screenframe.size.width - 70;
//    [self.cmtTextView scrollsToTop];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (([textView.text trim].length > 0)) {
            NSString *content = [textView.text trim];
            [SVProgressHUD show];
//            [[APIClient sharedInstance] addCommentTo:self.currentShare.share_id
//                                       withMediaType:@"0"
//                                         withContent:content
//                                       withMediaList:@""
//                                      withDeviceName:@"iOS客户端"
//                                  orReplayToParentId:@""
//                                             Success:^(int errorCode, id model) {
//                                                 [SVProgressHUD dismiss];
//                                                 if (errorCode == 1) {
//                                                     self.currentShare.comment_count = [NSString stringWithFormat:@"%i",([self.currentShare.comment_count intValue]+1)];
//                                                     [textView resignFirstResponder];
//                                                     textView.text = @"";
//                                                 }
//                                                 else {
//                                                     [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i", errorCode]];
//                                                 }
//                                             }
//                                             failure:^(NSString *message) {
//                                                 [SVProgressHUD showErrorWithStatus:message];
//                                             }];
        }
        return NO;
    }
    return YES;
}
#pragma mark textview delegate end

#pragma mark webview delegate begin
-(void)webViewDidStartLoad:(UIWebView *)webView
{
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    float newSize = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
    webviwHeight = newSize ;
    webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, newSize);
    [self.detailTableView reloadData];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@"*"];
        if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"vitalia:app"]) {
            if([(NSString *)[components objectAtIndex:1] isEqualToString:@"showImage"])
            {
                debugLog(@"%@", [components objectAtIndex:2]);
            }
            return NO;
        }
    return YES;
}

#pragma mark webview delegate end

#pragma mark tableview delegate begin
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0) {
//        return 58+titleHeight;
//    }
//    else {
        return webviwHeight;
//    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
//    if (indexPath.section == 0) {
//        CellIdentifier = @"HeaderCell";
//        DetailHeaderTableViewCell *cell = (DetailHeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.currentShare.avatar]
//                                placeholderImage:nil
//                                         options:SDWebImageRetryFailed|SDWebImageLowPriority];
//        cell.nicknameLabel.text = self.currentShare.user_name;
//        cell.timeLabel.text = [Tool phplong2DateNoHour:self.currentShare.share_time];
//        cell.titleLabel.text = self.currentShare.share_title;
//        cell.cmtLabel.text = self.currentShare.comment_count;
//        cell.favourLabel.text = self.currentShare.saygood_count;
//        return cell;
//    }
//    else {
        CellIdentifier = @"WebCell";
        DetailWebViewTableViewCell *cell = (DetailWebViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.detailWebView.delegate = self;
        return cell;
//    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark tableview delegate end

@end
