//
//  AgoraGroupEnterController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupEnterController.h"
#import "ACDContactListController.h"
#import "ACDGroupEnterCell.h"

#import "AgoraCreateNewGroupViewController.h"
#import "AgoraCreateNewGroupNewViewController.h"

#import "ACDPublicGroupListViewController.h"
#import "AgoraAddContactViewController.h"

#import "ACDGroupInfoViewController.h"

#import "ACDJoinGroupViewController.h"

static NSString *cellIdentifier = @"AgoraGroupEnterCell";

@interface ACDGroupEnterController ()
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *cellArray;
@property (nonatomic, strong) ACDContactListController *contactVC;

@end

@implementation ACDGroupEnterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"create";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
    
    [self.table reloadData];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepare {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.table];
}

- (void)placeSubViews {
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        [self.view addSubview:self.searchBar];
        [self.view addSubview:self.table];

        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view).offset(12.0);
            make.right.equalTo(self.view).offset(-12.0);
            make.height.equalTo(@40.0);
        }];
        
        [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom);
            make.left.equalTo(self.view).offset(12.0);
            make.right.equalTo(self.view).offset(-12.0);
            make.bottom.equalTo(self.view);
        }];

    }
    
    
    if (self.accessType == ACDGroupEnterAccessTypeContact) {
        [self.view addSubview:self.searchBar];
        [self.view addSubview:self.table];

        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view).offset(12.0);
            make.right.equalTo(self.view).offset(-12.0);
            make.height.equalTo(@40.0);
        }];
        
        [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom);
            make.left.equalTo(self.view).offset(12.0);
            make.right.equalTo(self.view).offset(-12.0);
            make.bottom.equalTo(self.view);
        }];
    }
}


#pragma mark private method
- (void)goCreateNewGroup {
    AgoraCreateNewGroupNewViewController *vc = AgoraCreateNewGroupNewViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)joinPublicGroup {
    ACDJoinGroupViewController *vc = ACDJoinGroupViewController.new;
    vc.isSearchGroup = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goPublicGroupList {
    ACDPublicGroupListViewController *vc = ACDPublicGroupListViewController.new;
    vc.selectedBlock = ^(NSString * _Nonnull groupId) {
        ACDGroupInfoViewController *vc = [[ACDGroupInfoViewController alloc] initWithGroupId:groupId];
        vc.accessType = ACDGroupInfoAccessTypeSearch;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];

    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goAddContact {
    ACDJoinGroupViewController *vc = ACDJoinGroupViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        return 4;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDGroupEnterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ACDGroupEnterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        if (indexPath.row == 0) {
            [cell.iconImageView setImage:ImageWithName(@"new_group")];
            cell.nameLabel.text = @"New Group";
        }
        
        if (indexPath.row == 1) {
            [cell.iconImageView setImage:ImageWithName(@"join_group")];
            cell.nameLabel.text = @"Join a Group";
        }

        if (indexPath.row == 2) {
            [cell.iconImageView setImage:ImageWithName(@"public_group")];
            cell.nameLabel.text = @"Public Group List";
        }

        if (indexPath.row == 3) {
            [cell.iconImageView setImage:ImageWithName(@"add_contact")];
            cell.nameLabel.text = @"Add Contacts";
        }
    }else {
        if (indexPath.row == 0) {
            [cell.iconImageView setImage:ImageWithName(@"add_contact")];
            cell.nameLabel.text = @"Add Contacts";
        }

        if (indexPath.row == 1) {
            [cell.iconImageView setImage:ImageWithName(@"join_group")];
            cell.nameLabel.text = @"Join a Group";
        }

        if (indexPath.row == 2) {
            [cell.iconImageView setImage:ImageWithName(@"public_group")];
            cell.nameLabel.text = @"Public Group List";
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        if (indexPath.row == 0) {
            [self goCreateNewGroup];
        }
        
        if (indexPath.row == 1) {
            [self joinPublicGroup];
        }
        
        if (indexPath.row == 2) {
            [self goPublicGroupList];
        }

        if (indexPath.row == 3) {
            [self goAddContact];
        }
    }else {
        if (indexPath.row == 0) {
            [self goAddContact];
        }
        
        if (indexPath.row == 1) {
            [self joinPublicGroup];
        }
        
        if (indexPath.row == 2) {
            [self goPublicGroupList];
        }

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

#pragma mark getter and setter
- (ACDContactListController *)contactVC {
    if (_contactVC == nil) {
        _contactVC = ACDContactListController.new;
        _contactVC.view.hidden = YES;
    }
    return _contactVC;
}

- (UITableView *)table {
    if (!_table) {
        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = UIColor.whiteColor;
        
         [_table registerClass:[ACDGroupEnterCell class] forCellReuseIdentifier:[ACDGroupEnterCell reuseIdentifier]];

    }
    return _table;
}

@end
