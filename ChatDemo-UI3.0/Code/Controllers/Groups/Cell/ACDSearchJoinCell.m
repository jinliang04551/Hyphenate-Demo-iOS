//
//  ACDSearchJoinCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSearchJoinCell.h"

@interface ACDSearchJoinCell ()
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation ACDSearchJoinCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.addButton];
//    self.nameLabel.backgroundColor = UIColor.blueColor;
//    self.contentView.backgroundColor = UIColor.grayColor;
}

- (void)placeSubViews {
    self.accessoryType = UITableViewCellAccessoryNone;
        
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
        make.right.equalTo(self.addButton.mas_left).offset(-kAgroaPadding * 1.6);
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
        make.width.equalTo(@50.0);
        make.height.equalTo(@30.0f);
    }];
    
}

- (void)addButtonAction {
    self.addButton.selected = !self.addButton.selected;
    if (self.addGroupBlock) {
        self.addGroupBlock();
    }
}

#pragma mark getter and setter
- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [[UIButton alloc] init];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_addButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
        [_addButton setTitleColor:ButtonDisableGrayColor forState:UIControlStateSelected];
        [_addButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_addButton setTitle:@"Applied" forState:UIControlStateSelected];
        
        [_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _addButton;
}

@end

