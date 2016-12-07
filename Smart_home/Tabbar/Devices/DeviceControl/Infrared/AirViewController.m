//
//  AirViewController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/19.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "AirViewController.h"
#import "TTSUtility.h"
#import "NSString+StringOperation.h"
@interface AirViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *nav_top;
@property (weak, nonatomic) IBOutlet UILabel *infraredID;
@property (weak, nonatomic) IBOutlet UILabel *tempertureLab;
@property (weak, nonatomic) IBOutlet UILabel *modeLab;
@property (weak, nonatomic) IBOutlet UILabel *speedLab;
@property (weak, nonatomic) IBOutlet UILabel *shaofenLab;
@end

@implementation AirViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[_nav_top subviews][0] setAlpha:0];
    _infraredID.text=[NSString stringWithFormat:@"红外伴侣:%@",self.deviceInfo.deviceInfraredID];
    [self setUIWithStatusString:self.deviceInfo.deviceStatus.stringValue needSync:NO];
    // Do any additional setup after loading the view.
}

-(IBAction)pressBtn:(UIButton *)sender
{
    NSString *btnString=[@(sender.tag-100).stringValue fullWithLengthCount:3];
    if (btnString.length==0) {
        return;
    }
    NSString *commandString=[[_deviceInfo.deviceInfaredCode stringByAppendingString:btnString]fullWithLengthCountBehide:27];
    [TTSUtility localDeviceControl:_deviceInfo.deviceInfraredID commandStr:commandString retryTimes:0 conditionReturn:^(id stateData) {
        if ([stateData isKindOfClass:[NSData class]])
        {
            NSString *statusString=[NSString stringWithFormat:@"%@",stateData];
            statusString=[statusString stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLogMethodArgs(@"%@",[NSString stringWithFormat:@"%@",stateData]);
            if ([[statusString substringWithRange:NSMakeRange(1, 2)] isEqualToString:@"aa"]){
                statusString=[statusString substringWithRange:NSMakeRange(5, 8)];
                [self setUIWithStatusString:statusString needSync:YES];
            }
        }
        
    }];
}

-(void)setUIWithStatusString:(NSString *)statusString needSync:(BOOL)isNeed
{
    if (statusString.length==8||statusString.length==7) {
        if (statusString.length==7) {
            statusString=[@"0" stringByAppendingString:statusString];
        }
        NSUInteger mode=[statusString substringWithRange:NSMakeRange(0, 2)].integerValue;
        NSDictionary *temertureDic=@{@"10":@"16",@"11":@"17",@"12":@"18",@"13":@"19",@"14":@"20",@"15":@"21",@"16":@"22",@"17":@"23",@"18":@"24",@"19":@"25",@"1a":@"26",@"1b":@"27",@"1c":@"28",@"1d":@"29",@"1e":@"30"};
        NSUInteger temperature=[statusString substringWithRange:NSMakeRange(2, 2)].integerValue;
        if (isNeed) {
            temperature=[temertureDic[[statusString substringWithRange:NSMakeRange(2, 2)]] integerValue];
        }
        NSUInteger direction=[statusString substringWithRange:NSMakeRange(4, 2)].integerValue;
        NSUInteger speed=[statusString substringWithRange:NSMakeRange(6, 2)].integerValue;
        
        
        NSArray *modeText=@[@"自动",@"制冷",@"加湿",@"送风",@"制暖",@"未知"];
        if (mode>4) {
            mode=5;
        }
        _modeLab.text=modeText[mode];
        _tempertureLab.text=[NSString stringWithFormat:@"%zd°c",temperature];
        NSArray *directionText=@[@"静止风",@"扫风1",@"扫风2",@"扫风3",@"扫风4",@"扫风5",@"未知"];
        if (direction>5) {
            direction=6;
        }
        _shaofenLab.text=directionText[direction];
        NSArray *speedText=@[@"自动",@"风速1",@"风速2",@"风速3",@"未知"];
        if (speed>4) {
            speed=5;
        }
        _speedLab.text=speedText[speed];
        if (isNeed) {
            NSString *tempString=@"";
            for (NSUInteger i=0; i<8; i+=2) {
                if (temertureDic[[statusString substringWithRange:NSMakeRange(i, 2)]]||[statusString substringWithRange:NSMakeRange(i, 2)])
                {
                    tempString=[tempString stringByAppendingString:i==2?
                                temertureDic[[statusString substringWithRange:NSMakeRange(i, 2)]]:
                                [statusString substringWithRange:NSMakeRange(i, 2)]];
                }
            }
            self.deviceInfo.deviceStatus=@(tempString.integerValue);
            [[TTSCoreDataManager getInstance]updateData];
        }
        
        //            0xAA, 开关状态， 模式， 温度， 风向， 风量， 0x00，0x00，0x00， 校验。
        //           <  aa     01      01    17    00   03    00     00   00    14 >
    }
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
