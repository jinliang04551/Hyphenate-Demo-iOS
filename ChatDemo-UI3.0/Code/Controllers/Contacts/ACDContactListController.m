//
//  AgoraContactListController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContactListController.h"
#import "MISScrollPage.h"
#import "AgoraContactsViewController.h"
#import "AgoraContactListSectionHeader.h"
#import "AgoraAddContactViewController.h"
//#import "AgoraContactInfoViewController.h"
#import "ACDContactInfoViewController.h"

#import "AgoraChatroomsViewController.h"
#import "AgoraGroupTitleCell.h"
#import "AgoraContactCell.h"
#import "AgoraUserModel.h"
#import "AgoraApplyManager.h"
#import "AgoraGroupsViewController.h"
#import "AgoraApplyRequestCell.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraRealtimeSearchUtils.h"
#import "NSArray+AgoraSortContacts.h"

#define KAgora_CONTACT_BASICSECTION_NUM  3

static NSString *cellIdentify = @"AgoraContactCell";

@interface ACDContactListController ()<MISScrollPageControllerContentSubViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *contactRequests;


@end

@implementation ACDContactListController
{
    NSMutableArray *_sectionTitles;
    NSMutableArray *_searchSource;
    NSMutableArray *_searchResults;
    BOOL _isSearchState;
}

#pragma mark life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingBlackListDidChange) name:@"AgoraSettingBlackListDidChange" object:nil];
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.yellowColor;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self tableDidTriggerHeaderRefresh];
}


- (void)tableDidTriggerHeaderRefresh {
    if (_isSearchState) {
        [self tableViewDidFinishTriggerHeader:YES];
        return;
    }
    
    WEAK_SELF
    [[AgoraChatClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, AgoraChatError *aError) {
        if (aError == nil) {
            [weakSelf tableViewDidFinishTriggerHeader:YES];
            dispatch_async(dispatch_get_global_queue(0, 0), ^(){
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [weakSelf updateContacts:aList];
                    [weakSelf.tableView reloadData];
                });
            });
        
        }
        else {
            [weakSelf tableViewDidFinishTriggerHeader:YES];
        }
    }];
}

- (void)loadContactsFromServer
{
    [self tableDidTriggerHeaderRefresh];
}

- (void)reloadContacts {
    NSArray *bubbyList = [[AgoraChatClient sharedClient].contactManager getContacts];
    [self updateContacts:bubbyList];
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^(){
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
    });
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
        self.contacts = [@[] mutableCopy];
        _sectionTitles = [@[] mutableCopy];
        _searchSource = [@[] mutableCopy];
        return;
    }
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:contacts
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.contacts removeAllObjects];
    [self.contacts addObjectsFromArray:sortArray];
    _sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    _searchSource = [NSMutableArray arrayWithArray:searchSource];
}


#pragma mark NSNotification
- (void)settingBlackListDidChange {
    [self reloadContacts];
}

#pragma mark - Lazy Method
- (NSMutableArray *)contacts {
    if (!_contacts) {
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}

#pragma mark - Action Method
- (void)addContactAction {
    AgoraAddContactViewController *addContactVc = [[AgoraAddContactViewController alloc] initWithNibName:@"AgoraAddContactViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addContactVc];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    if (_isSearchState) {
        return 1;
    }
    return  _sectionTitles.count;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)table {
    return _sectionTitles;
}

- (NSInteger)table:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSInteger)table:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return _searchResults.count;
    }
   
    return ((NSArray *)self.contacts[section]).count;
}

- (CGFloat)table:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}


- (UITableViewCell *)table:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraContactCell *cell = [table dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = (AgoraContactCell *)[[[NSBundle mainBundle] loadNibNamed:@"AgoraContactCell" owner:self options:nil] lastObject];
    }

    if (_isSearchState) {
        cell.model = _searchResults[indexPath.row];
    }else {
        cell.model = self.contacts[indexPath.row];
    }
    return cell;

}

#pragma mark - Table view delegate
- (void)table:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [table deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && !_isSearchState) {
        if (indexPath.row == 0) {
            AgoraGroupsViewController *groupsVc = [[AgoraGroupsViewController alloc] initWithNibName:@"AgoraGroupsViewController" bundle:nil];
            [self.navigationController pushViewController:groupsVc animated:YES];
        } else if (indexPath.row == 1) {
            AgoraChatroomsViewController *chatroomsVC = [[AgoraChatroomsViewController alloc] init];
            [self.navigationController pushViewController:chatroomsVC animated:YES];
        }
        
        return;
    }
    
    AgoraUserModel * model = nil;
    if (_isSearchState) {
        model = _searchResults[indexPath.row];
    }
    else if (indexPath.section >= KAgora_CONTACT_BASICSECTION_NUM) {
        NSArray *sectionContacts = _contacts[indexPath.section-KAgora_CONTACT_BASICSECTION_NUM];
        model = sectionContacts[indexPath.row];
    }
    if (model) {
//        AgoraContactInfoViewController *contactInfoVc = [[AgoraContactInfoViewController alloc] initWithUserModel:model];
        ACDContactInfoViewController *contactInfoVc = [[ACDContactInfoViewController alloc] initWithUserModel:model];

        contactInfoVc.addBlackListBlock = ^{
            [self reloadContacts];
        };
        contactInfoVc.deleteContactBlock = ^{
            [self reloadContacts];
        };
        [self.navigationController pushViewController:contactInfoVc animated:YES];
    }
}

#pragma mark
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    self.tableView.userInteractionEnabled = NO;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.tableView.userInteractionEnabled = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.tableView.userInteractionEnabled = YES;
    if (searchBar.text.length == 0) {
        [_searchResults removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchResults = [NSMutableArray arrayWithArray:results];
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    _isSearchState = NO;
    self.tableView.scrollEnabled = !_isSearchState;
    [self.tableView reloadData];
}


#pragma mark getter and setter
//- (UITableView *)table {
//    if (_table == nil) {
//        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
//        _table.delegate        = self;
//        _table.dataSource      = self;
//        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
//        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
//        _table.backgroundColor = UIColor.redColor;
//        _table.clipsToBounds = YES;
//    }
//    return _table;
//}


#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    NSLog(@"---------- viewDidLoadedForIndex ---------- %lu", (unsigned long)index);
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewWillAppearForIndex ---------- %lu", (unsigned long)index);
}

- (void)viewDidAppearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewDidAppearForIndex ---------- %lu", (unsigned long)index);
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewWillDisappearForIndex ---------- %lu", (unsigned long)index);
    
    self.editing = NO;
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    NSLog(@"---------- viewDidDisappearForIndex ---------- %lu", (unsigned long)index);
}

@end
