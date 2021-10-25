//
//  AgoraGroupEnterController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraGroupEnterController.h"
#import "AgoraContactListController.h"
#import "ACDGroupEnterCell.h"

#import "AgoraCreateNewGroupViewController.h"
#import "AgoraCreateNewGroupNewViewController.h"


static NSString *cellIdentifier = @"AgoraGroupEnterCell";

@interface AgoraGroupEnterController ()
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *cellArray;
@property (nonatomic, strong) AgoraContactListController *contactVC;

@end

@implementation AgoraGroupEnterController

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

//- (void)prepare {
//    [self.view addSubview:self.searchBar];
//    [self.view addSubview:self.table];
//    [self.view addSubview:self.contactVC.view];
//}
//
//- (void)placeSubViews {
//    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view);
//        make.left.equalTo(self.view).offset(12.0);
//        make.right.equalTo(self.view).offset(-12.0);
//        make.height.equalTo(@40.0);
//    }];
//
//    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.searchBar.mas_bottom);
//        make.left.equalTo(self.view).offset(12.0);
//        make.right.equalTo(self.view).offset(-12.0);
//        make.height.equalTo(@(44.0 * 4));
//    }];
//
//    [self.contactVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.table.mas_bottom);
//        make.left.equalTo(self.view).offset(12.0);
//        make.right.equalTo(self.view).offset(-12.0);
//        make.bottom.equalTo(self.view);
//    }];
//
//}

#pragma mark private method
- (void)createNewGroup {
//    AgoraCreateNewGroupViewController *vc = AgoraCreateNewGroupViewController.new;
    AgoraCreateNewGroupNewViewController *vc = AgoraCreateNewGroupNewViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDGroupEnterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ACDGroupEnterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
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

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self createNewGroup];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

#pragma mark getter and setter
- (AgoraContactListController *)contactVC {
    if (_contactVC == nil) {
        _contactVC = AgoraContactListController.new;
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
