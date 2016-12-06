//
//  CenterAirController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/22.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "CenterAirController.h"
#import "NSString+StringOperation.h"
#import "TTSUtility.h"
#import "FTPopOverMenu.h"
@interface CenterAirController ()

@property (weak, nonatomic) IBOutlet UILabel *infraredID;
@property (weak, nonatomic) IBOutlet UILabel *tempertureLab;
@property (weak, nonatomic) IBOutlet UILabel *modeLab;
@property (weak, nonatomic) IBOutlet UILabel *speedLab;
@property (weak, nonatomic) IBOutlet UILabel *shaofenLab;
@property (strong,nonatomic) DeviceInfo *deviceInfo;

@property(nonatomic,strong)NSString *currentDeviceID;
@property(nonatomic,strong)NSMutableArray *centerAirList;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBtnItem;

@end

@implementation CenterAirController

-(NSMutableArray *)centerAirList
{
    if (!_centerAirList) {
        _centerAirList=[NSMutableArray array];
    }
    return _centerAirList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self.navigationController.navigationBar subviews][0] setAlpha:0.0f];
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull deviceInfoDic, NSUInteger idx, BOOL * _Nonnull stop)
     {
         NSString *deviceBroadcastName= deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
         if ([deviceBroadcastName hasPrefix:@"Name17"]) {//
             if (![self.centerAirList containsObject:deviceBroadcastName]) {
                 [self.centerAirList addObject:deviceBroadcastName];
             }
             
             [_rightBtnItem setTitle:[NSString stringWithFormat:@"设备数:%@",@(self.centerAirList.count)]];
             if (self.centerAirList.count==1) {
                 self.currentDeviceID=[self.centerAirList[0] substringFromIndex:7];
                 _infraredID.text=self.centerAirList[0];
             }
         }
     }];
    [[BluetoothManager getInstance]addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self.navigationController.navigationBar subviews][0] setAlpha:1.0f];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"peripheralsInfo"]) {
        [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull deviceInfoDic, NSUInteger idx, BOOL * _Nonnull stop)
        {
            NSString *deviceBroadcastName= deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
            if ([deviceBroadcastName hasPrefix:@"Name17"]) {//浴缸
                if (![self.centerAirList containsObject:deviceBroadcastName]) {
                    [self.centerAirList addObject:deviceBroadcastName];
                }
                
                [_rightBtnItem setTitle:[NSString stringWithFormat:@"设备数:%@",@(self.centerAirList.count)]];
                if (self.centerAirList.count==1) {
                    self.currentDeviceID=[self.centerAirList[0] substringFromIndex:7];
                    _infraredID.text=self.centerAirList[0];
                }
            }
        }];
    }
}


- (IBAction)chooseDevice:(UIBarButtonItem *)sender event:(UIEvent *)event
{
        [[FTPopOverMenuConfiguration defaultConfiguration]setMenuWidth:200];
    [FTPopOverMenu showFromEvent:event withMenu:self.centerAirList imageNameArray:nil doneBlock:^(NSInteger selectedIndex)
     {
         self.currentDeviceID=[self.centerAirList[selectedIndex] substringFromIndex:7];
         _infraredID.text=self.centerAirList[selectedIndex];
     } dismissBlock:^{
         
     }];
}

-(IBAction)pressBtn:(UIButton *)sender
{
    NSString *btnString=[@(sender.tag-100).stringValue fullWithLengthCount:3];
    [TTSUtility localDeviceControl:_currentDeviceID commandStr:btnString retryTimes:0 conditionReturn:^(id stateData) {
        if ([stateData isKindOfClass:[NSData class]])
        {
//            NSString *statusString=[NSString stringWithFormat:@"%@",stateData];
//            statusString=[statusString stringByReplacingOccurrencesOfString:@" " withString:@""];
//            NSLogMethodArgs(@"%@",[NSString stringWithFormat:@"%@",stateData]);
//            if ([[statusString substringWithRange:NSMakeRange(1, 2)] isEqualToString:@"aa"]){
//                statusString=[statusString substringWithRange:NSMakeRange(5, 8)];
//                [self setUIWithStatusString:statusString];
//            }
        }
    }];
}

-(void)setUIWithStatusString:(NSString *)statusString
{
    if (statusString.length==8||statusString.length==7) {
        if (statusString.length==7) {
            statusString=[@"0" stringByAppendingString:statusString];
        }
        NSUInteger mode=[statusString substringWithRange:NSMakeRange(0, 2)].integerValue;
        NSDictionary *temertureDic=@{@"10":@"16",@"11":@"17",@"12":@"18",@"13":@"19",@"14":@"20",@"15":@"21",@"16":@"22",@"17":@"23",@"18":@"24",@"19":@"25",@"1a":@"26",@"1b":@"27",@"1c":@"28",@"1d":@"29",@"1e":@"30"};
        NSUInteger temperature=[statusString substringWithRange:NSMakeRange(2, 2)].integerValue;
        temperature=[temertureDic[[statusString substringWithRange:NSMakeRange(2, 2)]] integerValue];
        NSUInteger direction=[statusString substringWithRange:NSMakeRange(4, 2)].integerValue;
        NSUInteger speed=[statusString substringWithRange:NSMakeRange(6, 2)].integerValue;
        NSArray *modeText=@[@"自动",@"制冷",@"加湿",@"送风",@"制暖"];
        _modeLab.text=modeText[mode];
        _tempertureLab.text=[NSString stringWithFormat:@"%zd°c",temperature];
        NSArray *directionText=@[@"静止风",@"扫风1",@"扫风2",@"扫风3",@"扫风4",@"扫风5"];
        _shaofenLab.text=directionText[direction];
        NSArray *speedText=@[@"自动",@"风速1",@"风速2",@"风速3"];
        _speedLab.text=speedText[speed];
        
//        if (isNeed) {
//            NSString *tempString=@"";
//            for (NSUInteger i=0; i<8; i+=2) {
//                tempString=[tempString stringByAppendingString:i==2?
//                            temertureDic[[statusString substringWithRange:NSMakeRange(i, 2)]]:
//                            [statusString substringWithRange:NSMakeRange(i, 2)]];
//            }
//            self.deviceInfo.deviceStatus=@(tempString.integerValue);
//            [[TTSCoreDataManager getInstance]updateData];
//        }
        
        //            0xAA, 开关状态， 模式， 温度， 风向， 风量， 0x00，0x00，0x00， 校验。
        //           <  aa     01      01    17    00   03    00     00   00    14 >
    }
}


-(void)dealloc
{
    [[BluetoothManager getInstance]removeObserver:self forKeyPath:@"peripheralsInfo" context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
