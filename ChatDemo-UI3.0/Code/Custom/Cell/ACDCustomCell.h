//
//  AgoraCustomCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDCustomCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UIView* bottomLine;

- (void)prepare;
- (void)placeSubViews;
+ (NSString *)reuseIdentifier;
+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
