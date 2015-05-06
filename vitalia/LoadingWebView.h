//
//  LoadingWebView.h
//  vitalia
//
//  Created by Donal on 15/4/1.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingWebViewDelegate <NSObject>

-(void)reloadWeb;

@end

@interface LoadingWebView : UIView

@property (strong, nonatomic) UIImageView *loadingImageView;
@property (strong, nonatomic) UIImageView *reloadImageView;

@property (assign, nonatomic) id<LoadingWebViewDelegate> delegate;
@end
