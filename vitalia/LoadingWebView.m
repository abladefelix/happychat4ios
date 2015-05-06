//
//  LoadingWebView.m
//  vitalia
//
//  Created by Donal on 15/4/1.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "LoadingWebView.h"

@implementation LoadingWebView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = screenframe.size.width;
        self.height = screenframe.size.height;
        self.left = 0;
        self.top = 0;
        self.backgroundColor = [UIColor whiteColor];
        self.loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenframe.size.width-150)/2.0, 176.0/568*screenframe.size.height, 150, 150)];
        self.loadingImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.loadingImageView.animationImages = [NSArray arrayWithObjects:
                                                 [UIImage imageNamed:@"loading_web_1.png"],
                                                 [UIImage imageNamed:@"loading_web_2.png"],
                                                 [UIImage imageNamed:@"loading_web_3.png"],
                                                 [UIImage imageNamed:@"loading_web_4.png"],
                                                 [UIImage imageNamed:@"loading_web_5.png"],
                                                 [UIImage imageNamed:@"loading_web_6.png"],
                                                 [UIImage imageNamed:@"loading_web_7.png"],
                                                 [UIImage imageNamed:@"loading_web_8.png"],
                                                 [UIImage imageNamed:@"loading_web_9.png"],
                                                 [UIImage imageNamed:@"loading_web_10.png"],
                                                 [UIImage imageNamed:@"loading_web_11.png"],
                                                 [UIImage imageNamed:@"loading_web_12.png"],nil];
        [self.loadingImageView setAnimationDuration:1.5f];
        [self.loadingImageView setAnimationRepeatCount:0];
        [self addSubview:self.loadingImageView];
        
        self.reloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenframe.size.width, screenframe.size.height)];
        self.reloadImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.reloadImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.reloadImageView setImage:[UIImage imageNamed:@"web_reload"]];
        self.reloadImageView.hidden = YES;
        [self addSubview:self.reloadImageView];
        self.reloadImageView.userInteractionEnabled = YES;
        [self.reloadImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadThat)]];
    }
    return self;
}

-(void)reloadThat
{
    if (self.delegate) {
        [self.delegate reloadWeb];
    }
}


@end
