//
//  AgoraInfoBaseHeaderView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraInfoHeaderView.h"
#import "ACDImageTextButtonView.h"

#define kHeaderImageViewHeight  80.0f

@interface AgoraInfoHeaderView ()
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) ACDImageTextButtonView *buttonView;
@property (nonatomic, assign) AgoraHeaderInfoType infoType;

@end


@implementation AgoraInfoHeaderView
#pragma mark life cycle
- (instancetype)initWithFrame:(CGRect)frame
                     withType:(AgoraHeaderInfoType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.infoType = type;
        [self placeAndLayoutSubviews];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderViewAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (instancetype)initWithType:(AgoraHeaderInfoType)type {
    self = [super init];
    if (self) {
        self.infoType = type;
        [self placeAndLayoutSubviews];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderViewAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    if (self.infoType == AgoraHeaderInfoTypeContact) {
        [self placeAndLayoutForContactInfo];
    }

    if (self.infoType == AgoraHeaderInfoTypeGroup) {
        [self placeAndLayoutForGroupInfo];
    }
    
    if (self.infoType == AgoraHeaderInfoTypeMe) {
        [self placeAndLayoutForMeInfo];
    }
    
}

- (void)placeAndLayoutForContactInfo {
    [self addSubview:self.backButton];
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.userIdLabel];
//    [self addSubview:self.chatButton];
    [self addSubview:self.buttonView];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(kAgroaPadding * 4.4);
        make.left.equalTo(self).offset(kAgroaPadding);
        make.size.mas_equalTo(28.0);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(kAgroaPadding * 0.5);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(140.0);
        make.height.mas_equalTo(140.0);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatarImageView.mas_bottom).offset(kAgroaPadding);
        make.left.equalTo(self).offset(kAgroaPadding * 2);
        make.right.equalTo(self).offset(-kAgroaPadding * 2);
        make.height.mas_equalTo(28.0);
    }];
    
    [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom);
        make.left.equalTo(self).offset(kAgroaPadding * 2);
        make.right.equalTo(self).offset(-kAgroaPadding * 2);
        make.height.mas_equalTo(28.0);
    }];
    
    [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIdLabel.mas_bottom).offset(kAgroaPadding);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(120.0);
        make.height.mas_equalTo(100.0);
        make.bottom.equalTo(self).offset(-kAgroaPadding);
    }];
}

- (void)placeAndLayoutForGroupInfo {
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.userIdLabel];
    [self addSubview:self.describeLabel];
    [self addSubview:self.chatButton];
    
   
}

- (void)placeAndLayoutForMeInfo {
    
}


#pragma mark action
- (void)backAction {
    if (self.goBackBlock) {
        self.goBackBlock();
    }
}

- (void)goChatPageAction {
    if (self.goChatPageBlock) {
        self.goChatPageBlock();
    }
}

- (void)tapHeaderViewAction {
    if (self.tapHeaderBlock) {
        self.tapHeaderBlock();
    }
}


#pragma mark getter and setter
- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        _backButton.contentMode = UIViewContentModeScaleAspectFill;
        [_backButton setImage:ImageWithName(@"black_goBack") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIImageView *)backImageView {
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backImageView.image = ImageWithName(@"black_goBack");
    }
    return _backImageView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeCenter;
        _avatarImageView.image = ImageWithName(@"default_avatar");
        _avatarImageView.backgroundColor = UIColor.yellowColor;
    }
    return _avatarImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:20.0f];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textColor = COLOR_HEX(0x0D0D0D);
        _nameLabel.text = @"agoraChat";
        _nameLabel.backgroundColor = UIColor.blueColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)userIdLabel {
    if (_userIdLabel == nil) {
        _userIdLabel = [[UILabel alloc] init];
        _userIdLabel.font = [UIFont systemFontOfSize:12.0f];
        _userIdLabel.numberOfLines = 1;
        _userIdLabel.textColor = COLOR_HEX(0x999999);
        _userIdLabel.text = @"001";
        _userIdLabel.backgroundColor = UIColor.redColor;
        _userIdLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _userIdLabel;
}

- (UILabel *)describeLabel {
    if (_describeLabel == nil) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.font = [UIFont systemFontOfSize:14.0];
        _describeLabel.numberOfLines = 1;
        _describeLabel.textColor = COLOR_HEX(0x000000);
        _describeLabel.text = @"xxxxxxxxxxxx";
        _describeLabel.backgroundColor = UIColor.blueColor;
        _describeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _describeLabel;
}

- (UIButton *)chatButton {
    if (_chatButton == nil) {
        _chatButton = [[UIButton alloc] init];
        _chatButton.backgroundColor = UIColor.redColor;
        _chatButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_chatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_chatButton setTitle:@"chat" forState:UIControlStateNormal];
        [_chatButton addTarget:self action:@selector(goChatPageAction) forControlEvents:UIControlEventTouchUpInside];
//        [_chatButton.imageView setImage:ImageWithName(@"message")];
        [_chatButton setImage:ImageWithName(@"start_chat") forState:UIControlStateNormal];

        
    }
    return _chatButton;
}

- (ACDImageTextButtonView *)buttonView {
    if (_buttonView == nil) {
        _buttonView = [[ACDImageTextButtonView alloc] init];
        [_buttonView.iconImageView setImage:ImageWithName(@"start_chat")];
        _buttonView.titleLabel.text = @"chat";
        [_buttonView.tapBtn addTarget:self action:@selector(goChatPageAction) forControlEvents:UIControlEventTouchUpInside];
        _buttonView.backgroundColor = UIColor.yellowColor;
        
    }
    return _buttonView;
}

@end

#undef kHeaderImageViewHeight


