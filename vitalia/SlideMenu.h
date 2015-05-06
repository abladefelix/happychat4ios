//
//  SlideMenu.h
//  vitalia
//
//  Created by Donal on 15/3/5.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlideMenuDelegate <NSObject>

-(void)clickToGetShareType:(int)type;
-(void)clickToDismiss;

@end

@interface SlideMenu : UIView

- (id)initWithNib;

@property (strong, nonatomic) IBOutlet UIView *bView;

@property (strong, nonatomic) IBOutlet UIButton *allButton;

@property (strong, nonatomic) IBOutlet UIButton *foodButton;

@property (strong, nonatomic) IBOutlet UIButton *homeButton;

@property (strong, nonatomic) IBOutlet UIButton *wineButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UIButton *studentButton;
@property (strong, nonatomic) IBOutlet UIButton *makeupButton;
@property (strong, nonatomic) IBOutlet UIButton *tripButton;

@property (strong, nonatomic) IBOutlet UIButton *dressButton;

@property (strong, nonatomic) IBOutlet UIButton *moodButton;

@property (strong, nonatomic) IBOutlet UIButton *toolButton;


@property (strong, nonatomic) IBOutlet UIButton *brandButton;


@property (strong, nonatomic) IBOutlet UIButton *vitaliaButton;


@property (assign, nonatomic) id<SlideMenuDelegate> delegate;
@end
