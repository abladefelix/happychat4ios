//
//  PhotoGroupTableViewController.m
//  super
//
//  Created by Donal on 14-7-31.
//  Copyright (c) 2014年 super. All rights reserved.
//

#import "PhotoGroupTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoAlbumViewController.h"

@interface PhotoGroupTableViewController () <PhotoAlbumViewControllerDelegate>
@property (nonatomic, strong, readwrite) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, copy, readwrite) NSArray *assetsGroups;
@property (nonatomic, copy) NSArray *groupTypes;
@end

@implementation PhotoGroupTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"照片";
    self.assetsGroups = [NSMutableArray array];
    self.groupTypes = @[
                        @(ALAssetsGroupSavedPhotos),
                        @(ALAssetsGroupPhotoStream),
                        @(ALAssetsGroupAlbum)
                        ];
    [self queryALAssetsLibrary];
    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = cancleItem;
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView = footview;
}

-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)queryALAssetsLibrary
{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    [self loadAssetsGroupsWithTypes:self.groupTypes
                         completion:^(NSArray *assetsGroups) {
                             self.assetsGroups = assetsGroups;
                             [self.tableView reloadData];
                             if (self.assetsGroups.count > 0) {
                                 ALAssetsGroup *g = (ALAssetsGroup*)[self.assetsGroups objectAtIndex:0];
                                 PhotoAlbumViewController *vc = [[PhotoAlbumViewController alloc] init];
                                 vc.assetGroup = g;
                                 vc.maxCount = self.MaxCount;
                                 vc.delegate = self;
                                 [self.navigationController pushViewController:vc animated:NO];
                             }
                         }];
}

#pragma mark - Managing Assets

- (void)loadAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    for (NSNumber *type in types) {
        [self.assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                          usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                              if (assetsGroup) {
                                                  [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                                                  
                                                  if (assetsGroup.numberOfAssets > 0) {
                                                      // Add assets group
                                                      [assetsGroups addObject:assetsGroup];
                                                  }
                                              } else {
                                                  numberOfFinishedTypes++;
                                              }
                                              
                                              // Check if the loading finished
                                              if (numberOfFinishedTypes == types.count) {
                                                  // Sort assets groups
                                                  NSArray *sortedAssetsGroups = [self sortAssetsGroups:(NSArray *)assetsGroups typesOrder:types];
                                                  
                                                  // Call completion block
                                                  if (completion) {
                                                      completion(sortedAssetsGroups);
                                                  }
                                              }
                                          } failureBlock:^(NSError *error) {
                                              debugLog(@"Error: %@", [error localizedDescription]);
                                          }];
    }
}

- (NSArray *)sortAssetsGroups:(NSArray *)assetsGroups typesOrder:(NSArray *)typesOrder
{
    NSMutableArray *sortedAssetsGroups = [NSMutableArray array];
    
    for (ALAssetsGroup *assetsGroup in assetsGroups) {
        if (sortedAssetsGroups.count == 0) {
            [sortedAssetsGroups addObject:assetsGroup];
            continue;
        }
        
        ALAssetsGroupType assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSUInteger indexOfAssetsGroupType = [typesOrder indexOfObject:@(assetsGroupType)];
        
        for (NSInteger i = 0; i <= sortedAssetsGroups.count; i++) {
            if (i == sortedAssetsGroups.count) {
                [sortedAssetsGroups addObject:assetsGroup];
                break;
            }
            
            ALAssetsGroup *sortedAssetsGroup = [sortedAssetsGroups objectAtIndex:i];
            ALAssetsGroupType sortedAssetsGroupType = [[sortedAssetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
            NSUInteger indexOfSortedAssetsGroupType = [typesOrder indexOfObject:@(sortedAssetsGroupType)];
            
            if (indexOfAssetsGroupType < indexOfSortedAssetsGroupType) {
                [sortedAssetsGroups insertObject:assetsGroup atIndex:i];
                break;
            }
        }
    }
    
    return [sortedAssetsGroups copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"group"];
    }
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetsGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    cell.textLabel.text=[NSString stringWithFormat:@"%@(%ld)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[self.assetsGroups objectAtIndex:indexPath.row] posterImage]]];
    cell.imageView.left = 0;
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetsGroups objectAtIndex:indexPath.row];
    PhotoAlbumViewController *vc = [[PhotoAlbumViewController alloc] init];
    vc.assetGroup = g;
    vc.delegate = self;
    vc.maxCount = self.MaxCount;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark PhotoAlbumViewController delegate
-(void)sendPhotos:(NSArray *)photos
{
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate getPhotos:photos];
}


@end
