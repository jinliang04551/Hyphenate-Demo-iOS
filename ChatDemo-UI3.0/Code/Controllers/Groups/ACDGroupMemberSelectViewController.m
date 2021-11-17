//
//  ACDGroupMemberSelectViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberSelectViewController.h"
#import "AgoraUserModel.h"
#import "AgoraMemberCollectionCell.h"
#import "AgoraRealtimeSearchUtils.h"
#import "NSArray+AgoraSortContacts.h"
#import "AgoraGroupMemberCell.h"


#define NEXT_TITLE   NSLocalizedString(@"common.next", @"Next")

#define DONE_TITLE   @"Done"

@interface ACDGroupMemberSelectViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AgoraGroupUIProtocol>

@property (strong, nonatomic) NSMutableArray<AgoraUserModel *> *selectContacts;

@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *unselectedContacts;

@property (nonatomic) NSInteger maxInviteCount;


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end


@implementation ACDGroupMemberSelectViewController
{
    UIButton *_doneBtn;
    NSMutableArray *_hasInvitees;
    NSMutableArray *_sectionTitles;
    NSMutableArray *_searchSource;
    NSMutableArray *_searchResults;
    BOOL _isSearchState;
}

- (instancetype)initWithInvitees:(NSArray *)aHasInvitees
                  maxInviteCount:(NSInteger)aCount
{
    self = [super initWithNibName:@"AgoraMemberSelectViewController" bundle:nil];
    if (self) {
        _selectContacts = [NSMutableArray array];
        _unselectedContacts = [NSMutableArray array];
        _hasInvitees = [NSMutableArray arrayWithArray:aHasInvitees];
        _maxInviteCount = aCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupNavBar];
    [self loadUnSelectContacts];
}

- (void)prepare {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.table];
}

- (void)placeSubViews {
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(14.0);
        make.right.equalTo(self.view).offset(-14.0);
        make.height.equalTo(@40.0);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)setupNavBar {
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneBtn.frame = CGRectMake(0, 0, 44, 44);
    [self updateDoneUserInteractionEnabled:NO];
    NSString *title = @"Create";
    if (_style == AgoraContactSelectStyle_Invite) {
        title = DONE_TITLE;
    }

    [_doneBtn setTitle:title forState:UIControlStateNormal];
    [_doneBtn setTitle:title forState:UIControlStateHighlighted];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_doneBtn setTitleColor:TextLabelBlueColor forState:UIControlStateNormal];
    
    [_doneBtn addTarget:self action:@selector(selectDoneAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:_doneBtn];
    [self.navigationItem setRightBarButtonItem:rightBar];
}

- (void)updateHeaderView:(BOOL)isAdd {
//    if (_selectContacts.count > 0 && self.selectConllection.hidden) {
//        CGFloat height = self.selectConllection.frame.size.height;
//        CGRect frame = self.headerView.frame;
//        frame.size.height += height;
//        self.headerView.frame = frame;
//
//        frame = .frame;
//        frame.origin.y += height;
//        frame.size.height -= height;
//        .frame = frame;
//        [_selectConllection reloadData];
//        self.selectConllection.hidden = NO;
//
//        return;
//    }
//    if (_selectContacts.count == 0 && !self.selectConllection.hidden) {
//        self.selectConllection.hidden = YES;
//        CGFloat height = self.selectConllection.frame.size.height;
//        CGRect frame = self.headerView.frame;
//        frame.size.height -= height;
//        self.headerView.frame = frame;
//
//        frame = .frame;
//        frame.origin.y -= height;
//        frame.size.height += height;
//        .frame = frame;
//        [_selectConllection reloadData];
//        return;
//    }
//    if (isAdd) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectContacts.count - 1 inSection:0];
//        [_selectConllection insertItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
//    }
}

- (void)updateDoneUserInteractionEnabled:(BOOL)userInteractionEnabled {
    _doneBtn.userInteractionEnabled = userInteractionEnabled;
    if (userInteractionEnabled) {
        [_doneBtn setTitleColor:TextLabelBlueColor forState:UIControlStateNormal];
        [_doneBtn setTitleColor:TextLabelBlueColor forState:UIControlStateHighlighted];
    }
    else {
        [_doneBtn setTitleColor:CoolGrayColor forState:UIControlStateNormal];
        [_doneBtn setTitleColor:CoolGrayColor forState:UIControlStateHighlighted];
    }
}

- (void)loadUnSelectContacts {
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:[[AgoraChatClient sharedClient].contactManager getContacts]];
    NSArray *blockList = [[AgoraChatClient sharedClient].contactManager getBlackList];
    [contacts removeObjectsInArray:blockList];
    [contacts removeObjectsInArray:_hasInvitees];
    [_hasInvitees removeAllObjects];
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:contacts
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.unselectedContacts addObjectsFromArray:sortArray];
    _sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    _searchSource = [NSMutableArray arrayWithArray:searchSource];
}

- (void)removeOccupantsFromDataSource:(NSArray<AgoraUserModel *> *)modelArray {
    __block NSMutableArray *array = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    __weak NSMutableArray *weakHasInvitees = _hasInvitees;
    [modelArray enumerateObjectsUsingBlock:^(AgoraUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([weakSelf.selectContacts containsObject:obj]) {
            NSUInteger index = [weakSelf.selectContacts indexOfObject:obj];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [array addObject:indexPath];
            [weakHasInvitees removeObject:obj.hyphenateId];
            [weakSelf.selectContacts removeObjectsInArray:modelArray];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (array.count > 0) {
            [weakSelf.collectionView deleteItemsAtIndexPaths:array];
        }
        if (weakSelf.selectContacts.count == 0) {
            [self updateDoneUserInteractionEnabled:NO];
        }
        [weakSelf updateHeaderView:NO];
    });
}

#pragma mark - Action

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectDoneAction {
    if (_delegate && [_delegate respondsToSelector:@selector(addSelectOccupants:)]) {
        [_delegate addSelectOccupants:_selectContacts];
    }
    [self backAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSearchState) {
        return 1;
    }
    return _sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return _searchResults.count;
    }
    return [(NSArray *)_unselectedContacts[section] count];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_isSearchState) {
        return @[];
    }
    return _sectionTitles;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AgoraGroupMember_Invite_Cell";
    AgoraGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AgoraGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    AgoraUserModel *model = nil;
    if (_isSearchState) {
        model = _searchResults[indexPath.row];
    }
    else {
        NSMutableArray *array = _unselectedContacts[indexPath.section];
        model = array[indexPath.row];
    }
    cell.isSelected = [_hasInvitees containsObject:model.hyphenateId];
    cell.isEditing = YES;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView ==  && scrollView.contentOffset.y < 0) {
//        [scrollView setContentOffset:CGPointMake(0, 0)];
//    }
//    if (scrollView == self.selectConllection && scrollView.contentOffset.x < 0) {
//        [scrollView setContentOffset:CGPointMake(0, 0)];
//    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectContacts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AgoraMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AgoraMemberCollection_Edit_Cell" forIndexPath:indexPath];
    cell.model = _selectContacts[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    AgoraUserModel *model = _selectContacts[indexPath.row];
    [self removeOccupantsFromDataSource:@[model]];
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 5, collectionView.frame.size.height);
}


#pragma mark - AgoraGroupUIProtocol
- (void)addSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
    [self.selectContacts addObjectsFromArray:modelArray];
    for (AgoraUserModel *model in modelArray) {
        [_hasInvitees addObject:model.hyphenateId];
    }
    [self updateDoneUserInteractionEnabled:YES];
    [self updateHeaderView:YES];
}

- (void)removeSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
    [self removeOccupantsFromDataSource:modelArray];
}

#pragma mark getter and setter
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
//        [_collectionView registerClass:[ACDAvatarCollectionCell class] forCellWithReuseIdentifier:[ACDAvatarCollectionCell reuseIdentifier]];
        [_collectionView registerNib:[UINib nibWithNibName:@"AgoraMemberCollection_Edit_Cell" bundle:nil] forCellWithReuseIdentifier:@"AgoraMemberCollection_Edit_Cell"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat itemWidth = (KScreenWidth - 5.0 * 2)/2.0;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumLineSpacing = 5.0;
    flowLayout.minimumInteritemSpacing = 5.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0,
                                               0,
                                               0,
                                               0);
    return flowLayout;
}

- (NSMutableArray *)itemArray {
    if (_itemArray == nil) {
        _itemArray = NSMutableArray.new;
    }
    return _itemArray;
}

- (UITableView *)table {
    if (!_table) {
        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = UIColor.whiteColor;
        
//         [_table registerClass:[ACDGroupEnterCell class] forCellReuseIdentifier:[ACDGroupEnterCell reuseIdentifier]];
        
        _table.sectionIndexColor = SectionIndexTextColor;
        _table.sectionIndexBackgroundColor = [UIColor clearColor];
        
        _table.tableFooterView = [UIView new];
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}

- (UIView *)headerView {
    if (_headerView == nil) {
    
        
    }
    
    return _headerView;
}

@end
