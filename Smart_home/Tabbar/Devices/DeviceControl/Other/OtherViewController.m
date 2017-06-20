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
//@property(nonatomic, strong) NSArray *deviceList;
@property(nonatomic, assign) BOOL isLogin;
@property(nonatomic, copy)NSString *userName;
@property(nonatomic, copy)NSString *pwd;
@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:@"jfgworkdic"];
//    SDK初始化
        [JFGSDK connectForWorkDir:path];
    
//    SDK回调设置
        [JFGSDK addDelegate:self];
    
//    打开SDK操作日志
        [JFGSDK logEnable:NO];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- JFGSDK Delegate


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
        //        [JFGSDK userLogin:_userName.text keyword:_pwd.text vid:VID vkey:VKEY];
        
        AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        _isLogin = app.isJFGLogin;
        if (_isLogin) {
            [self performSegueWithIdentifier:@"other2chat1" sender:nil];
        } else {
            NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"JFGUSER"];
            NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"JFGPWD"];
            if (!userName || !pwd) {
                _userName = USERNAME;
                _pwd = USERPASS;
            } else {
                _userName = userName;
                _pwd = pwd;
            }
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"本功能需要登录" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = _userName;
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.secureTextEntry = YES;
                textField.text = _pwd;
            }];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [JFGSDK userLogin:_userName keyword:_pwd vid:VID vkey:VKEY];
                [TTSUtility startAnimationWithMainTitle:@"登录中..." subTitle:@""];
//                [self dismissViewControllerAnimated:YES completion:^{
//
//                }];
                
//                if ([alertController.textFields[0].text isEqualToString:@"admin"]&&[alertController.textFields[1].text isEqualToString:@"admin"]) {
//
//                    [self performSegueWithIdentifier:@"other2login" sender:nil];
//                } else {
//                    return;
//                }
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
//                [self performSegueWithIdentifier:@"other2login" sender:nil];
//            }];
//            [alertController addAction:okAction];
//            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)jfgLoginResult:(JFGErrorType)errorType {
    
    if (errorType == JFGErrorTypeNone) {
        [TTSUtility stopAnimationWithMainTitle:@"登录成功" subTitle:@""];
        [[NSUserDefaults standardUserDefaults] setObject:_userName forKey:@"JFGUSER"];
        [[NSUserDefaults standardUserDefaults] setObject:_pwd forKey:@"JFGPWD"];
        AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        app.isJFGLogin = YES;
        [self performSegueWithIdentifier:@"other2chat1" sender:nil];
//        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [TTSUtility stopAnimationWithMainTitle:@"登录失败" subTitle:@""];
    }
}


-(void)jfgDeviceList:(NSArray<JFGSDKDevice *> *)deviceList
{
//    _deviceList = [[NSArray alloc]initWithArray:deviceList];
    
    //登陆成功，跳转设备列表页面
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
