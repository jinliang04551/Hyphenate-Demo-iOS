//
//  AgoraCustomCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

@interface ACDCustomCell ()
@property (nonatomic, strong) UIView* bottomLine;

@end

@implementation ACDCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self prepare];
        [self placeSubViews];
    }
    return self;
}

- (void)prepare {

}

- (void)placeSubViews {
    
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (CGFloat)height {
    return 44.0f;
}

#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeCenter;
    }
    return _iconImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textColor = COLOR_HEX(0x0D0D0D);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}


- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = UIView.new;
        _bottomLine.backgroundColor = COLOR_HEX(0xE7E7E7);
    }
    return _bottomLine;
}

@end
