//
//  SidebarViewController.h
//  LLBlurSidebar
//
//  Created by Lugede on 14/11/20.
//  Copyright (c) 2014年 lugede.cn. All rights reserved.
//

#import "LLBlurSidebar.h"

@protocol SidebarViewControllerDelegate <NSObject>

-(void)showShareType:(NSString *)type name:(NSString *)name;

@end

@interface SidebarViewController : LLBlurSidebar

@property (nonatomic, assign) id<SidebarViewControllerDelegate> delegate;

@end
