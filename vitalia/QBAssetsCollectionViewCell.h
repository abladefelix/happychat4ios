//
//  QBAssetsCollectionViewCell.h
//  QBImagePickerController
//
//  Created by Tanaka Katsuma on 2013/12/31.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol QBAssetsCollectionViewCellDelegate <NSObject>

-(BOOL)returnShowsOverlayViewWhenSelected;

@end

@interface QBAssetsCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) id<QBAssetsCollectionViewCellDelegate> delegate;

@end
