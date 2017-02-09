//
//  DoorLabViewController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/21.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorLabViewController.h"
#import "FTPopOverMenu.h"
#import "BluetoothManager.h"
#import "TTSUtility.h"

@interface DoorLabViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBtnItem;
@property(nonatomic,strong)NSMutableArray *doorList;
@property(nonatomic,strong)DeviceInfo *currentDevice;
@property(nonatomic,strong)NSString *currentDeviceID;
@property (weak, nonatomic) IBOutlet UILabel *macIDLab;



@end

@implementation DoorLabViewController

-(NSMutableArray *)doorList
{
    if (!_doorList) {
        _doorList=[NSMutableArray array];
    }
    return _doorList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self.navigationController.navigationBar subviews][0] setAlpha:0.0f];
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull deviceInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *deviceBroadcastName= deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        if ([deviceBroadcastName hasPrefix:@"Name20"]) {//门口开关
            if (![self.doorList containsObject:deviceBroadcastName]) {
                [self.doorList addObject:deviceBroadcastName];
            }
            [_rightBtnItem setTitle:[NSString stringWithFormat:@"设备数:%@",@(self.doorList.count)]];
            if (self.doorList.count==1) {
                self.currentDeviceID=[self.doorList[0] substringFromIndex:7];
                _macIDLab.text=self.doorList[0];
            }
        }
        
    }];
    [[BluetoothManager getInstance]addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self.navigationController.navigationBar subviews][0] setAlpha:1.0f];
}

/**
 观察浴缸设备
 
 @param keyPath <#keyPath description#>
 @param object  <#object description#>
 @param change  <#change description#>
 @param context <#context description#>
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"peripheralsInfo"]) {
//        [self.doorList removeAllObjects];
        [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull deviceInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *deviceBroadcastName= deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
            if ([deviceBroadcastName hasPrefix:@"Name20"]) {//门口开关
                if (![self.doorList containsObject:deviceBroadcastName]) {
                    [self.doorList addObject:deviceBroadcastName];
                }
                [_rightBtnItem setTitle:[NSString stringWithFormat:@"设备数:%@",@(self.doorList.count)]];
                if (self.doorList.count==1) {
                    self.currentDeviceID=[self.doorList[0] substringFromIndex:7];
                    _macIDLab.text=self.doorList[0];
                }
            }
            
        }];
    }
}


- (IBAction)chooseDevice:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    if (self.doorList.count==0) {
        return;
    }
    [[FTPopOverMenuConfiguration defaultConfiguration]setMenuWidth:200];
    [FTPopOverMenu showFromEvent:event withMenu:self.doorList imageNameArray:nil doneBlock:^(NSInteger selectedIndex)
     {
         self.currentDeviceID=[self.doorList[selectedIndex] substringFromIndex:7];
         _macIDLab.text=self.doorList[selectedIndex];
     } dismissBlock:^{
     }];
}


- (IBAction)didClickBtn:(UIButton *)sender {
    NSNumber *command=@(sender.tag);
    [TTSUtility localDeviceControl:self.currentDeviceID commandStr:command.stringValue retryTimes:3 conditionReturn:^(id stateData) {
    }];
}


-(void)dealloc
{
    [[BluetoothManager getInstance]removeObserver:self forKeyPath:@"peripheralsInfo" context:nil];
}


@end
