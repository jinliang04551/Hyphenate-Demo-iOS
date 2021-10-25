//
//  EMLocalNotificationManager.h
//  LocalNotification
//
//  Created by lixiaoming on 2021/8/24.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMLocalNotificationDelegate <NSObject>

/*!
 *  \~chinese
 *  当应用收到非环信在线推送通知时，此方法会被调用
 *
 *
 *  \~english
 *
 *  This method will be called when application receive local notification except easemob notification.
 *
 */
- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
/*!
 *  \~chinese
 *  当应用打开非环信推送通知时，此方法会被调用
 *
 *
 *  \~english
 *
 *  This method will be called when user open local notification except easemob notification.
 *
 */
- (void)emuserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
@end

@interface EMLocalNotificationManager : NSObject
+(instancetype _Nonnull ) alloc __attribute__((unavailable("call sharedManager instead")));
+(instancetype _Nonnull ) new __attribute__((unavailable("call sharedManager instead")));
-(instancetype _Nonnull ) copy __attribute__((unavailable("call sharedManager instead")));
-(instancetype _Nonnull ) mutableCopy __attribute__((unavailable("call sharedManager instead")));
+ (instancetype _Nonnull )sharedManager;

/*!
 *  \~chinese
 *  启动环信本地推送模块
 *
 *
 *  \~english
 *
 *  Enable easemob local notification.
 *
 */
- (void)launchWithDelegate:(id<EMLocalNotificationDelegate>)aDelegate;

/*!
 *  \~chinese
 *  如果用户在app层设置了UNUserNotificationCenterDelegate，需要在delegate实现中调用此方法
 *
 *
 *  \~english
 *
 *  User should call this method in the implementation of  UNUserNotificationCenterDelegate if they have override UNUserNotificationCenterDelegate  in-app.
 *
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
/*!
 *  \~chinese
 *  如果用户在app层设置了UNUserNotificationCenterDelegate，需要在delegate实现中调用此方法
 *
 *
 *  \~english
 *
 *  User should call this method in the implementation of  UNUserNotificationCenterDelegate if they have override UNUserNotificationCenterDelegate  in-app.
 *
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
@end

NS_ASSUME_NONNULL_END
