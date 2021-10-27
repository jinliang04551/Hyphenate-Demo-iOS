//
//  ACDGroupInfoViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraBaseTableViewController.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ACDGroupInfoAccessType) {
    ACDGroupInfoAccessTypeContact,
    ACDGroupInfoAccessTypeChat,
    ACDGroupInfoAccessTypePublicGroups,
};


@interface ACDGroupInfoViewController : AgoraBaseTableViewController
@property (nonatomic, assign) ACDGroupInfoAccessType accessType;

- (instancetype)initWithGroupId:(NSString *)aGroupId;

@end

NS_ASSUME_NONNULL_END
