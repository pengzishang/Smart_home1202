//
//  RemoteController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/5.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "RemoteController.h"
#import "RemoteManger.h"
#import "BluetoothManager.h"
#import "TTSCoreDataManager.h"
#import "FTPopOverMenu.h"
#import "TTSUtility.h"
@interface RemoteController ()<UITableViewDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UILabel *currentRemoteController;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;


@property (strong,nonatomic)NSMutableArray <__kindof NSDictionary *> *nearRemoteController;
@property (assign,nonatomic)NSUInteger indexIdx;
@property (assign,nonatomic)NSUInteger selectIdx;
@property (strong,nonatomic)NSMutableArray <NSMutableDictionary *>*remoteList;

@end

@implementation RemoteController

-(NSMutableArray<NSMutableDictionary *> *)remoteList
{
    if (!_remoteList) {
        _remoteList=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"remoteList"]];
    }
    return _remoteList;
}

-(NSMutableArray *)nearRemoteController
{
    if (!_nearRemoteController) {
        _nearRemoteController=[NSMutableArray array];
    }
    return _nearRemoteController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _indexIdx=0;
    _selectIdx=0;
    if (self.roomInfo) {
        _currentRemoteController.text=[NSString stringWithFormat:@"当前远程控制器:%@",self.roomInfo.roomRemoteID];
    }
    else{
        if (RemoteDefault) {
            _currentRemoteController.text=[NSString stringWithFormat:@"当前远程控制器:%@",RemoteDefault];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"RemoteOn"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"RemoteOn"];
        }
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    _mainTableView.tableFooterView=[[UIView alloc]init];
    [self performSelector:@selector(refreshControl:) withObject:nil afterDelay:1.0];
}

//点击右侧
- (IBAction)refreshControl:(UIBarButtonItem *)sender {
    [[BluetoothManager getInstance]scanPeriherals:YES AllowPrefix:@[@(ScanTypeWIFIControl)]];
    [BluetoothManager getInstance].detectDevice=^(NSDictionary *infoDic){
        [self addRemote:infoDic];
    };
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (!_navItem.rightBarButtonItem) {
        UIBarButtonItem *chooseSevice=[[UIBarButtonItem alloc]initWithTitle:@"服务器" style:UIBarButtonItemStylePlain target:self action:@selector(addChange:event:)];
        _navItem.rightBarButtonItem=chooseSevice;
    }
}

- (IBAction)addChange:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    [FTPopOverMenuConfiguration defaultConfiguration].menuWidth=150;
    NSArray *seviceList=@[@"183.63.52.158",@"120.24.73.175",@"120.76.74.87",@"120.24.223.86"];
    [FTPopOverMenu showFromEvent:event withMenu:seviceList imageNameArray:@[@"setting_switch",@"setting_switch",@"setting_switch"] doneBlock:^(NSInteger selectedIndex) {
        [[NSUserDefaults standardUserDefaults]setObject:seviceList[selectedIndex] forKey:@"SeviceHost"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } dismissBlock:^{
        
    }];
}


-(void)addRemote:(NSDictionary *)infoDic
{
    NSString *deviceName = infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
    NSLogMethodArgs(@"%@",deviceName);
    if (![self isContainID:deviceName inArr:_nearRemoteController]) {
        [_nearRemoteController addObject:infoDic];
        if (![self isContainID:deviceName inArr:self.remoteList]) {
            NSMutableDictionary *targetDevice=[NSMutableDictionary dictionaryWithCapacity:3];
            targetDevice[@"remoteName"]=deviceName;
            targetDevice[@"remoteFullID"]=deviceName;
            if (![self.remoteList containsObject:targetDevice]) {
                [self.remoteList addObject:targetDevice];
                [[NSUserDefaults standardUserDefaults]setObject:self.remoteList forKey:@"remoteList"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }

        }
        [_mainTableView reloadData];
    }
    else
    {
        static NSUInteger times=0;
        if (++times==20) {
            [_nearRemoteController replaceObjectAtIndex:_indexIdx withObject:infoDic];
            [_mainTableView reloadData];
            times=0;
        }
    }
}

-(BOOL)isContainID:(NSString *)deviceName inArr:(NSArray *)arr
{
    __block BOOL isContain=NO;
    [arr enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull storeInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *storeID=storeInfo[AdvertisementData][@"kCBAdvDataLocalName"];
        if ([storeID isEqualToString:deviceName]) {
            isContain=YES;
            _indexIdx=idx;
            *stop=YES;
        }
    }];
    return isContain;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"可选的远程控制器";
    }
    else
    {
        return @"可设置的控制器";
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return self.nearRemoteController.count;
    }
    else
    {
        return self.remoteList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"remoteCell" forIndexPath:indexPath];
    UILabel *deviceIDLab=[cell viewWithTag:1001];
    UILabel *rssiLab=[cell viewWithTag:1002];
    UIImageView *imageView=[cell viewWithTag:1000];
    if (indexPath.section==0) {
        NSDictionary *infoDic=_nearRemoteController[indexPath.row];
        imageView.image=[UIImage imageNamed:(indexPath.row==_selectIdx)?@"pressed_select_btn":@"default_unselect_btn"];
        deviceIDLab.text=infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        rssiLab.text=[NSString stringWithFormat:@"信号强度:%@",infoDic[RSSI_VALUE]];
    }
    else if(indexPath.section==1){
        NSDictionary *infoDic=_remoteList[indexPath.row];
        deviceIDLab.text=infoDic[@"remoteName"];
        imageView.image=[UIImage imageNamed:(indexPath.row==_selectIdx)?@"pressed_select_btn":@"default_unselect_btn"];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectIdx=indexPath.row;
    NSString *remoteID=nil;
    NSString *remoteIDNumber=nil;
    if (indexPath.section==0) {
        remoteID=[_nearRemoteController[indexPath.row][AdvertisementData][@"kCBAdvDataLocalName"] substringFromIndex:5];
    }
    else if (indexPath.section==1){
        remoteID=[_remoteList[indexPath.row][@"remoteName"] substringFromIndex:5];
    }
    remoteID=[remoteID stringByReplacingOccurrencesOfString:@" " withString:@""];
    remoteIDNumber=[NSString translateRemoteID:remoteID];
    if (self.roomInfo) {
        self.roomInfo.roomRemoteID=remoteID;
        [[TTSCoreDataManager getInstance]updateData];
        _currentRemoteController.text=[NSString stringWithFormat:@"目前房间的远程控制器为:%@",self.roomInfo.roomRemoteID];
    }
    else{
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"RemoteOn"];
        [[NSUserDefaults standardUserDefaults]setObject:remoteID forKey:@"RemoteControlID"];
        [[NSUserDefaults standardUserDefaults]setObject:remoteIDNumber forKey:@"RemoteIDNumber"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        _currentRemoteController.text=[NSString stringWithFormat:@"目前的默认远程控制器为:%@",remoteID];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}


- (IBAction)didClickDone:(id)sender {
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    //多个远程同步
    NSMutableArray *devicesID=[NSMutableArray array];
    if (self.roomInfo) {
        [self.roomInfo.deviceInfo enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            [devicesID addObject:obj];
        }];
        
        [TTSUtility mutiRemoteSave:devicesID remoteMacID:self.roomInfo.roomRemoteID];
    }
    else
    {
        NSArray *devices=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"DeviceInfo" predicate:nil];
        [devices enumerateObjectsUsingBlock:^(DeviceInfo *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.deviceMacID) {
                [devicesID addObject:obj];
            }
        }];
        [TTSUtility mutiRemoteSave:devicesID remoteMacID:RemoteDefault];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
