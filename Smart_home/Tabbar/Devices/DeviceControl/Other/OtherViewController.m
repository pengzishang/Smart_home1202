//
//  OtherViewController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/19.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "OtherViewController.h"
#import "DoorBellController.h"
#import "AppDelegate.h"
#import "TTSUtility.h"

@interface OtherViewController () <JFGSDKCallbackDelegate>
@property(nonatomic, strong) NSArray *deviceList;
@property(nonatomic, assign) BOOL isLogin;
@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    if (!app.autoScan.valid) {
//        app.autoScan = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(autoScan:) userInfo:nil repeats:YES];
//        [app.autoScan fire];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    if (app.autoScan.valid) {
//        [app.autoScan invalidate];
//    }
}


//- (void)autoScan:(id)sender {
//    NSLogMethodArgs(@"autoScan");
//    [[BluetoothManager getInstance] scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
//}

#pragma mark- JFGSDK Delegate


//-(void)jfgDeviceList:(NSArray<JFGSDKDevice *> *)deviceList
//{
////    _deviceList = [[NSArray alloc]initWithArray:deviceList];
//
//    //登陆成功，跳转设备列表页面
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cellImage = @[@"equipment_ring_icon", @"equipment_remote_icon", @"equipment_autodoor_icon", @"equipment_bathtub_icon", @"equipment_ring_icon", @"equipment_center_icon", @"equipment_light_icon", @"equipment_magnetic_door_icon_pressed", @"equipment_sos_icon"];
    NSArray *cellTitle = @[@"智能门铃", @"遥控器配对", @"自动门", @"浴缸", @"门口指示板", @"中央空调", @"智能调光", @"门磁", @"呼救器"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell" forIndexPath:indexPath];
    if (indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.contentView.alpha = 0.3f;
    }
    UIImageView *iconImage = [cell viewWithTag:1001];
    UILabel *iconLab = [cell viewWithTag:2001];
    iconImage.image = [UIImage imageNamed:cellImage[indexPath.row]];
    iconLab.text = cellTitle[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"other2bath" sender:nil];
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"other2remote" sender:nil];
    } else if (indexPath.row == 4) {
        [self performSegueWithIdentifier:@"other2door" sender:nil];

    } else if (indexPath.row == 5) {
        [self performSegueWithIdentifier:@"other2center" sender:nil];
    } else if (indexPath.row == 0) {
        AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        _isLogin = app.isJFGLogin;
        if (_isLogin) {
            [self performSegueWithIdentifier:@"other2chat1" sender:_deviceList];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"本功能需要登录,点击确定登录" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [self performSegueWithIdentifier:@"other2login" sender:nil];
            }];
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSArray *)sender {
    if ([segue.identifier isEqualToString:@"other2chat1"]) {
//        DoorBellController *target=segue.destinationViewController;
//        target.deviceList=sender;
//        [TTSUtility stopAnimationWithMainTitle:@"刷新成功" subTitle:@""];
    }

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
