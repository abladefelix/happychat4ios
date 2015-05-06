//
//  CreditView.m
//  vitalia
//
//  Created by Donal on 15/3/18.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "CreditView.h"

@interface CreditView()
{
    UIView *_allView;
    UIImageView *_gbImageView;
    UILabel *_creditLabel;
}

@end

@implementation CreditView

+ (instancetype)shared
{
    static dispatch_once_t once = 0;
    static CreditView *alert;
    dispatch_once(&once, ^{
        alert = [[CreditView alloc] init];
    });
    return alert;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = (CGRect) {{0.f,0.f}, [[UIScreen mainScreen] bounds].size};
        self.alpha = 1;
        [self setBackgroundColor:[UIColor clearColor]];
        self.hidden = YES;//不隐藏
        self.windowLevel = 100;
        
        [self setInterFace];
    }
    
    return self;
}

- (void)setInterFace
{
    [self initView];
    [self controlsInit];
}

- (void)initView
{
    //移除画布
    [_allView removeFromSuperview];
    _allView = nil;
    //新建画布
    _allView                     = [UIView new];
    _allView.center              = CGPointMake(self.center.x, self.center.y);
    _allView.bounds              = CGRectMake(0, 0, screenframe.size.width, screenframe.size.height);
    _allView.backgroundColor     = [UIColor blackColor];
    _allView.alpha = 0.7;
    [self addSubview:_allView];
}

- (void)controlsInit
{
    _gbImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenframe.size.width-317+8)/2.0, 176.0/568*screenframe.size.height, 311, 257)];
    [_gbImageView setImage:[UIImage imageNamed:@"credit_bg"]];
    [self addSubview:_gbImageView];
}

-(void)showCreate
{
    self.hidden = NO;
}


@end
