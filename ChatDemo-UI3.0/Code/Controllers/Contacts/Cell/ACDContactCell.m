//
//  ACDContactCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContactCell.h"
#import "AgoraUserModel.h"

@implementation ACDContactCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
}

- (void)placeSubViews {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kAgroaPadding * 0.5);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.width.equalTo(@40.0f);
        make.bottom.equalTo(self.contentView).offset(-kAgroaPadding * 0.5);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.5);
    }];
}

#pragma mark setter
- (void)setModel:(AgoraUserModel *)model {
    if (_model != model) {
        _model = model;
    }
    self.nameLabel.text = _model.nickname;
    self.iconImageView.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_model.avatarURLPath] placeholderImage:_model.defaultAvatarImage];
    }
    else {
        self.iconImageView.image = _model.defaultAvatarImage;
    }
}


@end
