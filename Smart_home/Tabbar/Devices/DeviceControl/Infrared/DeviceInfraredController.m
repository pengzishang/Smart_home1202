//
//  DeviceInfraredController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DeviceInfraredController.h"
#import "TTSCoreDataManager.h"
#import "InfraredViewCell.h"
#import "AirViewController.h"
#import "CommonInfraredController.h"
#import "TVController.h"
#import "FTPopOverMenu.h"
#import "AppDelegate.h"
#import "CYLTableViewPlaceHolder.h"
#import "RoomAddDeviceController.h"
#import "BluetoothManager.h"

@interface DeviceInfraredController () <CYLTableViewPlaceHolderDelegate>

@property(weak, nonatomic) IBOutlet UITableView *mainTableView;
@property(strong, nonatomic) NSMutableArray *devicesOfRoom;
@property(weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation DeviceInfraredController

- (NSMutableArray<DeviceInfo *> *)devicesOfRoom {
    if (!_devicesOfRoom) {
        _devicesOfRoom = [NSMutableArray array];
        if (!ISALLROOM) {
            [self.roomInfo.deviceInfo enumerateObjectsUsingBlock:^(DeviceInfo *_Nonnull objItem, BOOL *_Nonnull stop) {
                if (objItem.deviceType.integerValue <= 104 && objItem.deviceType.integerValue >= 100) {
                    [_devicesOfRoom addObject:objItem];
                }
            }];
        } else {
            [_devicesOfRoom addObjectsFromArray:self.devices];
        }
    }
    return _devicesOfRoom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[FTPopOverMenuConfiguration defaultConfiguration] setMenuWidth:150];
    [_navItem setTitle:!ISALLROOM ? self.roomInfo.roomName : @"全部红外设备"];
    [_mainTableView cyl_reloadData];
    _mainTableView.tableFooterView = [[UIView alloc] init];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!app.autoScan.valid) {
        app.autoScan = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(autoScan:) userInfo:nil repeats:YES];
        [app.autoScan fire];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (app.autoScan.valid) {
        [app.autoScan invalidate];
    }
}


- (void)autoScan:(id)sender {
    NSLogMethodArgs(@"autoScan");
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}

- (IBAction)addDevice:(UIBarButtonItem *)sender event:(UIEvent *)event {
    __block BOOL isRemote = RemoteOn;
    NSString *remoteOnString = isRemote ? @"远程:开" : @"远程:关";
    if (!ISALLROOM) {
        [FTPopOverMenu showFromEvent:event withMenu:@[@"新设备", @"已有的设备", remoteOnString] imageNameArray:@[@"default_add_icon-0", @"default_add_icon-0", @"setting_switch"] doneBlock:^(NSInteger selectedIndex) {
            if (selectedIndex == 0) {
                [self performSegueWithIdentifier:@"infaredAdd" sender:nil];
            } else if (selectedIndex == 1) {
                [self performSegueWithIdentifier:@"addRoomInfrared" sender:self.roomInfo];//有房间信息
            } else if (selectedIndex == 2) {
                isRemote = !isRemote;
                [[NSUserDefaults standardUserDefaults] setBool:isRemote forKey:@"RemoteOn"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }               dismissBlock:^{
        }];
    } else {
        [FTPopOverMenu showFromEvent:event withMenu:@[@"新设备", remoteOnString] imageNameArray:@[@"default_add_icon-0", @"setting_switch"] doneBlock:^(NSInteger selectedIndex) {
            if (selectedIndex == 0) {
                [self performSegueWithIdentifier:@"infaredAdd" sender:nil];
            } else if (selectedIndex == 1) {
                isRemote = !isRemote;
                [[NSUserDefaults standardUserDefaults] setBool:isRemote forKey:@"RemoteOn"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }               dismissBlock:^{
        }];
    }

}

#pragma mark CYLTableViewPlaceHolderDelegate

- (UIView *)makePlaceHolderView {
    return [[NSBundle mainBundle] loadNibNamed:@"NoneTableView" owner:self options:nil][0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devicesOfRoom.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfraredViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonCell" forIndexPath:indexPath];
    [cell setInfoWithDeviceInfo:self.devicesOfRoom[indexPath.row]];
//    BOOL isNearBy=[self isNearby:self.devicesOfRoom[indexPath.row]];
//    if (!isNearBy) {
//        cell.contentView.alpha=0.4;
//    }
    return cell;
}

- (BOOL)isNearby:(DeviceInfo *)device {
    __block BOOL isNearBy = NO;
    [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        CBPeripheral *peripheral = obj[Peripheral];
        if ([[peripheral.name substringFromIndex:7] isEqualToString:device.deviceMacID] && [obj[RSSI_VALUE] integerValue] > -90) {
            *stop = YES;
            isNearBy = YES;
        }
    }];
    return isNearBy;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceInfo *deviceInfo = self.devicesOfRoom[indexPath.row];
    NSArray *identifier = @[@"infrared2air", @"infrared2TV", @"infrared2DVD", @"infrared2amp", @"infrared2box"];
    //    if (deviceInfo.deviceType.integerValue!=103) {//AMP设计中
    [self performSegueWithIdentifier:identifier[deviceInfo.deviceType.integerValue - 100] sender:deviceInfo];
    //    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        DeviceInfo *device_del = self.devicesOfRoom[indexPath.row];
        if (!ISALLROOM) {//存在房间信息
            NSMutableSet *devicesOfRoomInfo = [NSMutableSet setWithSet:self.roomInfo.deviceInfo];
            [devicesOfRoomInfo removeObject:device_del];
            self.roomInfo.deviceInfo = devicesOfRoomInfo;
            [self.devicesOfRoom removeObject:device_del];
            [[TTSCoreDataManager getInstance] updateData];
        } else {
            [[TTSCoreDataManager getInstance] deleteDataWithObject:self.devicesOfRoom[indexPath.row]];
            [self.devices removeObject:device_del];
            [self.devicesOfRoom removeObject:device_del];
        }
        //        [tableView cyl_reloadData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    delete.backgroundColor = [UIColor redColor];
    UITableViewRowAction *edit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"编辑" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        NSLogMethodArgs(@"编辑");
        //        [tableView resignFirstResponder];
    }];
    edit.backgroundColor = [UIColor blueColor];
    return @[delete];
}


- (IBAction)unwindToMainInfraredList:(UIStoryboardSegue *)sender {
    NSLog(@"%@", self.deviceForAdding);

    if ([sender.identifier isEqualToString:@"infrared2InfraredMain"]) {
        [self.devicesOfRoom addObject:self.deviceForAdding];
        [self.devices addObject:self.deviceForAdding];
        if (self.roomInfo) {
            NSMutableSet *devicesOfRoomInfo = [NSMutableSet setWithSet:self.roomInfo.deviceInfo];
            [devicesOfRoomInfo addObject:self.deviceForAdding];
            self.roomInfo.deviceInfo = devicesOfRoomInfo;
        }
        [[TTSCoreDataManager getInstance] insertDataWithObject:self.deviceForAdding];
        //        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.devicesOfRoom.count-1 inSection:0];
        [_mainTableView cyl_reloadData];
        self.deviceForAdding = nil;
        //        [_mainTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if ([sender.identifier isEqualToString:@"roomAddDevice2mainInfrared"]) {
        _devicesOfRoom = nil;
        self.deviceForAdding = nil;
        [self.mainTableView cyl_reloadData];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"infrared2air"]) {
        AirViewController *target = segue.destinationViewController;
        target.deviceInfo = (DeviceInfo *) sender;
    } else if ([segue.identifier isEqualToString:@"infaredAdd"]) {

    } else if ([segue.identifier isEqualToString:@"infrared2TV"]) {
        TVController *target = segue.destinationViewController;
        target.deviceInfo = (DeviceInfo *) sender;
    } else if ([segue.identifier isEqualToString:@"infrared2amp"] || [segue.identifier isEqualToString:@"infrared2DVD"] || [segue.identifier isEqualToString:@"infrared2box"]) {
        CommonInfraredController *target = segue.destinationViewController;
        target.deviceInfo = (DeviceInfo *) sender;
    } else if ([segue.identifier isEqualToString:@"addRoomInfrared"]) {
        RoomAddDeviceController *target = segue.destinationViewController;
        target.devicesOfRoom = self.devicesOfRoom;
        target.devicesOfAll = self.devices;
        target.roomInfo = (RoomInfo *) sender;
        target.enterId = @"addRoomInfrared";
    }

}


@end
