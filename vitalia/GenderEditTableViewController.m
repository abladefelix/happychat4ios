//
//  GenderEditTableViewController.m
//  vitalia
//
//  Created by Donal on 15/3/25.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "GenderEditTableViewController.h"

@interface GenderEditTableViewController ()
{
    NSMutableArray *sexs;
    NSIndexPath *lastIndexPath;
}
@end

@implementation GenderEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBar];
    
    sexs = [NSMutableArray arrayWithObjects:@"男", @"女", nil];
    NSString *gender = getUserGender;
    if (gender.length > 0) {
        lastIndexPath = [NSIndexPath indexPathForRow:(1-[gender intValue]) inSection:0];
    }
    else {
        lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

-(void)initBar
{
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"性别";
    titleLabel.textAlignment               = NSTextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    self.navigationItem.titleView          = titleLabel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sexs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier = @"gendercell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *type = [sexs objectAtIndex:indexPath.row];
    cell.textLabel.text = type;
    NSInteger oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    if(indexPath.row == oldRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger newRow = [indexPath row];
    NSInteger oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    if(newRow != oldRow)
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        lastIndexPath = indexPath;
        NSString *sex = [NSString stringWithFormat:@"%ld", (1-newRow)];
        setUserGender(sex);
        [[APIClient sharedInstance] updateUserGender:sex
                                             Success:^(int errorCode, id model) {
            
                                             }
                                             failure:^(NSString *message) {
            
                                             }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProfile" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
