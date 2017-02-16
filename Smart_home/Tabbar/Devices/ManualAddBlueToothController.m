//
//  ManualAddBlueToothController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/9.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "ManualAddBlueToothController.h"
#import "BluetoothManager.h"
#import "NSMutableArray+AddDeviceArray.h"
#import "DeviceSwitchController.h"
#import "TTSCoreDataManager.h"
#import "CYLTableViewPlaceHolder.h"

@interface ManualAddBlueToothController () <CYLTableViewPlaceHolderDelegate>
@property(nonatomic, strong) NSMutableArray *nearbyDevice;
@property(nonatomic, strong) NSMutableArray <NSDictionary *> *deviceInStore;

@end

@implementation ManualAddBlueToothController

- (NSMutableArray *)nearbyDevice {
    if (!_nearbyDevice) {
        _nearbyDevice = [NSMutableArray array];
    }
    return _nearbyDevice;
}

- (NSMutableArray<NSDictionary *> *)deviceInStore {
    if (!_deviceInStore) {
        _deviceInStore = [NSMutableArray array];
    }
    return _deviceInStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView cyl_reloadData];
    [self performSelector:@selector(startRefresh:) withObject:nil afterDelay:1];
}

- (IBAction)startRefresh:(id)sender {
    NSArray *scanTypeList = @[@(ScanTypeSwitch), @(ScanTypeSocket), @(ScanTypeCurtain)];
    [[BluetoothManager getInstance] scanPeriherals:YES AllowPrefix:scanTypeList];
    [BluetoothManager getInstance].detectDevice = ^(NSDictionary *deviceInfoDic) {
        NSString *deviceBroadcastName = deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        BOOL allDeviceContain = [self roomContain:[deviceBroadcastName substringFromIndex:7] inDevicesOfRoom:self.deviceOfRoom];
        if (self.roomInfo) {
            NSSortDescriptor *sortWithDate = [NSSortDescriptor sortDescriptorWithKey:@"deviceCreateDate" ascending:YES];
            NSArray *roomdevices = [self.roomInfo.deviceInfo sortedArrayUsingDescriptors:@[sortWithDate]];
            BOOL isRoomContain = [self roomContain:[deviceBroadcastName substringFromIndex:7] inDevicesOfRoom:roomdevices];
            if (allDeviceContain && !isRoomContain) {
                [self refreshWithArr:self.deviceInStore forDic:deviceInfoDic inSection:1];
            } else if (!allDeviceContain && !isRoomContain) {
                [self refreshWithArr:self.nearbyDevice forDic:deviceInfoDic inSection:0];
            }
        } else {
            if (!allDeviceContain) {

                [self refreshWithArr:self.nearbyDevice forDic:deviceInfoDic inSection:0];
            }
        }

    };
}

- (void)refreshWithArr:(NSMutableArray *)arr forDic:(NSDictionary *)dic inSection:(NSUInteger)section {
    NSUInteger currentIdx = [arr refreshWithDeviceInfo:dic];
    if (currentIdx == NSUIntegerMax) {
        [self.tableView cyl_reloadData];
    } else {
        static NSUInteger refreshTime = 0;
        if (++refreshTime == 35) {//刷新
            NSIndexPath *idxPath = [NSIndexPath indexPathForRow:currentIdx inSection:section];
            [self.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
            refreshTime = 0;
        }
    }
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

- (NSString *)deviceTypeWithID:(NSString *)deviceName {
    NSString *deviceType = [NSString new];
    BOOL isOldDevice = [deviceName hasPrefix:@"Switch"] || [deviceName hasPrefix:@"Socket"];
    if (isOldDevice) {
        deviceType = [deviceName substringWithRange:NSMakeRange(7, 1)];
    } else {
        deviceType = [deviceName substringWithRange:NSMakeRange(4, 2)];
        if (deviceType.integerValue >= 21) {
            deviceType = @(deviceType.integerValue - 20).stringValue;
        } else if (deviceType.integerValue >= 11 && deviceType.integerValue <= 13) {
            deviceType = @(deviceType.integerValue - 10).stringValue;
        } else if (deviceType.integerValue >= 0 && deviceType.integerValue <= 5) {

        } else {
            deviceType = @"00";
        }
    }
    return deviceType;
}

//工厂中有个设备有问题,需要纠正状态码
- (NSNumber *)getStateCode:(NSString *)deviceType stateCodeNum:(NSNumber *)stateCode {
    if (deviceType.integerValue == 2) {
        return @(stateCode.integerValue & 0x03);
    } else if (deviceType.integerValue == 1) {
        return @(stateCode.integerValue & 0x01);
    } else {
        return stateCode;
    }
}

#pragma mark CYLTableViewPlaceHolderDelegate

- (UIView *)makePlaceHolderView {
    return [[NSBundle mainBundle] loadNibNamed:@"NoneTableView" owner:self options:nil][0];
}

#pragma mark - Table view data source

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"附近的未添加设备";
    } else {
        return @"已经添加的设备";
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.roomInfo) {
        return 2;
    } else {
        return 1;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _nearbyDevice.count;
    } else {
        return _deviceInStore.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceNameCell" forIndexPath:indexPath];
    NSArray *deviceImage = @[@"equipment_socket_icon_default", @"equipment_one_switch_icon", @"equipment_two_switch_icon", @"equipment_three_switch_icon", @"equipment_window_icon_pressed", @"equipment_window_icon_pressed"];
    UIImageView *deviceImageView = [cell viewWithTag:201];
    UILabel *deviceIDLab = [cell viewWithTag:202];
    UILabel *rssiLab = [cell viewWithTag:203];
    if (indexPath.section == 0) {
        NSString *deviceFullName = _nearbyDevice[indexPath.row][@"advertisementData"][@"kCBAdvDataLocalName"];
        NSString *deviceIDstr = [deviceFullName substringFromIndex:7];
        NSNumber *rssiNum = _nearbyDevice[indexPath.row][RSSI_VALUE];
        NSString *deviceType = [self deviceTypeWithID:deviceFullName];
        deviceImageView.image = [UIImage imageNamed:deviceImage[deviceType.integerValue]];
        deviceIDLab.text = deviceIDstr;
        rssiLab.text = [NSString stringWithFormat:@"信号强度:%@", rssiNum];
    } else {
        NSString *deviceFullName = _deviceInStore[indexPath.row][@"advertisementData"][@"kCBAdvDataLocalName"];
        NSString *deviceIDstr = [deviceFullName substringFromIndex:7];
        NSNumber *rssiNum = _deviceInStore[indexPath.row][RSSI_VALUE];
        NSString *deviceType = [self deviceTypeWithID:deviceFullName];
        deviceImageView.image = [UIImage imageNamed:deviceImage[deviceType.integerValue]];
        deviceIDLab.text = deviceIDstr;
        rssiLab.text = [NSString stringWithFormat:@"信号强度:%@", rssiNum];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSDictionary *infoDic = _nearbyDevice[indexPath.row];
        NSString *deviceName = infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        NSString *deviceType = [self deviceTypeWithID:deviceName];
        NSString *deviceIDstr = [deviceName substringFromIndex:7];
        NSNumber *deviceStateCode = [self getStateCode:deviceType stateCodeNum:infoDic[@"stateCode"]];
        NSDictionary *devicesInfoDic = @{@"deviceMacID": deviceIDstr, @"deviceCustomName": deviceName, @"deviceType": deviceType, @"deviceStatus": deviceStateCode};
        DeviceInfo *deviceInfo = (DeviceInfo *) [[TTSCoreDataManager getInstance] getNewManagedObjectWithEntiltyName:@"DeviceInfo"];
        [deviceInfo setValuesForKeysWithDictionary:devicesInfoDic];
        if ([deviceName hasPrefix:@"Switch"]) {
            deviceInfo.deviceCustomName = [NSString stringWithFormat:@"%@:%@", [NSString ListNameWithPrefix:[deviceName substringToIndex:8]], [deviceIDstr substringFromIndex:deviceIDstr.length - 4]];
        } else {
            deviceInfo.deviceCustomName = [NSString stringWithFormat:@"%@:%@", [NSString ListNameWithPrefix:[deviceName substringToIndex:7]], [deviceIDstr substringFromIndex:deviceIDstr.length - 4]];
        }

        deviceInfo.deviceCreateDate = [NSDate date];
        if (RemoteDefault) {
            deviceInfo.deviceRemoteMac = RemoteDefault;
        }
        deviceInfo.deviceTapCount = @(0);
        deviceInfo.isCommonDevice = @(YES);
        [self performSegueWithIdentifier:@"manual2MainSwitch" sender:deviceInfo];
    } else {
        NSDictionary *infoDic = _deviceInStore[indexPath.row];
        NSString *deviceName = infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        NSString *deviceID = [deviceName substringFromIndex:7];
        __block DeviceInfo *deviceInfo = nil;
        [self.deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj.deviceMacID isEqualToString:deviceID]) {
                deviceInfo = obj;
                *stop = YES;
            }
        }];
        [self performSegueWithIdentifier:@"manual2MainSwitch" sender:deviceInfo];
    }

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(DeviceInfo *)sender {
    if ([segue.identifier isEqualToString:@"manual2MainSwitch"]) {
        DeviceSwitchController *target = segue.destinationViewController;
        target.deviceForAdding = sender;
    }
}


@end
