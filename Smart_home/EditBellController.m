//
//  EditBellController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/31.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "EditBellController.h"
#import "DoorBellController.h"
#import "TTSUtility.h"
#import "SetBellWifiController.h"
@interface EditBellController ()<UITextFieldDelegate,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *namePad;
@property (weak, nonatomic) IBOutlet UILabel *ssidLab;

@end

@implementation EditBellController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.namePad.delegate=self;
    self.namePad.text=self.device.alias;
    
    
    [TTSUtility getVideoWifiInfoWithCid:self.device.uuid success:^(NSString *wifiSSID) {
        _ssidLab.text=[NSString stringWithFormat:@"当前:%@",wifiSSID];
    } failure:^(NSInteger type) {
        
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    if (indexPath.section==0&&indexPath.row==3) {
        [self performSegueWithIdentifier:@"door2Wifi" sender:self.device];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 3;
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
    if ([segue.identifier isEqualToString:@"editbell2mainBell"]) {
        DoorBellController *target=segue.destinationViewController;
        target.editName=self.namePad.text;
        target.editDevice=self.device;
    }
    else if ([segue.identifier isEqualToString:@"door2Wifi"])
    {
        SetBellWifiController *target=segue.destinationViewController;
        target.device=self.device;
        target.ssid=_ssidLab.text;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
