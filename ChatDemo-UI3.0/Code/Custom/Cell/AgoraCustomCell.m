//
//  AgoraCustomCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/20.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraCustomCell.h"

#define kIconImageViewHeight 20.0f

@interface AgoraCustomCell ()

@end

@implementation AgoraCustomCell
#pragma mark life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.detailTextLabel];
}


#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.image = ImageWithName(@"login.bundle/login_logo");
//        _avatarImageView.layer.cornerRadius = kHeaderImageViewHeight * 0.5;
        _iconImageView.backgroundColor = UIColor.yellowColor;
    }
    return _iconImageView;
}


- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:20.0];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = COLOR_HEX(0x0D0D0D);
        _titleLabel.text = @"agoraChat";
        _titleLabel.backgroundColor = UIColor.blueColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}


@end

#undef kIconImageViewHeight
