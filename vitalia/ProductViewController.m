//
//  ProductViewController.m
//  vitalia
//
//  Created by Donal on 15/4/1.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "ProductViewController.h"
#import "CommunityDetailViewController.h"
#import "LoadingWebView.h"
#import "LoginViewController.h"

@interface ProductViewController () <UIWebViewDelegate, LoginViewControllerDelegate>

@property (strong, nonatomic) LoadingWebView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *productWebView;
@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingView = [[LoadingWebView alloc] init];
    [self.view addSubview:self.loadingView];
    self.loadingView.hidden = NO;
    [self loadWebview];

}

-(void)loadWebview
{
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cook in cookies) {
        self.url = [self.url stringByAppendingString:[NSString stringWithFormat:@"&c_a[%@]=%@", cook.name, cook.value]];
    }
    NSString *urlString = [self.url stringByAppendingString:@"&remote_cookie=1"];
    self.productWebView.delegate = self;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.productWebView loadRequest:request];
}

#pragma mark webview delegate begin
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingView.hidden = NO;
    [self.loadingView.loadingImageView startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
//    
//    // 禁用长按弹出框
//    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    self.loadingView.hidden = YES;
    [self.loadingView.loadingImageView stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@"*"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"vitalia:app"]) {
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"loadProductForum"])
        {
            debugLog(@"%@", [components objectAtIndex:2]);
            [self enterCommunity:[components objectAtIndex:2]];
        }
        else if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"loadLoginPage"]) {
            [self enterLogin];
        }
        return NO;
    }
    return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    debugLog(@"%@", error.description);
    self.loadingView.hidden = YES;
    [self.loadingView.loadingImageView stopAnimating];
}

#pragma mark webview delegate end

-(void)enterCommunity:(NSString *)tid
{
    CommunityDetailViewController *vc = [[CommunityDetailViewController alloc] init];
    vc.threadId = tid;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterLogin
{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark login delegate
-(void)loginByAccountSuccess:(User *)user
{
    [self loadWebview];
}
@end
