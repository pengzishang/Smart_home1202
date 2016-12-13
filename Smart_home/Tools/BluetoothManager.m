//
//  BluetoothManager.m
//  ttsBluetooth_iPhone
//
//  Created by tts on 14-10-10.
//  Copyright (c) 2014年 tts. All rights reserved.
//


//如果寻找设备过久,很容易导致控制失败
#import "BluetoothManager.h"
static  BluetoothManager *  shareInstance;
typedef void(^stateValueFailReturn)(NSInteger);
typedef void(^stateValueSuccessReturn)(NSData *);

@interface BluetoothManager()
{
    BOOL _isDiscoverSuccess;
    BOOL _isWritingSuccess;
    BOOL _scanFastSpeed;
    NSData *_stateData;
    SendType _sendType;
    NSDate *_dataf;
    NSTimer *_timeOutTimer;
    CBCentralManager * _centralManager;
    CBPeripheral  * _curPeripheral;
    NSMutableArray *_dataArr;
}

@property (copy,nonatomic,nonnull)stateValueSuccessReturn successControl;
@property (copy,nonatomic,nonnull)stateValueFailReturn failControl;


@end

@implementation BluetoothManager

NSString * _Nonnull const ScanTypeDescription[] = {
    [ScanTypeSocket]            =   @"ScanTypeSocket",
    [ScanTypeSwitch]            =   @"ScanTypeSwitch",
    [ScanTypeCurtain]           =   @"ScanTypeCurtain",
    [ScanTypeWarning]           =   @"ScanTypeWarning",
    [ScanTypeOther]             =   @"ScanTypeOther",
    [ScanTypeWIFIControl]       =   @"ScanTypeWIFIControl",
    [ScanTypeInfraredControl]   =   @"ScanTypeInfraredControl",
    [ScanTypeRemoteControl]     =   @"ScanTypeRemoteControl",
    [ScanTypeAll]               =   @"ScanTypeAll",
};

+ (BluetoothManager *)getInstance
{
    if (shareInstance == nil) {
        shareInstance = [[BluetoothManager alloc]init];
        [shareInstance initData];
    }
    return shareInstance;
}


-(NSMutableArray<NSString *> *)scaningPreFix
{
    if (!_scaningPreFix) {
        _scaningPreFix =[NSMutableArray array];
    }
    return _scaningPreFix;
}

-(NSMutableArray *)dataArr{
    if(!_dataArr){
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

-(NSMutableArray *)peripheralsInfo
{
    if (!_peripheralsInfo) {
        _peripheralsInfo=[NSMutableArray array];
    }
    return _peripheralsInfo;
}

-(CBCentralManager *)centralManager
{
    if (!_centralManager) {
        _centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];

    }
    return _centralManager;
}

- (void)initData
{
    NSLogMethodArgs(@"%i",self.centralManager.isScanning);
}

- (void)scanPeriherals:(BOOL)isAllowDuplicates AllowPrefix:(NSArray<__kindof NSNumber *> * _Nullable)PrefixArr
{
    /*****是否重复scan****/
    //任意扫描
    [self initPreFix:PrefixArr];
    _scanFastSpeed=isAllowDuplicates;
    NSDictionary * optionsDic= @{CBCentralManagerScanOptionAllowDuplicatesKey : @(isAllowDuplicates)};
    //代理触发更新了
    [self.centralManager scanForPeripheralsWithServices:nil options:optionsDic];
}

-(void)initPreFix:(NSArray <__kindof NSNumber *>*)PrefixArr
{
    [self.scaningPreFix removeAllObjects];
    if(PrefixArr.count==0)
    {
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DeviceTypeList" ofType:@"plist"];
    NSDictionary *DeviceTypeList=[NSDictionary dictionaryWithContentsOfFile:path];
    [PrefixArr enumerateObjectsUsingBlock:^(__kindof NSNumber * _Nonnull scanTypeNum, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *deviceTypeStr=[self getScanTypeString:(ScanType)scanTypeNum.integerValue];
        if ([[DeviceTypeList allKeys] containsObject:deviceTypeStr]) {
            [_scaningPreFix addObjectsFromArray:[DeviceTypeList[deviceTypeStr][0] allKeys]];
        }
    }];
}

- (NSString *)getScanTypeString:(ScanType)scan
{
    return ScanTypeDescription[scan];
}

- (void)stopScan
{
    [self.centralManager stopScan];
}

- (void)disconnectPeriheral:(NSTimer *)sender
{
    CBPeripheral *peripheral=(CBPeripheral *)sender.userInfo;
    [self.centralManager cancelPeripheralConnection:peripheral];
    [sender invalidate];
}

-(void)queryDeviceStatus:(DeviceInfo *)deviceInfo
                 success:(void (^ _Nullable)(NSData * _Nullable))success
                    fail:(NSUInteger (^ _Nullable)(NSString * _Nullable))fail
{
    _sendType=SendTypeQuery;
    [self.dataArr removeAllObjects];
    _dataf = [NSDate date];
    if (success) {
        __block BluetoothManager *blockManger=self;
        blockManger.successControl=^(NSData *stateData){
            //返回成功
            success(stateData);
        };
    }
    
    if (fail) {
        __block BluetoothManager *blockManger=self;
        blockManger.failControl=^(NSInteger stateCode){
            NSString *stateCodeStr=@(stateCode).stringValue;
            //返回错误状态码
            NSUInteger failRetryTime=fail(stateCodeStr);
            if (failRetryTime!=0&&[stateCodeStr integerValue]!=404&&[stateCodeStr integerValue]!=403) {
                CBPeripheral *curPeripheral=[self isAvailableID:deviceInfo.deviceMacID];
                [self connect2Peripheral:curPeripheral];
            }
            else
            {
                NSLog(@"重试次数为0或者不在范围");
            }
        };
    }
    
    
    
    if (self.centralManager.state!=CBCentralManagerStatePoweredOn) {
        if (self.failControl) {
            _failControl(403);
        }
    }
    
    CBPeripheral *curPeripheral=[self isAvailableID:deviceInfo.deviceMacID];
    
    if(curPeripheral)
    {
        [self connect2Peripheral:curPeripheral];
    }
    else
    {//超出范围
        if (self.failControl) {
            self.failControl(404);
        }
    }
    
}

-(void)setTimeOutWithPeriheral:(CBPeripheral *)periheral
{
    [_timeOutTimer invalidate];
    _timeOutTimer=[NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(disconnectPeriheral:) userInfo:periheral repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:_timeOutTimer forMode:NSDefaultRunLoopMode];
}


-(void)sendByteCommandWithString:(NSString *)commandStr
                        deviceID:(NSString *)deviceID
                        sendType:(SendType)sendType
                         success:(void (^)(NSData * _Nullable))success
                            fail:(NSUInteger (^)(NSString * _Nullable))fail
{
    //命令处理
    _isDiscoverSuccess=NO;
    _isWritingSuccess=NO;
    NSLog(@"当前的DeviceID:%@   命令:%@",deviceID,commandStr);
    _sendType=sendType;
    [self.dataArr removeAllObjects];
    
    //计时器
    _dataf = [NSDate date];
    
    if(success)
    {
        __block BluetoothManager *blockManger=self;
        blockManger.successControl=^(NSData *stateData){
            //返回成功
            success(stateData);
        };
    }
    if(fail)
    {
        __block BluetoothManager *blockManger=self;
        blockManger.failControl=^(NSInteger stateCode){
            NSString *stateCodeStr=@(stateCode).stringValue;
            //返回错误状态码
            NSUInteger failRetryTime=fail(stateCodeStr);
            if (failRetryTime!=0&&[stateCodeStr integerValue]!=404&&[stateCodeStr integerValue]!=403) {
                CBPeripheral *curPeripheral=[self isAvailableID:deviceID];
//                [curPeripheral readRSSI];//<<<<<<<
                if (curPeripheral) {
                    [self connect2Peripheral:curPeripheral];
                }
            }
            else{
                NSLog(@"重试次数为0或者不在范围");
            }
        };
    }
    if (self.centralManager.state!=CBCentralManagerStatePoweredOn) {
        if (self.failControl) {
            _failControl(403);
        }
    }
    
    CBPeripheral *curPeripheral=[self isAvailableID:deviceID];
    if (curPeripheral) {
        NSString *udid=curPeripheral.identifier.UUIDString;
        [self initCommandWithStr:commandStr UDID:udid];
        [self connect2Peripheral:curPeripheral];
    }
    else
    {
        if (self.failControl) {
            self.failControl(404);
        }
    }
}


-(void)connect2Peripheral:(CBPeripheral *)curPeripheral
{
    
    curPeripheral.delegate=self;
    NSDictionary * options= @{CBConnectPeripheralOptionNotifyOnConnectionKey : @NO,
                              CBConnectPeripheralOptionNotifyOnDisconnectionKey : @NO,
                              CBConnectPeripheralOptionNotifyOnNotificationKey : @NO};
    [self setTimeOutWithPeriheral:curPeripheral];
    [ self.centralManager connectPeripheral:curPeripheral options:options];
    
    double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
    NSLog(@"STEP1:开始连接:%f  id:%@",time1,curPeripheral.name);
}

-(void)mutiCommandControlWithStringArr:(NSArray *__nullable)commandArr resultList:(void(^ _Nullable)(NSArray * _Nullable))resultList;
{
    _dataf = [NSDate date];
    NSUInteger totalCount=commandArr.count;
    if(commandArr.count==0)
    {
        return;
    }
    
    __block NSUInteger operationIndex=0;
    __block NSMutableDictionary *operationDic=[NSMutableDictionary dictionaryWithDictionary:commandArr[operationIndex]];
    __block NSString *operationDeviceID=commandArr[operationIndex][@"deviceID"];
    __block NSString *operationCommand=commandArr[operationIndex][@"deviceCommand"];
    __block NSUInteger operationDeviceType=[commandArr[operationIndex][@"deviceType"] integerValue];
    __block NSMutableArray *requestArr=[NSMutableArray array];
    
    [self sendByteCommandWithString:operationCommand deviceID:operationDeviceID sendType:SendTypeSingle
                            success:^(NSData * _Nullable stateData)
     {
         
         operationDic=[NSMutableDictionary dictionaryWithDictionary:commandArr[operationIndex]];
         //         operationDic[@"stateCode"]=@(stateCode.integerValue-192);//待修改
         operationDic[@"stateCode"]=[self returnStateCodeWithData:stateData btnCount:operationDeviceType];
         [requestArr addObject:operationDic];
         
         if (operationIndex+1<totalCount) {
             operationIndex++;
             operationDeviceID=commandArr[operationIndex][@"deviceID"];
             operationCommand=commandArr[operationIndex][@"deviceCommand"];
             operationDeviceType=[commandArr[operationIndex][@"deviceType"] integerValue];
             [self sendByteCommandWithString:operationCommand deviceID:operationDeviceID sendType:SendTypeSingle success:nil fail:nil];
         }
         else
         {
             operationIndex=0;
             if (resultList) {
                 resultList(requestArr);
             }
         }
         
     } fail:^NSUInteger(NSString * _Nullable stateCode) {
         
         operationDic=[NSMutableDictionary dictionaryWithDictionary:commandArr[operationIndex]];
         operationDic[@"stateCode"]=@(stateCode.integerValue);//待修改
         [requestArr addObject:operationDic];
         if (operationIndex+1<totalCount) {
             operationIndex++;
             operationDeviceID=commandArr[operationIndex][@"deviceID"];
             operationCommand=commandArr[operationIndex][@"deviceCommand"];
             operationDeviceType=[commandArr[operationIndex][@"deviceType"] integerValue];
             [self sendByteCommandWithString:operationCommand deviceID:operationDeviceID sendType:SendTypeSingle success:nil fail:nil];
         }
         else
         {
             operationIndex=0;
             if (resultList) {
                 resultList(requestArr);
             }
         }
         return 0;
     }];
    
}


-(NSNumber *)returnStateCodeWithData:(NSData *)data btnCount:(NSUInteger)btnCount
{
    Byte  byte;
    
    [data getBytes:&byte length:1];
    if (btnCount==0||btnCount==1) {
        byte = byte & 0x01;
    }
    else if (btnCount==2){
        byte = byte & 0x03;
    }
    else if (btnCount==3){
        byte = byte & 0x07;
    }
    else if (btnCount==4||btnCount==5){
        
    }
    return @(byte);
}

-(void)initCommandWithStr:(NSString *)commandStr UDID:(NSString *)UDID;
{
    NSData *singleData=[[NSData alloc]init];
    if([commandStr length]>3){
        if(_sendType==SendTypeLock)
        {
            Byte *byte1to10=[NSString translateToByte:commandStr];
            singleData =[NSData dataWithBytes:byte1to10 length:10];
            NSLogMethodArgs(@"%@",singleData);
        }
        else
        {
            _sendType=SendTypeInfrared;
            Byte *byte1to9=[NSString translateToByte:commandStr];
            Byte byteCommand[]={0,0,0,0,0,0,0,0,0,0};
            for (NSInteger i=0; i<9; i++) {
                byteCommand[i]=byte1to9[i];
            }
            byteCommand[9]= byte1to9[1]^byte1to9[2]^byte1to9[3];//第10个字节
            singleData =[NSData dataWithBytes:byteCommand length:10];
            
        }
    }
    else{
        //开关控制
        _sendType=SendTypeSingle;
        Byte commamd=(Byte)[commandStr integerValue];
        singleData=[NSData dataWithBytes:&commamd length:1];
    }
    
    NSDictionary *singleDic=@{@"Data":singleData,@"ID":UDID};
    [self.dataArr addObject:singleDic];
}

-(void)refreshMutiDeviceInfo:(CBPeripheral *)peripheral
{
    _sendType=SendTypeSyncdevice;
    _curPeripheral=peripheral;
    _curPeripheral.delegate=self;
    _dataf = [NSDate date];
    NSDictionary * options;
    options = @{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES,
                CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES,
                CBConnectPeripheralOptionNotifyOnNotificationKey : @YES};
    [ self.centralManager connectPeripheral:_curPeripheral options:options];
    double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
    NSLog(@"time1 sync:%f",time1);
    
}


-(CBPeripheral *)isAvailableID:(NSString *)opeartionDeviceID
{
    BOOL isAvailable = NO;
    CBPeripheral *curPeripheral;
    for (NSDictionary * perInfo in self.peripheralsInfo)
    {
        NSDictionary *peripheralInfo=perInfo[AdvertisementData];
        NSString *deviceIDFromAdv=[peripheralInfo[@"kCBAdvDataLocalName"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (deviceIDFromAdv.length>7) {
            NSString * deviceID=[deviceIDFromAdv substringFromIndex:7];
            if ([opeartionDeviceID isEqualToString:deviceID]) {
                curPeripheral = perInfo[Peripheral];
                isAvailable = YES;
                break;
            }
        }
    }
    return isAvailable?curPeripheral:nil;
}


#pragma mark -  CBCentralManagerDelegate methodes   主要是发现,主设备动作
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
        }
            break;
        case CBCentralManagerStateResetting:
        {
            NSLog(@"蓝牙重置");
        }
            break;
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"蓝牙关闭");
        }
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"蓝牙打开");
            [self scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *deviceIDFromAdv=[advertisementData[@"kCBAdvDataLocalName"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *deviceIDFromPeripheral=[peripheral.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([RSSI integerValue]<=-115||[RSSI integerValue]==127)
    {
        return;
    }
    if ([deviceIDFromAdv length]<15&&deviceIDFromPeripheral.length<15) {
        return;
    }
    __block BOOL isSelectPreFix=NO;
    //检查前缀是否符合条件
    [_scaningPreFix enumerateObjectsUsingBlock:^(__kindof NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([deviceIDFromAdv hasPrefix:obj]) {
            isSelectPreFix=YES;
            *stop=YES;
        }
    }];
    if (!isSelectPreFix) {
        return;
    }
    //慢速,监测扫描,
    if (!_scanFastSpeed) {
        if (deviceIDFromAdv.length<6) {
            return;
        }
        NSString *stateCode=[deviceIDFromAdv substringWithRange:NSMakeRange(6, 1)];
                NSString *deviceType=[deviceIDFromAdv substringWithRange:NSMakeRange(5, 1)];
        NSInteger stateIndex=[stateCode characterAtIndex:0];
        
        NSNumber *stateCodeCurrent=[[NSNumber alloc]init];
        if ([deviceType isEqualToString:@"0"]||[deviceType isEqualToString:@"1"]) {
            stateCodeCurrent=@(stateIndex&(0x01));
        }
        else if ([deviceType isEqualToString:@"2"]){
            stateCodeCurrent=@(stateIndex&(0x03));
        }
        else {
            stateCodeCurrent=@(stateIndex&(0x07));
        }
        
        
        if ([stateCode isEqualToString:@":"]||[deviceIDFromAdv hasPrefix:@"WIFI"]) {
            stateIndex=48;//48一个不存在的状态
            stateCodeCurrent=@(-1);
            //老设备
        }
        __block BOOL isContain = NO;
        __block BOOL isStatusSame=NO;
        __block NSUInteger operationIndex=0;
        [self.peripheralsInfo enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBPeripheral *peripheralInStore=obj[Peripheral];
            NSString * pIdentiferInStore = peripheralInStore.identifier.UUIDString;
            NSString * pIdentiferCurrent =peripheral.identifier.UUIDString;
            if ([pIdentiferInStore isEqual:pIdentiferCurrent]) {
                isContain = YES;
                NSNumber *stateCodeInStore=@([obj[@"stateCode"] integerValue]);
                if ([stateCodeCurrent isEqualToNumber:stateCodeInStore]) {
                    isStatusSame=YES;
                }
                else
                {
                    operationIndex=idx;
                    NSLogMethodArgs(@"刷新 %@  强度:%@ 原状态:%@ 现状态:%@",deviceIDFromAdv,RSSI,stateCodeInStore,stateCodeCurrent);
//                    [[NSNotificationCenter defaultCenter]postNotificationName:Note_Refresh_State object:nil userInfo:nil];
                }
            }
        }];
        //如果没有与现有或者新发现的设备重复,那么加入全局的周边设备库
        if (!isContain) {
            NSLog(@"加入 %@  强度:%@  状态:%@",deviceIDFromAdv,RSSI,stateCodeCurrent);
            
            NSDictionary * peripheralInfo = @{Peripheral : peripheral, AdvertisementData : advertisementData, RSSI_VALUE : RSSI,@"stateCode":stateCodeCurrent};
            [[self mutableArrayValueForKey:@"peripheralsInfo"] addObject:peripheralInfo];//数组,观察者
//            if (_detectDevice) {
//                _detectDevice(peripheralInfo);
//            }
            //  刷新数据库
            //                [[NSNotificationCenter defaultCenter]postNotificationName:Note_Refresh_State object:nil userInfo:peripheralInfo];
        }
        else if(isContain&&!isStatusSame)
        {
            //不一样
            //                    [[NSNotificationCenter defaultCenter]postNotificationName:Note_Refresh_State object:nil userInfo:nil];
            
            NSDictionary * peripheralInfo = @{Peripheral : peripheral, AdvertisementData : advertisementData, RSSI_VALUE : RSSI,@"stateCode":stateCodeCurrent};
            [[NSNotificationCenter defaultCenter]postNotificationName:Note_Refresh_State object:nil userInfo:peripheralInfo];
            [self.peripheralsInfo replaceObjectAtIndex:operationIndex withObject:peripheralInfo];

        }
    }
    
    //快速扫描
    else if (_scaningPreFix.count!=0&&_scanFastSpeed)
    {
        if (deviceIDFromAdv.length<6) {
            return;
        }
        NSString *stateCode=[deviceIDFromAdv substringWithRange:NSMakeRange(6, 1)];
        NSString *deviceType=[deviceIDFromAdv substringWithRange:NSMakeRange(5, 1)];
        NSUInteger stateIndex=[stateCode characterAtIndex:0];
        
        NSNumber *stateCodeCurrent=[[NSNumber alloc]init];
        if ([deviceType isEqualToString:@"0"]||[deviceType isEqualToString:@"1"]) {
            stateCodeCurrent=@(stateIndex&(0x01));
        }
        else if ([deviceType isEqualToString:@"2"]){
            stateCodeCurrent=@(stateIndex&(0x03));
        }
        else {
            stateCodeCurrent=@(stateIndex&(0x07));
        }
        
        if ([stateCode isEqualToString:@":"]||[deviceIDFromAdv hasPrefix:@"WIFI"]) {
            stateIndex=48;//48一个不存在的状态
            stateCodeCurrent=@(-1);
            //老设备
        }
        NSLog(@"快速扫描 %@|  强度:%@  状态:%@",deviceIDFromAdv,RSSI,stateCodeCurrent);
        NSDictionary * peripheralInfo = @{Peripheral : peripheral, AdvertisementData : advertisementData, RSSI_VALUE : RSSI,@"stateCode":stateCodeCurrent};
        if (_detectDevice) {
            _detectDevice(peripheralInfo);
        }
        
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
    NSLog(@"STEP2:连接设备成功,开始寻找服务:%f",time1);
    CBUUID * uuid = [CBUUID UUIDWithString:@"FFF0"];
    [peripheral discoverServices:@[uuid]];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
    NSLog(@"STEP7:断开设备:%f",time1);
    if (error) {
        if (self.failControl) {
            //结束失败
            self.failControl(107);
            NSLogMethodArgs(@"异常断开连接 --- %@", error);
        }
    }
    else{
        BOOL isResponse=NO;
        if (![[NSString stringWithFormat:@"%@",_stateData] hasPrefix:@"<ef"]) {//如果有ef,证明红外伴侣未响应
            isResponse=YES;
        }
        if (_isDiscoverSuccess&&_isWritingSuccess&&isResponse) {
            if(self.successControl){
                self.successControl(_stateData);
                NSLogMethodArgs(@"正常断开");
            }
        }
        else{
            if (!_isDiscoverSuccess) {//防止未发现服务提前中止造成正常连接的误报
                if (self.failControl) {
                    self.failControl(103);
                }
            }
            else if (!_isWritingSuccess){
                if (self.failControl) {
                    self.failControl(104);
                }
            }
            else if (!isResponse)
            {
                if (self.failControl) {
                    self.failControl(106);
                }
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        if (self.failControl) {
            self.failControl(102);
        }
    }
    NSLogMethodArgs(@"连接失败 --- %@",error.localizedDescription);
}


#pragma mark -  CBPeripheralDelegate methodes 主要是控制
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
    NSLog(@"STEP3:已经发现服务 寻找特征字:%f",time1);
    if (peripheral.services.count==0) {
        NSLogMethodArgs(@"设备找不到服务");
        if (self.failControl) {
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
    }
    for (CBService * service in peripheral.services ) {
        NSString * serviceID = service.UUID.UUIDString;
        if ([serviceID isEqualToString:@"FFF0"]) {
            CBUUID * FFF1 = [CBUUID UUIDWithString:@"FFF1"];
            CBUUID * FFF6 = [CBUUID UUIDWithString:@"FFF6"];
            NSArray * characteristics = @[FFF1,FFF6];
            [peripheral discoverCharacteristics:characteristics forService:service];
            break;
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    _isDiscoverSuccess=YES;
    double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
    NSLog(@"STEP4:已经发现特征字,准备写入值:%f",time1);
    for (CBCharacteristic * character in service.characteristics) {
        NSString * characterID=character.UUID.UUIDString;
        NSData *controlData= [self returnWithDeviceID:peripheral.identifier.UUIDString];
        if ([characterID isEqualToString:@"FFF1"]&& [controlData length] == 1)
        {
            NSLog(@"写入1bit数据");
            if (_sendType==SendTypeSingle) {
                [peripheral writeValue:controlData forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
            break;
        }
        else if ([characterID isEqualToString:@"FFF6"])
        {
            if ([controlData length]==10) {
                //进行长数据写入
                NSLog(@"写入10bit长数据Data:%@",controlData);
                [peripheral writeValue:controlData forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
            else
            {
                //进行查询数据
                [peripheral readValueForCharacteristic:character];
                _isWritingSuccess=YES;
            }
        }
    }
}

-(NSData *)returnWithDeviceID:(NSString *)deviceID
{
    if (_sendType==SendTypeQuery) {
        return nil;
    }
    __block NSData *data=[[NSData alloc]init];
    [_dataArr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"ID"] isEqualToString:deviceID]) {
            data=obj[@"Data"];
            *stop=YES;
        }
    }];
    return data;
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        [peripheral readValueForCharacteristic: characteristic];
        _isWritingSuccess=YES;
        double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
        NSLog(@"STEP5:写入特征字成功 等待读取特征值:%f",time1);
    }else{
        NSLogMethodArgs(@"写操作失败");
    }
}
/**
 * 读取到特征值
 更新完特征值后运行
 这里不影响开关控制了
 **/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        _stateData=characteristic.value;
    }else{
    }
    double time1=[[NSDate date]timeIntervalSinceDate:_dataf];
    NSLog(@"STEP6:已经获取特征值%@,操作成功,准备断开:%f",_stateData,time1);
    [self.centralManager cancelPeripheralConnection:peripheral];
}



@end
