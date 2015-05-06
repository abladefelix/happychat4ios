//
//  SlideMenu.m
//  vitalia
//
//  Created by Donal on 15/3/5.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "SlideMenu.h"

@implementation SlideMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithNib
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SlideMenu" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        [self bringSubviewToFront:self.bView];
        self.height = screenframe.size.height;
        [self.allButton setSelected:YES];
        [self.allButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.foodButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.homeButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.wineButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.studentButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.makeupButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.tripButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.dressButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.moodButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.toolButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.brandButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        [self.vitaliaButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateHighlighted];
        
        [self.allButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.foodButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.homeButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.wineButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.studentButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.makeupButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.tripButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.dressButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.moodButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.toolButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.brandButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        [self.vitaliaButton setTitleColor:UIColorFromRGB(0xffd322, 1.0) forState:UIControlStateSelected];
        
        [self.allButton addTarget:self action:@selector(clickAllShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.foodButton addTarget:self action:@selector(clickFoodShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.homeButton addTarget:self action:@selector(clickHomeShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.wineButton addTarget:self action:@selector(clickWineShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.studentButton addTarget:self action:@selector(clickStudentShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.makeupButton addTarget:self action:@selector(clickMakeupShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.tripButton addTarget:self action:@selector(clickTripShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.dressButton addTarget:self action:@selector(clickDressShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.moodButton addTarget:self action:@selector(clickMoodShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolButton addTarget:self action:@selector(clickToolShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.brandButton addTarget:self action:@selector(clickBrandShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.vitaliaButton addTarget:self action:@selector(clickVitaliaShare:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.backButton addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clickAllShare:(id)sender {
    [self setButtonHighted:0];
}
- (void)clickFoodShare:(id)sender {
    [self setButtonHighted:1];
    
}
- (void)clickHomeShare:(id)sender {
    [self setButtonHighted:2];
    
}
- (void)clickWineShare:(id)sender {
    [self setButtonHighted:3];
    
}
- (void)clickStudentShare:(id)sender {
    [self setButtonHighted:4];
    
}
- (void)clickMakeupShare:(id)sender {
    [self setButtonHighted:5];
    
}
- (void)clickTripShare:(id)sender {
    [self setButtonHighted:6];
    
}
- (void)clickDressShare:(id)sender {
    [self setButtonHighted:7];
    
}
- (void)clickMoodShare:(id)sender {
    [self setButtonHighted:8];
    
}
- (void)clickToolShare:(id)sender {
    [self setButtonHighted:9];
    
}
- (void)clickBrandShare:(id)sender {
    [self setButtonHighted:10];
    
}
- (void)clickVitaliaShare:(id)sender {
    [self setButtonHighted:11];
}

- (void)clickBack:(id)sender {
    [self.delegate clickToDismiss];
}

-(void)setButtonHighted:(int)index
{
    [self.allButton setSelected:(index==0)];
    [self.foodButton setSelected:(index==1)];
    [self.homeButton setSelected:(index==2)];
    [self.wineButton setSelected:(index==3)];
    [self.studentButton setSelected:(index==4)];
    [self.makeupButton setSelected:(index==5)];
    [self.tripButton setSelected:(index==6)];
    [self.dressButton setSelected:(index==7)];
    [self.moodButton setSelected:(index==8)];
    [self.toolButton setSelected:(index==9)];
    [self.brandButton setSelected:(index==10)];
    [self.vitaliaButton setSelected:(index==11)];
    [self.delegate clickToGetShareType:index];
}
@end
