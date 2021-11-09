//
//  ACDGroupMemberMutedViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberMutedListViewController.h"

@interface ACDGroupMemberMutedListViewController ()

@end

@implementation ACDGroupMemberMutedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [self showMemberActionSheetWithGroup:self.group];
    
}


@end
