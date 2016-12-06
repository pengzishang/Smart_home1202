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

@end

@implementation LockAddController

-(NSMutableArray *)nearbyDevice
{
    if (!_nearbyDevice) {
        _nearbyDevice=[NSMutableArray array];
    }
    return _nearbyDevice;
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
        if ([self roomContain:[deviceBroadcastName substringFromIndex:7]]) {
            return ;
        }
        NSUInteger currentIdx= [self.nearbyDevice refreshWithDeviceInfo:deviceInfoDic];
        if (currentIdx==NSUIntegerMax) {//如果没有这个设备
            [self.tableView cyl_reloadData];
        }
        else
        {
            static NSUInteger refreshTime=0;
            if (++refreshTime==35) {//有这个设备,并且35次刷新后
                NSIndexPath *idxPath=[NSIndexPath indexPathForRow:currentIdx inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
                refreshTime=0;
            }
        }
    };
}

-(BOOL)roomContain:(NSString *)deviceID
{
    __block BOOL isContain=NO;
    [self.devicesOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    return @"附近的设备";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _nearbyDevice.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceNameCell" forIndexPath:indexPath];
    NSString *deviceFullName = _nearbyDevice[indexPath.row][@"advertisementData"][@"kCBAdvDataLocalName"];
    NSString *deviceIDstr=[deviceFullName substringFromIndex:7];
    NSNumber *rssiNum=_nearbyDevice[indexPath.row][RSSI_VALUE];
    UILabel *deviceIDLab=[cell viewWithTag:202];
    UILabel *rssiLab=[cell viewWithTag:203];
    deviceIDLab.text=deviceIDstr;
    rssiLab.text=[NSString stringWithFormat:@"信号强度:%@",rssiNum];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[BluetoothManager getInstance]stopScan];
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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(DeviceInfo *)sender {
    if ([segue.identifier isEqualToString:@"back2mainLock"]) {
        LockController *target=segue.destinationViewController;
        target.deviceForAdding=sender;
    }
}


@end
