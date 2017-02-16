//
//  ConfirmCodeController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/8.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "ConfirmCodeController.h"
#import "DeviceInfraredController.h"
#import "NSString+StringOperation.h"
#import "TTSUtility.h"

@interface ConfirmCodeController ()

@property(assign, nonatomic) NSInteger codeIndex;
@property(strong, nonatomic) NSMutableArray *codeList;
@property(weak, nonatomic) IBOutlet UILabel *codeLab;
@property(weak, nonatomic) IBOutlet UINavigationItem *brandName;
@property(strong, nonatomic) NSString *brandTitle;

@end

@implementation ConfirmCodeController

- (NSMutableArray *)codeList {
    if (!_codeList) {
        NSArray *deviceTitle = @[@"AIR", @"TV", @"DVD", @"AMP", @"BOX"];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"InfraredBrandList" ofType:@"plist"];
        NSDictionary *dataDic = [[NSDictionary alloc] initWithContentsOfFile:path];
        _codeList = [NSMutableArray arrayWithArray:dataDic[deviceTitle[self.deviceType.integerValue]][self.deviceInfaredCode.integerValue][@"code"]];
        _brandTitle = [NSString stringWithFormat:@"%@", dataDic[deviceTitle[self.deviceType.integerValue]][self.deviceInfaredCode.integerValue][@"brand"]];
    }
    return _codeList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.infraredDeviceID = InfraredDefault;
    _codeIndex = 0;
    NSLogMethodArgs(@"%@", self.codeList[_codeIndex]);
    self.codeLab.text = [NSString stringWithFormat:@"%@:%@", _brandTitle, self.codeList[_codeIndex]];;
    NSArray *brandNameTitle = @[@"空调", @"电视", @"DVD", @"功放机", @"机顶盒"];
    _brandName.title = brandNameTitle[self.deviceType.integerValue];
}

- (IBAction)nextCode:(id)sender {
    _codeIndex++;
    if (_codeIndex == [self.codeList count]) {
        _codeIndex--;
    }
    self.codeLab.text = [NSString stringWithFormat:@"%@:%@", _brandTitle, self.codeList[_codeIndex]];
    NSLog(@"next");
}


- (IBAction)previousCode:(id)sender {
    if (_codeIndex > 0) {
        _codeIndex--;
    }
    self.codeLab.text = [NSString stringWithFormat:@"%@:%@", _brandTitle, self.codeList[_codeIndex]];
}
//空调
//                        品牌号(Brand)，码组号(Code)， 按键值(Key)
//                  EFH,    Brand,         Code,       Key,     00H,00H,00H,00H 00H,  校验值 ;  共10个字节
//其他
//                        起始标志                     码组号    按键值       备用字节         校验
//                        FEH,        0xH,(电视05 )   xxH,xxh    01H,   00H,00H,00H,00H,

- (IBAction)tryCode:(id)sender {
    NSString *fullCommand = [[self returnPrefixWithoutBtnTagWithTypeisTest:YES] fullWithLengthCountBehide:27];
    [TTSUtility localDeviceControl:self.infraredDeviceID commandStr:fullCommand retryTimes:0 conditionReturn:nil];
}

- (IBAction)ConfirmToMain:(UIButton *)sender {
    NSString *deviceName = [NSString stringWithFormat:@"%@%@", _brandName.title, self.codeLab.text];
    NSString *deviceType = @(self.deviceType.integerValue + 100).stringValue;
    NSString *deviceInfraredID = InfraredDefault;
    DeviceInfo *deviceInfo = (DeviceInfo *) [[TTSCoreDataManager getInstance] getNewManagedObjectWithEntiltyName:@"DeviceInfo"];
    deviceInfo.deviceCustomName = deviceName;
    deviceInfo.deviceInfaredCode = [self returnPrefixWithoutBtnTagWithTypeisTest:NO];
    deviceInfo.deviceType = deviceType;
    deviceInfo.deviceInfraredID = deviceInfraredID;
    deviceInfo.deviceCreateDate = [NSDate date];
    deviceInfo.deviceTapCount = @(0);
    deviceInfo.isCommonDevice = @(YES);
    [self performSegueWithIdentifier:@"infrared2InfraredMain" sender:deviceInfo];
}

- (NSString *)returnPrefixWithoutBtnTagWithTypeisTest:(BOOL)isTest//返回码组号
{
    NSString *codeStr = self.codeList[_codeIndex];//码组号
    NSString *preFixFull = [NSString new];
    if (self.deviceType.integerValue) {//除了空调以外
        NSString *HighBit = [NSString stringWithFormat:@"%zd", codeStr.integerValue / 256];//高位
        HighBit = [HighBit fullWithLengthCount:3];
        NSString *LowBit = [NSString stringWithFormat:@"%zd", codeStr.integerValue % 256];//将高位减去,剩下的低位
        LowBit = [LowBit fullWithLengthCount:3];
        NSString *deviceTypeCode = [@(self.deviceType.integerValue + 4).stringValue fullWithLengthCount:3];
        preFixFull = [NSString stringWithFormat:@"254%@%@%@", deviceTypeCode, HighBit, LowBit];
        return isTest ? [NSString stringWithFormat:@"%@002", preFixFull] : preFixFull;
    } else {

        preFixFull = [NSString stringWithFormat:@"239%@%@", [@(self.deviceInfaredCode.integerValue + 1).stringValue fullWithLengthCount:3], [codeStr fullWithLengthCount:3]];
        return isTest ? [NSString stringWithFormat:@"%@001", preFixFull] : preFixFull;
    }
    //默认是电源的命令
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(DeviceInfo *)sender {
    if ([segue.identifier isEqualToString:@"infrared2InfraredMain"]) {
        DeviceInfraredController *target = segue.destinationViewController;
        target.deviceForAdding = sender;
    }
}


@end
