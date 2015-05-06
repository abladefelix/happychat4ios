//
//  PubViewController.h
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define TYPE_SHARE 0
#define TYPE_COMMENT 1

#define OPRATION_NEW 0
#define OPRATION_EDIT 2

@protocol PubViewControllerDelegate <NSObject>

@optional
-(void)editDraftSuccess;

@end

@interface PubViewController : UIViewController

@property int type;
@property int operation;
@property (nonatomic, strong) NSString *tid;
@property (nonatomic, strong) NSString *commentId;

@property (weak, nonatomic) IBOutlet UIButton *faceButton;
@property (nonatomic, strong) NSDictionary *draft;

@property (weak, nonatomic) IBOutlet UITableView *pubTableView;

@property (weak, nonatomic) IBOutlet UIView *operationView;

@property (nonatomic, assign) id<PubViewControllerDelegate> delegate;
@end
