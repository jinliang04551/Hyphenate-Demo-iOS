//
//  AgoraContactInfoNewViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraContactInfoNewViewController.h"
#import "AgoraContactInfoViewController.h"
#import "UIImage+ImageEffect.h"
#import "AgoraUserModel.h"
#import "AgoraContactInfoCell.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraChatViewController.h"
#import "AgoraInfoHeaderView.h"

static NSString *cellIdentify = @"AgoraContactCell";

#define NAME                NSLocalizedString(@"contact.name", @"Name")
#define HYPHENATE_ID        NSLocalizedString(@"contact.hyphenateId", @"Hyphenate ID")
#define APNS_NICKNAME       NSLocalizedString(@"contact.apnsnickname", @"iOS APNS")
#define DELETE_CONTACT      NSLocalizedString(@"contact.delete", @"Delete Contact")
#define ADD_BLACKLIST       NSLocalizedString(@"contact.block", @"Black Contact")

#define KContactInfoKey     @"contactInfoKey"
#define KContactInfoValue   @"contactInfoValue"
#define KContactInfoTitle   @"contactInfoTitle"

typedef enum : NSUInteger {
    AgoraContactInfoActionNone,
    AgoraContactInfoActionDelete,
    AgoraContactInfoActionBlackList,
} AgoraContactInfoAction;

@interface AgoraContactInfoNewViewController ()<UIActionSheetDelegate, AgoraContactsUIProtocol,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) AgoraInfoHeaderView *headerView;
@property (nonatomic, strong) AgoraUserModel *model;
@property (nonatomic, strong) UITableView *table;

@end

@implementation AgoraContactInfoNewViewController
{
    NSArray *_contactInfo;
    NSArray *_contactActions;
}

- (instancetype)initWithUserModel:(AgoraUserModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self loadContactInfo];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)loadContactInfo {
    self.headerView.nameLabel.text = _model.nickname;
    self.headerView.avatarImageView.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [self.headerView.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Action

//- (IBAction)backAction:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//
//- (IBAction)chatAction:(id)sender {
//    AgoraChatViewController *chatViewController = [[AgoraChatViewController alloc] initWithConversationId:_model.hyphenateId conversationType:AgoraChatConversationTypeChat];
//    [self.navigationController pushViewController:chatViewController animated:YES];
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        [scrollView setContentOffset:contentOffset];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraChatCustomBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[AgoraChatCustomBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    
    if (indexPath.row == 0) {
        [cell.imageView setImage:ImageWithName(@"blocked")];
        cell.textLabel.text = @"block";
    }
    
    if (indexPath.row == 1) {
        [cell.imageView setImage:ImageWithName(@"delete")];
        cell.textLabel.text = @"delete";
    }

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Block this contact now?" message:@"When you block this contact, you will not receive any messages from them." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alertController addAction:cancelAction];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"Block" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self addBlackList];
        }]];
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    if (indexPath.row == 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete this contact now?" message:@"Delete this contact and associated Chats." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alertController addAction:cancelAction];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"Delete" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self deleteContact];
        }]];
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];

    }}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}


#pragma mark - UIActionSheetDelegate
- (void)deleteContact {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient].contactManager deleteContact:_model.hyphenateId isDeleteConversation:YES completion:^(NSString *aUsername, AgoraChatError *aError) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!aError) {
            if (self.deleteContactBlock) {
                self.deleteContactBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.deleteFailure", @"Delete contacts failed")];
        }
    }];
}

- (void)addBlackList {
    [[AgoraChatClient sharedClient].contactManager addUserToBlackList:_model.hyphenateId completion:^(NSString *aUsername, AgoraChatError *aError) {
        if ((!aError)) {
            if (self.addBlackListBlock) {
                self.addBlackListBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.blockFailure", @"Black failure")];
        }
    }];
    
}

#pragma mark - AgoraContactsUIProtocol
- (void)needRefreshContactsFromServer:(BOOL)isNeedRefresh {
    if (isNeedRefresh) {
        [[AgoraChatDemoHelper shareHelper].contactsVC loadContactsFromServer];
    }
    else {
        [[AgoraChatDemoHelper shareHelper].contactsVC reloadContacts];
    }
}

#pragma mark getter and setter
- (AgoraInfoHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[AgoraInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180) withType:AgoraHeaderInfoTypeContact];
        _headerView.backgroundColor = UIColor.grayColor;
        
        ACD_WS
        _headerView.tapHeaderBlock = ^{
            
        };
        
        _headerView.goChatPageBlock = ^{
            AgoraChatViewController *chatViewController = [[AgoraChatViewController alloc] initWithConversationId:weakSelf.model.hyphenateId conversationType:AgoraChatConversationTypeChat];
            [weakSelf.navigationController pushViewController:chatViewController animated:YES];
        };
        
        _headerView.goBackBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];

        };
    }
    return _headerView;
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
//        [_table registerClass:[self.viewModel cellClass] forCellReuseIdentifier:[self.viewModel cellReuseIdentifier]];

    }
    return _table;
}


@end


#undef NAME
#undef HYPHENATE_ID
#undef DELETE_CONTACT
#undef ADD_BLACKLIST
#undef KContactInfoKey
#undef KContactInfoValue
#undef KContactInfoTitle




