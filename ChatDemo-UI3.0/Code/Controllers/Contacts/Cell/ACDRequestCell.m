//
//  ACDRequestCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/27.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDRequestCell.h"
#import "AgoraApplyModel.h"

#define kAcceptButtonHeight 72.0f
#define kIconImageViewHeight 58.0f

@interface ACDRequestCell ()
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIButton *rejectButton;
@property (nonatomic, strong) AgoraApplyModel *model;

@end


@implementation ACDRequestCell
- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.acceptButton];
    [self.contentView addSubview:self.rejectButton];
    [self.contentView addSubview:self.bottomLine];

}


- (void)placeSubViews {
    self.iconImageView.layer.cornerRadius = kIconImageViewHeight * 0.5;
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@kIconImageViewHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12.0f);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.timeLabel.mas_left);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-16.0f);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(kAgroaPadding * 0.5);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.timeLabel);
    }];

    [self.rejectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-kAgroaPadding);
        make.right.equalTo(self.contentView).offset(-16.0f);
        make.size.equalTo(@28.0f);
    }];
    
    [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rejectButton);
        make.right.equalTo(self.rejectButton.mas_left).offset(-5.0);
        make.width.equalTo(@kAcceptButtonHeight);
        make.height.equalTo(@28.0);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(ACD_ONE_PX);
    }];
}

#pragma mark action
- (void)acceptButtonAction {
    if (self.acceptBlock) {
        self.acceptBlock(self.model);
    }
}

- (void)rejectButtonAction {
    if (self.rejectBlock) {
        self.rejectBlock(self.model);
    }
}

- (void)updateWithObj:(id)obj {
    self.model = (AgoraApplyModel*)obj;
    self.nameLabel.text = self.model.applyHyphenateId;
    self.timeLabel.text = @"Now";
    self.contentLabel.text = self.model.reason;
    
//    NSString *iconImageName = @"";
//    if (self.model.style == AgoraApplyStyle_contact) {
//        iconImageName = @"default_avatar";
//    }else {
//        iconImageName = @"group_default_avatar";
//    }
//
//    [self.iconImageView setImage:ImageWithName(iconImageName)];
  
    UIImage *avatarImage = nil;
    if (self.model.style == AgoraApplyStyle_contact) {
        avatarImage = [UIImage imageWithColor:AvatarLightGreenColor size:CGSizeMake(kIconImageViewHeight, kIconImageViewHeight)];
    }else {
        UIImage *originImage = ImageWithName(@"group_default_avatar");
        
        avatarImage = [originImage acd_scaleToAssignSize:CGSizeMake(kIconImageViewHeight, kIconImageViewHeight)];
     }
    
    [self.iconImageView setImage:avatarImage];

    
}

#pragma mark getter and setter
- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14.0f];
        _timeLabel.textColor = TextLabelGrayColor;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _timeLabel.text = @"Now";
    }
    return _timeLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14.0f];
        _contentLabel.numberOfLines = 2;
        _contentLabel.textColor = TextLabelGrayColor;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.text = @"hhhhhh";
    }
    return _contentLabel;
}


- (UIButton *)acceptButton {
    if (_acceptButton == nil) {
        _acceptButton = [[UIButton alloc] init];
        _acceptButton.backgroundColor = ButtonEnableBlueColor;
        _acceptButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
        [_acceptButton addTarget:self action:@selector(acceptButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _acceptButton.layer.cornerRadius = 15.0f;
    }
    return _acceptButton;
}

- (UIButton *)rejectButton {
    if (_rejectButton == nil) {
        _rejectButton = [[UIButton alloc] init];
        [_rejectButton addTarget:self action:@selector(rejectButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_rejectButton setImage:ImageWithName(@"request_reject") forState:UIControlStateNormal];
    }
    return _rejectButton;
}


@end

#undef kAcceptButtonHeight
#undef kIconImageViewHeight

