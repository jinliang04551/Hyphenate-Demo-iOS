//
//  AgoraChatUserDataModel.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/12/3.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "AgoraChatUserDataModel.h"

@implementation AgoraChatUserDataModel

- (instancetype)initWithUserInfo:(AgoraChatUserInfo *)userInfo
{
    if (self = [super init]) {
        _easeId = userInfo.userId;
        _showName = userInfo.nickName;
        _avatarURL = userInfo.avatarUrl;
        _defaultAvatar = [self getAvatar:userInfo.userId];
    }
    return self;
}

- (UIImage *)getAvatar:(NSString *)uName
{
    if ([uName isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *imageName = [userDefault valueForKey:[NSString stringWithFormat:@"%@_avatar",AgoraChatClient.sharedClient.currentUsername]];
        return ImageWithName(imageName);
    }
    
    return ImageWithName(@"defaultAvatar");
}

@end
