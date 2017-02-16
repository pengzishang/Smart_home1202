//
//  SetBellWifiController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/11/8.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "SetBellWifiController.h"
#import "TTSUtility.h"

@interface SetBellWifiController () <JFGSDKCallbackDelegate> {
    NSTimer *timer;
}
@property(weak, nonatomic) IBOutlet UITextField *wifiField;
@property(weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation SetBellWifiController

- (void)viewDidLoad {
    [super viewDidLoad];
    _wifiField.placeholder = _ssid;
    [JFGSDK addDelegate:self];
    self.tableView.tableFooterView = [[UIView alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)saveWifi:(UIBarButtonItem *)sender {
    [TTSUtility startAnimationWithMainTitle:@"读取数据中" subTitle:@""];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [timer fire];

}

- (void)timerFired:(id)sender {
    [JFGSDK fping:@"255.255.255.255"];
}

- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask {
    [timer invalidate];
    [TTSUtility stopAnimationWithMainTitle:@"保存完成" subTitle:@""];
    NSLog(@"mac:%@  ver:%@ address:%@ cid:%@", ask.mac, ask.ver, ask.address, ask.cid);
    [JFGSDK wifiSetWithSSid:_wifiField.text keyword:_pwdField.text cid:ask.cid ipAddr:ask.address mac:ask.mac];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 0;
//}
//
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
