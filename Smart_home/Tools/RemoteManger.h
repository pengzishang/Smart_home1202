//
//  RemoteManger.h
//  ttsBluetooth_iPhone
//
//  Created by pzs on 15/9/29.
//  Copyright © 2015年 tts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface RemoteManger : NSObject <GCDAsyncSocketDelegate>


/**
 初始化

 @return <#return value description#>
 */
+ (RemoteManger *)getInstance;


/**
 发送远程控制命令,非锁

 @param commandCode 控制指令
 @param deviceID    控制目标ID
 @param success     <#success description#>
 @param fail        <#fail description#>
 */
- (void)sendRemoteCommand:(NSString *)commandCode deviceID:(NSString *)deviceID success:(void (^)(NSString *))success fail:(NSUInteger(^)(NSString *))fail;


/**
 远程控制锁

 @param password <#password description#>
 @param lockID   <#lockID description#>
 @param methods  <#methods description#>
 */
- (void)sendLockRemotePassword:(NSString *)password lockID:(NSString *)lockID Methods:(NSUInteger)methods
                       success:(void (^)(NSString *statusCode))success
                          fail:(NSUInteger(^)(NSString *statusCode))fail;

/**
 同步,写入远程控制器地址

 @param remoteDeviceMac 远程控制器ID
 @param deviceID        设备ID
 @param success         <#success description#>
 @param fail            <#fail description#>
 */
- (void)syncRemoteDevice:(NSString *)remoteDeviceMac deviceID:(NSString *)deviceID success:(void (^)(NSString *))success fail:(NSUInteger(^)(NSString *))fail;


/**
 批量同步远程控制器

 @param deviceIDs        <#deviceIDs description#>
 @param number           <#number description#>
 @param remoteMacAddress <#remoteMacAddress description#>
 */
- (void)multiSaveRemoteDevices:(NSArray *)deviceIDs successNumberReturn:(void (^)(NSUInteger))number remoteMac:(NSString *)remoteMacAddress;


/**
 *  批量控制
 *
 *  @param deviceInfoArr <#deviceInfoArr description#>
 *  @param resultArr     <#resultArr description#>
 */
- (void)multRemoteControlWithDeviceInfoArr:(NSArray *)deviceInfoArr result:(void (^)(NSArray *))resultArr;

- (void)cutOffSocket;

@end
