//
//  ACDTransViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraSearchTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDTransferOwnerViewController : AgoraSearchTableViewController
@property (nonatomic,copy) void(^transferOwnerBlock)(void);

@property (nonatomic,assign) BOOL isLeaveGroup;


- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup;
@end

NS_ASSUME_NONNULL_END
