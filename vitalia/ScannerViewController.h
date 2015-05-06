//
//  ScannerViewController.h
//  vitalia
//
//  Created by Donal on 14-8-7.
//  Copyright (c) 2014年 vitalia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>

@protocol  ScannerViewControllerDelegate<NSObject>

-(void)getResultFromScan:(NSString *)result;

@end

@interface ScannerViewController : UIViewController<ZXCaptureDelegate>

@property (nonatomic, assign) id<ScannerViewControllerDelegate> delegate;
@end
