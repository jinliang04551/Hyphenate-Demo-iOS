//
//  ACDGroupMemberAdminListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberAdminListViewController.h"
#import "AgoraMemberCell.h"
#import "UIViewController+HUD.h"
#import "AgoraAddAdminViewController.h"
#import "AgoraNotificationNames.h"
#import "ACDInfoDetailCell.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"


@interface ACDGroupMemberAdminListViewController ()

@property (nonatomic, strong) AgoraChatGroup *group;

@end

@implementation ACDGroupMemberAdminListViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:@"UpdateGroupAdminList" object:nil];

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self buildAdmins];
    [self.table reloadData];
}

- (void)buildAdmins {
    NSMutableArray *tempArray = NSMutableArray.new;
    [tempArray addObject:self.group.owner];
    [tempArray addObjectsFromArray:self.group.adminList];
    [self sortMembers:tempArray];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    
    cell.iconImageView.image = [UIImage imageNamed:@"default_avatar"];
        
    cell.detailLabel.text = nil;
    cell.nameLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ACDInfoDetailCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.group.permissionType == AgoraChatGroupPermissionTypeOwner) {
//        return YES;
//    }
//
//    return NO;
//}
//
//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.remove", @"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self editActionsForRowAtIndexPath:indexPath actionIndex:0];
//    }];
//    deleteAction.backgroundColor = [UIColor redColor];
//
//    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.block", @"Block") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self editActionsForRowAtIndexPath:indexPath actionIndex:1];
//    }];
//    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
//
//    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.mute", @"Mute") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self editActionsForRowAtIndexPath:indexPath actionIndex:2];
//    }];
//    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
//
//    UITableViewRowAction *toMemberAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.demote", @"Demote") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self editActionsForRowAtIndexPath:indexPath actionIndex:3];
//    }];
//    toMemberAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
//
//    return @[deleteAction, blackAction, muteAction, toMemberAction];
//}
//
//#pragma mark - Action
//
//- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
//{
//    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
//    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
//
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        AgoraChatError *error = nil;
//        if (buttonIndex == 0) { //remove
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager removeOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
//        } else if (buttonIndex == 1) { //blacklist
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager blockOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
//        } else if (buttonIndex == 2) {  //mute
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager muteMembers:@[userName] muteMilliseconds:-1 fromGroup:weakSelf.group.groupId error:&error];
//        }  else if (buttonIndex == 3) {  //to member
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager removeAdmin:userName fromGroup:weakSelf.group.groupId error:&error];
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf hideHud];
//            if (!error) {
//                if (buttonIndex != 2) {
//                    [weakSelf.dataArray removeObject:userName];
//                    [weakSelf.table reloadData];
//                } else {
//                    [weakSelf showHint:NSLocalizedString(@"group.mute.success", @"Mute success")];
//                }
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:weakSelf.group];
//            }
//            else {
//                [weakSelf showHint:error.errorDescription];
//            }
//        });
//    });
//}

- (void)addAdminAction
{
    AgoraAddAdminViewController *addController = [[AgoraAddAdminViewController alloc] initWithGroupId:self.group.groupId];
    [self.navigationController pushViewController:addController animated:YES];
}

- (void)updateUI:(NSNotification *)aNotification
{
    id obj = aNotification.object;
    if (obj && [obj isKindOfClass:[AgoraChatGroup class]]) {
        self.group = (AgoraChatGroup *)obj;
    }
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:self.group.adminList];
    [self.table reloadData];
}

#pragma mark - data

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
        
//        [weakSelf tableViewDidFinishTriggerHeader:YES];
        if (!error) {
            weakSelf.group = group;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:weakSelf.group.adminList];
                [weakSelf.table reloadData];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHint:NSLocalizedString(@"group.admin.fetchFail", @"failed to get the admin list, please try again later")];
            });
        }
    });
}

@end
