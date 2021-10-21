//
//  AgoraInfoBaseHeaderView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AgoraHeaderInfoType) {
    AgoraHeaderInfoTypeContact,
    AgoraHeaderInfoTypeGroup,
    AgoraHeaderInfoTypeMe,
};

@interface AgoraInfoHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                     withType:(AgoraHeaderInfoType)type;

- (instancetype)initWithType:(AgoraHeaderInfoType)type;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, copy) void (^tapHeaderBlock)(void);
@property (nonatomic, copy) void (^goChatPageBlock)(void);
@property (nonatomic, copy) void (^goBackBlock)(void);


@end

NS_ASSUME_NONNULL_END
