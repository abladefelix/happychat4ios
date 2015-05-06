//
//  CreditViewController.m
//  vitalia
//
//  Created by Donal on 15/4/2.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CreditViewController.h"

@interface CreditViewController ()
{
    UIView *_allView;
}
@property (weak, nonatomic) IBOutlet UILabel *creditLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@end

@implementation CreditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _allView = nil;
//    //新建画布
//    _allView                     = [UIView new];
//    _allView.frame              = CGRectMake(0, 0, screenframe.size.width, screenframe.size.height);
//    _allView.backgroundColor     = [UIColor blackColor];
//    _allView.alpha = 0.4;
//    [self.view addSubview:_allView];s
    self.creditLabel.text = [NSString stringWithFormat:@"+%@",self.credits];
        [self performSelector:@selector(dismissBySelf) withObject:nil afterDelay:3];
    [self.bgImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBySelf)]];
}

- (void)dismissBySelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
