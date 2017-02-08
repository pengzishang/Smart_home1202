//
//  DevicesController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/6/30.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DevicesController.h"
#import "AddDevicesController.h"
#import "TTSUtility.h"
#import "DeviceSwitchController.h"
#import "DeviceInfraredController.h"
#import "LockController.h"
#import "FTPopOverMenu.h"
#import "OtherViewController.h"
#import "EditSceneController.h"
#import "AppDelegate.h"
#import <sys/utsname.h>
//#import "UIDevice+DeviceModel.h"
@interface DevicesController ()<MainDelegate>


@property(nonatomic,strong) IBOutlet UITableView *mainTableView;
@property(nonatomic,strong) NSMutableArray <__kindof DeviceInfo *>*deviceOfRoom;
@property(nonatomic,strong) NSMutableArray <__kindof RoomInfo *>*rooms;

@property (weak, nonatomic) IBOutlet UIButton *roomTitle;
@property (weak, nonatomic) IBOutlet UILabel *totalSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lockTitle;
@property (weak, nonatomic) IBOutlet UILabel *totalInfrared;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editRoom;

@end

@implementation DevicesController

#pragma mark - 数据初始化

-(NSMutableArray<DeviceInfo *> *)deviceOfRoom
{
    if (!_deviceOfRoom) {
        _deviceOfRoom=[NSMutableArray array];
        if([_currentRoom.roomType isEqual:@(10)])
        {
            NSArray *devices=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"DeviceInfo" predicate:nil];
            [_deviceOfRoom addObjectsFromArray:devices];
        }
        else{
            [_currentRoom.deviceInfo enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull obj, BOOL * _Nonnull stop){
                [_deviceOfRoom addObject:obj];
            }];

        }
    }
    return _deviceOfRoom;
}

-(NSMutableArray<RoomInfo *> *)rooms
{
    if ([[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"RoomInfo" predicate:nil].count==1) {
        _rooms=nil;
    }
    if (!_rooms) {
        _rooms=[NSMutableArray arrayWithArray:[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"RoomInfo" predicate:nil]];
        [_rooms enumerateObjectsUsingBlock:^(__kindof RoomInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.roomType isEqualToNumber:@(10)]) {
                *stop=YES;//将
                [_rooms insertObject:obj atIndex:0];
                [_rooms removeObjectAtIndex:idx+1];
            }
        }];
    }
    return _rooms;
}

#pragma mark storyBoard动作
- (IBAction)switchRoomBtn:(UIButton *)sender forEvent:(UIEvent *)event {
    
    [[FTPopOverMenuConfiguration defaultConfiguration]setMenuWidth:180];
    NSArray *roomImage=@[@"room_icon_bathroom",@"room_icon_bedroom",@"room_icon_kitchen",@"room_icon_livingroom",@"room_icon_book",@"room_icon_children",@"room_icon_kitchen",@"room_icon_custom",@"",@"",@"lock_funtion1"];
    NSMutableArray *roomNames=[NSMutableArray array];
    NSMutableArray *roomTypeImage=[NSMutableArray array];
    [self.rooms enumerateObjectsUsingBlock:^(__kindof RoomInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [roomNames addObject:obj.roomName];
        [roomTypeImage addObject:roomImage[obj.roomType.integerValue]];
    }];
    [roomNames addObject:@"添加房间"];
    [roomTypeImage addObject:@"default_add_icon-0"];
    [FTPopOverMenu showForSender:sender withMenu:roomNames imageNameArray:roomTypeImage
                       doneBlock:^(NSInteger selectedIndex) {
                           if (selectedIndex>=0&&selectedIndex<roomNames.count-1) {
                               _currentRoom=self.rooms[selectedIndex];
                               [self.rooms enumerateObjectsUsingBlock:^(__kindof RoomInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                                   if ([obj.isCommonRoom isEqualToNumber:@(YES)]) {
                                       obj.isCommonRoom=@(NO);
//                                       *stop=YES;
//                                   }
                               }];
                               if (self.currentRoom) {
                                   self.currentRoom.isCommonRoom=@(YES);
                               }
                               [[TTSCoreDataManager getInstance]updateData];
                               [self setTotalLabWithRoomInfo:self.rooms[selectedIndex]];
                           }
                           else if (selectedIndex==roomNames.count-1) {//添加房间
                               if (self.rooms.count==1&&self.deviceOfRoom.count==0) {
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"建议" message:@"请先添加设备,再添加房间\n(否则房间内将不会有可添加设备,反正我已经警告你了)" preferredStyle:UIAlertControllerStyleAlert];
                                   UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的,我知道了" style:UIAlertActionStyleCancel handler:nil];
                                   UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"不,我偏要!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                       [self performSegueWithIdentifier:@"main2addRoom" sender:nil];
                                   }];
                                   [alertController addAction:cancelAction];
                                   [alertController addAction:okAction];
                                   [self presentViewController:alertController animated:YES completion:nil];
                               }
                               else{
                                   [self performSegueWithIdentifier:@"main2addRoom" sender:nil];
                               }
                           }
                       } dismissBlock:^{}];
}

#pragma mark 自有方法
-(IBAction)editRoom:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"编辑房间标题" message:@"这里可以更改房间名字" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder=self.currentRoom.roomName;
        textField.textAlignment=NSTextAlignmentCenter;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteRoom];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *roomName=alertController.textFields[0].text.length>0?
        alertController.textFields[0].text:alertController.textFields[0].placeholder;
        self.currentRoom.roomName=roomName;
        [_roomTitle setTitle:roomName forState:UIControlStateNormal];
        [[TTSCoreDataManager getInstance]updateData];
    }];
    [alertController addAction:okAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)deleteRoom
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"是否删除[%@]这个空间",self.currentRoom.roomName] preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *confirmlAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[TTSCoreDataManager getInstance]deleteDataWithObject:self.currentRoom];
        [self.rooms removeObject:self.currentRoom];
        _currentRoom=nil;
        _editRoom.enabled=NO;
        [self setTotalLabWithRoomInfo:self.rooms[0]] ;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmlAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)leftBarItemDidClick:(id)sender
{
    if (_delegate&&[_delegate respondsToSelector:@selector(didClickLeftDrawer)]) {
        [_delegate didClickLeftDrawer];
    }
}

#pragma mark 系统方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCommonRoom];
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    MainLeftController *main=[TTSUtility getCurrentDrawerControl];
    main.delegate=self;
    [self loadUI];
}

-(void)loadUI
{
    UIView *sceneView=[[NSBundle mainBundle]loadNibNamed:@"AddView" owner:self options:nil][0];
    sceneView.center=CGPointMake(Screen_Width-40, Screen_Height-100);
    UIButton *btn=[sceneView viewWithTag:1001];
    [btn addTarget:self action:@selector(openSceneMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sceneView];
        _mainTableView.tableFooterView=[[UIView alloc]init];
}

-(void)openSceneMenu:(UIButton *)sender
{
    if (_delegate&&[_delegate respondsToSelector:@selector(didClickSceneIcon:)]) {
        [_delegate didClickSceneIcon:self.currentRoom];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTotalLabWithRoomInfo:self.currentRoom];
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!app.autoScan.valid) {
        app.autoScan=[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(autoScan:) userInfo:nil repeats:YES];
        [app.autoScan fire];
    }
    
}

-(void)autoScan:(id)sender
{
    NSLogMethodArgs(@"autoScan");
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}


-(void)setCommonRoom
{
    [self.rooms enumerateObjectsUsingBlock:^(__kindof RoomInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isCommonRoom.boolValue) {
            self.currentRoom=obj;
            _editRoom.enabled=YES;
            if ([obj.roomType isEqualToNumber:@10]) {
                _editRoom.enabled=NO;
            }
            [self setTotalLabWithRoomInfo:obj];
            *stop=YES;
        }
    }];
}

-(void)setTotalLabWithRoomInfo:(RoomInfo *)roomInfo
{
    _deviceOfRoom=nil;
    _rooms=nil;
    if (self.rooms.count==1||[roomInfo.roomType isEqualToNumber:@(10)]) {
        roomInfo=self.rooms[0];
        self.currentRoom=self.rooms[0];//修复删除房间后不能正确归位
        roomInfo.isCommonRoom=@(YES);
        [[TTSCoreDataManager getInstance]updateData];
    }
    [_roomTitle setTitle:roomInfo.roomName forState:UIControlStateNormal];
    _editRoom.enabled=[roomInfo.roomType isEqualToNumber:@10]?NO:YES;
    self.totalSwitch.text=[NSString stringWithFormat:@"共%@个设备",[self numberOfSwitch]];
    self.lockTitle.text=[NSString stringWithFormat:@"共%@个设备",[self numberOfLock]];
    self.totalInfrared.text=[NSString stringWithFormat:@"共%@个设备",[self numberOfInfrared]];
}

-(NSNumber *)numberOfSwitch
{
    __block NSUInteger i=0;
    [self.deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            if (obj.deviceType.integerValue>=0&&obj.deviceType.integerValue<=5) {
                i++;
            }
        }
    }];
    return @(i);
}

-(NSNumber *)numberOfLock
{
    __block NSUInteger i=0;
    [self.deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.deviceType.integerValue==8) {
            i++;
        }
    }];
    return @(i);
}


-(NSNumber *)numberOfInfrared
{
    __block NSUInteger i=0;
    [self.deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.deviceType.integerValue<=105&&obj.deviceType.integerValue>=100) {
            i++;
        }
    }];
    return @(i);
}

#pragma mark 推送

- (void)networkDidSetup:(NSNotification *)notification {
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    NSLog(@"未连接");
}

- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"%@", [notification userInfo]);
    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, extra];
    NSLog(@"%@", currentContent);
}



#pragma mark main

-(void)didFinishAdding
{
    [self setCommonRoom];
}

#pragma mark 情景模式关联

-(void)didClickSceneIndex:(NSUInteger)index
{

    NSSortDescriptor *sortByDate=[NSSortDescriptor sortDescriptorWithKey:@"sceneCreateDate" ascending:YES];
    NSArray <SceneInfo *>*all_Scene=[self.currentRoom.sceneInfo sortedArrayUsingDescriptors:@[sortByDate]];
    
    if (index==all_Scene.count) {
        //添加情景模式
        NSLogMethodArgs(@"%@",[UIDevice currentDevice].model);
        struct utsname systemInfo;//识别是否4S
        uname(&systemInfo);
        NSString* code = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSUTF8StringEncoding];
        NSUInteger maxItem=0;
        if ([code isEqualToString:@"iPhone4,1"]) {
            maxItem=5;
        }
        if (index<maxItem) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加情景模式" message:@"输入情景模式的名字" preferredStyle: UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder=@"情景模式名字";
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *roomName=alertController.textFields[0].text;
                if (roomName.length==0) {
                    roomName=alertController.textFields[0].placeholder;
                }

                if ([self.currentRoom.roomType isEqualToNumber:@(10)]) {
                    [TTSUtility addSceneWithRoom:self.rooms[0] roomDevice:self.deviceOfRoom index:self.currentRoom.sceneInfo.count roomName:roomName];
                }
                else
                {
                    [TTSUtility addSceneWithRoom:self.currentRoom roomDevice:self.deviceOfRoom index:self.currentRoom.sceneInfo.count roomName:roomName];
                }
                
            }];
            
            
            [alertController addAction:cancelAction];
            [alertController  addAction:confirmAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"此房间情景模式不能超过8个" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
 
        
    }
    else
    {//点击执行情景模式
        NSSortDescriptor *sortByID=[NSSortDescriptor sortDescriptorWithKey:@"deviceMacID" ascending:YES];
        NSArray *all_devices=[all_Scene[index].devicesInfo sortedArrayUsingDescriptors:@[sortByID]];
        if (all_devices.count==0) {
#warning 加入所有设备下的判定
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"房间内没有设备" preferredStyle: UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            //这里只有蓝牙控制
            if (RemoteOn) {
                [TTSUtility mutiRemoteControl:all_devices result:^(NSArray *list) {
                    NSLogMethodArgs(@"%@",list);
                }];
            }
            else
            {
                [TTSUtility mutiLocalDeviceControlWithDeviceInfoArr:all_devices result:^(NSArray <NSDictionary *>*resultArr) {
                    [resultArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull resultObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [_deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.deviceMacID isEqualToString:resultObj[@"deviceID"]]) {
                                obj.deviceSceneStatus=resultObj[@"stateCode"];
                                *stop=YES;
                            }
                        }];
                    }];
                }];
            }
            
            
            
        }
    }

}

-(void)willEditSceneIndex:(NSUInteger)index
{
    [self performSegueWithIdentifier:@"main2SceneEdit" sender:@(index)];
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<4) {
        NSArray *identifiers=@[@"default2Switch",@"default2Infrared",@"default2Lock",@"default2Other"];
        [self performSegueWithIdentifier:identifiers[indexPath.row] sender:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSArray *devicesOfAll=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"DeviceInfo" predicate:nil];
    if ([segue.identifier isEqualToString:@"default2Switch"]) {
        __block NSMutableArray *deviceOfSwitch=[NSMutableArray array];
        [devicesOfAll enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull objItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (objItem.deviceType.integerValue <=5&&objItem.deviceType.integerValue >=0) {
                [deviceOfSwitch addObject:objItem];
            }
        }];
        DeviceSwitchController *target=segue.destinationViewController;
        target.roomInfo=_currentRoom;
        target.devices=deviceOfSwitch;//所有的开关
    }
    else if ([segue.identifier isEqualToString:@"default2Infrared"]){
        __block NSMutableArray *deviceOfInfrared=[NSMutableArray array];
        [devicesOfAll enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull objItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (objItem.deviceType.integerValue <=104&&objItem.deviceType.integerValue >=100) {
                [deviceOfInfrared addObject:objItem];
            }
        }];
        DeviceInfraredController *target=segue.destinationViewController;
        target.roomInfo=_currentRoom;
        target.devices=deviceOfInfrared;
    }
    else if ([segue.identifier isEqualToString:@"default2Lock"]){
        __block NSMutableArray *deviceOfLock=[NSMutableArray array];
        [devicesOfAll enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull objItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (objItem.deviceType.integerValue ==8) {
                [deviceOfLock addObject:objItem];
            }
        }];
        LockController *target=segue.destinationViewController;
        target.roomInfo=_currentRoom;
        target.devices=deviceOfLock;
    }
    else if ([segue.identifier isEqualToString:@"default2Other"]){
        __block NSMutableArray *deviceOfOther=[NSMutableArray array];
        [devicesOfAll enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull objItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if (objItem.deviceType.integerValue <=20||objItem.deviceType.integerValue >=9||
                objItem.deviceType.integerValue ==6||
                objItem.deviceType.integerValue ==53||objItem.deviceType.integerValue ==54) {//遥控器为53 54
                [deviceOfOther addObject:objItem];
            }
        }];
        OtherViewController *target=segue.destinationViewController;
        target.roomInfo=_currentRoom;
        target.devices=deviceOfOther;
    }
    else if ([segue.identifier isEqualToString:@"main2SceneEdit"]){
        EditSceneController *target=segue.destinationViewController;
        NSNumber *index=(NSNumber *)sender;
        NSSortDescriptor *sort=[[NSSortDescriptor alloc]initWithKey:@"sceneCreateDate" ascending:YES];
        NSArray *scene_all=[self.currentRoom.sceneInfo sortedArrayUsingDescriptors:@[sort]];
        [self loadingSceneData:scene_all];
        target.sceneInfo= scene_all[index.integerValue];
    }
}


/**
 去除重复的情景模式数据

 @param allScene 全部的情景模式
 */
-(void)loadingSceneData:(NSArray *)allScene
{
    SceneInfo *temp=allScene[0];//目前房间内的Scene
    NSSet <DeviceForScene *>*sceneDevice=temp.devicesInfo;//目前scene设备
    NSMutableSet <DeviceInfo *>*roomDevice=[NSMutableSet set];
    //得到room内应有的scene设备
    [self.deviceOfRoom enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull roomDeviceObj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((roomDeviceObj.deviceType.integerValue <=5&&roomDeviceObj.deviceType.integerValue >=0)||(roomDeviceObj.deviceType.integerValue<=23&&roomDeviceObj.deviceType.integerValue>20))  {
            [roomDevice addObject:roomDeviceObj];
        }
    }];

    __block NSMutableSet <NSString *>*deviceNeedRemove=[NSMutableSet set];
    __block NSMutableSet <DeviceInfo *>*deviceNeedAdd=[NSMutableSet set];
    //找出重复的设备
    [sceneDevice enumerateObjectsUsingBlock:^(DeviceForScene * _Nonnull sceneDeviceObj, BOOL * _Nonnull stop) {
        __block BOOL isContain=NO;
        [roomDevice enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull roomDeviceObj, BOOL * _Nonnull stop) {
            if ([roomDeviceObj.deviceMacID isEqualToString:sceneDeviceObj.deviceMacID]) {
                isContain=YES;

                *stop=YES;
            }
        }];
        if (!isContain) {
                            [deviceNeedRemove addObject:sceneDeviceObj.deviceMacID];
        }
    }];
    
    [roomDevice enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull roomDeviceObj, BOOL * _Nonnull stop) {
        __block BOOL isContain=NO;
        [sceneDevice enumerateObjectsUsingBlock:^(DeviceForScene * _Nonnull sceneDeviceObj, BOOL * _Nonnull stop) {
            if ([roomDeviceObj.deviceMacID isEqualToString:sceneDeviceObj.deviceMacID]) {
                isContain=YES;
                *stop=YES;
            }
        }];
        if (!isContain) {
            [deviceNeedAdd addObject:roomDeviceObj];
        }
    }];
    
    //排查,去除重复的设备,添加新设备
    
    [allScene enumerateObjectsUsingBlock:^(SceneInfo *  _Nonnull sceneObj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSet <DeviceForScene *>*sceneDeviceBefore= sceneObj.devicesInfo;
        NSMutableSet *sceneDeviceAfter=[NSMutableSet setWithSet:sceneDeviceBefore];
        
        [sceneDeviceBefore enumerateObjectsUsingBlock:^(DeviceForScene * _Nonnull obj, BOOL * _Nonnull stop) {
            [deviceNeedRemove enumerateObjectsUsingBlock:^(NSString * _Nonnull deviceIDStr, BOOL * _Nonnull stop) {
                if ([obj.deviceMacID isEqualToString:deviceIDStr]) {
                    [sceneDeviceAfter removeObject:obj];
                }
            }];
        }];
        
        [deviceNeedAdd enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            DeviceForScene *newSceneDevice=(DeviceForScene *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"DeviceForScene"];
            newSceneDevice.deviceMacID=obj.deviceMacID;
            newSceneDevice.deviceCustomName=obj.deviceCustomName;
            newSceneDevice.deviceType=@(obj.deviceType.integerValue);
            newSceneDevice.deviceSceneStatus=@"0";
            [[TTSCoreDataManager getInstance]insertDataWithObject:newSceneDevice];
            [sceneDeviceAfter addObject:newSceneDevice];
        }];
        
        sceneObj.devicesInfo=sceneDeviceAfter;
    }];
    
    [[TTSCoreDataManager getInstance]updateData];
    
}


-(IBAction)unwindToMainList:(UIStoryboardSegue *)sender
{
    if ([sender.sourceViewController isKindOfClass:[AddDevicesController class]]) {
    }
}

@end
