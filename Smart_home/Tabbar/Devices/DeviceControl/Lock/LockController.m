//
//  LockController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/22.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "LockController.h"
#import "XLPasswordView.h"
#import "LockAddController.h"
#import "LockSettingController.h"
#import "TTSUtility.h"
#import "FTPopOverMenu.h"
#import "RoomAddDeviceController.h"
#import "CYLTableViewPlaceHolder.h"
#import "BluetoothManager.h"
#import "AppDelegate.h"
@interface LockController ()<XLPasswordViewDelegate,CYLTableViewPlaceHolderDelegate>
@property (nonatomic,assign)NSUInteger operationIndex;
@property(nonatomic,strong)NSMutableArray <__kindof DeviceInfo *>*devicesOfRoom;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation LockController

-(NSMutableArray<DeviceInfo *> *)devicesOfRoom
{
    if (!_devicesOfRoom) {
        _devicesOfRoom=[NSMutableArray array];
        if (!ISALLROOM) {
            [self.roomInfo.deviceInfo enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull objItem, BOOL * _Nonnull stop) {
                if (objItem.deviceType.integerValue ==8) {
                    [_devicesOfRoom addObject:objItem];
                }
            }];
        }
        else
        {
            [_devicesOfRoom addObjectsFromArray:self.devices];
        }
    }
    return _devicesOfRoom;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [_navItem setTitle:!ISALLROOM?self.roomInfo.roomName:@"全部智能门锁"];
    self.tableView.tableFooterView=[[UIView alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!app.autoScan.valid) {
        app.autoScan=[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(autoScan:) userInfo:nil repeats:YES];
        [app.autoScan fire];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.autoScan.valid) {
        [app.autoScan invalidate];
    }
}


-(void)autoScan:(id)sender
{
    NSLogMethodArgs(@"autoScan");
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}

- (IBAction)addLock:(UIBarButtonItem *)sender  event:(UIEvent *)event
{
    __block BOOL isRemote=RemoteOn;
    NSString *remoteOnString=isRemote?@"远程:开":@"远程:关";
    NSString *title1=!ISALLROOM?@"添加已有智能门锁":@"添加新智能门锁";
    NSString *remoteId=!ISALLROOM?@"设置默认远程":@"设置房间远程";
    NSString *remoteSync=!ISALLROOM?@"同步房间内的远程":@"同步所有设备远程";
    [FTPopOverMenuConfiguration defaultConfiguration].menuWidth=200;
    [FTPopOverMenu showFromEvent:event withMenu:@[title1,remoteOnString,remoteId,remoteSync] imageNameArray:@[@"default_add_icon-0",@"setting_switch",@"setting_switch",@"setting_switch"] doneBlock:^(NSInteger selectedIndex) {
        if (selectedIndex==0) {
            !ISALLROOM?
            [self performSegueWithIdentifier:@"addRoomLock" sender:self.roomInfo]://有房间信息
            [self performSegueWithIdentifier:@"lockAdd" sender:self.devicesOfRoom];
        }
        else if (selectedIndex==1){
            isRemote=!isRemote;
            [[NSUserDefaults standardUserDefaults]setBool:isRemote forKey:@"RemoteOn"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        else if (selectedIndex==2){
            [self performSegueWithIdentifier:@"room2addRemote" sender:self.roomInfo];
        }
        else if (selectedIndex==3){
            //远程同步房间
            NSMutableArray *devicesID=[NSMutableArray array];
            if (!ISALLROOM) {
                [self.roomInfo.deviceInfo enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                    [devicesID addObject:obj];
                }];
                [TTSUtility mutiRemoteSave:devicesID remoteMacID:self.roomInfo.roomRemoteID];
//                [[RemoteManger getInstance]multiSaveRemoteDevices:devicesID successNumberReturn:^(NSUInteger successCount) {
//                } remoteMac:self.roomInfo.roomRemoteID];
            }
            else
            {
                [self.devices enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [devicesID addObject:obj];
                }];
                [TTSUtility mutiRemoteSave:devicesID remoteMacID:RemoteDefault];
//                [[RemoteManger getInstance]multiSaveRemoteDevices:devicesID successNumberReturn:^(NSUInteger successCount) {
//                } remoteMac:RemoteDefault];
            }
        }
    } dismissBlock:^{
    }];
}

#pragma mark CYLTableViewPlaceHolderDelegate

- (UIView *)makePlaceHolderView
{
    return [[NSBundle mainBundle]loadNibNamed:@"NoneTableView" owner:self options:nil][0];
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devicesOfRoom.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _operationIndex=indexPath.row;
    XLPasswordView *passwordView = [XLPasswordView passwordView];
    passwordView.delegate = self;
    [passwordView showPasswordInView:self.view.window];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceInfo *device=self.devicesOfRoom[indexPath.row];
//    BOOL isNearBy=[self isNearby:device];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LockCell" forIndexPath:indexPath];
    UILabel *nameLab=[cell viewWithTag:1001];
    nameLab.text=device.deviceCustomName;
    UILabel *IDLab=[cell viewWithTag:1002];
    IDLab.text=device.deviceMacID;
//    if (!isNearBy) {
//        cell.contentView.alpha=0.4;
//    }
    return cell;
}

-(BOOL)isNearby:(DeviceInfo *)device
{
    __block BOOL isNearBy=NO;
    [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBPeripheral *peripheral=obj[Peripheral];
        if ([[peripheral.name substringFromIndex:7]isEqualToString:device.deviceMacID]&&[obj[RSSI_VALUE] integerValue]>-90) {
            *stop=YES;
            isNearBy=YES;
        }
    }];
    return isNearBy;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _operationIndex=indexPath.row;
    [self performSegueWithIdentifier:@"lockmain2detail" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DeviceInfo *device_del=self.devicesOfRoom[indexPath.row];
        if (!ISALLROOM) {//存在房间信息
            NSMutableSet *devicesOfRoomInfo=[NSMutableSet setWithSet:self.roomInfo.deviceInfo];
            [devicesOfRoomInfo removeObject:device_del];
            self.roomInfo.deviceInfo=devicesOfRoomInfo;
            [self.devicesOfRoom removeObject:device_del];
            [[TTSCoreDataManager getInstance]updateData];
        }
        else
        {
            [[TTSCoreDataManager getInstance]deleteDataWithObject:self.devicesOfRoom[indexPath.row]];
            [self.devices removeObject:device_del];
            [self.devicesOfRoom removeObject:device_del];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark XLPasswordView

- (void)passwordView:(XLPasswordView *)passwordView passwordTextDidChange:(NSString *)password
{
    
}
/**
 *  输入密码位数已满时调用
 */
- (void)passwordView:(XLPasswordView *)passwordView didFinishInput:(NSString *)password
{
    [passwordView hidePasswordView];
    if (RemoteOn) {
        
        [TTSUtility lockWithRemoteInfo:self.devicesOfRoom[_operationIndex] lockMode:APPLockModeOpen passWord:password validtime:10000];
    }
    else
    {
        [TTSUtility lockWithDeviceInfo:self.devicesOfRoom[_operationIndex] lockMode:APPLockModeOpen passWord:password validtime:10000];
    }

}


-(IBAction)unwindToMainLockList:(UIStoryboardSegue *)sender
{
    if ([sender.sourceViewController isKindOfClass:[LockAddController class]]) {
        NSLog(@"%@",self.deviceForAdding);
        [[TTSCoreDataManager getInstance]insertDataWithObject:self.deviceForAdding];
        [TTSUtility syncRemoteDevice:self.deviceForAdding remoteMacID:RemoteDefault conditionReturn:^(NSString *statusCode) {
            
        }];
        [self.devicesOfRoom addObject:self.deviceForAdding];
//        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.devicesOfRoom.count-1 inSection:0];
        [self.tableView cyl_reloadData];
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if ([sender.identifier isEqualToString:@"roomAddDevice2mainLock"])
    {
        _devicesOfRoom=nil;
        [self.tableView cyl_reloadData];
    }
}



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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"lockmain2detail"]) {
        LockSettingController *target=segue.destinationViewController;
        DeviceInfo *device=self.devicesOfRoom[_operationIndex];
        target.deviceInfo=device;
        self.navItem.title=self.devicesOfRoom[_operationIndex].deviceCustomName;
    }
    else if ([segue.identifier isEqualToString:@"addRoomLock"])
    {
        RoomAddDeviceController *target=segue.destinationViewController;
        target.devicesOfRoom=self.devicesOfRoom;
        target.devicesOfAll=self.devices;
        target.roomInfo=(RoomInfo *)sender;
        target.enterId=@"addRoomLock";

    }
    else if ([segue.identifier isEqualToString:@"lockAdd"])
    {
        LockAddController *target=segue.destinationViewController;
        target.devicesOfRoom=(NSMutableArray *)sender;
    }
}


@end
