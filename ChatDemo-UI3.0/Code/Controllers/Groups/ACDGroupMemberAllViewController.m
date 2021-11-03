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
@property (nonatomic, strong) NSMutableArray *ownerAndAdmins;

@end

@implementation ACDGroupMemberAllViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        self.groupId = self.group.groupId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAllMembers];
    [self.table reloadData];
}

- (void)loadAllMembers {
    [self.ownerAndAdmins addObject:self.group.owner];
    [self.ownerAndAdmins addObject:self.group.adminList];

    [self sortALlMembers];
}

- (void)sortALlMembers {
//    NSMutableSet *adminSet = [NSMutableSet setWithArray:self.ownerAndAdmins];
//    NSMutableSet *memberSet = [NSMutableSet setWithArray:self.group.memberList];
//    [memberSet minusSet:adminSet];
//
//    NSArray *members = [memberSet allObjects];
    [self sortMembers:self.group.occupants];
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
    
    NSLog(@"%s members:%@",__func__,members);

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)table {
    return self.sectionTitles;
}

- (NSInteger)table:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
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

    if ([self.ownerAndAdmins containsObject:name]) {
        if (name == self.group.owner) {
            cell.detailLabel.text = @"owner";
        } else {
            cell.detailLabel.text = @"admin";
        }
    }

    ACD_WS
    cell.tapCellBlock = ^{
        
    };
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 0) {
        return NO;
    }
    
    if (self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        return YES;
    }
    
    return NO;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.remove", @"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:0];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.block", @"Block") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:1];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.mute", @"Mute") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:2];
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    
    UITableViewRowAction *toAdminAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.upgrade", @"Up") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:3];
    }];
    toAdminAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    if (indexPath.section == 1) {
        return @[deleteAction, blackAction, muteAction, toAdminAction];
    }
    
    return @[deleteAction, blackAction, muteAction];
}

#pragma mark - Action

- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
{
    NSString *userName = @"";
    if (indexPath.section == 0) {
        userName = [self.ownerAndAdmins objectAtIndex:indexPath.row];
    } else {
        userName = [self.dataArray objectAtIndex:indexPath.row];
    }
    
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AgoraChatError *error = nil;
        if (buttonIndex == 0) { //Remove
            weakSelf.group = [[AgoraChatClient sharedClient].groupManager removeOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
            if (!error) {
                if (indexPath.section == 0) {
                    [weakSelf.ownerAndAdmins removeObject:userName];
                } else {
                    [weakSelf.dataArray removeObject:userName];
                }
            }
        } else if (buttonIndex == 1) { //Blacklist
            weakSelf.group = [[AgoraChatClient sharedClient].groupManager blockOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
            if (!error) {
                if (indexPath.section == 0) {
                    [weakSelf.ownerAndAdmins removeObject:userName];
                } else {
                    [weakSelf.dataArray removeObject:userName];
                }
            }
        } else if (buttonIndex == 2) {  //Mute
            weakSelf.group = [[AgoraChatClient sharedClient].groupManager muteMembers:@[userName] muteMilliseconds:-1 fromGroup:weakSelf.group.groupId error:&error];
        } else if (buttonIndex == 3) {  //To Admin
            weakSelf.group = [[AgoraChatClient sharedClient].groupManager addAdmin:userName toGroup:weakSelf.group.groupId error:&error];
            if (!error) {
                [weakSelf.ownerAndAdmins addObject:userName];
                [weakSelf.dataArray removeObject:userName];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (!error) {
                if (buttonIndex != 2) {
                    [weakSelf.table reloadData];
                } else {
                    [weakSelf showHint:NSLocalizedString(@"group.mute.success", @"Mute success")];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:weakSelf.group];
            }
            else {
                [weakSelf showHint:error.errorDescription];
            }
        });
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - private

- (BOOL)_isShowCellAccessoryView
{
    if (self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        return YES;
    }
    
    return NO;
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self fetchGroupInfo];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithCursor:self.cursor isHeader:NO];
}

- (void)fetchGroupInfo
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[AgoraChatClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        [weakSelf hideHud];
        
        if (!aError) {
            weakSelf.group = aGroup;
            AgoraChatConversation *conversation = [[AgoraChatClient sharedClient].chatManager getConversation:aGroup.groupId type:AgoraChatConversationTypeGroupChat createIfNotExist:YES];
            if ([aGroup.groupId isEqualToString:conversation.conversationId]) {
                NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                [ext setObject:aGroup.subject forKey:@"subject"];
                [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
                conversation.ext = ext;
            }
            
            
            [weakSelf.ownerAndAdmins removeAllObjects];
            [weakSelf.ownerAndAdmins addObject:aGroup.owner];
            [weakSelf.ownerAndAdmins addObjectsFromArray:aGroup.adminList];
            
            weakSelf.cursor = @"";
            [weakSelf fetchMembersWithCursor:weakSelf.cursor isHeader:YES];
        }
        else{
            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
        }
    }];
}

- (void)fetchMembersWithCursor:(NSString *)aCursor
                      isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[AgoraChatClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupId cursor:aCursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        weakSelf.cursor = aResult.cursor;
        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        if (!aError) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }
            
            [weakSelf.dataArray addObjectsFromArray:aResult.list];
            [weakSelf.table reloadData];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.member.fetchFail", @"Failed to get the group details, please try again later")];
        }
        
        if ([aResult.list count] < pageSize) {
//            weakSelf.showRefreshFooter = NO;
        } else {
//            weakSelf.showRefreshFooter = YES;
        }
    }];
}


- (NSMutableArray *)ownerAndAdmins {
    if (_ownerAndAdmins == nil) {
        _ownerAndAdmins = NSMutableArray.new;
    }
    return _ownerAndAdmins;
}


@end
