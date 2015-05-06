//
//  DraftViewController.m
//  vitalia
//
//  Created by Donal on 15/3/12.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "DraftViewController.h"
#import "SuperDB.h"
#import "PubViewController.h"
#import "DraftTableViewCell.h"

@interface DraftViewController () <UITableViewDataSource, UITableViewDelegate, PubViewControllerDelegate>
{
    NSMutableArray *drafts;
}
@end

@implementation DraftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    drafts = [NSMutableArray array];
    [drafts addObjectsFromArray:[SuperDB getUnPubDraft]];
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.draftTableView.tableFooterView = footview;
    [self.draftTableView registerNib:[UINib nibWithNibName:@"DraftTableViewCell" bundle:nil] forCellReuseIdentifier:@"DraftCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUploadProgress:) name:@"UploadShareProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUploadSuccess:) name:@"UploadShareSuccess" object:nil];
    [self initBar];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"草稿箱";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadShareProgress" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadShareSuccess" object:nil];
}

- (void)didReceiveUploadProgress:(NSNotification *)notification
{
    NSString *progress = notification.object;
    NSDictionary *draft = notification.userInfo;
    for (NSDictionary *m in drafts) {
        if ([[m objectForKey:@"draftid"] isEqualToString:[draft objectForKey:@"draftid"]]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:[drafts indexOfObject:m] inSection:0];
            DraftTableViewCell *cell = (DraftTableViewCell *)[self.draftTableView cellForRowAtIndexPath:path];
            cell.progressLabel.text = progress;
            break;
        }
    }
}

- (void)didReceiveUploadSuccess:(NSNotification *)notification
{
    NSDictionary *draft = notification.userInfo;
    for (NSDictionary *m in drafts) {
        if ([[m objectForKey:@"draftid"] isEqualToString:[draft objectForKey:@"draftid"]]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:[drafts indexOfObject:m] inSection:0];
            DraftTableViewCell *cell = (DraftTableViewCell *)[self.draftTableView cellForRowAtIndexPath:path];
            cell.progressLabel.text = @"发送成功";
            [self performSelector:@selector(removeSuccessDraft:) withObject:path afterDelay:0.1];
            break;
        }
    }
}

-(void)removeSuccessDraft:(NSIndexPath *)path
{
    [drafts removeObjectAtIndex:path.row];
    [self.draftTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationLeft];
    [self.draftTableView reloadData];

}

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return drafts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    CellIdentifier        = @"DraftCell";
    DraftTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *draft = drafts[indexPath.row];
    cell1.titleLabel.text = [NSString stringWithFormat:@"帖子 %@", [draft objectForKey:@"title"]];
    cell1.contentLabel.text = [draft objectForKey:@"content"];
    cell1.timeLabel.text = [Tool phplong2Data:[draft objectForKey:@"time"]];
    return cell1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *draft = drafts[indexPath.row];
    PubViewController *vc = [[PubViewController alloc] init];
    vc.draft = draft;
    vc.operation = OPRATION_EDIT;
    vc.type = [[draft objectForKey:@"is_comment"] intValue];
    vc.commentId = [draft objectForKey:@"commentid"];
    vc.tid = [draft objectForKey:@"tid"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark PubViewController Delegate
-(void)editDraftSuccess
{
    [drafts removeAllObjects];
    [drafts addObjectsFromArray:[SuperDB getUnPubDraft]];
    [self.draftTableView reloadData];
}

@end
