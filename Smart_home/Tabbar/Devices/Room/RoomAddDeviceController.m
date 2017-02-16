//
//  RoomAddDeviceController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/30.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "RoomAddDeviceController.h"
#import "TTSCoreDataManager.h"
#import "CYLTableViewPlaceHolder.h"
#import "TTSUtility.h"

@interface RoomAddDeviceController () <CYLTableViewPlaceHolderDelegate>

@property(weak, nonatomic) IBOutlet UIBarButtonItem *confirmBtn;
@property(nonatomic, strong) NSMutableArray *devicesNotIn;
@property(nonatomic, strong) NSMutableSet <__kindof NSIndexPath *> *selectItem;
@end

@implementation RoomAddDeviceController

- (NSMutableArray *)devicesNotIn {
    if (!_devicesNotIn) {
        _devicesNotIn = [NSMutableArray array];
        [_devicesOfAll enumerateObjectsUsingBlock:^(DeviceInfo *_Nonnull deviceAllObj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (![_devicesOfRoom containsObject:deviceAllObj]) {
                [_devicesNotIn addObject:deviceAllObj];
            }
        }];
    }
    return _devicesNotIn;
}

- (NSMutableSet<NSIndexPath *> *)selectItem {
    if (!_selectItem) {
        _selectItem = [NSMutableSet set];
    }
    return _selectItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView cyl_reloadData];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//确认选择
- (IBAction)confirmChoose:(UIBarButtonItem *)sender {
    [self addSelectItemInRoomInfo];
    [self refreshSceneInRoomInfo];
    if ([self.enterId isEqualToString:@"addRoomSwitch"]) {
        [self performSegueWithIdentifier:@"roomAddDevice2mainSwitch" sender:nil];
    } else if ([self.enterId isEqualToString:@"addRoomInfrared"]) {
        [self performSegueWithIdentifier:@"roomAddDevice2mainInfrared" sender:nil];
    } else if ([self.enterId isEqualToString:@"addRoomLock"]) {
        [self performSegueWithIdentifier:@"roomAddDevice2mainLock" sender:nil];
    }

}

/**
 刷新房间的设备
 */
- (void)addSelectItemInRoomInfo {
    NSMutableSet *before = [NSMutableSet setWithSet:self.roomInfo.deviceInfo];
    [self.selectItem enumerateObjectsUsingBlock:^(__kindof NSIndexPath *_Nonnull indexPath, BOOL *_Nonnull stop) {
        [before addObject:self.devicesNotIn[indexPath.row]];//指定项目加入房间的设备
    }];

    NSSortDescriptor *sortWithDate = [[NSSortDescriptor alloc] initWithKey:@"deviceCreateDate" ascending:YES];
    NSArray *devices = [before sortedArrayUsingDescriptors:@[sortWithDate]];
    if (self.roomInfo.roomRemoteID) {
        [TTSUtility mutiRemoteSave:devices remoteMacID:self.roomInfo.roomRemoteID];
    } else {
        [TTSUtility mutiRemoteSave:devices remoteMacID:RemoteDefault];
    }

    self.roomInfo.deviceInfo = before;
}

//刷新scene
- (void)refreshSceneInRoomInfo {
    [self.roomInfo.sceneInfo enumerateObjectsUsingBlock:^(SceneInfo *_Nonnull sceneObj, BOOL *_Nonnull stop) {
        NSMutableSet *sceneDevicesBefore = [NSMutableSet setWithSet:sceneObj.devicesInfo];
        [self.selectItem enumerateObjectsUsingBlock:^(__kindof NSIndexPath *_Nonnull selectedObj, BOOL *_Nonnull stop) {
            DeviceInfo *deviceForCopy = self.devicesNotIn[selectedObj.row];
            DeviceForScene *deviceAddToScene = (DeviceForScene *) [[TTSCoreDataManager getInstance] getNewManagedObjectWithEntiltyName:@"DeviceForScene"];
            deviceAddToScene.deviceType = @(deviceForCopy.deviceType.integerValue);
            deviceAddToScene.deviceMacID = deviceForCopy.deviceMacID;
            deviceAddToScene.deviceCustomName = deviceForCopy.deviceCustomName;
            deviceAddToScene.deviceSceneStatus = @"0";
            [sceneDevicesBefore addObject:deviceAddToScene];
        }];
        sceneObj.devicesInfo = sceneDevicesBefore;
    }];
    [[TTSCoreDataManager getInstance] updateData];
}

#pragma mark CYLTableViewPlaceHolderDelegate

- (UIView *)makePlaceHolderView {
    return [[NSBundle mainBundle] loadNibNamed:@"NoneTableView" owner:self options:nil][0];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devicesNotIn.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceNameCell" forIndexPath:indexPath];


    DeviceInfo *device = self.devicesNotIn[indexPath.row];
    NSString *deviceName = device.deviceCustomName;
    NSString *deviceID = device.deviceMacID;
    NSString *infraredID = device.deviceInfraredID;
    NSArray *deviceImage = @[@"equipment_socket_icon_default", @"equipment_one_switch_icon", @"equipment_two_switch_icon", @"equipment_three_switch_icon", @"equipment_window_icon_pressed", @"equipment_window_icon_pressed", @"6", @"7", @"equipment_door_lock_icon"];
    NSArray *infaredDeviceImage = @[@"icon_air", @"icon_tv", @"icon_dvd1", @"add_amp", @"icon_digitalbox"];
    UIImageView *deviceImageView = [cell viewWithTag:201];
    UILabel *deviceNameLab = [cell viewWithTag:202];
    UILabel *deviceIDLab = [cell viewWithTag:203];
    if (device.deviceType.integerValue < 100) {
        deviceImageView.image = [UIImage imageNamed:deviceImage[device.deviceType.integerValue]];
    } else {
        deviceImageView.image = [UIImage imageNamed:infaredDeviceImage[device.deviceType.integerValue - 100]];
    }

    deviceIDLab.text = [NSString stringWithFormat:@"MacID:%@", deviceID.length > 0 ? deviceID : infraredID];
    deviceNameLab.text = deviceName;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.selectItem containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self.selectItem containsObject:indexPath]) {
        [self.selectItem removeObject:indexPath];
        if (self.selectItem.count == 0) {
            _confirmBtn.enabled = NO;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.selectItem addObject:indexPath];
        _confirmBtn.enabled = YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
