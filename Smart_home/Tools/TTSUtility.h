//
//  TTSUtility.h
//  ttsBluetooth_iPhone
//
//  Created by tts on 14-9-16.
//  Copyright (c) 2014年 tts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothManager.h"
#import "RemoteManger.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "NSString+StringOperation.h"
#import "TTSCoreDataManager.h"
#import "MainLeftController.h"
#import "TTSTabBarController.h"
#import "CallingController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <JFGSDK/JFGSDKDataPoint.h>


/**
 锁模式

 - APPLockModeOpen: 开锁
 - APPLockModeChange: 加密码
 - APPLockModeCleanAll: 清除所有
 - APPLockModeSync: 同步时间
 - APPLockModeLinkage: 联动
 - APPLockModeLowPower: 电量阈值
 - APPLockModePowerValue: 电量
 - APPLockModeQuery: 开锁记录
 */
typedef NS_ENUM(NSUInteger, APPLockMode) {
    APPLockModeOpen = 1,
    APPLockModeChange = 2,
    APPLockModeCleanAll = 3,
    APPLockModeSync = 8,
    APPLockModeLinkage = 16,
    APPLockModeLowPower = 17,
    APPLockModePowerValue = 18,
    APPLockModeQuery = 19,
};


@interface TTSUtility : NSObject

+ (void)shake;


+ (MainLeftController *)getCurrentDrawerControl;

/**
 *  模糊效果加入
 *
 *  @param tag  <#tag description#>
 *  @param view <#view description#>
 *
 *  @return 返回模糊窗口
 */
//+ (UIView *)addBlurWithtag:(NSUInteger)tag view:(UIView *)view;

/**
 短时间动画

 @param time <#time description#>
 @param maintitle <#maintitle description#>
 @param subTitle <#subTitle description#>
 */
+ (void)showForShortTime:(NSUInteger)time mainTitle:(NSString *)maintitle subTitle:(NSString *)subTitle;


/**
 开始显示一段屏幕提示

 @param mainTitle <#mainTitle description#>
 @param subTitle <#subTitle description#>
 */
+ (void)startAnimationWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle;

/**
 停止显示屏幕提示

 @param mainTitle <#mainTitle description#>
 @param subTitle <#subTitle description#>
 */
+ (void)stopAnimationWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle;


/**
 加入数个设备的动画

 @param finish <#finish description#>
 */
+ (void)addMutiDeviceAnimationFinish:(void (^)(void))finish;


/**
 播放声音

 @param fileName <#fileName description#>
 */
+ (void)playSoundWithName:(NSString *)fileName;


/**
 得到最顶层VC

 @return <#return value description#>
 */
+ (UIViewController *)getTopVC;

/**
 *  得到当前最顶层VC
 *
 *  @return <#return value description#>
 */
+ (UIViewController *)getCurrentVC;


+ (NSArray *)initScene:(RoomInfo *)roomInfo;

+ (SceneInfo *)addSceneWithRoom:(RoomInfo *)roomInfo roomDevice:(NSArray <DeviceInfo *> *)roomDevice index:(NSUInteger)roomIndex roomName:(NSString *)roomName;

+ (void)deleteScene:(SceneInfo *)sceneInfo room:(RoomInfo *)roomInfo;

+ (void)newGuideWithPoint:(CGPoint)point title:(NSString *)title;


/**
 弹出视频窗口
 @param userInfo <#userInfo description#>
 */
+ (void)openVideo:(id)userInfo;


/**
 *  本地蓝牙封装
 */

+ (void)localDeviceControl:(NSString *)deviceID commandStr:(NSString *)command retryTimes:(NSUInteger)retryTimes conditionReturn:(void (^)(id stateData))getStateCode;


+ (void)mutiLocalDeviceControlWithDeviceInfoArr:(NSArray *)deviceArr result:(void (^)(NSArray *resultArr))resultArr;


/**
 *  远程控制
 *
 *  @param deviceInfo   设备信息
 *  @param command      设备控制码
 *  @param retryTimes   重试时间
 *  @param getStateCode 返回码
 */
+ (void)remoteDeviceControl:(DeviceInfo *)deviceInfo commandStr:(NSString *)command retryTimes:(NSUInteger)retryTimes conditionReturn:(void (^)(NSString *))getStateCode;

/**
 新远程控制

 @param deviceInfo <#deviceInfo description#>
 @param command <#command description#>
 @param retryTimes <#retryTimes description#>
 @param getStateCode <#getStateCode description#>
 */
+ (void)remoteWithSoap:(DeviceInfo *)deviceInfo commandStr:(NSString *)command retryTimes:(NSUInteger)retryTimes conditionReturn:(void (^)(NSString *))getStateCode;
/**
 *  同步状态
 *
 *  @param deviceInfo   <#deviceInfo description#>
 *  @param remoteMacID  <#remoteMacID description#>
 *  @param getStateCode <#getStateCode description#>
 */
+ (void)syncRemoteDevice:(DeviceInfo *)deviceInfo remoteMacID:(NSString *)remoteMacID conditionReturn:(void (^)(NSString *))getStateCode;

/**
 *  批量控制
 *
 *  @param deviceArr   <#deviceArr description#>
 *  @param remoteMacID <#remoteMacID description#>
 *  @param resultArr   <#resultArr description#>
 */
+ (void)mutiRemoteControl:(NSArray <DeviceInfo *> *)deviceArr result:(void (^)(NSArray *))resultArr;


/**
 批量同步设备

 @param devices     即将同步的设备
 @param remoteMacID 远程控制ID
 */
+ (void)mutiRemoteSave:(NSArray <DeviceInfo *> *)devices remoteMacID:(NSString *)remoteMacID;


+ (RoomInfo *)addRoomWithName:(NSString *)roomName roomType:(NSNumber *)roomType;

//锁功能


/**
 本地控制

 @param deviceInfo <#deviceInfo description#>
 @param lockMode   <#lockMode description#>
 @param passWord   <#passWord description#>
 @param validtime  <#validtime description#>
 */
+ (void)lockWithDeviceInfo:(DeviceInfo *)deviceInfo lockMode:(APPLockMode)lockMode passWord:(NSString *)passWord validtime:(NSTimeInterval)validtime;

+ (void)lockWithRemoteInfo:(DeviceInfo *)lockInfo lockMode:(APPLockMode)lockMode passWord:(NSString *)passWord validtime:(NSTimeInterval)validtime;

+ (void)lockWithRemoteNew:(DeviceInfo *)lockInfo passWord:(NSString *)passWord validtime:(NSTimeInterval)validtime;

+ (void)lockWithLinkDevice:(NSString *)deviceID lockInfo:(DeviceInfo *)lockInfo command:(NSString *)command;

+ (void)lockWithPowerLockInfo:(DeviceInfo *)lockInfo lockMode:(APPLockMode)lockMode powerWarning:(NSInteger)val;

+ (void)lockWithQueryLogLockInfo:(DeviceInfo *)lockInfo;

+ (void)lockWithSystemInfo:(DeviceInfo *)lockInfo codeReturn:(void (^)(NSData *data))codeReturn;

//遥控器绑定

+ (void)switchWithBinding:(DeviceInfo *)deviceInfo ctrlNum:(NSUInteger)ctrlNum remoteID:(NSString *)remoteID;

+ (void)remoteBind:(DeviceInfo *)deviceInfo remoteCommand:(NSInteger)remoteCommand switchCommand:(NSInteger)switchCommand remoteID:(NSString *)remoteID;

//可视对讲相关
+ (void)getVideoHistoryListWithCid:(NSString *)cid
                           success:(void (^)(NSArray *historyList))success
                           failure:(void (^)(NSInteger type))fail;

//可视对讲获得Wifi信息
+ (void)getVideoWifiInfoWithCid:(NSString *)cid
                        success:(void (^)(NSString *wifiSSID))success
                        failure:(void (^)(NSInteger type))fail;

@end
