//
//  DoorBellStep2.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorBellStep2.h"
#import "DoorBellBinding.h"
#import <JFGSDK/JFGSDKBindingDevice.h>

@interface DoorBellStep2 ()<JFGSDKBindDeviceDelegate>

{
    JFGSDKBindingDevice *bindDevice;
}
@property (weak, nonatomic) IBOutlet UITextField *ssid;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *deviceName;

@end

@implementation DoorBellStep2

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_wifiSSID.length>=1) {
        _ssid.text=_wifiSSID;
    }
//    bindDevice.delegate = self;
//    [bindDevice scanWifi];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextStep:(UIBarButtonItem *)sender {
    if (_ssid.text.length>0) {
        [self performSegueWithIdentifier:@"doorBinding" sender:nil];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:@"WiFi名称不能为空" preferredStyle: UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


-(void)jfgBindDeviceProgressStatus:(JFGSDKBindindProgressStatus)status
{
    if (status == JFGSDKBindindProgressStatusSuccess) {
        NSLog(@"bind-Result:success");
    }
    else{
        NSLog(@"%zd",status);
    }
}

//绑定失败
-(void)jfgBindDeviceFailed:(JFGSDKBindindProgressStatus)errorType;
{
    NSLog(@"bind-Result:fail:%zd",errorType);
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"doorBinding"]) {
        DoorBellBinding *target=segue.destinationViewController;
        target.wifiPWD=_password.text;
        target.wifiSSID=_ssid.text;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
