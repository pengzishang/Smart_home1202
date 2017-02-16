//
//  RemoteManger.m
//  ttsBluetooth_iPhone
//
//  Created by pzs on 15/9/29.
//  Copyright © 2015年 tts. All rights reserved.
//

#import "RemoteManger.h"
#import "NSString+StringOperation.h"

static RemoteManger *shareInstance = nil;

typedef NS_ENUM(NSUInteger, RemoteMethod) {
    RemoteMethodWrite = 0,
    RemoteMethodSave,
    RemoteMethodMulti,
    RemoteMethodLock,
};

//typedef void(^remoteCompleteReturn)(BOOL,NSString *);
typedef void(^codeReturn)(NSString *);

typedef void(^mutiSave)(BOOL);

@interface RemoteManger ()

@property(nonatomic, strong) GCDAsyncSocket *clientSocket;
@property(nonatomic, strong) NSString *commandCode;

@property(nonatomic, strong) NSString *stateCode;


@property(nonatomic, strong) NSData *commandData;
@property(nonatomic, strong) NSDate *dataTime;

@property(nonatomic, assign) NSInteger operationIndex;
@property(nonatomic, assign) NSInteger deviceCount;

@property(nonatomic, assign) BOOL didError;

//@property (nonatomic,copy)remoteCompleteReturn isCompleteAndSuccess;

@property(nonatomic, copy) codeReturn successReturn;
@property(nonatomic, copy) codeReturn failReturn;

@property(nonatomic, copy) mutiSave isSuccess;

@property(nonatomic, assign) RemoteMethod remoteMethod;

@end

@implementation RemoteManger

+ (RemoteManger *)getInstance {
    @synchronized (self) {
        if (shareInstance == nil) {
            shareInstance = [[[self class] alloc] init];
            if (!HOST) {
                [[NSUserDefaults standardUserDefaults] setObject:@"120.76.74.87" forKey:@"SeviceHost"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    return shareInstance;
}

- (void)cutOffSocket {
    [self.clientSocket disconnect];
}

- (void)startConnectSocket:(NSString *)deviceID commandCode:(NSString *)commandCode method:(RemoteMethod)method {
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [self.clientSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    [_clientSocket connectToHost:HOST onPort:Port withTimeout:TimeOut error:nil];
    [_clientSocket readDataWithTimeout:TimeOut tag:100];
    switch (method) {
        case RemoteMethodWrite: {
            NSLogMethodArgs(@"控制模式:发送%@", [NSString stringWithFormat:@"FA07 %@ 10 %@", deviceID, commandCode]);
            _commandData = [[NSString stringWithFormat:@"FA07%@10%@", deviceID, commandCode] dataUsingEncoding:NSUTF8StringEncoding];//中间的10要改
        }
            break;
        case RemoteMethodSave: {
            NSLogMethodArgs(@"储存模式:发送%@", [NSString stringWithFormat:@"FF10 %@ %@", deviceID, commandCode]);
            _commandData = [[NSString stringWithFormat:@"FF10%@%@", deviceID, commandCode] dataUsingEncoding:NSUTF8StringEncoding];
        }
            break;
        case RemoteMethodLock: {
            NSLogMethodArgs(@"锁模式:发送%@", [NSString stringWithFormat:@"FA0A %@ %@", deviceID, commandCode]);
            _commandData = [[NSString stringWithFormat:@"FA0A%@%@", deviceID, commandCode] dataUsingEncoding:NSUTF8StringEncoding];
//            FA0A        D0B5C2A3FFC2   01    100909080808  123456
//            固定格式 +  锁地址          +  开锁  +  时间  +        密码
        }
            break;
        default:
            break;
    }

}
//香菇滑鸡放17   招牌云吞16  共19.3            萝卜牛腩17  耗油菜心 8  共14   小胖10块  小蒲9.5

- (void)sendRemoteCommand:(NSString *)commandCode deviceID:(NSString *)deviceID success:(void (^)(NSString *))success fail:(NSUInteger (^)(NSString *))fail {
    _dataTime = [NSDate date];
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataTime];
    NSLog(@"time1:%f   id:%@", time1, deviceID);
    [self cutOffSocket];
    [self startConnectSocket:deviceID commandCode:commandCode method:RemoteMethodWrite];
    if (success) {
        self.successReturn = ^(NSString *stateCode) {
            success(stateCode);
        };
    }
    if (fail) {
        __weak RemoteManger *retryManger = self;
        retryManger.failReturn = ^(NSString *stateCode) {
            NSUInteger failRetryTime = fail(stateCode);
            if (failRetryTime > 0) {
                [retryManger cutOffSocket];
                [retryManger startConnectSocket:deviceID commandCode:commandCode method:RemoteMethodWrite];
            } else {
                NSLog(@"重试次数为0或者不在范围");
            }
        };
    }
}


/**
 远程锁控制

 @param password <#password description#>
 @param lockID   <#lockID description#>
 @param methods  <#methods description#>
 @param success  <#success description#>
 @param fail     <#fail description#>
 */
- (void)sendLockRemotePassword:(NSString *)password lockID:(NSString *)lockID Methods:(NSUInteger)methods
                       success:(void (^)(NSString *))success
                          fail:(NSUInteger (^)(NSString *))fail {
    _dataTime = [NSDate date];
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataTime];
    NSLog(@"time1:%f   id:%@", time1, lockID);
    NSString *timeStr = [NSString initWithDate:[NSDate date] isRemote:YES];
    NSString *methodString = [@(methods).stringValue fullWithLengthCount:2];
    NSString *commandCode = [NSString stringWithFormat:@"%@%@%@", methodString, timeStr, password];
    [self cutOffSocket];
    [self startConnectSocket:lockID commandCode:commandCode method:RemoteMethodLock];
    if (success) {
        self.successReturn = ^(NSString *stateCode) {
            success(stateCode);
        };
    }

    if (fail) {
        __weak RemoteManger *retryManger = self;
        retryManger.failReturn = ^(NSString *stateCode) {
            NSUInteger failRetryTime = fail(stateCode);
            if (failRetryTime > 0) {
                [retryManger cutOffSocket];
                [retryManger startConnectSocket:lockID commandCode:commandCode method:RemoteMethodLock];
            } else {
                NSLog(@"重试次数为0或者不在范围");
            }
        };
    }

}


- (void)syncRemoteDevice:(NSString *)remoteDeviceMac deviceID:(NSString *)deviceID success:(void (^)(NSString *))success fail:(NSUInteger (^)(NSString *))fail {
    _dataTime = [NSDate date];
    [self cutOffSocket];
    NSString *remoteDeviceMacID = [NSString translateRemoteID:remoteDeviceMac];
    [self startConnectSocket:deviceID commandCode:remoteDeviceMacID method:RemoteMethodSave];
    if (success) {
        self.successReturn = ^(NSString *stateCode) {
            success(stateCode);
        };
    }
    if (fail) {
        __weak RemoteManger *retryManger = self;
        retryManger.failReturn = ^(NSString *stateCode) {
            NSUInteger failRetryTime = fail(stateCode);
            if (failRetryTime != 0) {
                [self cutOffSocket];
                [self startConnectSocket:deviceID commandCode:remoteDeviceMac method:RemoteMethodSave];
            } else {
                NSLog(@"重试次数为0或者不在范围");
            }
        };
    }
}


- (void)multiSaveRemoteDevices:(NSArray *)deviceIDs successNumberReturn:(void (^)(NSUInteger))number remoteMac:(NSString *)remoteMacAddress//转换完成的
{
    NSUInteger totalCount = deviceIDs.count;
    __block NSUInteger operationIndex = 0;
    if (totalCount == 0) {
        return;
    }
    [self syncRemoteDevice:remoteMacAddress deviceID:deviceIDs[operationIndex]
                   success:^(NSString *stateCode) {
                       if (++operationIndex < totalCount) {
                           [self syncRemoteDevice:remoteMacAddress deviceID:deviceIDs[operationIndex] success:nil fail:nil];
                       }
                   } fail:^NSUInteger(NSString *stateCode) {
                return 0;//返回0表示不重试
            }];
}

- (void)multRemoteControlWithDeviceInfoArr:(NSArray *)deviceInfoArr result:(void (^)(NSArray *))resultArr {
    NSUInteger totalCount = deviceInfoArr.count;

    if (deviceInfoArr.count == 0) {
        return;
    }

    __block NSUInteger operationIndex = 0;
    __block NSMutableDictionary *operationDic = [NSMutableDictionary dictionaryWithDictionary:deviceInfoArr[operationIndex]];
    __block NSString *operationDeviceID = deviceInfoArr[operationIndex][@"deviceID"];
    __block NSString *operationCommand = deviceInfoArr[operationIndex][@"deviceCommand"];
    __block NSMutableArray *requestArr = [NSMutableArray array];


    [self sendRemoteCommand:operationCommand deviceID:operationDeviceID success:^(NSString *stateCode) {
        operationDic = [NSMutableDictionary dictionaryWithDictionary:deviceInfoArr[operationIndex]];
        operationDic[@"stateCode"] = stateCode;
        [requestArr addObject:operationDic];
        if (++operationIndex < totalCount) {
            operationDeviceID = deviceInfoArr[operationIndex][@"deviceID"];
            operationCommand = deviceInfoArr[operationIndex][@"deviceCommand"];
            [self sendRemoteCommand:operationCommand deviceID:operationDeviceID success:nil fail:nil];
        } else {
            if (resultArr) {
                resultArr(requestArr);
            }
        }
    }                  fail:^NSUInteger(NSString *stateCode) {
        operationDic = [NSMutableDictionary dictionaryWithDictionary:deviceInfoArr[operationIndex]];
        operationDic[@"stateCode"] = stateCode;
        [requestArr addObject:operationDic];
        if (++operationIndex < totalCount) {
            operationDeviceID = deviceInfoArr[operationIndex][@"deviceID"];
            operationCommand = deviceInfoArr[operationIndex][@"deviceCommand"];
            [self sendRemoteCommand:operationCommand deviceID:operationDeviceID success:nil fail:nil];
        } else {
            if (resultArr) {
                resultArr(requestArr);
            }
        }
        return 0;
    }];
}


#pragma mark - Socket远程读写methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [_clientSocket writeData:_commandData withTimeout:TimeOut tag:200];
    [_clientSocket writeData:[@"eof\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:TimeOut tag:300];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"客户端已经写完数据...");
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataTime];
    NSLog(@"time2:%f", time1);
    [_clientSocket disconnectAfterReadingAndWriting];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *msgReturn = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msgReturn.length < 6) {
        _stateCode = @"E5";
        NSLogMethodArgs(@"返回错误的状态");
    } else {
        _stateCode = [msgReturn substringWithRange:NSMakeRange([msgReturn length] - 6, 2)];
        NSLogMethodArgs(@"返回的:%@", _stateCode);
    }

    double time1 = [[NSDate date] timeIntervalSinceDate:_dataTime];
    NSLog(@"time2:%f", time1);
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        _stateCode = @"E5";
        NSLogMethodArgs(@"%@", err);
        _didError = YES;
    }
    NSLog(@"\n\nonSocketDidDisconnect  断开目标服务器\n\n");
    NSDictionary *statusCode = @{@"99": @YES, @"EE": @YES, @"E5": @NO, @"E8": @NO, @"E0": @NO, @"E1": @NO, @"E2": @NO};

    if ([_stateCode length] < 1) {
//        typeOfErr=ConnectionTimeOut;
        _stateCode = @"66";
    } else {
        switch (_remoteMethod) {
            case RemoteMethodWrite:
            case RemoteMethodSave: {
                if ([[statusCode objectForKey:_stateCode] boolValue] || ![statusCode objectForKey:_stateCode]) {
                    if (self.successReturn) {
                        self.successReturn(_stateCode);
                    }
                } else {
                    if (self.failReturn) {
                        self.failReturn(_stateCode);
                    }
                }
            }
                break;

            case RemoteMethodMulti: {
                if ([[_stateCode substringToIndex:1] isEqualToString:@"E"]) {
                    if (![_stateCode isEqualToString:@"EE"]) {
                        _didError = YES;
                    }
                }
                if (_operationIndex == _deviceCount - 1) {
                    if (_didError) {
                    } else {
                    }
                }
            }
                break;
            default:
                break;
        }
    }

}


@end
