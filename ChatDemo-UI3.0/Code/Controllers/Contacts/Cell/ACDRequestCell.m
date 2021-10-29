//
//  ACDRequestCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/27.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDRequestCell.h"

@interface ACDRequestCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIButton *rejectButton;

@end


@implementation ACDRequestCell
- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.acceptButton];
    [self.contentView addSubview:self.rejectButton];
}


- (void)placeSubViews {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@58.0f);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@58.0f);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@58.0f);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@58.0f);
    }];

    [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@58.0f);
    }];

    [self.rejectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@58.0f);
    }];

}

#pragma mark action
- (void)acceptButtonAction {
    if (self.acceptBlock) {
        self.acceptBlock();
    }
}

- (void)rejectButtonAction {
    if (self.rejectBlock) {
        self.rejectBlock();
    }
}


#pragma mark getter and setter
- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14.0f];
        _timeLabel.textColor = COLOR_HEX(0x000000);
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _timeLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14.0f];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = COLOR_HEX(0x000000);
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _contentLabel;
}


- (UIButton *)acceptButton {
    if (_acceptButton == nil) {
        _acceptButton = [[UIButton alloc] init];
        _acceptButton.backgroundColor = UIColor.redColor;
        _acceptButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
        [_acceptButton addTarget:self action:@selector(acceptButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _acceptButton;
}

- (UIButton *)rejectButton {
    if (_rejectButton == nil) {
        _rejectButton = [[UIButton alloc] init];
        _rejectButton.backgroundColor = UIColor.redColor;
        [_rejectButton addTarget:self action:@selector(rejectButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_rejectButton setImage:ImageWithName(@"request_reject") forState:UIControlStateNormal];
    }
    return _rejectButton;
}


@end
