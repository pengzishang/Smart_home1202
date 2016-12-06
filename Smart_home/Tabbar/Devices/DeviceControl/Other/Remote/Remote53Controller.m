//
//  Remote53Controller.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/22.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "Remote53Controller.h"
#import "TTSUtility.h"
@interface Remote53Controller ()

@property (weak, nonatomic) IBOutlet UIButton *selectDeviceBtn;
@property (weak, nonatomic) IBOutlet UIView *bindingView;
@property (weak, nonatomic) IBOutlet UIView *switchOne;
@property (weak, nonatomic) IBOutlet UIView *switchTwo;
@property (weak, nonatomic) IBOutlet UIView *switchThree;
@property (weak, nonatomic) IBOutlet UILabel *currentDeviceName;
@property (weak, nonatomic) IBOutlet UILabel *currentDeviceMAC;
@property (weak, nonatomic) IBOutlet UIStackView *contentStackView;

@property (strong,nonatomic) UIImageView *movingImageView;
@property (assign,nonatomic)CGFloat x;
@property (assign,nonatomic)CGFloat y;
@property (assign,nonatomic)NSInteger targetSwitch;


@end

@implementation Remote53Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)reChoose:(UIBarButtonItem *)sender {
    _selectDeviceBtn.hidden=NO;
    _bindingView.hidden=YES;
}

- (IBAction)moveImage:(UIPanGestureRecognizer *)sender {
    
    CGPoint translatedPoint=[sender translationInView:sender.view];
    if (sender.state==UIGestureRecognizerStateBegan) {
        _targetSwitch=sender.view.tag-200;
        _x=[sender.view convertPoint:sender.view.bounds.origin toView:self.view].x+sender.view.bounds.size.width/2;
        _y=[sender.view convertPoint:sender.view.bounds.origin toView:self.view].y+sender.view.bounds.size.height/2;
        _movingImageView=[[UIImageView alloc]initWithFrame:CGRectMake(_x, _y, sender.view.frame.size.width, sender.view.frame.size.height)];
        _movingImageView.image=[UIImage imageNamed:@"add_Remote_Control"];
        [self.view addSubview:_movingImageView];
    }
    translatedPoint=CGPointMake(translatedPoint.x+_x, translatedPoint.y+_y);
    _movingImageView.center=translatedPoint;
    
    if (sender.state==UIGestureRecognizerStateEnded) {
        _x=_movingImageView.center.x;
        _y=_movingImageView.center.y;
        NSLog(@"%f  %f",_x,_y);
        NSInteger targetTag=[self isInAnyBtnFrame:_movingImageView.center];
        [_movingImageView removeFromSuperview];
        if (targetTag) {
            [self sendBindingCommand:targetTag];
        }
        
    }
}


-(NSInteger)isInAnyBtnFrame:(CGPoint)point
{
    __block NSInteger targetTag=0;
    [_contentStackView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIStackView * _Nonnull stackView, NSUInteger idx, BOOL * _Nonnull stop) {
        [stackView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull btnView, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect btnRect= [btnView convertRect:btnView.bounds toView:self.view];
            if (CGRectContainsPoint(btnRect, point)) {
                targetTag=btnView.tag;
                *stop=YES;
            }
        }];
    }];
    //    123 116 109
    return targetTag;
}
//实现绑定命令
-(void)sendBindingCommand:(NSInteger)targetTag
{
    [TTSUtility remoteBind:self.currentDevice remoteCommand:targetTag switchCommand:_targetSwitch remoteID:_remoteDeviceID];
}


-(void)refreshTopView
{
    NSArray <__kindof UIView*>*allSwitch=@[_switchOne,_switchTwo,_switchThree];
    [allSwitch enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden=YES;
    }];
    _selectDeviceBtn.hidden=YES;
    _bindingView.hidden=NO;
    _currentDeviceMAC.text=_currentDevice.deviceMacID;
    _currentDeviceName.text=_currentDevice.deviceCustomName;
    NSUInteger deviceType=_currentDevice.deviceType.integerValue;
    _switchOne.hidden=NO;
    switch (deviceType) {
        case 0:
        case 1:
        {
        }
            break;
        case 2:
        case 4:
        case 5:
        {
            _switchTwo.hidden=NO;
        }
            break;
        case 3:
        {
            _switchTwo.hidden=NO;
            _switchThree.hidden=NO;
        }
            break;
        default:
            break;
    }
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
