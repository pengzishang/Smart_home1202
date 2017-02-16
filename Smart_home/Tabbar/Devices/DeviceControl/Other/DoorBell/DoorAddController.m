//
//  DoorAddController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorAddController.h"

@interface DoorAddController ()

@property(weak, nonatomic) IBOutlet UIImageView *mainImage;

@end

@implementation DoorAddController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *imgSet = @[[UIImage imageNamed:@"device_door_add"], [UIImage imageNamed:@"device_door_add_down"]];

    [self.mainImage setAnimationImages:imgSet];
    [self.mainImage setAnimationRepeatCount:0];
    [self.mainImage setAnimationDuration:2 * 0.74];

    [self.mainImage startAnimating];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
