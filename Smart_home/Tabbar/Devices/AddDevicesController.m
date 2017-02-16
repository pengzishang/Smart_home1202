//
//  AddDevicesController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/8.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "AddDevicesController.h"
#import "ManualAddBlueToothController.h"
#import "DeviceSwitchController.h"
#import "BluetoothManager.h"
#import "TTSCoreDataManager.h"

@interface AddDevicesController ()
@property(weak, nonatomic) IBOutlet UIImageView *flashImage;
@property(weak, nonatomic) IBOutlet UILabel *lab1;
@property(weak, nonatomic) IBOutlet UIButton *confirmAdd;
@property(weak, nonatomic) IBOutlet UILabel *macID;
@property(weak, nonatomic) IBOutlet UITextField *deviceNameField;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property(strong, nonatomic) NSTimer *globalTime;
@property(strong, nonatomic) NSDictionary *currentDeviceDic;

@end

@implementation AddDevicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
    _globalTime = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(repeatAction) userInfo:nil repeats:YES];

}

- (void)repeatAction {
    NSArray *frameImage = @[@"click_frame_a", @"click_frame_b", @"click_frame_c", @"click_frame_d", @"click_frame_e"];
    static NSUInteger idx = 0;
    _flashImage.image = [UIImage imageNamed:frameImage[idx]];
    idx++;
    if (idx == frameImage.count) {
        idx = 0;
    }
}


- (void)refreshData {
    NSArray *scanTypeList = @[@(ScanTypeSwitch), @(ScanTypeSocket), @(ScanTypeCurtain)];

    [[BluetoothManager getInstance] scanPeriherals:YES AllowPrefix:scanTypeList];

    [BluetoothManager getInstance].detectDevice = ^(NSDictionary *deviceInfoDic) {
        NSString *deviceBroadcastName = deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        if ([deviceBroadcastName hasPrefix:@"AMJ"]) {
            if (self.roomInfo) {
                NSSortDescriptor *sortWithDate = [NSSortDescriptor sortDescriptorWithKey:@"deviceCreateDate" ascending:YES];
                NSArray *roomdevices = [self.roomInfo.deviceInfo sortedArrayUsingDescriptors:@[sortWithDate]];
                if ([self roomContain:[deviceBroadcastName substringFromIndex:7] inDevicesOfRoom:roomdevices]) {
                    return;
                }
            } else if ([self roomContain:[deviceBroadcastName substringFromIndex:7] inDevicesOfRoom:self.deviceOfRoom]) {
                return;
            }
            [self DirectConfirm:deviceInfoDic];
        }
    };
}

- (BOOL)roomContain:(NSString *)deviceID inDevicesOfRoom:(NSArray *)deviceOfRoom {
    __block BOOL isContain = NO;
    [deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([deviceID isEqualToString:obj.deviceMacID]) {
            isContain = YES;
            *stop = YES;
        }
    }];
    return isContain;
}

/**
 *  直接按开关添加
 *
 *  @param infoDic <#infoDic description#>
 */
- (void)DirectConfirm:(NSDictionary *)infoDic {
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    NSString *deviceName = infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
    NSString *deviceType = [self deviceTypeWithID:deviceName];
    NSString *deviceIDstr = [deviceName substringFromIndex:7];
    NSNumber *deviceStateCode = [self getStateCode:deviceType stateCodeNum:infoDic[@"stateCode"]];
    NSDictionary *devicesInfoDic = @{@"deviceMacID": deviceIDstr, @"deviceCustomName": deviceName, @"deviceType": deviceType, @"deviceStatus": deviceStateCode};
    self.currentDeviceDic = devicesInfoDic;
    [self changeView:devicesInfoDic];
}

- (NSNumber *)getStateCode:(NSString *)deviceType stateCodeNum:(NSNumber *)stateCode {
    if (deviceType.integerValue == 2) {
        return @(stateCode.integerValue & 0x03);
    } else if (deviceType.integerValue == 1) {
        return @(stateCode.integerValue & 0x01);
    } else {
        return stateCode;
    }
}

- (NSString *)deviceTypeWithID:(NSString *)deviceName {
    return [deviceName substringWithRange:NSMakeRange(4, 2)];
}


- (void)changeView:(NSDictionary *)deviceDic {
    [_globalTime invalidate];
    _lab1.hidden = YES;
    _macID.hidden = NO;
    _confirmAdd.hidden = NO;
    _deviceNameField.hidden = NO;
    [_deviceNameField resignFirstResponder];
    _rightBarButton.title = @"重新扫描";
    _rightBarButton.action = @selector(resetToNormal:);

    NSString *deviceName = deviceDic[@"deviceCustomName"];
    NSUInteger deviceType = [deviceDic[@"deviceType"] integerValue];
    NSString *deviceIDstr = [deviceName substringFromIndex:7];

    if (deviceType > 5) {
        deviceType = 0;
    }
    NSArray *auto_add_image = @[@"auto_add_type00", @"auto_add_type01", @"auto_add_type02", @"auto_add_type03", @"auto_add_type04", @"auto_add_type05"];
    _deviceNameField.placeholder = [NSString stringWithFormat:@"%@:%@", [NSString ListNameWithPrefix:[deviceName substringToIndex:6]], [deviceIDstr substringFromIndex:deviceIDstr.length - 4]];
    _macID.text = [NSString stringWithFormat:@"ID:%@", deviceIDstr];
    _flashImage.image = [UIImage imageNamed:auto_add_image[deviceType]];
}

- (void)resetToNormal:(UIBarButtonItem *)sender {
    _lab1.hidden = NO;
    _macID.hidden = YES;
    _confirmAdd.hidden = YES;
    _deviceNameField.hidden = YES;
    _rightBarButton.title = @"手动模式";
    _rightBarButton.action = @selector(manualMode:);
    [self refreshData];
    _globalTime = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(repeatAction) userInfo:nil repeats:YES];

}


- (IBAction)manualMode:(UIBarButtonItem *)sender {

    [self performSegueWithIdentifier:@"manualMode" sender:nil];
}


- (IBAction)confirmAdd:(UIButton *)sender {
    NSString *deviceName = self.currentDeviceDic[@"deviceCustomName"];
    NSString *deviceIDstr = self.currentDeviceDic[@"deviceMacID"];
    if (self.roomInfo) {
        if (![self roomContain:deviceIDstr inDevicesOfRoom:self.deviceOfRoom]) {
            DeviceInfo *deviceInfo = (DeviceInfo *) [[TTSCoreDataManager getInstance] getNewManagedObjectWithEntiltyName:@"DeviceInfo"];
            [deviceInfo setValuesForKeysWithDictionary:self.currentDeviceDic];
            deviceInfo.deviceCustomName = [NSString stringWithFormat:@"%@:%@", [NSString ListNameWithPrefix:[deviceName substringToIndex:6]], [deviceIDstr substringFromIndex:deviceIDstr.length - 4]];
            deviceInfo.deviceCreateDate = [NSDate date];
            if (RemoteDefault) {
                deviceInfo.deviceRemoteMac = RemoteDefault;
            }
            deviceInfo.deviceTapCount = @(0);
            deviceInfo.isCommonDevice = @(YES);
            [self performSegueWithIdentifier:@"quick2MainSwitch" sender:deviceInfo];
        } else {
            __block DeviceInfo *deviceInfo = nil;
            [self.deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([obj.deviceMacID isEqualToString:deviceIDstr]) {
                    deviceInfo = obj;
                    *stop = YES;
                }
            }];
            [self performSegueWithIdentifier:@"quick2MainSwitch" sender:deviceInfo];
        }
    } else {
        DeviceInfo *deviceInfo = (DeviceInfo *) [[TTSCoreDataManager getInstance] getNewManagedObjectWithEntiltyName:@"DeviceInfo"];
        [deviceInfo setValuesForKeysWithDictionary:self.currentDeviceDic];
        deviceInfo.deviceCustomName = [NSString stringWithFormat:@"%@:%@", [NSString ListNameWithPrefix:[deviceName substringToIndex:6]], [deviceIDstr substringFromIndex:deviceIDstr.length - 4]];
        deviceInfo.deviceCreateDate = [NSDate date];
        if (RemoteDefault) {
            deviceInfo.deviceRemoteMac = RemoteDefault;
        }
        deviceInfo.deviceTapCount = @(0);
        deviceInfo.isCommonDevice = @(YES);
        [self performSegueWithIdentifier:@"quick2MainSwitch" sender:deviceInfo];
    }


}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    [_globalTime invalidate];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLogMethodArgs(@"%@", segue.sourceViewController);
    if ([segue.identifier isEqualToString:@"quick2MainSwitch"]) {
        DeviceSwitchController *target = segue.destinationViewController;
        target.deviceForAdding = (DeviceInfo *) sender;
    } else if ([segue.identifier isEqualToString:@"manualMode"]) {
        ManualAddBlueToothController *target = segue.destinationViewController;
        target.deviceOfRoom = self.deviceOfRoom;
        if (!ISALLROOM) {
            target.roomInfo = self.roomInfo;
        }
    }
}


@end
