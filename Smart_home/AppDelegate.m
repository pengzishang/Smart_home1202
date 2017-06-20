//
//  AppDelegate.m
//  Smart_home
//
//  Created by 彭子上 on 2016/6/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//
#import "BluetoothManager.h"
#import "AppDelegate.h"
#import "TTSUtility.h"
#import <Bugly/Bugly.h>
#import "JPUSHService.h"
#import "DoorBellStep1.h"
#import "IQKeyboardManager.h"
#import "AvoidCrash.h"
#import <JFGSDK/JFGSDKToolMethods.h>
#import "Reachability.h"
#import "CustomStatusBar.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max

#import <UserNotifications/UserNotifications.h>

#endif

@interface AppDelegate () <JPUSHRegisterDelegate, MainDelegate, JFGSDKCallbackDelegate>
@property (strong,nonatomic)CustomStatusBar *netBar;
@end

@implementation AppDelegate


-(CustomStatusBar *)netBar
{
    if (!_netBar) {
        _netBar = [[CustomStatusBar alloc]init];
        [self.window addSubview:_netBar];
    }
    return _netBar;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder = YES;
#if defined (DEBUG)|| defined (_DEBUG)//开发环境
#else
    [self BugAndUpdate];
    [AvoidCrash becomeEffective];
#endif
    [self JFGConfig];
    [self JpushConfig:launchOptions];
    
//    Reachability *reachManger = [Reachability reachabilityWithHostName:@"http://120.76.74.87/PMSWebService/services/"];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(reachabilityChanged:)
//                                                 name:kReachabilityChangedNotification
//                                               object:nil];
//    [reachManger startNotifier];
    return YES;
}

-(void)reachabilityChanged:(NSNotification *)notification{
    static NetworkStatus statusSteady = NotReachable;
    Reachability *reach = [notification object];
    if([reach isKindOfClass:[Reachability class]]){
        NetworkStatus status = [reach currentReachabilityStatus];
        statusSteady = status;
        NSLog(@"%zd",status);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (statusSteady == NotReachable) {
                    [self.netBar showBar];
                    [TTSUtility showForShortTime:2 mainTitle:@"网络有问题" subTitle:@""];
                }
                else
                {
                    [self.netBar hideBar];
                }
            });
        });
    }
}

- (void)BugAndUpdate {
    [Bugly startWithAppId:@"b911c456be"];
}

- (void)JFGConfig {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"jfgworkdic"];
    //SDK初始化
    [JFGSDK connectForWorkDir:path];
    //SDK回调设置
    [JFGSDK addDelegate:self];
    [JFGSDK logEnable:YES];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"JFGUSER"];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"JFGPWD"];
    if (userName.length != 0 && pwd.length != 0) {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];

#if defined (DEBUG)|| defined (_DEBUG)//开发环境
        [JFGSDK userLogin:userName keyword:pwd vid:VID vkey:VKEY cerType:[NSString stringWithFormat:@"%@.Dev", bundleID]];//这个大写小写有待确认
#else//生产
        [JFGSDK userLogin:userName keyword:pwd vid:VID vkey:VKEY cerType:bundleID];
#endif
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"JFGUSER"];
        [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:@"JFGPWD"];
    }

}

- (void)JpushConfig:(NSDictionary *)launchOptions {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_x_Max) {
        JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    } else if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                        UIUserNotificationTypeSound |
                        UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:nil
                 apsForProduction:isProduction
            advertisingIdentifier:nil];

    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (resCode == 0) {
            NSLog(@"registrationID获取成功：%@", registrationID);

        } else {
            NSLog(@"registrationID获取失败，code：%d", resCode);
        }
    }];
}

#pragma mark 推送

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    _deviceToken = deviceToken;
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)                             application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {//过期
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    NSLog(@"iOS7及以上系统，1111收到通知:%@", userInfo);
    [TTSUtility showForShortTime:3 mainTitle:@"111" subTitle:@""];
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"%@", userInfo);
    [self setValue:userInfo forKey:@"pushUserInfo"];
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);//先在全局储存,再到相应页面推送,设置标识就好
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

#endif

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

//前台收到,即使在APP内也能收到弹窗
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;

    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容

    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    //    NSString *title = content.title;  // 推送消息的标题
    NSString *title = @"收到了吗?";
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self setValue:userInfo forKey:@"pushUserInfo"];
        NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}", body, title, subtitle, badge, sound, userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置 去除将不执行弹窗
}

//后台收到,IOS10 开发环境有效
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {

    NSDictionary *userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容

    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    //    NSString *title = content.title;  // 推送消息的标题
    NSString *title = @"收到了吗?";
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", userInfo);
        [self setValue:userInfo forKey:@"pushUserInfo"];
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}", body, title, subtitle, badge, sound, userInfo);
    }
    completionHandler();  // 系统要求执行这个方法
}

#endif

#pragma mark 可视对讲代理


- (void)jfgLoginResult:(JFGErrorType)errorType {
    if (errorType == JFGErrorTypeNone) {
        _isJFGLogin = YES;
        if (_deviceToken) {
            [JFGSDK deviceTokenUpload:_deviceToken];
        } else {
            NSLogMethodArgs(@"deviceToke上传失败");
        }

    } else {

    }
}

- (void)jfgUploadDeviceTokenResult:(JFGErrorType)errorType {
    NSLogMethodArgs(@"上传结果:%zd", errorType);
}

- (void)jfgUpdateAccount:(JFGSDKAcount *)account {
    NSLogMethodArgs(@"账号:%@", account);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.


}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([[TTSUtility getTopVC] isKindOfClass:[DoorBellStep1 class]]) {
        DoorBellStep1 *topView = (DoorBellStep1 *) [TTSUtility getTopVC];
        topView.wifiSSID = [JFGSDKToolMethods currentWifiName];
        if ([topView.wifiSSID hasPrefix:@"DOG-ML"]) {
            topView.nextStep.enabled = YES;
            [topView.nextStep setTitle:@"下一步" forState:UIControlStateNormal];
        } else {
            topView.lastWifiSSID = topView.wifiSSID;
            [topView.nextStep setTitle:[NSString stringWithFormat:@"当前:%@", topView.wifiSSID] forState:UIControlStateNormal];
        }
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    Reachability *reachManger = [Reachability reachabilityWithHostName:@"http://120.76.74.87/PMSWebService/services/"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reachManger startNotifier];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

@end
