//
//  SidebarViewController.m
//  LLBlurSidebar
//
//  Created by Lugede on 14/11/20.
//  Copyright (c) 2014年 lugede.cn. All rights reserved.
//

#import "SidebarViewController.h"
#import "SlideMenu.h"
#import "SideMenuTableViewCell.h"

@interface SidebarViewController ()<UITableViewDelegate, UITableViewDataSource>

{
    SlideMenu *slideMenu;
    NSMutableArray *types;
    NSInteger lastIndexPath;
}
@property (nonatomic, retain) UITableView* menuTableView;

@end

@implementation SidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    types = [NSMutableArray array];
    lastIndexPath = 0;
    // Do any additional setup after loading the view from its nib.
    self.contentView.width = 227.0/320*screenframe.size.width;
    // 列表
    self.menuTableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    [self.menuTableView registerNib:[UINib nibWithNibName:@"SideMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"MenuCell"];
    [self.menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.menuTableView.backgroundColor = [UIColor clearColor];
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    [self.menuTableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [self.contentView addSubview:self.menuTableView];
    UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToPresentSlideMenu:)];
    [swipeGesture delaysTouchesBegan];
    [self.view addGestureRecognizer:swipeGesture];
    
    [self getShareTypeFromCache];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getShareTypeFromCache) name:ShareTypeCache object:nil];
}

-(void)getShareTypeFromCache
{
    [self initType];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[Tool returnDataFilePath:ShareTypeCache]];
    if(data) {
        id dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([[dic objectForKey:@"result"] intValue] == 1) {
            [types removeAllObjects];
            [types addObjectsFromArray:[dic objectForKey:@"data"]];
            [self.menuTableView reloadData];
        }
    }
}

-(void)initType
{
    [types removeAllObjects];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"至坚推荐", @"name", nil];
    [types addObject:dic];
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"50", @"id", @"意大利起泡酒", @"name", nil];
    [types addObject:dic];
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"36", @"id", @"传播坚嘢", @"name", nil];
    [types addObject:dic];
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"37", @"id", @"流嘢横行", @"name", nil];
    [types addObject:dic];
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"38", @"id", @"意国风情", @"name", nil];
    [types addObject:dic];
    [self.menuTableView reloadData];
}

#pragma mark UIPanGestureRecognizer
-(void)swipeToPresentSlideMenu:(UIPanGestureRecognizer *)recognizer
{
    //    [self.delegate swipeRight:recognizer];
    [self panDetected:recognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return types.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sidebarMenuCellIdentifier = @"MenuCell";
    SideMenuTableViewCell *cell = (SideMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:sidebarMenuCellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *t = types[indexPath.row];
    cell.typeLabel.textColor = [UIColor whiteColor];
    cell.typeLabel.text = [t objectForKey:@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == lastIndexPath) {
        cell.typeLabel.highlighted = YES;
        cell.typeImageView.highlighted = YES;
        cell.selectedImageView.highlighted = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *t = types[indexPath.row];
    [self.delegate showShareType:[t objectForKey:@"id"] name:[t objectForKey:@"name"]];
    [self showHideSidebar];
    lastIndexPath = indexPath.row;
    [self.menuTableView reloadData];
    
}

@end
