//
//  ACDGroupInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupInfoViewController.h"
#import "AgoraInfoHeaderView.h"
#import "ACDJoinGroupCell.h"

@interface ACDGroupInfoViewController ()
@property (nonatomic, strong) AgoraInfoHeaderView *groupInfoHeaderView;
@property (nonatomic, strong) AgoraChatGroup *currentGroup;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) ACDJoinGroupCell *joinGroupCell;

@end

@implementation ACDGroupInfoViewController

- (instancetype)initWithGroupId:(NSString *)aGroupId {
    self = [self init];
    self.groupId = aGroupId;
    return self;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:KAgora_REFRESH_GROUP_INFO object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blueColor;
    [self fetchGroupInfo];
}

- (void)placeSubViews {
   
}

#pragma mark NSNotification
- (void)updateUIWithNotification:(NSNotification *)notification
{
    id obj = notification.object;
    if (obj && [obj isKindOfClass:[AgoraChatGroup class]]) {
        self.currentGroup = (AgoraChatGroup *)obj;
    }
}

- (void)updateUI {
    if (self.accessType == ACDGroupInfoAccessTypeContact) {
            
    }
    
    if (self.accessType == ACDGroupInfoAccessTypePublicGroups) {
        
    }
    
}

#pragma mark action
- (void)fetchGroupInfo
{
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    ACD_WS
    [[AgoraChatClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        [weakSelf hideHud];
        if (aError == nil) {
            weakSelf.currentGroup = aGroup;
            [weakSelf updateUI];
        }else {
            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
        }
    }];
    
    
    [[AgoraChatClient sharedClient].groupManager getGroupAnnouncementWithId:self.groupId completion:^(NSString *aAnnouncement, AgoraChatError *aError) {
//        if (!aError) {
//            [weakSelf reloadUI];
//        }
    }];
}

- (void)fetchGroupMembers
{
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[AgoraChatClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupId cursor:@"" pageSize:10 completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
//        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:YES];
//        if (!aError) {
//            weakSelf.showMembers = aResult.list;
//            [weakSelf reloadUI];
//        } else {
//            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
//        }
    }];
}

#pragma mark - Join Public Group
- (void)requestJoinGroup {
    if (self.currentGroup.setting.style == AgoraChatGroupStylePublicOpenJoin) {
        [self joinToPublicGroup:self.currentGroup.groupId];
    }
    else {
        [self showAlertView];
    }
}

- (void)joinToPublicGroup:(NSString *)groupId {
    ACD_WS
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                         animated:YES];
    [[AgoraChatClient sharedClient].groupManager joinPublicGroup:groupId
                                               completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
           [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
           if (!aError) {
//               [weakSelf updateUI];
               
           }
           else {
               NSString *msg = NSLocalizedString(@"group.requestFailure", @"Failed to apply to the group");
               [weakSelf showAlertWithMessage:msg];
           }
       }
     ];
}

- (void)requestToJoinPublicGroup:(NSString *)groupId message:(NSString *)message {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                         animated:YES];
    [[AgoraChatClient sharedClient].groupManager requestToJoinPublicGroup:groupId
           message:message
        completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
            if (!aError) {
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];

//                [weakSelf updateUI];
            }
            else {
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

                NSString *msg = NSLocalizedString(@"group.requestFailure", @"Failed to apply to the group");
                [weakSelf showAlertWithMessage:msg];
            }
        }];
}

- (void)showAlertView {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"group.joinPublicGroupMessage", "Requesting message") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *messageTextField = alertController.textFields.firstObject;
        [self requestToJoinPublicGroup:self.groupId message:messageTextField.text];

    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.accessType == ACDGroupInfoAccessTypePublicGroups) {
        return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.accessType == ACDGroupInfoAccessTypePublicGroups) {
        return self.joinGroupCell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

#pragma mark getter and setter
- (AgoraInfoHeaderView *)groupInfoHeaderView {
    if (_groupInfoHeaderView == nil) {
        _groupInfoHeaderView = [[AgoraInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180) withType:AgoraHeaderInfoTypeContact];
        _groupInfoHeaderView.backgroundColor = UIColor.grayColor;
        
        ACD_WS
//        _headerView.tapHeaderBlock = ^{
//
//        };
//
//        _headerView.goChatPageBlock = ^{
//            AgoraChatViewController *chatViewController = [[AgoraChatViewController alloc] initWithConversationId:weakSelf.model.hyphenateId conversationType:AgoraChatConversationTypeChat];
//            [weakSelf.navigationController pushViewController:chatViewController animated:YES];
//        };
//
//        _headerView.goBackBlock = ^{
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//
//        };
    }
    return _groupInfoHeaderView;
}


- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = COLOR_HEX(0xFFFFFF);
        _table.tableHeaderView = [self headerView];
        
    }
    return _table;
}

- (ACDJoinGroupCell *)joinGroupCell {
    if (_joinGroupCell == nil) {
        _joinGroupCell = [[ACDJoinGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDJoinGroupCell reuseIdentifier]];
        [_joinGroupCell.iconImageView setImage:ImageWithName(@"request_join_group")];
        _joinGroupCell.nameLabel.text = @"Join this Group";
        ACD_WS
        _joinGroupCell.joinGroupBlock = ^{
            [weakSelf requestJoinGroup];
        };
    }
    return _joinGroupCell;
}

@end
