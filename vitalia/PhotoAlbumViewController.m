//
//  PhotoAlbumViewController.m
//  super
//
//  Created by Donal on 14-7-31.
//  Copyright (c) 2014年 super. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import "QBAssetsCollectionViewCell.h"

@interface PhotoAlbumViewController () <QBAssetsCollectionViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) NSMutableArray *photoSelected;
@property (nonatomic, strong) NSMutableArray *photoPathSelected;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@end

@implementation PhotoAlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
    self.photos = [NSMutableArray array];
    self.photoSelected = [NSMutableArray array];
    self.photoPathSelected = [NSMutableArray array];
    [self preparePhotos];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[QBAssetsCollectionViewCell class]
            forCellWithReuseIdentifier:@"AssetsCell"];
    [self.sendButton setBackgroundImage:[[UIImage imageNamed:@"BarButton_blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[[UIImage imageNamed:@"f_button_01"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)] forState:UIControlStateDisabled];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.enabled = NO;
    
    self.previewButton.titleLabel.text = @"预览";
    self.previewButton.enabled = NO;
    
    [self.badgeLabel.layer setCornerRadius:10];
    [self.badgeLabel.layer setMasksToBounds:YES];
    self.badgeLabel.backgroundColor = UIColorFromRGB(0x28da46, 1.0);
    self.badgeLabel.hidden = YES;
    
}

-(void)send
{
    [SVProgressHUD show];
    for (ALAsset *asset in self.photoSelected) {
        NSURL *assetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
        NSString *compressedPhotoFileName = [NSString stringWithFormat:@"%@.jpg",[Tool getMd5_32Bit_String:[assetUrl absoluteString]]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[Tool returnCompressedPhotoFilePath:compressedPhotoFileName]]) {
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            UIImageOrientation orientation = UIImageOrientationUp;
            NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
            if (orientationValue != nil) {
                orientation = [orientationValue intValue];
            }
            CGFloat scale  = 1;
            UIImage *uploadPhoto = [UIImage imageWithCGImage:representation.fullResolutionImage scale:scale orientation:orientation];
            int width = uploadPhoto.size.width;
            int height = uploadPhoto.size.height;
            int contentImageHeight = height * 500 / width;
            UIImage *imageResize = [Tool imageWithImageSimple:uploadPhoto scaledToSize:CGSizeMake(500, contentImageHeight)];
            NSData *dataImg = UIImageJPEGRepresentation(imageResize,0.8);
            [dataImg writeToFile:[Tool returnCompressedPhotoFilePath:compressedPhotoFileName] atomically:YES];
        }
        [self.photoPathSelected addObject:[Tool returnCompressedPhotoFilePath:compressedPhotoFileName]];
    }
    [SVProgressHUD dismiss];
    [self.delegate sendPhotos:self.photoPathSelected];
}

-(void)preparePhotos
{
    [self.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    __weak typeof(self) weakSelf = self;
    [self.assetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if(result == nil)
         {
             return;
         }
         [weakSelf.photos addObject:result];
     }];
}

#pragma mark collectionview delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetsCell" forIndexPath:indexPath];
    cell.delegate = self;
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    cell.asset = asset;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.photoSelected.count==self.maxCount) {
        return;
    }
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    [self.photoSelected addObject:asset];
    self.sendButton.enabled = self.photoSelected.count!=0;
    self.previewButton.enabled = self.photoSelected.count!=0;
    self.badgeLabel.text = [NSString stringWithFormat:@"%ld", self.photoSelected.count];
    self.badgeLabel.hidden = self.photoSelected.count==0;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    [self.photoSelected removeObject:asset];
    self.sendButton.enabled = self.photoSelected.count!=0;
    self.previewButton.enabled = self.photoSelected.count!=0;
    self.badgeLabel.text = [NSString stringWithFormat:@"%ld", self.photoSelected.count];
    self.badgeLabel.hidden = self.photoSelected.count==0;
}

//  设置每个元素大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float size = 75.0/320 * screenframe.size.width;
    return CGSizeMake(size, size);
    
}

//  定义每个元素的margin(边缘 上-左-下-右)
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}

//  定义单元格所在行line之间的距离,前一行和后一行的距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    float size = 4.0/320 * screenframe.size.width;
    return size;
}

//  定义每个单元格相互之间的距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    float size = 4.0/320 * screenframe.size.width;
    return size;
    
}

#pragma mark QBAssetsCollectionViewCellDelegate
-(BOOL)returnShowsOverlayViewWhenSelected
{
    return self.photoSelected.count!=self.maxCount;
}

@end
