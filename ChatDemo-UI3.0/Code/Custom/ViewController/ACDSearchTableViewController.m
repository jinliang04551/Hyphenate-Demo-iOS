//
//  AgoraSearchTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSearchTableViewController.h"
#import "AgoraRealtimeSearchUtils.h"

#define kSearchBarHeight 30.0f

@interface ACDSearchTableViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL isSearchState;

@end

@implementation ACDSearchTableViewController
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
        make.height.mas_equalTo(kSearchBarHeight);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-5.0);

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
    
    [_searchResults removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.table reloadData];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchResults = [NSMutableArray arrayWithArray:results];
                if (weakSelf.searchResultBlock) {
                    weakSelf.searchResultBlock();
                }
                
                [weakSelf.table reloadData];
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
    if (self.searchCancelBlock) {
        self.searchCancelBlock();
    }
    [self.searchResults removeAllObjects];
    self.table.scrollEnabled = !_isSearchState;
    [self.table reloadData];
}

#pragma mark getter and setter
- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _searchBar.placeholder = @"Search";
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
        [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:COLOR_HEX(0xF2F2F2) size:_searchBar.bounds.size] forState:UIControlStateNormal];
        
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
          if (searchField) {
              [searchField setBackgroundColor:[UIColor whiteColor]];
              searchField.layer.cornerRadius = 14.0f;
              searchField.layer.masksToBounds = YES;
          }
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

