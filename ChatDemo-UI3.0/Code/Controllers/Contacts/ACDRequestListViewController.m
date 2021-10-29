//
//  AgoraRequestListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDRequestListViewController.h"
#import "MISScrollPage.h"
#import "ACDRequestCell.h"

@interface ACDRequestListViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>

@end

@implementation ACDRequestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return [self.searchResults count];
    }
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AgoraGroupCell";
    ACDRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ACDRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}


#pragma mark getter and setter
- (UITableView *)table {
    if (_table == nil) {
        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_table registerClass:[ACDRequestCell class] forCellReuseIdentifier:[ACDRequestCell reuseIdentifier]];
        
    }
    return _table;
}

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
