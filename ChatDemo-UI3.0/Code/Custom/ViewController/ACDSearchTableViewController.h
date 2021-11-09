//
//  AgoraSearchTableViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDSearchTableViewController : AgoraBaseTableViewController
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *searchSource;
@property (nonatomic, strong, readonly) NSMutableArray *searchResults;
@property (nonatomic, assign, readonly) BOOL isSearchState;

@property (nonatomic, copy) void (^searchResultNullBlock)(void);


@end

NS_ASSUME_NONNULL_END
