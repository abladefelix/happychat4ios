//
//  CommentViewController.m
//  vitalia
//
//  Created by Donal on 15/3/6.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentHeaderTableViewCell.h"
#import "CommentTableViewCell.h"
#import "CommentBaseTableViewCell.h"
#import "MJRefresh.h"

@interface CommentViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    int titleHeight;
    NSMutableArray *comments;
    int tableviewDataState;
    int tableviewActionState;
    NSString *previousCursor;
    int toolbarTop;
    int defaultTableViewHeight;
}
@property (weak, nonatomic) IBOutlet UITextView *cmtTextView;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
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
    comments = [NSMutableArray array];
//    titleHeight = [Tool getViewMinHeightWithUIFont:[UIFont systemFontOfSize:16] andText:self.currentShare.share_title andFixedWidth:screenframe.size.width-20 minHeight:21];
    self.commentTableView.delegate = self;
    self.commentTableView.dataSource = self;
    [self.commentTableView registerNib:[UINib nibWithNibName:@"CommentHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"HeaderCell"];
    [self.commentTableView registerNib:[UINib nibWithNibName:@"CommentBaseTableViewCell" bundle:nil] forCellReuseIdentifier:@"BaseCell"];
    [self.commentTableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    [self.commentTableView addHeaderWithTarget:self action:@selector(refreshShareCommentList)];
    [self.commentTableView headerBeginRefreshing];
    [self.commentTableView addFooterWithTarget:self action:@selector(loadmoreShareCommentList)];
    
    [self.cmtTextView.layer setBorderColor:UIColorFromRGB(0xcccccc, 1.0).CGColor];
    [self.cmtTextView.layer setBorderWidth:1];
    [self.toolbarView.layer setBorderColor:UIColorFromRGB(0xd9d9d9, 1.0).CGColor];
    [self.toolbarView.layer setBorderWidth:1];
    self.cmtTextView.delegate = self;
    self.cmtTextView.scrollsToTop = NO;
    
    defaultTableViewHeight = self.commentTableView.height;
}


#pragma mark listen keyboard
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary*info=[notification userInfo];
    CGSize kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    //在这里调整UI位置
    [self adjustToolbarViewByKeyboard:kbSize.height];
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

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.commentTableView.contentInset = insets;
    self.commentTableView.scrollIndicatorInsets = insets;
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
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.toolbarView.bottom = screenframe.size.height;
    self.toolbarView.height = 43;
    self.cmtTextView.height = 30;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (([textView.text trim].length > 0)) {
            if (([textView.text trim].length > 0)) {
                NSString *content = [textView.text trim];
                [SVProgressHUD show];
//                [[APIClient sharedInstance] addCommentTo:self.currentShare.share_id
//                                           withMediaType:@"0"
//                                             withContent:content
//                                           withMediaList:@""
//                                          withDeviceName:@"iOS客户端"
//                                      orReplayToParentId:@""
//                                                 Success:^(int errorCode, id model) {
//                                                     [SVProgressHUD dismiss];
//                                                     if (errorCode == 1) {
//                                                         self.currentShare.comment_count = [NSString stringWithFormat:@"%i",([self.currentShare.comment_count intValue]+1)];
//                                                         [textView resignFirstResponder];
//                                                         textView.text = @"";
//                                                         [self refreshShareCommentList];
//                                                     }
//                                                     else {
//                                                         [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i", errorCode]];
//                                                     }
//                                                 }
//                                                 failure:^(NSString *message) {
//                                                     [SVProgressHUD showErrorWithStatus:message];
//                                                 }];
            }
        }
        return NO;
    }
    return YES;
}
#pragma mark textview delegate end

#pragma mark get share comment list begin
-(void)refreshShareCommentList
{
    [self getShareCommentList:@"" orSinceId:@"" withAction:TABLEVIEW_ACTION_REFRESH];
}

-(void)loadmoreShareCommentList
{
    if (tableviewDataState == TABLEVIEW_DATA_MORE) {
        [self getShareCommentList:previousCursor orSinceId:@"" withAction:TABLEVIEW_ACTION_SCROLL];
    }
    else {
        [self.commentTableView footerEndRefreshing];
    }
}

-(void)getShareCommentList:(NSString *)maxId orSinceId:(NSString *)sinceId withAction:(int)action
{
//    [[APIClient sharedInstance] getCommentFrom:self.currentShare.share_id
//                                         maxId:maxId
//                                       sinceId:sinceId
//                                       Success:^(int errorCode, id model) {
//                                           if (errorCode == 1) {
//                                               CommentList *temp = (CommentList *)model;
//                                               [self handleData:temp action:action];
//                                           }
//                                           else {
//                                               
//                                           }
//                                       }
//                                       failure:^(NSString *message) {
//                                           [self.commentTableView headerEndRefreshing];
//                                           [self.commentTableView footerEndRefreshing];
//                                       }];
}

-(void)handleData:(CommentList *)data action:(int)action
{
    switch (action) {
        case TABLEVIEW_ACTION_INIT:
            [comments removeAllObjects];
            [comments addObjectsFromArray:data.share_comment_list];
            [self.commentTableView reloadData];
            break;
            
        case TABLEVIEW_ACTION_REFRESH:
            [self.commentTableView headerEndRefreshing];
            [comments removeAllObjects];
            [comments addObjectsFromArray:data.share_comment_list];
            [self.commentTableView reloadData];
            previousCursor =  data.previous_cursor;
            break;
        case TABLEVIEW_ACTION_SCROLL:
            [self.commentTableView footerEndRefreshing];
            [comments addObjectsFromArray:data.share_comment_list];
            [self.commentTableView reloadData];
            previousCursor =  data.previous_cursor;
            break;
        default:
            break;
    }
    if ([previousCursor isEqualToString:@"-1"]) {
        tableviewDataState = TABLEVIEW_DATA_FULL;
    }
    else {
        tableviewDataState = TABLEVIEW_DATA_MORE;
    }
    
    
}
#pragma mark get sharelist end

#pragma mark tableview delegate begin
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 1;
    }
    else {
        return comments.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 8+titleHeight;
    }
    else if (indexPath.section == 1 ) {
        return 64;
    }
    else {
        Comment *comment = comments[indexPath.row];
        return comment.cellHeight;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    if (indexPath.section == 0) {
        CellIdentifier = @"HeaderCell";
        CommentHeaderTableViewCell *cell = (CommentHeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//        cell.titleLabel.text = self.currentShare.share_title;
        cell.titleLabel.height = titleHeight;
        return cell;
    }
    else if (indexPath.section == 1) {
        CellIdentifier = @"BaseCell";
        CommentBaseTableViewCell *cell = (CommentBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//        cell.timeLabel.text = [Tool phplong2DateNoHour:self.currentShare.share_time];
//        cell.cmtLabel.text = self.currentShare.comment_count;
        return cell;
    }
    else {
        CellIdentifier = @"CommentCell";
        CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        Comment *comment = comments[indexPath.row];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.avatar]
                                placeholderImage:nil
                                         options:SDWebImageRetryFailed|SDWebImageLowPriority];
        cell.contentLabel.height = comment.contentHeight;
        cell.contentLabel.text = comment.share_comment_content;
        cell.timeLabel.text = [Tool phplong2DateNoHour:comment.share_comment_time];
        cell.nicknameLabel.text = comment.user_name;
        cell.containView.height = comment.cellHeight;
        cell.dividerView.bottom = comment.cellHeight - 1;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark tableview delegate end


@end
