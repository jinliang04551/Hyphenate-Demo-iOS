//
//  ACDChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/5.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDChatViewController : UIViewController

@property (nonatomic, strong) AgoraChatConversation *conversation;
@property (nonatomic, strong) EaseChatViewController *chatController;

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(AgoraChatConversationType)conType;

- (NSArray *)formatMessages:(NSArray<AgoraChatMessage *> *)aMessages;

@end

NS_ASSUME_NONNULL_END
