//
//  ACDGroupEnterNewViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupEnterController.h"
#import "ACDContactListController.h"
#import "ACDGroupEnterCell.h"
#import "ACDContactCell.h"

#import "AgoraCreateNewGroupViewController.h"
#import "ACDCreateNewGroupViewController.h"

#import "ACDPublicGroupListViewController.h"
#import "AgoraAddContactViewController.h"

#import "ACDGroupInfoViewController.h"

#import "ACDJoinGroupViewController.h"

#define kHeaderInSection  30.0

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
    
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        [self fetchAllContactsFromServer];
    }else {
        [self.table reloadData];
    }
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
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark private method
- (void)fetchAllContactsFromServer {
    ACD_WS
    [[AgoraChatClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, AgoraChatError *aError) {
        if (aError == nil) {
            [weakSelf updateContacts:aList];
            [weakSelf.table reloadData];
        }
        else {

        }
    }];
}

- (void)updateContacts:(NSArray *)bubbyList {
    NSArray *blockList = [[AgoraChatClient sharedClient].contactManager getBlackList];
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:bubbyList];
    for (NSString *blockId in blockList) {
        [contacts removeObject:blockId];
    }
    [self sortContacts:contacts];
    
}

- (void)sortContacts:(NSArray *)contacts {
    if (contacts.count == 0) {
        self.dataArray = [@[] mutableCopy];
        self.sectionTitles = [@[] mutableCopy];
        self.searchSource = [@[] mutableCopy];
        return;
    }
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:contacts
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:sortArray];
    self.sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    self.searchSource = [NSMutableArray arrayWithArray:searchSource];
}


- (void)goCreateNewGroup {
    ACDCreateNewGroupViewController *vc = ACDCreateNewGroupViewController.new;
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.accessType == ACDGroupEnterAccessTypeChat && section == 1) {
        return kHeaderInSection;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.accessType == ACDGroupEnterAccessTypeChat && section == 1) {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kHeaderInSection)];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = TextLabelGrayColor;
        label.text = @"Contacts";
        label.textAlignment = NSTextAlignmentLeft;
        
        [sectionView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(sectionView);
            make.left.equalTo(sectionView).offset(16.0);
        }];
        
        return sectionView;

    }
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        if (self.isSearchState) {
            return 1;
        }
        return  self.sectionTitles.count + 1;
    }
    return 1;
    
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        return self.sectionTitles;
    }
    return @[];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        return index;
    }
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        if (self.isSearchState) {
            return self.searchResults.count;
        }
        else {
            if (section == 0) {
                return 4;
            }else {
                NSInteger contactCount = ((NSArray *)self.dataArray[section-1]).count;

                return contactCount;
            }
        }
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ACDContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDContactCell reuseIdentifier]];
    }
    
    if (self.accessType == ACDGroupEnterAccessTypeChat) {
        if (self.isSearchState) {
            cell.model = self.searchResults[indexPath.row];
        }else {
            if (indexPath.section == 0) {
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
             cell.model = self.dataArray[indexPath.section - 1][indexPath.row];
            }
            
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
        if (indexPath.section == 0) {
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
        
        _table.sectionIndexColor = TextLabelGrayColor;
        _table.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    return _table;
}


@end
#undef kHeaderInSection
