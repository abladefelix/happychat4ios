/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "FacialView.h"
#import "Emoji.h"

@interface FacialView () <UIScrollViewDelegate>

@end

@implementation FacialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _faces = [Emoji allEmoji];
    }
    return self;
}


//给faces设置位置
-(void)loadFacialView:(int)page size:(CGSize)size
{
    
    CGFloat faceHeight = self.frame.size.height-10;
    int maxRow = 4;
    int maxCol = 7;
    int maxPage = ceil(_faces.count * 1.0 / (maxCol * maxRow));
    CGFloat itemWidth = self.frame.size.width / maxCol;
    CGFloat itemHeight = faceHeight / (maxRow+1);
    
    faceHeight = itemHeight * maxRow;
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setBackgroundColor:[UIColor clearColor]];
    [deleteButton setFrame:CGRectMake((maxCol - 1) * itemWidth, (maxRow ) * itemHeight, itemWidth, itemHeight)];
    [deleteButton setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
    deleteButton.tag = 10000;
    [deleteButton addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    
//    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sendButton setTitle:NSLocalizedString(@"send", @"Send") forState:UIControlStateNormal];
//    [sendButton setFrame:CGRectMake((maxCol - 2) * itemWidth - 10, (maxRow - 1) * itemHeight + 5, itemWidth + 10, itemHeight - 10)];
//    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
//    [sendButton setBackgroundColor:[UIColor colorWithRed:10 / 255.0 green:82 / 255.0 blue:104 / 255.0 alpha:1.0]];
//    [self addSubview:sendButton];
    self.faceScroolView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, screenframe.size.width, faceHeight)];
    [self.faceScroolView setShowsHorizontalScrollIndicator:NO];
    self.faceScroolView.delegate = self;
    [self addSubview:self.faceScroolView];
    self.faceScroolView.scrollEnabled = YES;
    self.faceScroolView.pagingEnabled = YES;
    [self.faceScroolView setContentSize:CGSizeMake(screenframe.size.width*maxPage, faceHeight)];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((screenframe.size.width-100)/2, 0, 100, 10)];
    [self.pageControl setNumberOfPages:maxPage];
    [self addSubview:self.pageControl];
    [self bringSubviewToFront:deleteButton];
    
    for (int cpage = 0; cpage < maxPage; cpage++) {
        for (int row = 0; row < maxRow; row++) {
            for (int col = 0; col < maxCol; col++) {
                int index = row * maxCol + col + (cpage)*maxRow*maxCol;
                if (index < [_faces count]) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundColor:[UIColor clearColor]];
                    [button setFrame:CGRectMake(col * itemWidth+(screenframe.size.width*cpage), row * itemHeight, itemWidth, itemHeight)];
                    [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                    [button setTitle: [_faces objectAtIndex:index] forState:UIControlStateNormal];
                    button.tag = index;
                    [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                    [self.faceScroolView addSubview:button];
                }
                else{
                    break;
                }
            }
        }
    }
}


-(void)selected:(UIButton*)bt
{
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    }else{
        NSString *str = [_faces objectAtIndex:bt.tag];
        if (_delegate) {
            [_delegate selectedFacialView:str];
        }
    }
}

- (void)sendAction:(id)sender
{
    if (_delegate) {
        [_delegate sendFace];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pagewidth = self.faceScroolView.frame.size.width;
    int currentPage = floor((self.faceScroolView.contentOffset.x - pagewidth/ 3) / pagewidth) + 1;
    [self.pageControl setCurrentPage:currentPage];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    CGFloat pagewidth = self.faceScroolView.frame.size.width;
    int currentPage = floor((self.faceScroolView.contentOffset.x - pagewidth/ 3) / pagewidth) + 1;
    [self.pageControl setCurrentPage:currentPage];
}

@end
