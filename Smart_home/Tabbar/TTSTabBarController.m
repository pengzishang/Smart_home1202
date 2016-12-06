//
//  TTSTabBarController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/6/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "TTSTabBarController.h"

@interface TTSTabBarController ()

@end

@implementation TTSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor=[UIColor colorWithRed:49.0/255.0 green:202.0/255.0 blue:143.0/255.0 alpha:1.0];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
