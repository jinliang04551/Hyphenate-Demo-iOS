//
//  ACDTransViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDTransferOwnerViewController.h"
#import "AgoraMemberCell.h"
#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "AgoraUserModel.h"

@interface ACDTransferOwnerViewController ()

@property (nonatomic, strong) AgoraChatGroup *group;

@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIView *selectedView;

@end

@implementation ACDTransferOwnerViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self _setupNavigationBar];
    
//    self.showRefreshHeader = YES;
//    self.showRefreshFooter = YES;
    
    self.selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    
    [self tableViewDidTriggerHeaderRefresh];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark private method
- (void)fetchMembersFromServer {
    self.cursor = @"";
    [self fetchMembersWithPage:self.page isHeader:YES];
}

- (void)updateMembers:(NSArray *)members {
    [self sortMembers:members];
}

- (void)sortMembers:(NSArray *)members {
    if (members.count == 0) {
        self.dataArray = [@[] mutableCopy];
        self.sectionTitles = [@[] mutableCopy];
        self.searchSource = [@[] mutableCopy];
        return;
    }
    
    if (members.count == 1) {
        NSString *firstLetter = [self.group.owner substringToIndex:1];
        [self.dataArray addObject:self.group.owner];
        self.sectionTitles = [NSMutableArray arrayWithObject:firstLetter];
        self.searchSource = self.dataArray;
        return;
    }
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:members
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:sortArray];
    self.sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    self.searchSource = [NSMutableArray arrayWithArray:searchSource];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearchState) {
        return 1;
    }
    return  self.sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sectionTitles objectAtIndex:section];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
     return self.sectionTitles;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *contentView = UIView.new;
    contentView.backgroundColor = UIColor.whiteColor;
    UILabel *label = UILabel.new;
    label.font = Font(@"PingFangSC-Regular", 15.0f);
    label.textColor = COLOR_HEX(0x242424);
    label.text = self.sectionTitles[section];
    [contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(0, 20.0f, 0, -20.0));
    }];
    return contentView;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return ((NSArray *)self.dataArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraMemberCell *cell = (AgoraMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"AgoraMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraMemberCell" owner:self options:nil] lastObject];
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    AgoraUserModel *model = self.dataArray[indexPath.section][indexPath.row];
    cell.leftLabel.text = model.nickname;
    
    if (indexPath == self.selectedIndexPath) {
        cell.accessoryView = self.selectedView;
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndexPath) {
        AgoraMemberCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        oldCell.accessoryView = nil;
    }
    
    if (self.selectedIndexPath == indexPath) {
        self.selectedIndexPath = nil;
        return;
    }
    
    self.selectedIndexPath = nil;
    if (self.selectedIndexPath != indexPath) {
        self.selectedIndexPath = indexPath;
        
        AgoraMemberCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.accessoryView = self.selectedView;
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)doneAction
{
    if (self.selectedIndexPath) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *newOwner = [self.dataArray objectAtIndex:self.selectedIndexPath.row];
        
        __weak typeof(self) weakSelf = self;
        [[AgoraChatClient sharedClient].groupManager updateGroupOwner:self.group.groupId newOwner:newOwner completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            weakSelf.group = aGroup;
            if (aError) {
                [weakSelf showHint:NSLocalizedString(@"group.changeOwnerFail", @"Failed to change owner")];
            } else {
                if (self.transferOwnerBlock) {
                    self.transferOwnerBlock();
                }
                [weakSelf backAction];
            }
        }];
    }
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        AgoraChatError *error = nil;
        AgoraChatGroup *group = [[AgoraChatClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.group.groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
        });
        
        if (!error) {
            weakSelf.group = group;
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:weakSelf.group.adminList];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.cursor = @"";
                [weakSelf fetchMembersWithPage:weakSelf.page isHeader:YES];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
            });
        }
    });
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithPage:self.page isHeader:NO];
}

- (void)fetchMembersWithPage:(NSInteger)aPage
                    isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    ACD_WS
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[AgoraChatClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.group.groupId cursor:self.cursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        weakSelf.cursor = aResult.cursor;
        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        if (!aError) {
            [weakSelf updateMembers:aResult.list];
            [weakSelf.table reloadData];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.member.fetchFail", @"failed to get the member list, please try again later")];
        }
        
        if ([aResult.list count] < pageSize) {
//            weakSelf.showRefreshFooter = NO;
        } else {
//            weakSelf.showRefreshFooter = YES;
        }
    }];
}

@end
