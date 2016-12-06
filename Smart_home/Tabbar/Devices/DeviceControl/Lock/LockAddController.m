//
//  LockAddController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/23.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "LockAddController.h"
#import "LockController.h"
#import "TTSCoreDataManager.h"
#import "BluetoothManager.h"
#import "NSString+StringOperation.h"
#import "CYLTableViewPlaceHolder.h"
#import "NSMutableArray+AddDeviceArray.h"
#import "AppDelegate.h"
@interface LockAddController ()<CYLTableViewPlaceHolderDelegate>

@property (nonatomic,strong)NSMutableArray *nearbyDevice;
@property (nonatomic,strong)NSMutableArray <NSDictionary *>*deviceInStore;
@end

@implementation LockAddController

-(NSMutableArray *)nearbyDevice
{
    if (!_nearbyDevice) {
        _nearbyDevice=[NSMutableArray array];
    }
    return _nearbyDevice;
}

-(NSMutableArray<NSDictionary *> *)deviceInStore
{
    if (!_deviceInStore) {
        _deviceInStore=[NSMutableArray array];
    }
    return _deviceInStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView cyl_reloadData];
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.autoScan invalidate];
    [self performSelector:@selector(startRefresh:) withObject:nil afterDelay:1];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.autoScan=[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(autoScan:) userInfo:nil repeats:YES];
    [app.autoScan fire];
}


-(void)autoScan:(id)sender
{
    NSLogMethodArgs(@"autoScan");
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRefresh:(id)sender {
    NSArray *scanTypeList=@[@(ScanTypeWarning)];
    [[BluetoothManager getInstance] scanPeriherals:YES AllowPrefix:scanTypeList];
    [BluetoothManager getInstance].detectDevice=^(NSDictionary *deviceInfoDic){
        NSString *deviceBroadcastName= deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        BOOL allDeviceContain=[self roomContain:[deviceBroadcastName substringFromIndex:7] inDevicesOfRoom:self.devicesOfRoom];
        if (self.roomInfo) {
            NSSortDescriptor *sortWithDate=[NSSortDescriptor sortDescriptorWithKey:@"deviceCreateDate" ascending:YES];
            NSArray *roomdevices=[self.roomInfo.deviceInfo sortedArrayUsingDescriptors:@[sortWithDate]];
            BOOL isRoomContain=[self roomContain:[deviceBroadcastName substringFromIndex:7] inDevicesOfRoom:roomdevices];
            if (allDeviceContain&&!isRoomContain) {
                [self refreshWithArr:self.deviceInStore forDic:deviceInfoDic inSection:1];
            }
            else if (!allDeviceContain&&!isRoomContain){
                [self refreshWithArr:self.nearbyDevice forDic:deviceInfoDic inSection:0];
            }
        }
        else
        {
            if (!allDeviceContain) {
                
                [self refreshWithArr:self.nearbyDevice forDic:deviceInfoDic inSection:0];
            }
        }
    };
}

-(void)refreshWithArr:(NSMutableArray *)arr forDic:(NSDictionary *)dic inSection:(NSUInteger)section
{
    NSUInteger currentIdx= [arr refreshWithDeviceInfo:dic];
    if (currentIdx==NSUIntegerMax) {
        [self.tableView cyl_reloadData];
    }
    else
    {
        static NSUInteger refreshTime=0;
        if (++refreshTime==15) {//刷新
            NSIndexPath *idxPath=[NSIndexPath indexPathForRow:currentIdx inSection:section];
            [self.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
            refreshTime=0;
        }
    }
}


-(BOOL)roomContain:(NSString *)deviceID inDevicesOfRoom:(NSArray *)deviceOfRoom
{
    __block BOOL isContain=NO;
    [deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([deviceID isEqualToString:obj.deviceMacID]) {
            isContain=YES;
            *stop=YES;
        }
    }];
    return isContain;
}


#pragma mark CYLTableViewPlaceHolderDelegate

- (UIView *)makePlaceHolderView
{
    return [[NSBundle mainBundle]loadNibNamed:@"NoneTableView" owner:self options:nil][0];
}


#pragma mark - Table view data source

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return @"附近的未添加设备";
    }
    else
    {
        return @"已经添加的设备";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.roomInfo) {
        return 2;
    }
    else
    {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return _nearbyDevice.count;
    }
    else
    {
        return _deviceInStore.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceNameCell" forIndexPath:indexPath];
    UILabel *deviceIDLab=[cell viewWithTag:202];
    UILabel *rssiLab=[cell viewWithTag:203];
    
    if (indexPath.section==0) {
        NSString *deviceFullName = _nearbyDevice[indexPath.row][@"advertisementData"][@"kCBAdvDataLocalName"];
        NSString *deviceIDstr=[deviceFullName substringFromIndex:7];
        NSNumber *rssiNum=_nearbyDevice[indexPath.row][RSSI_VALUE];
        deviceIDLab.text=deviceIDstr;
        rssiLab.text=[NSString stringWithFormat:@"信号强度:%@",rssiNum];
    }
    else if (indexPath.section==1){
        NSString *deviceFullName = _deviceInStore[indexPath.row][@"advertisementData"][@"kCBAdvDataLocalName"];
        NSString *deviceIDstr=[deviceFullName substringFromIndex:7];
        NSNumber *rssiNum=_deviceInStore[indexPath.row][RSSI_VALUE];
        deviceIDLab.text=deviceIDstr;
        rssiLab.text=[NSString stringWithFormat:@"信号强度:%@",rssiNum];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[BluetoothManager getInstance]stopScan];
    
    
    if (indexPath.section==0) {
        NSDictionary *infoDic=_nearbyDevice[indexPath.row];
        NSString *deviceName = infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        NSString *deviceIDstr=[deviceName substringFromIndex:7];
        NSDictionary *devicesInfoDic=@{@"deviceMacID":deviceIDstr,@"deviceCustomName":deviceName,@"deviceType":@"8",@"deviceStatus":@(0)};
        DeviceInfo *deviceInfo = (DeviceInfo *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"DeviceInfo"];
        [deviceInfo setValuesForKeysWithDictionary:devicesInfoDic];
        deviceInfo.deviceCustomName=[NSString stringWithFormat:@"%@:%@",[NSString ListNameWithPrefix:[deviceName substringToIndex:7]],[deviceIDstr substringFromIndex:deviceIDstr.length-4]];
        deviceInfo.deviceCreateDate=[NSDate date];
        if (RemoteDefault) {
            deviceInfo.deviceRemoteMac=RemoteDefault;
        }
        deviceInfo.deviceTapCount=@(0);
        deviceInfo.isCommonDevice=@(YES);
        [self performSegueWithIdentifier:@"back2mainLock" sender:deviceInfo];
    }
    else
    {
        NSDictionary *infoDic=_deviceInStore[indexPath.row];
        NSString *deviceName = infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        NSString *deviceID=[deviceName substringFromIndex:7];
        __block DeviceInfo *deviceInfo=nil;
        [self.devicesOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.deviceMacID isEqualToString:deviceID]) {
                deviceInfo=obj;
                *stop=YES;
            }
        }];
        [self performSegueWithIdentifier:@"back2mainLock" sender:deviceInfo];
    }

}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(DeviceInfo *)sender {
    if ([segue.identifier isEqualToString:@"back2mainLock"]) {
        LockController *target=segue.destinationViewController;
        target.deviceForAdding=sender;
    }
}


@end
