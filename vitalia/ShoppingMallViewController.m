//
//  ShoppingMallViewController.m
//  vitalia
//
//  Created by Donal on 15/3/26.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ShoppingMallViewController.h"
#import "ScannerViewController.h"
#import "MJRefresh.h"
#import "ProductViewController.h"

@interface ShoppingMallViewController () <ScannerViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *mallHeadView;
@property (weak, nonatomic) IBOutlet UITableView *mallTableView;
@property (weak, nonatomic) IBOutlet UIWebView *mallWebView;
@end

@implementation ShoppingMallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBar];
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"商城";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStyleDone target:self action:@selector(scan)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.mallHeadView.height = screenframe.size.height-64-49;
    self.mallTableView.tableHeaderView = self.mallHeadView;
    [self.mallTableView addHeaderWithTarget:self action:@selector(loadWebview)];
    [self.mallTableView headerBeginRefreshing];
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

-(void)loadWebview
{
    NSString *urlString = GYMallURL;
    self.mallWebView.delegate = self;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.mallWebView loadRequest:request];
}

-(void)scan
{
    ScannerViewController *vc = [[ScannerViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ScannerViewController delegate
-(void)getResultFromScan:(NSString *)result
{
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark webview delegate begin
-(void)webViewDidStartLoad:(UIWebView *)webView
{
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.mallTableView headerEndRefreshing];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用长按弹出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@"*"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"vitalia:app"]) {
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"loadProduct"])
        {
            debugLog(@"%@", [components objectAtIndex:2]);
            [self enterProduct:[components objectAtIndex:2]];
        }
        return NO;
    }
    return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    debugLog(@"%@", error.description);
    [self.mallTableView headerEndRefreshing];
}

#pragma mark webview delegate end

-(void)enterProduct:(NSString *)url
{
    ProductViewController *vc = [[ProductViewController alloc] init];
    vc.url = url;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
