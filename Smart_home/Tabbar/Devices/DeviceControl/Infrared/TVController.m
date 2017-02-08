//
//  TVController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/22.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "TVController.h"
#import "TTSUtility.h"

@interface TVController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navTop;

@property (weak, nonatomic) IBOutlet UIView *otherMenu;
@property (weak, nonatomic) IBOutlet UIView *mainMenu;
@property (weak, nonatomic) IBOutlet UIView *numMenu;
@property (weak, nonatomic) IBOutlet UILabel *topLab;



@end

@implementation TVController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *views= [_navTop subviews];
    [_navTop setTintColor:[UIColor whiteColor]];
    [views[0] setAlpha:0];
    _topLab.text=self.deviceInfo.deviceCustomName;
    // Do any additional setup after loading the view.
}
- (IBAction)other2main:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        _mainMenu.alpha=1;
        _otherMenu.alpha=0;
    } completion:^(BOOL finished) {
        if (finished) {
            _otherMenu.hidden=YES;
            _mainMenu.hidden=NO;
            _numMenu.hidden=YES;
        }
    }];
}
- (IBAction)num2main:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        _mainMenu.alpha=1;
        _numMenu.alpha=0;
    } completion:^(BOOL finished) {
        if (finished) {
            _otherMenu.hidden=YES;
            _mainMenu.hidden=NO;
            _numMenu.hidden=YES;
        }
    }];
}
- (IBAction)main2num:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        _mainMenu.alpha=0;
        _numMenu.alpha=1;
    } completion:^(BOOL finished) {
        if (finished) {
            _otherMenu.hidden=YES;
            _mainMenu.hidden=YES;
            _numMenu.hidden=NO;
        }
    }];
}

- (IBAction)main2other:(UIButton *)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        _mainMenu.alpha=0;
        _otherMenu.alpha=1;
    } completion:^(BOOL finished) {
        if (finished) {
            _otherMenu.hidden=NO;
            _mainMenu.hidden=YES;
            _numMenu.hidden=YES;
        }
    }];

}

-(IBAction)pressBtn:(UIButton *)sender
{
    NSLogMethodArgs(@"....%@",@(sender.tag));
    NSString *btnString=[@(sender.tag-100).stringValue fullWithLengthCount:3];
    NSString *commandString=[[_deviceInfo.deviceInfaredCode stringByAppendingString:btnString]fullWithLengthCountBehide:27];
    [TTSUtility localDeviceControl:_deviceInfo.deviceInfraredID commandStr:commandString retryTimes:0 conditionReturn:^(id stateData) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
