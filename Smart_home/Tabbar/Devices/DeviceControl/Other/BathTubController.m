//
//  BathTubController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/19.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "BathTubController.h"
#import "FTPopOverMenu.h"
#import "BluetoothManager.h"
#import "TTSUtility.h"
@interface BathTubController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBtnItem;
@property(nonatomic,strong)NSMutableArray *bathTubList;
@property(nonatomic,strong)DeviceInfo *currentDevice;
@property(nonatomic,strong)NSString *currentDeviceID;
@property (weak, nonatomic) IBOutlet UILabel *macIDLab;
@end

@implementation BathTubController

-(NSMutableArray *)bathTubList
{
    if (!_bathTubList) {
        _bathTubList=[NSMutableArray array];
    }
    return _bathTubList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self.navigationController.navigationBar subviews][0] setAlpha:0.0f];
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull deviceInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *deviceBroadcastName= deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        if ([deviceBroadcastName hasPrefix:@"Name14"]) {//浴缸
            if (![self.bathTubList containsObject:deviceBroadcastName]) {
                [self.bathTubList addObject:deviceBroadcastName];
            }
            [_rightBtnItem setTitle:[NSString stringWithFormat:@"设备数:%@",@(self.bathTubList.count)]];
            if (self.bathTubList.count==1) {
                self.currentDeviceID=[self.bathTubList[0] substringFromIndex:7];
                _macIDLab.text=self.bathTubList[0];
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

        [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull deviceInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *deviceBroadcastName= deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
            if ([deviceBroadcastName hasPrefix:@"Name14"]) {//浴缸
                if (![self.bathTubList containsObject:deviceBroadcastName]) {
                    [self.bathTubList addObject:deviceBroadcastName];
                }
                [_rightBtnItem setTitle:[NSString stringWithFormat:@"设备数:%@",@(self.bathTubList.count)]];
                if (self.bathTubList.count==1) {
                    self.currentDeviceID=[self.bathTubList[0] substringFromIndex:7];
                    _macIDLab.text=self.bathTubList[0];
                }
            }

        }];
    }
}

- (IBAction)chooseDevice:(UIBarButtonItem *)sender event:(UIEvent *)event
{
        [[FTPopOverMenuConfiguration defaultConfiguration]setMenuWidth:200];
    [FTPopOverMenu showFromEvent:event withMenu:self.bathTubList imageNameArray:nil doneBlock:^(NSInteger selectedIndex)
     {
         self.currentDeviceID=[self.bathTubList[selectedIndex] substringFromIndex:7];
         _macIDLab.text=self.bathTubList[selectedIndex];
     } dismissBlock:^{
     }];
}


- (IBAction)didClickBtn:(UIButton *)sender {
    NSNumber *command=@(sender.tag);
    [TTSUtility localDeviceControl:self.currentDeviceID commandStr:command.stringValue retryTimes:3 conditionReturn:^(id stateData) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[BluetoothManager getInstance]removeObserver:self forKeyPath:@"peripheralsInfo" context:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
