//
//  LoginController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/13.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "LoginController.h"
#import "TTSUtility.h"
#import <JFGSDK/JFGSDK.h>
#import "AppDelegate.h"

@interface LoginController ()<JFGSDKCallbackDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *pwd;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userName.text=USERNAME;
    _pwd.text=USERPASS;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"jfgworkdic"];
    //SDK初始化
    [JFGSDK connectForWorkDir:path];
    
    //SDK回调设置
    [JFGSDK addDelegate:self];
    
    //打开SDK操作日志
    [JFGSDK logEnable:NO];
    // Do any additional setup after loading the view.
}
- (IBAction)loginIn:(UIButton *)sender {
    if (_userName.text.length==0||_pwd.text.length==0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:@"用户名和密码不能为空" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [TTSUtility startAnimationWithMainTitle:@"登录中...." subTitle:@""];
        [JFGSDK userLogin:_userName.text keyword:_pwd.text vid:VID vkey:VKEY];
    }
    
}
- (IBAction)cancle:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- JFGSDK Delegate

-(void)jfgLoginResult:(JFGErrorType)errorType
{
    
    if (errorType == JFGErrorTypeNone) {
        [TTSUtility stopAnimationWithMainTitle:@"登录成功" subTitle:@""];
        [[NSUserDefaults standardUserDefaults]setObject:_userName.text forKey:@"JFGUSER"];
        [[NSUserDefaults standardUserDefaults]setObject:_pwd.text forKey:@"JFGPWD"];
        AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        app.isJFGLogin=YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [TTSUtility stopAnimationWithMainTitle:@"登录失败" subTitle:@""];
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
