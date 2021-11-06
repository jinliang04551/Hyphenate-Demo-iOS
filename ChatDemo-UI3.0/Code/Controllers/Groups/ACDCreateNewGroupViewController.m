//
//  AgoraCreateNewGroupNewViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCreateNewGroupViewController.h"
#import "AgoraUserModel.h"
#import "AgoraMemberCollectionCell.h"
#import "AgoraGroupPermissionCell.h"
#import "AgoraNotificationNames.h"
#import "AgoraMemberSelectViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+DismissKeyboard.h"
#import "ACDTextFieldCell.h"
#import "ACDTextViewCell.h"
#import "ACDMAXGroupNumberCell.h"

#define KAgora_GROUP_MAgoraBERSCOUNT         2000


static NSString *agoraGroupPermissionCellIdentifier = @"AgoraGroupPermissionCell";

@interface ACDCreateNewGroupViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, UINavigationControllerDelegate, AgoraGroupUIProtocol>


@property (strong, nonatomic) ACDTextFieldCell *groupNameCell;
@property (strong, nonatomic) ACDTextViewCell *descriptionCell;
@property (strong, nonatomic) ACDMAXGroupNumberCell *maxGroupNumberCell;

@property (nonatomic, strong) NSMutableArray<AgoraUserModel *> *occupants;
@property (nonatomic, strong) NSMutableArray *groupPermissions;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) BOOL isAllowMemberInvite;
@property (nonatomic, strong) NSMutableArray<NSString *> *invitees;

@end

@implementation ACDCreateNewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavbar];
    [self setupForDismissKeyboard];
    [self initBasicData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupNavbar {
    self.title = NSLocalizedString(@"title.newGroup", @"New Group");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(0, 0, 50, 40);
    createBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [createBtn setTitleColor:ButtonDisableGrayColor forState:UIControlStateNormal];
    [createBtn setTitle:@"Next" forState:UIControlStateNormal];
    [createBtn setTitle:@"Next" forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:createBtn];
    
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    rightSpace.width = -2;
    [self.navigationItem setRightBarButtonItems:@[rightSpace,rightBar]];
}

- (void)initBasicData {
    _occupants = [NSMutableArray array];
    AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:[AgoraChatClient sharedClient].currentUsername];
    if (model) {
        [_occupants addObject:model];
    }
    [self reloadPermissions];
}

- (void)reloadPermissions {
    _groupPermissions = [NSMutableArray array];
    AgoraGroupPermissionModel *model = [[AgoraGroupPermissionModel alloc] init];
    model.title = @"Set to a Public Group";
    model.isEdit = YES;
    model.switchState = NO;
    model.type = AgoraGroupInfoType_groupType;
    [_groupPermissions addObject:model];
    
    model = [[AgoraGroupPermissionModel alloc] init];
    model.title = @"Allow members to invite";
    model.isEdit = YES;
    model.switchState = NO;
    model.type = AgoraGroupInfoType_canAllInvite;
    [_groupPermissions addObject:model];
}

- (void)updatePermission {
    AgoraGroupPermissionModel *model = _groupPermissions.firstObject;
    model.switchState = _isPublic;
    [_groupPermissions replaceObjectAtIndex:0 withObject:model];
    
    model = _groupPermissions.lastObject;
    if (_isPublic) {
        model.title = NSLocalizedString(@"group.openJoin", @"Join the group freely");
        model.type = AgoraGroupInfoType_openJoin;
    }
    else {
        model.title = @"Allow members to invite";
        model.type = AgoraGroupInfoType_canAllInvite;
    }
    [_groupPermissions replaceObjectAtIndex:1 withObject:model];
    [self.tableView reloadData];
}


#pragma mark - Action
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonAction {
    if (self.groupNameCell.titleTextField.text.length == 0) {
        [self showAlertWithMessage:@"请输入群组标题"];
        return;
    }
    
    AgoraMemberSelectViewController *selectVC = [[AgoraMemberSelectViewController alloc] initWithInvitees:@[] maxInviteCount:0];
    selectVC.style = AgoraContactSelectStyle_Add;
    selectVC.title = @"Add Members";
    selectVC.delegate = self;
    [self.navigationController pushViewController:selectVC animated:YES];
        
}


- (void)permissionSelectAction:(UISwitch *)permissionSwitch {
    if (permissionSwitch.tag == AgoraGroupInfoType_groupType) {
        _isPublic = permissionSwitch.isOn;
        [self updatePermission];
    }
    else {
        _isAllowMemberInvite = permissionSwitch.isOn;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return self.groupNameCell;
    }
    
    if (indexPath.row == 1) {
        return self.descriptionCell;
    }
    
    if (indexPath.row == 2) {
        return self.maxGroupNumberCell;
    }
    
    
    AgoraGroupPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:agoraGroupPermissionCellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupPermissionCell" owner:self options:nil] lastObject];
    }
    
    if (indexPath.row == 3) {
        cell.model = _groupPermissions[0];
    }
    
    if (indexPath.row == 4) {
        cell.model = _groupPermissions[1];
    }

    cell.permissionSwitch.tag = cell.model.type;
    [cell.permissionSwitch addTarget:self
                              action:@selector(permissionSelectAction:)
                    forControlEvents:UIControlEventValueChanged];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 134.0f;
    }
    return 54.0f;
}


#pragma mark - AgoraGroupUIProtocol
- (void)addSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
    
//    [self.occupants addObjectsFromArray:modelArray];
//    [self.membersCollection reloadSections:[NSIndexSet indexSetWithIndex:1]];
//    for (AgoraUserModel *model in modelArray) {
//        [_invitees addObject:model.hyphenateId];
//    }
//    [self updateMemberCountLabel];
    
    for (AgoraUserModel *model in modelArray) {
        [self.invitees addObject:model.hyphenateId];
    }
    
    AgoraChatGroupOptions *options = [[AgoraChatGroupOptions alloc] init];
    options.maxUsersCount = KAgora_GROUP_MAgoraBERSCOUNT;
    if (_isPublic) {
        options.style = _isAllowMemberInvite ? AgoraChatGroupStylePublicOpenJoin : AgoraChatGroupStylePublicJoinNeedApproval;
    }
    else {
        options.style = _isAllowMemberInvite ? AgoraChatGroupStylePrivateMemberCanInvite : AgoraChatGroupStylePrivateOnlyOwnerInvite;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.inviteToJoin", @"%@ invite you to join the group [%@]"),[AgoraChatClient sharedClient].currentUsername, self.groupNameCell.titleTextField.text];

    ACD_WS
    [[AgoraChatClient sharedClient].groupManager createGroupWithSubject:self.groupNameCell.titleTextField.text
                                                     description:self.descriptionCell.contentTextView.text
                                                        invitees:self.invitees
                                                         message:message
                                                         setting:options
                                                      completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
      if (!aError) {
        dispatch_async(dispatch_get_main_queue(), ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION
                                                                  object:nil];
          });
          
          //跳转到聊天页面
          
          [self backAction];
      }
      else {
         [weakSelf showAlertWithMessage:NSLocalizedString(@"group.createFailure", @"Create group failure")];
     }
        
    }];
}


#pragma mark getter
- (ACDTextFieldCell *)groupNameCell {
    if (_groupNameCell == nil) {
        _groupNameCell = ACDTextFieldCell.new;
        _groupNameCell.nameLabel.text = @"Group Name";
    }
    return _groupNameCell;
}

- (ACDTextViewCell *)descriptionCell {
    if (_descriptionCell == nil) {
        _descriptionCell = ACDTextViewCell.new;
    }
    return _descriptionCell;
}

- (ACDMAXGroupNumberCell *)maxGroupNumberCell {
    if (_maxGroupNumberCell == nil) {
        _maxGroupNumberCell = ACDMAXGroupNumberCell.new;
        _maxGroupNumberCell.nameLabel.text = @"Maximum Mumber";
    }
    return _maxGroupNumberCell;
}

- (NSMutableArray<NSString *> *)invitees {
    if (_invitees == nil) {
        _invitees = [NSMutableArray array];
    }
    return _invitees;
}

@end
