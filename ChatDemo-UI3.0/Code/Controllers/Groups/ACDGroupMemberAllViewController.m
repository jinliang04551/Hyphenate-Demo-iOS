//
//  ACDGroupMemberAllViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberAllViewController.h"
#import "AgoraGroupOccupantsViewController.h"
#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"
#import "ACDInfoDetailCell.h"
#import "NSArray+AgoraSortContacts.h"


@interface ACDGroupMemberAllViewController ()

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) AgoraChatGroup *group;
@property (nonatomic, strong) NSString *cursor;

@end

@implementation ACDGroupMemberAllViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        self.groupId = self.group.groupId;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:KAgora_REFRESH_GROUP_INFO object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)updateUIWithResultList:(NSArray *)sourceList IsHeader:(BOOL)isHeader {
    
    NSLog(@"%s sourceList:%@ isHeader:%@",__func__,sourceList,@(isHeader));
    if (isHeader) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObject:self.group.owner];
        [self.dataArray addObjectsFromArray:self.group.adminList];
    }
    
    [self.dataArray addObjectsFromArray:sourceList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark updateUIWithNotification
- (void)updateUIWithNotification:(NSNotification *)notify {
    [self tableViewDidTriggerHeaderRefresh];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

    if (name == self.group.owner) {
        cell.detailLabel.text = @"owner";
    } else if([self.group.adminList containsObject:name]){
        cell.detailLabel.text = @"admin";
    }else {
        cell.detailLabel.text = @"";
    }

    ACD_WS
    cell.tapCellBlock = ^{
        [weakSelf actionSheetWithUserId:name memberListType:ACDGroupMemberListTypeALL group:weakSelf.group];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - private
- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self fetchMembersWithCursor:self.cursor isHeader:YES];

}

- (void)tableViewDidTriggerFooterRefresh
{
    NSLog(@"%s",__func__);
    
    [self fetchMembersWithCursor:self.cursor isHeader:NO];
}


- (void)fetchMembersWithCursor:(NSString *)aCursor
                      isHeader:(BOOL)aIsHeader
{
    NSLog(@"%s aCursor:%@ aIsHeader:%@",__func__,aCursor,@(aIsHeader));
    NSInteger pageSize = 50;
    
    ACD_WS
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[AgoraChatClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupId cursor:aCursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        weakSelf.cursor = aResult.cursor;
        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        if (!aError) {
            [weakSelf updateUIWithResultList:aResult.list IsHeader:aIsHeader];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.member.fetchFail", @"Failed to get the group details, please try again later")];
        }
        
        if ([aResult.list count] < pageSize) {
//            weakSelf.showRefreshFooter = NO;
            [weakSelf.table reloadData];
        } else {
//            weakSelf.showRefreshFooter = YES;
        }
    }];
}


@end
