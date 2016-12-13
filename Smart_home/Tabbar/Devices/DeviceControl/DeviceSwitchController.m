//
//  DeviceSwitchController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/15.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DeviceSwitchController.h"
#import "RemoteController.h"
#import "EditDeviceController.h"
#import "SwtichCollectionCell.h"
#import "CurtainCollectionCell.h"
#import "TTSCoreDataManager.h"
#import "RoomAddDeviceController.h"
#import "AddDevicesController.h"
#import "TTSUtility.h"
#import "FTPopOverMenu.h"
#import "BluetoothManager.h"
#import "AppDelegate.h"
@class CBPeripheral;
@interface DeviceSwitchController ()<SwitchDelegate,CurtainDelegate>
{
    NSTimer *curtainTimer;
}
@property(nonatomic,strong)NSMutableArray <__kindof DeviceInfo *>*devicesOfRoom;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addItemOnStore;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation DeviceSwitchController

-(NSMutableArray<DeviceInfo *> *)devicesOfRoom
{
    if (!_devicesOfRoom) {
        _devicesOfRoom=[NSMutableArray array];
        if (!ISALLROOM) {
            [self.roomInfo.deviceInfo enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull objItem, BOOL * _Nonnull stop) {
                if (objItem.deviceType.integerValue <=5&&objItem.deviceType.integerValue >=0) {
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
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(backgroundRefreshState:) name:Note_Refresh_State object:nil];
    [_navItem setTitle:ISALLROOM?@"全部开关":self.roomInfo.roomName];
    
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

-(void)backgroundRefreshState:(NSNotification *)sender
{
    NSDictionary *peripheralInfo=sender.userInfo[AdvertisementData];
    NSString *deviceIDFromAdv=[peripheralInfo[@"kCBAdvDataLocalName"]
                               stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString * deviceID=[deviceIDFromAdv substringFromIndex:7];
    NSString *stateCode=[deviceIDFromAdv substringWithRange:NSMakeRange(6, 1)];
    [self.devicesOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.deviceMacID isEqualToString:deviceID]) {
            obj.deviceStatus=@(stateCode.integerValue);
            [[TTSCoreDataManager getInstance]updateData];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:idx inSection:0];
            [_mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }];
}


-(void)autoScan:(id)sender
{
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}

- (IBAction)addDevice:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    __block BOOL isRemote=RemoteOn;
    NSString *remoteOnString=isRemote?@"远程:开":@"远程:关";
    NSString *title1=!ISALLROOM?@"添加设备":@"添加设备";
    NSString *remoteId=!ISALLROOM?@"设置默认远程":@"设置房间远程";
    NSString *remoteSync=!ISALLROOM?@"同步房间内的远程":@"同步所有设备远程";
    [FTPopOverMenuConfiguration defaultConfiguration].menuWidth=150;
    [FTPopOverMenu showFromEvent:event withMenu:@[title1,remoteOnString,remoteId,remoteSync] imageNameArray:@[@"default_add_icon-0",@"setting_switch",@"setting_switch",@"setting_switch"] doneBlock:^(NSInteger selectedIndex) {
        if (selectedIndex==0) {
            [self performSegueWithIdentifier:@"addSwitchDevice" sender:self.devices];

        }
        else if (selectedIndex==1){
            isRemote=!isRemote;
            [[NSUserDefaults standardUserDefaults]setBool:isRemote forKey:@"RemoteOn"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        else if (selectedIndex==2){
            ISALLROOM?
            [self performSegueWithIdentifier:@"room2addRemote" sender:nil]:
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

            }
            else
            {
                [self.devices enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [devicesID addObject:obj];
                }];
                [TTSUtility mutiRemoteSave:devicesID remoteMacID:RemoteDefault];

            }
        }
    } dismissBlock:^{
        
    }];
}


#pragma mark-collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.devicesOfRoom.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceInfo *deviceInfo=self.devicesOfRoom[indexPath.row];
//    BOOL isNearBy=[self isNearby:deviceInfo];
    NSArray *reuseId=@[@"Socket",@"SwitchOne",@"SwitchTwo",@"SwitchThree"];
    if (deviceInfo.deviceType.integerValue<=3) {
        SwtichCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:reuseId[deviceInfo.deviceType.integerValue] forIndexPath:indexPath];
        cell.delegate=self;
        [cell.nameBtn setTitle:deviceInfo.deviceCustomName forState:UIControlStateNormal];
        cell.macLab.text=deviceInfo.deviceMacID;
        cell.tag=200+indexPath.row;
        [cell setStateImageWithBtnCount:deviceInfo.deviceType.integerValue deviceState:deviceInfo.deviceStatus];
//        if (!isNearBy) {
//            cell.contentView.alpha=0.4;
//            UILabel *lowRssi=[cell viewWithTag:2001];
//            lowRssi.hidden=NO;
//        }
        return cell;
    }
    else
    {
        CurtainCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"VCurtain" forIndexPath:indexPath];
        cell.delegate=self;
        
//        if (cell.isRuning) {
//            [cell setStateImageWithDeviceState:deviceInfo.deviceStatus];
//            curtainTimer =[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(changeCurtainImage:) userInfo:cell repeats:NO];;
//            [[NSRunLoop currentRunLoop]addTimer:curtainTimer forMode:NSDefaultRunLoopMode];
//        }
//        else if(!cell.isRuning)
//        {
//            cell.isRuning=NO;
            [cell setInformationMac:deviceInfo.deviceMacID name:deviceInfo.deviceCustomName indexPath:indexPath];
//        }
//        if (!isNearBy) {
//            cell.contentView.alpha=0.4;
//            UILabel *lowRssi=[cell viewWithTag:2001];
//            lowRssi.hidden=NO;
//        }
        return cell;
    }
}

-(BOOL)isNearby:(DeviceInfo *)device
{
    __block BOOL isNearBy=NO;
    [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBPeripheral *peripheral=obj[Peripheral];
        if (peripheral.name.length<7) {
            return ;
        }
        if ([[peripheral.name substringFromIndex:7]isEqualToString:device.deviceMacID]&&[obj[RSSI_VALUE] integerValue]>-110) {
            *stop=YES;
            isNearBy=YES;
        }
    }];
    return isNearBy;
}

-(void)changeCurtainImage:(NSTimer *)timer
{
    CurtainCollectionCell *cell=timer.userInfo;
    cell.isRuning=NO;
    [_mainCollectionView reloadItemsAtIndexPaths:@[cell.indexPath]];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//定义每个UICollectionView 的大小,空白的部分是可以重叠的
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger width=(Screen_Width-10-10-10)/2;
    NSUInteger high=width*1.16;//暂时隐藏
    return CGSizeMake(width, high);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 20, 10);
}

#pragma mark SwitchCell方法 CurtainCell方法

-(void)didClickEditCellTag:(NSUInteger)cellTag;
{
//    NSLogMethodArgs(@"%@",self.devicesOfRoom[cellTag-200]);
    [self performSegueWithIdentifier:@"editDevice" sender:self.devicesOfRoom[cellTag-200]];
}

-(void)didClickBtnTag:(NSUInteger)btnTag cellTag:(NSUInteger)cellTag
{
    __block DeviceInfo *device=self.devicesOfRoom[cellTag-200];
    if (RemoteOn) {
        [TTSUtility remoteDeviceControl:device commandStr:[@(btnTag-1000).stringValue fullWithLengthCount:2]  retryTimes:2 conditionReturn:^(NSString *statusCode) {
            NSData *stateData=[[statusCode substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            device.deviceStatus=[self returnStateCodeWithData:(NSData *)stateData btnCount:device.deviceType.integerValue];
            [[TTSCoreDataManager getInstance]updateData];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:cellTag-200 inSection:0];
            [_mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
    }
    else
    {
        [TTSUtility localDeviceControl:device.deviceMacID commandStr:@(btnTag-1000).stringValue retryTimes:3 conditionReturn:^(id stateData) {
            if ([stateData isKindOfClass:[NSData class]]) {//控制成功的
                device.deviceStatus=[self returnStateCodeWithData:(NSData *)stateData btnCount:device.deviceType.integerValue];
                [[TTSCoreDataManager getInstance]updateData];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:cellTag-200 inSection:0];
                [_mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
            else if ([stateData isKindOfClass:[NSString class]])
            {
                
            }
        }];
    }
}

#pragma mark CurtainCell方法

-(void)didClickCurtainBtnTag:(NSUInteger)btnTag cellTag:(NSUInteger)cellTag cell:(CurtainCollectionCell *)cell
{
    //    [curtainTimer invalidate];
    __block DeviceInfo *device=self.devicesOfRoom[cellTag-200];
    if (RemoteOn) {
        [TTSUtility remoteDeviceControl:device commandStr:@(btnTag-1000-24).stringValue retryTimes:3 conditionReturn:^(NSString *statusCode) {
            device.deviceStatus=@(statusCode.integerValue);
            [[TTSCoreDataManager getInstance]updateData];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:cellTag-200 inSection:0];
            [_mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
    }
    else
    {
        [TTSUtility localDeviceControl:device.deviceMacID commandStr:@(btnTag-1000).stringValue retryTimes:3 conditionReturn:^(id stateData) {
            if ([stateData isKindOfClass:[NSData class]]) {//控制成功的
                device.deviceStatus=[self returnStateCodeWithData:(NSData *)stateData btnCount:device.deviceType.integerValue];
                cell.status=device.deviceStatus;
                [[TTSCoreDataManager getInstance]updateData];
                cell.isRuning=YES;
                [_mainCollectionView reloadItemsAtIndexPaths:@[cell.indexPath]];
            }
            else if ([stateData isKindOfClass:[NSString class]])
            {
                
            }
        }];
    }
}

-(NSNumber *)returnStateCodeWithData:(NSData *)data btnCount:(NSUInteger)btnCount
{
    Byte  byte;
    [data getBytes:&byte length:1];
    if (btnCount==0||btnCount==1) {
        byte = (Byte) (byte & 0x01);
    }
    else if (btnCount==2){
        byte = (Byte) (byte & 0x03);
    }
    else if (btnCount==3){
        byte = (Byte) (byte & 0x07);
    }
    else if (btnCount==4||btnCount==5){
        
    }
    return @(byte);
}

-(IBAction)unwindToMainSwitchList:(UIStoryboardSegue *)sender
{
    if ([sender.sourceViewController isKindOfClass:[EditDeviceController class]]) {
        if (self.deviceForChanging) {
            [self editRoomSceneChange];
            [[TTSCoreDataManager getInstance]updateData];
            self.deviceForChanging=nil;
        }
        else if(self.deviceForDelete){
            if (!ISALLROOM) {//存在房间信息
                [self editRoomSceneDelete];
                NSMutableSet *devicesOfRoomInfo=[NSMutableSet setWithSet:self.roomInfo.deviceInfo];
                [devicesOfRoomInfo removeObject:self.deviceForDelete];
                self.roomInfo.deviceInfo=devicesOfRoomInfo;
                [[TTSCoreDataManager getInstance]updateData];
            }
            else{
                [self editRoomSceneDelete];
                [[TTSCoreDataManager getInstance]deleteDataWithObject:self.deviceForDelete];
                [self.devices removeObject:self.deviceForDelete];
            }
            [self.devicesOfRoom removeObject:self.deviceForDelete];
            self.deviceForDelete=nil;
        }
        [self.mainCollectionView reloadData];
    }
    else if ([sender.sourceViewController isKindOfClass:[RoomAddDeviceController class]])
    {
        _devicesOfRoom=nil;
        [self.mainCollectionView reloadData];
    }
    else//添加设备
    {
        [self.devicesOfRoom addObject:self.deviceForAdding];
        if(!ISALLROOM){
            NSMutableSet *devicesOfRoomInfo=[NSMutableSet setWithSet:self.roomInfo.deviceInfo];
            [devicesOfRoomInfo addObject:self.deviceForAdding];
            self.roomInfo.deviceInfo=devicesOfRoomInfo;
            [[TTSCoreDataManager getInstance]updateData];
        }
        else
        {
            [self.devices addObject:self.deviceForAdding];
            [[TTSCoreDataManager getInstance]insertDataWithObject:self.deviceForAdding];
            [TTSUtility syncRemoteDevice:self.deviceForAdding remoteMacID:RemoteDefault conditionReturn:^(NSString *statusCode) {
                
            }];
        }
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.devicesOfRoom.count-1 inSection:0];
        [self.mainCollectionView insertItemsAtIndexPaths:@[indexPath]];
    }
}
//删除后同步房间设备
-(void)editRoomSceneDelete{
    if (!ISALLROOM) {
        [self.roomInfo.sceneInfo enumerateObjectsUsingBlock:^(SceneInfo * _Nonnull sceneObj, BOOL * _Nonnull stop) {
            NSMutableSet <DeviceForScene *>*deviceSetBefore=[NSMutableSet setWithSet:sceneObj.devicesInfo];
            NSString *selectDeviceName=self.deviceForDelete.deviceMacID;
            [deviceSetBefore enumerateObjectsUsingBlock:^(DeviceForScene * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj.deviceMacID isEqualToString:selectDeviceName]) {
                    *stop=YES;
                    [deviceSetBefore removeObject:obj];
                }
            }];
            sceneObj.devicesInfo=deviceSetBefore;
        }];
    }
    else//对所有设备进行编辑
    {
        NSMutableArray <DeviceForScene *>*device_scene_del=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"DeviceForScene" predicate:nil];
        [device_scene_del enumerateObjectsUsingBlock:^(DeviceForScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *selectDeviceName=self.deviceForDelete.deviceMacID;
            if ([selectDeviceName isEqualToString:obj.deviceMacID]) {
                [[TTSCoreDataManager getInstance]deleteDataWithObject:obj];
            }
        }];
    }
}

-(void)editRoomSceneChange{
    NSMutableArray <DeviceForScene *>*device_scene_change=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"DeviceForScene" predicate:nil];
    [device_scene_change enumerateObjectsUsingBlock:^(DeviceForScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *selectDeviceName=self.deviceForChanging.deviceMacID;
        if ([selectDeviceName isEqualToString:obj.deviceMacID]) {
            obj.deviceCustomName=self.deviceForChanging.deviceCustomName;
        }
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editDevice"]) {
        EditDeviceController *target=segue.destinationViewController;
        target.deviceInfo=(DeviceInfo *)sender;
    }
    else if ([segue.identifier isEqualToString:@"addSwitchDevice"])
    {
        AddDevicesController *target=segue.destinationViewController;
        target.deviceOfRoom=(NSMutableArray *)sender;
        if (!ISALLROOM) {
            target.roomInfo=self.roomInfo;
        }
        
    }
    else if ([segue.identifier isEqualToString:@"addRoomSwitch"])
    {
        RoomAddDeviceController *target=segue.destinationViewController;
        target.enterId=@"addRoomSwitch";
        target.devicesOfRoom=self.devicesOfRoom;
        target.devicesOfAll=self.devices;
        target.roomInfo=(RoomInfo *)sender;
    }
    else if ([segue.identifier isEqualToString:@"room2addRemote"])
    {
        RemoteController *target=segue.destinationViewController;
        target.roomInfo=(RoomInfo *)sender;
    }
    
}


-(void)dealloc
{
    
}

@end
