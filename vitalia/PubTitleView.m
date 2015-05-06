//
//  PubTitleView.m
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "PubTitleView.h"

@implementation PubTitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithNib
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"PubTitleView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        UIView *padView2              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.titleTextField.height)];
        self.titleTextField.leftView          = padView2;
        self.titleTextField.leftViewMode      = UITextFieldViewModeAlways;
    }
    return self;
}

@end
