//
//  ACDChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/5.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDChatViewController.h"
#import "ACDContactInfoViewController.h"
#import "AgoraUserModel.h"
#import "AgoraChatUserDataModel.h"
#import "AgoraChatDateHelper.h"
#import "UserInfoStore.h"

@interface ACDChatViewController ()<EaseChatViewControllerDelegate, AgoraChatroomManagerDelegate, AgoraChatGroupManagerDelegate, EaseMessageCellDelegate>
@property (nonatomic, strong) EaseConversationModel *conversationModel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;
@property (nonatomic, strong) NSString *moreMsgId;  //第一条消息的消息id
@property (nonatomic, strong) UIView* fullScreenView;
@end

@implementation ACDChatViewController

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(AgoraChatConversationType)conType {
    if (self = [super init]) {
        _conversation = [AgoraChatClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:YES];
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
        
        EaseChatViewModel *viewModel = [[EaseChatViewModel alloc]init];
        _chatController = [EaseChatViewController initWithConversationId:conversationId
                                                    conversationType:conType
                                                        chatViewModel:viewModel];
        [_chatController setEditingStatusVisible:YES];
        _chatController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserInfo:) name:USERINFO_UPDATE object:nil];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [self _setupChatSubviews];
    if (_conversation.unreadMessagesCount > 0) {
        [[AgoraChatClient sharedClient].chatManager ackConversationRead:_conversation.conversationId completion:nil];
    }
}

- (void)dealloc
{
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
    [[AgoraChatClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
}

- (void)_setupChatSubviews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    [self _setupNavigationBarTitle];
    //[self _setupNavigationBarRightItem];
    [self addChildViewController:_chatController];
    [self.view addSubview:_chatController.view];
    _chatController.view.frame = self.view.bounds;
    [self loadData:YES];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

- (void)_setupNavigationBarRightItem
{
//    if (self.conversation.type == AgoraChatConversationTypeChat) {
//        UIImage *image = [[UIImage imageNamed:@"userData"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(chatInfoAction)];
//    }
//    if (self.conversation.type == AgoraChatConversationTypeGroupChat) {
//        UIImage *image = [[UIImage imageNamed:@"groupInfo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(groupInfoAction)];
//    }
//    if (self.conversation.type == AgoraChatConversationTypeChatRoom) {
//        UIImage *image = [[UIImage imageNamed:@"groupInfo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(chatroomInfoAction)];
//    }
}

- (void)_setupNavigationBarTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 06, 40)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = _conversationModel.showName;
    if(self.conversation.type == AgoraChatConversationTypeChat) {
        AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:self.conversation.conversationId];
        if(userInfo && userInfo.nickName.length > 0)
            self.titleLabel.text = userInfo.nickName;
    }
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView);
        make.left.equalTo(titleView).offset(5);
        make.right.equalTo(titleView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(titleView);
    }];
    
    self.navigationItem.titleView = titleView;
}

#pragma mark - EaseChatViewControllerDelegate

//自定义通话记录cell
- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel
{
//    if (messageModel.type == AgoraChatMessageTypePictMixText) {
//        AgoraChatMsgPicMixTextBubbleView* picMixBV = [[AgoraChatMsgPicMixTextBubbleView alloc] init];
//        [picMixBV setModel:messageModel];
//        AgoraChatMessageCell *cell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:picMixBV];
//        cell.model = messageModel;
//        cell.delegate = self;
//        return cell;
//    }

    if(messageModel.message.body.type == AgoraChatMessageBodyTypeCustom) {
        AgoraChatCustomMessageBody* body = (AgoraChatCustomMessageBody*)messageModel.message.body;
        if([body.event isEqualToString:@"userCard"]){
//            AgoraChatUserCardMsgView* userCardMsgView = [[AgoraChatUserCardMsgView alloc] init];
//            userCardMsgView.backgroundColor = [UIColor whiteColor];
//            [userCardMsgView setModel:messageModel];
//            AgoraChatMessageCell* userCardCell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:userCardMsgView];
//            userCardCell.model = messageModel;
//            userCardCell.delegate = self;
//            return userCardCell;
        }
    }
    return nil;
}
//对方输入状态
- (void)beginTyping
{
    self.titleDetailLabel.text = @"other party is typing";
}
- (void)endTyping
{
    self.titleDetailLabel.text = nil;
}
//userProfile
- (id<EaseUserProfile>)userProfile:(NSString *)huanxinID
{
    AgoraChatUserDataModel *model = nil;
    AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:huanxinID];
    if(userInfo) {
        model = [[AgoraChatUserDataModel alloc]initWithUserInfo:userInfo];
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[huanxinID]];
    }
    return model;
}

//头像点击
- (void)avatarDidSelected:(id<EaseUserProfile>)userData
{
    if (userData && userData.easeId) {
        [self personData:userData.easeId];
    }
}

- (void)loadMoreMessageData:(NSString *)firstMessageId currentMessageList:(NSArray<AgoraChatMessage *> *)messageList
{
    self.moreMsgId = firstMessageId;
    [self loadData:NO];
}

- (void)didSendMessage:(AgoraChatMessage *)message error:(AgoraChatError *)error
{
    if (error) {
        [self showHint:error.errorDescription];
    }
}

#pragma mark - AgoraChatMessageCellDelegate

//通话记录点击事件
- (void)messageCellDidSelected:(EaseMessageCell *)aCell
{
    if (!aCell.model.message.isReadAcked) {
        [[AgoraChatClient sharedClient].chatManager sendMessageReadAck:aCell.model.message.messageId toUser:aCell.model.message.conversationId completion:nil];
    }
}
//通话记录cell头像点击事件
- (void)messageAvatarDidSelected:(EaseMessageModel *)model
{
    [self personData:model.message.from];
}

#pragma mark - data

- (void)loadData:(BOOL)isScrollBottom
{
    __weak typeof(self) weakself = self;
    void (^block)(NSArray *aMessages, AgoraChatError *aError) = ^(NSArray *aMessages, AgoraChatError *aError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.chatController refreshTableViewWithData:aMessages isInsertBottom:NO isScrollBottom:isScrollBottom];
        });
    };
    
    [self.conversation loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:AgoraChatMessageSearchDirectionUp completion:block];
}

- (void)resetUserInfo:(NSNotification *)notification
{
    NSArray *userinfoList = (NSArray *)notification.userInfo[USERINFO_LIST];
    if (!userinfoList && userinfoList.count == 0)
        return;
    
    NSMutableArray *userInfoAry = [[NSMutableArray alloc]init];
    for (AgoraChatUserInfo *userInfo in userinfoList) {
        AgoraChatUserDataModel *model = [[AgoraChatUserDataModel alloc]initWithUserInfo:userInfo];
        [userInfoAry addObject:model];
    }
    
    [self.chatController resetUserProfiles:userInfoAry];
}

#pragma mark - ConfirmUserCardViewDelegate

- (NSArray *)formatMessages:(NSArray<AgoraChatMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aMessages count]; i++) {
        AgoraChatMessage *msg = aMessages[i];
        if (msg.chatType == AgoraChatTypeChat && msg.isReadAcked && (msg.body.type == AgoraChatMessageBodyTypeText || msg.body.type == AgoraChatMessageBodyTypeLocation)) {
            [[AgoraChatClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        }
        
        CGFloat interval = (self.chatController.msgTimelTag - msg.timestamp) / 1000;
        if (self.chatController.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [AgoraChatDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            [formated addObject:timeStr];
            self.chatController.msgTimelTag = msg.timestamp;
        }
        EaseMessageModel *model = nil;
        model = [[EaseMessageModel alloc] initWithAgoraChatMessage:msg];
        if (!model) {
            model = [[EaseMessageModel alloc]init];
        }
        model.userDataProfile = [self userProfile:msg.from];
        [formated addObject:model];
    }
    
    return formated;
}

//个人资料页
- (void)personData:(NSString*)contanct
{
    AgoraUserModel *userModel = [[AgoraUserModel alloc] initWithHyphenateId:contanct];
    UIViewController* controller = [[ACDContactInfoViewController alloc] initWithUserModel:userModel];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AgoraChatGroupManagerDelegate

- (void)didLeaveGroup:(AgoraChatGroup *)aGroup reason:(AgoraChatGroupLeaveReason)aReason
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AgoraChatroomManagerDelegate

//有用户加入聊天室
- (void)userDidJoinChatroom:(AgoraChatroom *)aChatroom
                       user:(NSString *)aUsername
{
    if (self.conversation.type == AgoraChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:self.conversation.conversationId]) {
        NSString *str = [NSString stringWithFormat:@"%@ 加入聊天室", aUsername];
        [self showHint:str];
    }
}

- (void)userDidLeaveChatroom:(AgoraChatroom *)aChatroom
                        user:(NSString *)aUsername
{
    if (self.conversation.type == AgoraChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:self.conversation.conversationId]) {
        NSString *str = [NSString stringWithFormat:@"%@ 离开聊天室", aUsername];
        [self showHint:str];
    }
}

- (void)didDismissFromChatroom:(AgoraChatroom *)aChatroom
                        reason:(AgoraChatroomBeKickedReason)aReason
{
    if (aReason == 0)
        [self showHint:[NSString stringWithFormat:@"被移出聊天室 %@", aChatroom.subject]];
    if (aReason == 1)
        [self showHint:[NSString stringWithFormat:@"聊天室 %@ 已解散", aChatroom.subject]];
    if (aReason == 2)
        [self showHint:@"您的账号已离线"];
    if (self.conversation.type == AgoraChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:self.conversation.conversationId]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom removedMutedMembers:(NSArray *)aMutes
{
    if ([aMutes containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被解除禁言"];
    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom addedMutedMembers:(NSArray *)aMutes muteExpire:(NSInteger)aMuteExpire
{
    if ([aMutes containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被禁言"];
    }
}

- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom addedWhiteListMembers:(NSArray *)aMembers
{
    if ([aMembers containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被加入白名单"];
    }
}

- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom removedWhiteListMembers:(NSArray *)aMembers
{
    if ([aMembers containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"您已被移出白名单"];
    }
}

- (void)chatroomAllMemberMuteChanged:(AgoraChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    [self showHint:[NSString stringWithFormat:@"全员禁言已%@", aMuted ? @"开启" : @"关闭"]];
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom addedAdmin:(NSString *)aAdmin
{
    [self showHint:[NSString stringWithFormat:@"%@已成为管理员", aAdmin]];
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom removedAdmin:(NSString *)aAdmin
{
    [self showHint:[NSString stringWithFormat:@"%@被降级为普通成员", aAdmin]];
}

- (void)chatroomOwnerDidUpdate:(AgoraChatroom *)aChatroom newOwner:(NSString *)aNewOwner oldOwner:(NSString *)aOldOwner
{
    [self showHint:[NSString stringWithFormat:@"%@ 已将聊天室移交给 %@", aOldOwner, aNewOwner]];
}

- (void)chatroomAnnouncementDidUpdate:(AgoraChatroom *)aChatroom announcement:(NSString *)aAnnouncement
{
    [self showHint:@"聊天室公告内容已更新，请查看"];
}

@end

