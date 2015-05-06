//
//  TabbarController.h
//  vitalia
//
//  Created by Donal on 15/3/3.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabbarController : UITabBarController<UITabBarControllerDelegate>

-(void)setMessageBadge:(int)num;
@end
