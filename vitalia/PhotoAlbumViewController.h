//
//  PhotoAlbumViewController.h
//  super
//
//  Created by Donal on 14-7-31.
//  Copyright (c) 2014年 super. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol PhotoAlbumViewControllerDelegate <NSObject>

-(void)sendPhotos:(NSArray *)photos;

@end

@interface PhotoAlbumViewController : UIViewController

@property int maxCount;
@property (nonatomic,assign) ALAssetsGroup *assetGroup;

@property (nonatomic, assign) id<PhotoAlbumViewControllerDelegate> delegate;

@end
