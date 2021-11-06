//
//  ACDGroupMemberMutedViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberMutedListViewController.h"
#import "ACDInfoDetailCell.h"
#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"

@interface ACDGroupMemberMutedListViewController ()

@property (nonatomic, strong) AgoraChatGroup *group;

@end

@implementation ACDGroupMemberMutedListViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:KAgora_REFRESH_GROUP_INFO object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
        
//    self.showRefreshHeader = YES;
    if (self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark updateUIWithNotification
- (void)updateUIWithNotification:(NSNotification *)notify {
    [self tableViewDidTriggerHeaderRefresh];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ACDInfoDetailCell height];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDInfoDetailCell *cell = (ACDInfoDetailCell *)[tableView dequeueReusableCellWithIdentifier:[ACDInfoDetailCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *name = self.dataArray[indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:@"default_avatar"];
    cell.nameLabel.text = name;
    ACD_WS
    cell.tapCellBlock = ^{
        [weakSelf actionSheetWithUserId:name memberListType:ACDGroupMemberListTypeMute group:weakSelf.group];
    };
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - data
- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchMutesWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchMutesWithPage:self.page isHeader:NO];
}

- (void)fetchMutesWithPage:(NSInteger)aPage
                  isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    ACD_WS
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[AgoraChatClient sharedClient].groupManager getGroupMuteListFromServerWithId:self.group.groupId pageNumber:self.page pageSize:pageSize completion:^(NSArray *aMembers, AgoraChatError *aError) {
        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        if (!aError) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }

            [weakSelf.dataArray addObjectsFromArray:aMembers];
            [weakSelf.table reloadData];
        } else {
            NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"group.mute.fetchFail", @"fail to get mutes: %@"), aError.errorDescription];
            [weakSelf showHint:errorStr];
        }
        
        if ([aMembers count] < pageSize) {
//            self.showRefreshFooter = NO;
        } else {
//            self.showRefreshFooter = YES;
        }
    }];
}


@end
