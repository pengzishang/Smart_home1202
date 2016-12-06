//
//  BluetoothManager.h
//  ttsBluetooth_iPhone
//
//  Created by tts on 14-10-10.
//  Copyright (c) 2014年 tts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+StringOperation.h"
#import <CoreBluetooth/CoreBluetooth.h>


#define Peripheral         @"peripheral"
#define AdvertisementData  @"advertisementData"
#define RSSI_VALUE         @"RSSI"



/**
 控制类型方式

 - SendTypeSingle: 单个控制锁
 - SendTypeMuti: 控制多个锁
 - SendTypeSyncdevice: 同步设备状态
 - SendTypeInfrared: 控制红外设备
 - SendTypeLock: 控制锁
 - SendTypeQuery: 查询锁
 */
typedef NS_ENUM(NSUInteger, SendType) {
    SendTypeSingle      = 0,
    SendTypeMuti        = 1,
    SendTypeSyncdevice  = 2,
    SendTypeInfrared    = 3,
    SendTypeLock        = 4,
    SendTypeQuery       = 5
};


 /**
  扫描类型

  - ScanTypeSocket: 只扫描插座
  - ScanTypeSwitch: 只扫描开关
  - ScanTypeCurtain: 窗帘
  - ScanTypeWarning: 报警
  - ScanTypeOther: 其他设备
  - ScanTypeWIFIControl: 远程控制器
  - ScanTypeInfraredControl:红外控制器
  - ScanTypeRemoteControl: 遥控器
  - ScanTypeAll: 全部
  */
 typedef NS_ENUM(NSUInteger, ScanType) {
    ScanTypeSocket          =       0,
    ScanTypeSwitch          =       1,
    ScanTypeCurtain         =       2,
    ScanTypeWarning         =       3,
    ScanTypeOther           =       4,
    ScanTypeWIFIControl     =       5,
    ScanTypeInfraredControl =       6,
    ScanTypeRemoteControl   =       7,
    ScanTypeAll             =       8,
};


/**
 发现设备,扫描设备

 @param __nullable <#__nullable description#>
 */
typedef void(^detectDevice)( NSDictionary * __nullable);

@interface BluetoothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>



/**
 周围设备
 */
@property (retain,nonatomic,nullable)NSMutableArray <__kindof NSDictionary *>* peripheralsInfo;

/**
 扫描的设备种类
 */
@property (strong,nonatomic,nullable)NSMutableArray<__kindof NSString *> *scaningPreFix;


/**
 用这个block触发发现设备
 */
@property (copy,nonatomic,nullable)detectDevice detectDevice;//发现设备

/**
 初始化

 @return <#return value description#>
 */
+ (nullable BluetoothManager *)getInstance;

/**
 扫描设备

 @param isAllowDuplicates NO的时候是低功耗扫描 YES为快速扫描
 @param PrefixArr 一个列表,包括设备类型的NSNumber
 */
- (void)scanPeriherals:(BOOL)isAllowDuplicates AllowPrefix:(NSArray <__kindof NSNumber *>* _Nullable)PrefixArr;

/**
 停止扫描
 */
- (void)stopScan;

/**
 断开设备

 @param peripheral <#peripheral description#>
 */
- (void)disconnectPeriheral:(nullable CBPeripheral *)peripheral;


/**
 查询设备设备状态

 @param deviceInfo <#deviceInfo description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)queryDeviceStatus:(nonnull DeviceInfo *)deviceInfo
                  success:(void(^ _Nullable)( NSData * _Nullable  data))success
                     fail:(NSUInteger(^ _Nullable)( NSString * _Nullable  statusCode))fail;


/**
 发送单个控制指令

 @param commandStr <#commandStr description#>
 @param deviceID <#deviceID description#>
 @param sendType <#sendType description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sendByteCommandWithString:(NSString *__nonnull)commandStr
                         deviceID:(NSString *__nonnull)deviceID
                         sendType:(SendType)sendType
                          success:(void  (^ _Nullable)(NSData *__nullable stateData))success
                             fail:(NSUInteger (^ _Nullable)(NSString *__nullable stateCode))fail;



/**
 刷新多个设备状态

 @param peripheral <#peripheral description#>
 */
-(void)refreshMutiDeviceInfo:(nullable CBPeripheral *)peripheral;


/**
 控制多个设备

 @param commandArr <#commandArr description#>
 @param resultList <#resultList description#>
 */
-(void)mutiCommandControlWithStringArr:(NSArray <__kindof DeviceForScene *>*__nullable)commandArr resultList:(void(^ _Nullable)(NSArray * _Nullable))resultList;

@end
