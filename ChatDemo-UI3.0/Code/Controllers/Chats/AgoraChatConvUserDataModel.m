//
//  AgiraChatConvUserDataModel.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/12/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "AgoraChatConvUserDataModel.h"

@implementation AgoraChatConvUserDataModel

- (instancetype)initWithUserInfo:(AgoraChatUserInfo *)userInfo conversationType:(AgoraChatConversationType)type
{
    if (self = [super init]) {
        _easeId = userInfo.userId;
        _showName = userInfo.nickName;
        _avatarURL = userInfo.avatarUrl;

        if(type == AgoraChatConversationTypeGroupChat) {
            AgoraChatGroup* group = [AgoraChatGroup groupWithId:userInfo.userId];
            _showName = [group groupName];
        }
        //_defaultAvatar = [self _getDefaultAvatarImage:userInfo.userId conversationType:type];
        _defaultAvatar = nil;
    }
    return self;
}

- (UIImage*)_getDefaultAvatarImage:(NSString*)easeId conversationType:(AgoraChatConversationType)type
{
    if (type == AgoraChatConversationTypeChat) {
        return [UIImage imageNamed:@"defaultAvatar"];
    }
    if (type == AgoraChatConversationTypeGroupChat) {
        return [UIImage imageNamed:@"groupConversation"];
    }
    if (type == AgoraChatConversationTypeChatRoom) {
        return [UIImage imageNamed:@"chatroomConversation"];
    }
    return [UIImage imageNamed:@"defaultAvatar"];
}

@end
