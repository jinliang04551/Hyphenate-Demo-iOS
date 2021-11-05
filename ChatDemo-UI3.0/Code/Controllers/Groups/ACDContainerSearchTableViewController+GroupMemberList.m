//
//  ACDContainerSearchTableViewController+GroupMemberList.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContainerSearchTableViewController+GroupMemberList.h"

typedef void(^actionBlock)();

#define kActionAdminKey   @"ActionAdminKey"
#define kActionUnAdminKey @"ActionUnAdminKey"

#define kActionMuteKey    @"ActionMuteKey"
#define kActionUnMuteKey  @"ActionUnMuteKey"

#define kActionBlockKey   @"ActionBlockKey"
#define kActionUnBlockKey @"ActionUnBlockKey"

#define kActionRemoveFromGroupKey @"ActionRemoveFromGroupKey"

@interface ACDContainerSearchTableViewController ()
@property (nonatomic, strong) NSString *selectedUserId;
@property (nonatomic, strong) NSString *groupId;

@end

@implementation ACDContainerSearchTableViewController (GroupMemberList)

- (void)actionSheetWithUserId:(NSString *)userId
               memberListType:(ACDGroupMemberListType)memberListType
                        group:(AgoraChatGroup *)group
                   completion:(void (^)(AgoraChatError* error))completion {
    //if selected user is currentUsernam, than do nothing
    if ([userId isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
        return;
    }
    
    //admin can not opertion admin
    if (group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        BOOL isAdminUserId = [group.adminList containsObject:userId];
        if (isAdminUserId) {
            return;
        }
    }
    
    if (group.permissionType == AgoraChatGroupPermissionTypeMember) {
        return;
    }
    
    self.selectedUserId = userId;
    self.groupId = group.groupId;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:userId message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (group.permissionType == AgoraChatGroupPermissionTypeOwner) {
        BOOL isAdmin = [group.adminList containsObject:userId];
        NSArray *actions = [self ownerWithMemberListType:memberListType selectedIsAdmin:isAdmin alertController:alertController];
        for (UIAlertAction *action in actions) {
            [alertController addAction:action];
        }
        
    }
    
    if (group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        NSArray *actions = [self adminWithMemberListType:memberListType alertController:alertController];
        
        for (UIAlertAction *action in actions) {
            [alertController addAction:action];
        }
    }
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    return;

}
   

-(NSArray *)ownerWithMemberListType:(ACDGroupMemberListType)memberListType
                    selectedIsAdmin:(BOOL)selectedIsAdmin
                    alertController:(UIAlertController *)alertController {
    
    NSMutableArray *actionArray = NSMutableArray.new;
    NSDictionary *actionDic = [self alertActionDics];
    if (memberListType == ACDGroupMemberListTypeALL) {
        if (selectedIsAdmin) {
            [actionArray addObject:actionDic[kActionUnAdminKey]];
            [actionArray addObject:actionDic[kActionMuteKey]];
            [actionArray addObject:actionDic[kActionBlockKey]];
            [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    
        }else {
            [actionArray addObject:actionDic[kActionAdminKey]];
            [actionArray addObject:actionDic[kActionMuteKey]];
            [actionArray addObject:actionDic[kActionBlockKey]];
            [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
        }
    }
    
    if (memberListType == ACDGroupMemberListTypeBlock) {
        [actionArray addObject:actionDic[kActionUnBlockKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    if (memberListType == ACDGroupMemberListTypeMute) {
        [actionArray addObject:actionDic[kActionUnMuteKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    return [actionArray copy];
    
}


-(NSArray *)adminWithMemberListType:(ACDGroupMemberListType)memberListType
               alertController:(UIAlertController *)alertController {
    
    NSMutableArray *actionArray = NSMutableArray.new;
    NSDictionary *actionDic = [self alertActionDics];
    if (memberListType == ACDGroupMemberListTypeALL) {
        [actionArray addObject:actionDic[kActionMuteKey]];
        [actionArray addObject:actionDic[kActionBlockKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }
    
    if (memberListType == ACDGroupMemberListTypeBlock) {
        [actionArray addObject:actionDic[kActionUnBlockKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    if (memberListType == ACDGroupMemberListTypeMute) {
        [actionArray addObject:actionDic[kActionUnMuteKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    return [actionArray copy];

}

- (NSDictionary *)alertActionDics {
        NSMutableDictionary *alertActionDics = NSMutableDictionary.new;
        UIAlertAction *makeAdminAction = [self alertActionWithTitle:@"Make Admin" completion:^{
            [self makeAdmin];
        }];
        
        UIAlertAction *makeMuteAction = [self alertActionWithTitle:@"Mute" completion:^{
            [self makeMute];
        }];

        UIAlertAction *makeBlockAction = [self alertActionWithTitle:@"Move to Blocked List" completion:^{
            [self makeBlock];
        }];

        
        UIAlertAction *makeRemoveGroupAction = [self alertActionWithTitle:@"Remove From Group" completion:^{
            [self makeRemoveGroup];
        }];

    
        UIAlertAction *makeUnAdminAction = [self alertActionWithTitle:@"Remove as Admin" completion:^{
            [self makeMute];
        }];
    
        UIAlertAction *makeUnMuteAction = [self alertActionWithTitle:@"Unmute" completion:^{
            [self makeMute];
        }];

        
        UIAlertAction *makeUnBlockAction = [self alertActionWithTitle:@"Remove from Blocked List" completion:^{
            [self makeMute];
        }];
        
    alertActionDics[kActionAdminKey] = makeAdminAction;
    alertActionDics[kActionMuteKey] =  makeMuteAction;
    alertActionDics[kActionBlockKey] = makeBlockAction;
    alertActionDics[kActionUnAdminKey] = makeUnAdminAction;
    alertActionDics[kActionUnMuteKey] = makeUnMuteAction;
    alertActionDics[kActionUnBlockKey] = makeUnBlockAction;
    alertActionDics[kActionRemoveFromGroupKey] = makeRemoveGroupAction;

    return alertActionDics;
}

- (UIAlertAction* )alertActionWithTitle:(NSString *)title
                             completion:(actionBlock)completion {
    UIAlertAction* alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }];
    return alertAction;
}


- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
{
//    NSString *userName = @"";
//    if (indexPath.section == 0) {
//        userName = [self.ownerAndAdmins objectAtIndex:indexPath.row];
//    } else {
//        userName = [self.dataArray objectAtIndex:indexPath.row];
//    }
    
//    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
//
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        AgoraChatError *error = nil;
//        if (buttonIndex == 0) { //Remove
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager removeOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
//            if (!error) {
//                if (indexPath.section == 0) {
//                    [weakSelf.ownerAndAdmins removeObject:userName];
//                } else {
//                    [weakSelf.dataArray removeObject:userName];
//                }
//            }
//        } else if (buttonIndex == 1) { //Blacklist
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager blockOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
//            if (!error) {
//                if (indexPath.section == 0) {
//                    [weakSelf.ownerAndAdmins removeObject:userName];
//                } else {
//                    [weakSelf.dataArray removeObject:userName];
//                }
//            }
//        } else if (buttonIndex == 2) {  //Mute
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager muteMembers:@[userName] muteMilliseconds:-1 fromGroup:weakSelf.group.groupId error:&error];
//        } else if (buttonIndex == 3) {  //To Admin
//            weakSelf.group = [[AgoraChatClient sharedClient].groupManager addAdmin:userName toGroup:weakSelf.group.groupId error:&error];
//            if (!error) {
//                [weakSelf.ownerAndAdmins addObject:userName];
//                [weakSelf.dataArray removeObject:userName];
//            }
//        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf hideHud];
//            if (!error) {
//                if (buttonIndex != 2) {
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
    
}




- (void)makeAdmin {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager addAdmin:self.selectedUserId toGroup:self.groupId error:&error];
    [self handleActionTitle:@"add admin" responseError:error];
}




- (void)unAdmin {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager removeAdmin:self.selectedUserId fromGroup:self.groupId error:&error];
    
    [self handleActionTitle:@"remove admin" responseError:error];

}


- (void)makeMute {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager muteMembers:@[self.selectedUserId] muteMilliseconds:-1 fromGroup:self.groupId error:&error];
    
    [self handleActionTitle:@"Mute" responseError:error];

}

- (void)unMute {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager unmuteMembers:@[self.selectedUserId] fromGroup:self.groupId error:&error];
    [self handleActionTitle:@"unmute" responseError:error];

}


- (void)makeBlock {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager blockOccupants:@[self.selectedUserId] fromGroup:self.groupId error:&error];
    [self handleActionTitle:@"block" responseError:error];

}

- (void)unBlock {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager unblockOccupants:@[self.selectedUserId] forGroup:self.groupId error:&error];
    [self handleActionTitle:@"unBlock" responseError:error];

}


- (void)makeRemoveGroup {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager removeOccupants:@[self.selectedUserId] fromGroup:self.groupId error:&error];
    [self handleActionTitle:@"remove" responseError:error];

}

- (void)handleActionTitle:(NSString *)title
            responseError:(AgoraChatError *)error {
    if (error == nil) {
        [self showHint:[NSString stringWithFormat:@"%@ success",title]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:self.groupId];
    }else {
        [self showHint:error.errorDescription];
    }
}

@end

#undef kActionAdminKey
#undef kActionUnAdminKey

#undef kActionMuteKey
#undef kActionUnMuteKey

#undef kActionBlockKey
#undef kActionUnBlockKey

#undef kActionRemoveFromGroupKey
