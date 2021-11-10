//
//  ACDJoinGroupViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/25.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDJoinGroupViewController.h"
#import "ACDSearchResultView.h"
#import "ACDSearchTableViewController.h"
#import "AgoraRealtimeSearchUtils.h"
#import "ACDSearchJoinCell.h"

#define kSearchBarHeight 40.0f

@interface ACDJoinGroupViewController ()
@property (nonatomic, strong) ACDSearchResultView *resultView;
@property (nonatomic, strong) ACDSearchJoinCell *searchJoincell;
@end

@implementation ACDJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isSearchGroup) {
        self.title = @"Join a Group";
    }else {
        self.title = @"Add Contacts";
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
               
           }
           else {
               NSString *msg = NSLocalizedString(@"group.requestFailure", @"Failed to apply to the group");
               [weakSelf showAlertWithMessage:msg];
           }
       }
     ];
}


- (void)sendAddContact:(NSString *)contactName {
    NSString *requestMessage = [NSString stringWithFormat:@"%@ add you as a friend",contactName];
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[AgoraChatClient sharedClient].contactManager addContact:contactName
                                               message:requestMessage
                                            completion:^(NSString *aUsername, AgoraChatError *aError) {
        [MBProgressHUD hideHUDForView:weakSelf.navigationController.view animated:YES];
        if (!aError) {
            NSString *msg =  @"You request has been sent.";
            [weakSelf showAlertWithMessage:msg];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else {
            [weakSelf showAlertWithMessage:aError.errorDescription];
        }
    }];
}



#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.dataArray = [@[searchText] mutableCopy];
    self.searchSource = self.dataArray;
    [self.table reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    self.searchSource = [@[] mutableCopy];
    self.table.scrollEnabled = NO;
    [self.table reloadData];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = @"";
    if (self.isSearchGroup) {
        title = [NSString stringWithFormat:@"GroupID：%@",self.searchSource[0]];
    }else {
        title = [NSString stringWithFormat:@"AgoraID：%@",self.searchSource[0]];
    }

    self.searchJoincell.nameLabel.text = title;
    return self.searchJoincell;
}


#pragma mark getter and setter
- (ACDSearchResultView *)resultView {
    if (_resultView == nil) {
        _resultView = [[ACDSearchResultView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30.0)];
    }
    
    return _resultView;
}


- (ACDSearchJoinCell *)searchJoincell {
    if (_searchJoincell == nil) {
        _searchJoincell = [[ACDSearchJoinCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDSearchJoinCell reuseIdentifier]];
        ACD_WS
        _searchJoincell.tapCellBlock = ^{
            if (weakSelf.isSearchGroup) {
                [weakSelf joinToPublicGroup:weakSelf.searchSource[0]];

            }else {
                [weakSelf sendAddContact:weakSelf.searchSource[0]];
            }
        };
    }
    return _searchJoincell;
}


@end

#undef kSearchBarHeight
