//
//  AgoraSearchTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraSearchTableViewController.h"
#import "AgoraRealtimeSearchUtils.h"

#define kSearchBarHeight 40.0f

@interface AgoraSearchTableViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL isSearchState;

@end

@implementation AgoraSearchTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepare {
    [super prepare];
    [self.view addSubview:self.searchBar];
}

- (void)placeSubViews {
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@kSearchBarHeight);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(40, 0, 0, 0));
    }];

}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    self.table.userInteractionEnabled = NO;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.table.userInteractionEnabled = YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.table.userInteractionEnabled = YES;
    if (searchBar.text.length == 0) {
        [_searchResults removeAllObjects];
        [self.table reloadData];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchResults = [NSMutableArray arrayWithArray:results];
                if (weakSelf.searchResultNullBlock && _searchResults.count == 0) {
                    weakSelf.searchResultNullBlock();
                }else {
                    [weakSelf.table reloadData];
                }
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
    self.table.scrollEnabled = !_isSearchState;
    [self.table reloadData];
}

#pragma mark getter and setter
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.barTintColor = [UIColor whiteColor];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.placeholder = @"Search";
        _searchBar.layer.cornerRadius = kSearchBarHeight * 0.5;
        _searchBar.backgroundColor = UIColor.whiteColor;
    }
    
    return _searchBar;
}


- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}


- (NSMutableArray *)searchResults {
    if (_searchResults == nil) {
        _searchResults = NSMutableArray.new;
    }
    return _searchResults;
}

@end
#undef kSearchBarHeight

