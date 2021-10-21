//
//  AgoraSearchTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraSearchTableViewController.h"

#define kSearchBarHeight 40.0f

@interface AgoraSearchTableViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchDataArray;
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
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];

        return NO;
    }

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];
}

#pragma mark getter and setter
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.barTintColor = [UIColor whiteColor];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
        CGFloat color = 245 / 255.0;
        searchField.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
        _searchBar.placeholder = @"Search";
        _searchBar.layer.cornerRadius = kSearchBarHeight * 0.5;
    }
    return _searchBar;
}


@end
#undef kSearchBarHeight

