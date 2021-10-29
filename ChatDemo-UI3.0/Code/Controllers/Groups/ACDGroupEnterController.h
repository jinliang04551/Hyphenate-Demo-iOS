//
//  AgoraGroupEnterController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraSearchTableViewController.h"

@protocol  ACDGroupEnterControllerDelegate <NSObject>

@optional
- (void)enterCreateNewGroupPage;
- (void)enterJoinGroupPage;
- (void)enterPublicGroupPage;
- (void)enterAddContactsPage;
@end


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ACDGroupEnterAccessType) {
    ACDGroupEnterAccessTypeContact, // from tab contact right bar
    ACDGroupEnterAccessTypeChat,  // from tab chat right bar
};

@interface ACDGroupEnterController : AgoraSearchTableViewController
@property (nonatomic, assign) ACDGroupEnterAccessType accessType;
@property (nonatomic, assign) id<ACDGroupEnterControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
