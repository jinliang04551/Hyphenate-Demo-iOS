//
//  ACDRequestCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/27.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDRequestCell : ACDCustomCell
@property (nonatomic, copy) void (^acceptBlock)(void);
@property (nonatomic, copy) void (^rejectBlock)(void);

@end

NS_ASSUME_NONNULL_END
