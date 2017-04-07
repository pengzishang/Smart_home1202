//
//  RemoteSetting.m
//  Smart_home
//
//  Created by 彭子上 on 2017/2/13.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "RemoteSetting.h"
#import "BluetoothManager.h"
#import "TTSUtility.h"
//#import "HiJoine.framework/Headers/HiJoine.h"

@interface RemoteSetting () <UITableViewDelegate> {
//    HiJoine *joine;
}
@property(weak, nonatomic) IBOutlet UIButton *startBtn;
@property(weak, nonatomic) IBOutlet UIView *buttomMain;
@property(weak, nonatomic) IBOutlet UITableView *selectTable;
@property(weak, nonatomic) IBOutlet UIView *settingView;
@property(weak, nonatomic) IBOutlet UILabel *ssidLab;
@property(weak, nonatomic) IBOutlet UITextField *pwdLab;
@property(weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property(weak, nonatomic) IBOutlet UILabel *returnLab;

@property(strong, nonatomic) NSMutableArray *remoteList;

@end

@implementation RemoteSetting

- (NSMutableArray *)remoteList {
    if (!_remoteList) {
        _remoteList = [NSMutableArray array];
    }
    return _remoteList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    joine = [[HiJoine alloc] init];
    _startBtn.enabled = NO;
//    NSDictionary *ssidInfo = [joine fetchSSIDInfo];
//    _ssidLab.text = ssidInfo[@"SSID"];
    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeWIFIControl)]];
    [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary *_Nonnull deviceInfoDic, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *deviceBroadcastName = deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
        if ([deviceBroadcastName containsString:@"WIFI"]) {
            if (![self.remoteList containsObject:deviceBroadcastName]) {
                [self.remoteList addObject:deviceBroadcastName];
            }
        }
    }];
    [[BluetoothManager getInstance] addObserver:self forKeyPath:@"peripheralsInfo" options:NSKeyValueObservingOptionOld context:nil];
    // Do any additional setup after loading the view.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"peripheralsInfo"]) {
        [[BluetoothManager getInstance].peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary *_Nonnull deviceInfoDic, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *deviceBroadcastName = deviceInfoDic[AdvertisementData][@"kCBAdvDataLocalName"];
            if ([deviceBroadcastName containsString:@"WIFI"]) {
                if (![self.remoteList containsObject:deviceBroadcastName]) {
                    [self.remoteList addObject:deviceBroadcastName];
                }
            }
        }];
    }
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)clickStart:(UIButton *)sender {
    NSString *opertionID = [self.remoteList[0] substringFromIndex:5];
    opertionID = [opertionID stringByReplacingOccurrencesOfString:@" " withString:@""];
    [TTSUtility localDeviceControl:opertionID commandStr:@"01" retryTimes:3 conditionReturn:^(id stateData) {
        self.selectTable.hidden = YES;
        self.settingView.hidden = NO;
    }];

}

- (IBAction)settingWifi:(UIButton *)sender {
//    __weak RemoteSetting *weakself = self;
//    [joine setBoardDataWithPassword:_pwdLab.text withBackBlock:^(NSInteger result, NSString *message) {
//        NSLog(@"message = %@", message);
//        weakself.returnLab.text = [NSString stringWithFormat:@"返回结果:%@", message];
//    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.remoteList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"remoteID" forIndexPath:indexPath];
    UILabel *remoteID = [cell viewWithTag:1000];
    remoteID.text = self.remoteList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _startBtn.enabled = YES;
    [_startBtn setTitle:[NSString stringWithFormat:@"打开%@的WIFI设置开关", self.remoteList[indexPath.row]] forState:UIControlStateNormal];
    [_startBtn setBackgroundColor:[UIColor whiteColor]];

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
