//
//  LockSettingController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/23.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "LockSettingController.h"
#import "TTSUtility.h"

@interface LockSettingController ()
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *addImageBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitleItem;


@end

@implementation LockSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    _nameField.placeholder=self.deviceInfo.deviceCustomName;
    _navTitleItem.title=self.deviceInfo.deviceCustomName;
    // Do any additional setup after loading the view.
}
- (IBAction)addImage:(UIButton *)sender {
    [sender setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
}

- (IBAction)getPhoto:(UIButton *)sender {
    [sender setBackgroundImage:nil forState:UIControlStateNormal];
}
- (IBAction)confirmName:(UIButton *)sender {
    
    self.deviceInfo.deviceCustomName=_nameField.text;
    _navTitleItem.title=self.deviceInfo.deviceCustomName;
    [[TTSCoreDataManager getInstance]updateData];
    [_nameField resignFirstResponder];
    [_nameField endEditing:YES];
}

#pragma mark -editView



#pragma mark-collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *iconName=@[@"lock_funtion1",@"lock_funtion2",@"lock_funtion4",@"lock_funtion3",@"lock_funtion5",@"lock_funtion6",@"lock_funtion7",@"lock_funtion8",@"lock_funtion9"];
    NSArray *funtionTitle=@[@"增加密码",@"清除所有密码",@"同步时间",@"设置联动",@"设置电池低压报警",@"查询电量",@"查询开门记录",@"锁系统时间",@"锁软件版本查询"];
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"funtionCell" forIndexPath:indexPath];
    UIImageView *iconImage=[cell viewWithTag:1001];
    iconImage.image=[UIImage imageNamed:iconName[indexPath.row]];
    UILabel *iconTitle=[cell viewWithTag:1002];
    iconTitle.text=funtionTitle[indexPath.row];
    return cell;
}

//定义每个UICollectionView 的大小,空白的部分是可以重叠的
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger width=(Screen_Width-10-10-10-10)/3;
    NSUInteger high=width*0.8;
    return CGSizeMake(width, high);
}
//表边缘
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 10, 20, 10);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [self addPassword];
        }
            break;
        case 1:
        {
            [self cleanAllPassword];
        }
            break;
        case 2:
        {
            [TTSUtility lockWithDeviceInfo:self.deviceInfo lockMode:APPLockModeSync passWord:nil validtime:0];
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            [self lowPowerVal];
        }
            break;
        case 5:
        {
            [TTSUtility lockWithPowerLockInfo:self.deviceInfo lockMode:APPLockModePowerValue powerWarning:10];
        }
            break;
        case 6:
        {
            [TTSUtility lockWithQueryLogLockInfo:self.deviceInfo];
            break;
        }
            case 7:
            case 8:
        {
            [TTSUtility lockWithSystemInfo:self.deviceInfo codeReturn:^(NSData *data) {
                
            }];
            break;
        }
        default:
            break;
    }
}

-(void)addPassword
{
    NSString *lastTimePwd=[[NSUserDefaults standardUserDefaults]objectForKey:@"lastTimePwd"];
    NSString *lastTime=[[NSUserDefaults standardUserDefaults]objectForKey:@"lastTime"];
    UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"增加密码" message:@"输入一组密码" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *passWordField= alertView.textFields[0];
        UITextField *timeField=alertView.textFields[1];
        if (passWordField.text.length==6&&timeField.text.integerValue<8640000) {
            [[NSUserDefaults standardUserDefaults]setObject:lastTimePwd forKey:@"lastTimePwd"];
            [[NSUserDefaults standardUserDefaults]setObject:lastTime forKey:@"lastTime"];
            [TTSUtility lockWithDeviceInfo:self.deviceInfo lockMode:APPLockModeChange passWord:passWordField.text validtime:timeField.text.integerValue];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            UIAlertController *warningView=[UIAlertController alertControllerWithTitle:@"密码位数或者有效期错误" message:@"必须是位数为6位,有效期小于100天" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *haoba=[UIAlertAction actionWithTitle:@"好吧" style:UIAlertActionStyleDefault handler:nil];
            [warningView addAction:haoba];
            [self presentViewController:warningView animated:YES completion:nil];
        }
        
    }];
    
    UIAlertAction *cancle=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull passWordField) {
        passWordField.keyboardType=UIKeyboardTypeNumberPad;
        if (lastTimePwd.length==6) {
            passWordField.placeholder=lastTimePwd;
        }else{
        passWordField.placeholder=@"输入密码(6位)";
        }
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull timeField) {
        timeField.keyboardType=UIKeyboardTypeNumberPad;
        if (lastTime.length>0) {
            timeField.placeholder=lastTime;
        }
        else
        {
            timeField.placeholder=@"输入一个有效期(秒)";
        }
    }];
    
    [alertView addAction:ok];
    [alertView addAction:cancle];
    [self presentViewController:alertView animated:YES completion:nil];
}

-(void)cleanAllPassword
{
    UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"清除所有密码" message:@"真的要全部清除吗？清除后不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        //123456随机的
        [TTSUtility lockWithDeviceInfo:self.deviceInfo lockMode:APPLockModeCleanAll passWord:@"123456" validtime:10000];
    }];
    
    UIAlertAction *cancle=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:ok];
    [alertView addAction:cancle];
    [self presentViewController:alertView animated:YES completion:nil];
}

-(void)lowPowerVal
{
    UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"电量提醒" message:@"输入低电量提醒阈值" preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType=UIKeyboardTypeNumberPad;
        
    }];
    UIAlertAction *ok=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField= alertView.textFields.firstObject;
        [self dismissViewControllerAnimated:YES completion:nil];
        [TTSUtility lockWithPowerLockInfo:self.deviceInfo lockMode:APPLockModeLowPower powerWarning:textField.text.integerValue];
    }];
    
    UIAlertAction *cancle=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:ok];
    [alertView addAction:cancle];
    [self presentViewController:alertView animated:YES completion:nil];
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
