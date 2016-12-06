//
//  DoorCheckController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/19.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorCheckController.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import <JFGSDK/JFGSDK.h>
@interface DoorCheckController ()<JFGSDKCallbackDelegate,JFGSDKPlayVideoDelegate>
{
    JFGSDKVideoView *playView;
    BOOL isTalkBack;
}
@property (weak, nonatomic) IBOutlet UIView *videoView;

@end

@implementation DoorCheckController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    playView = [[JFGSDKVideoView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    playView.delegate = self;
    [_videoView addSubview:playView];
    isTalkBack=NO;
    [playView startLiveRemoteVideo:self.targetDevice.uuid];
    // Do any additional setup after loading the view.
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [playView stopVideo];
//}
- (IBAction)stopVideo:(UIButton *)sender {
    [playView stopVideo];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)getPhoto:(UIButton *)sender {
    UIImage *videoImage = [playView videoScreenshotForLocal:NO];
    UIImageWriteToSavedPhotosAlbum(videoImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = error?@"保存图片失败":@"保存图片成功";
    NSLog(@"%@",msg);
}


- (IBAction)noSound:(UIButton *)sender {
    isTalkBack=!isTalkBack;
    [playView setAudioForLocal:YES openMic:isTalkBack openSpeaker:isTalkBack];//本地
    [playView setAudioForLocal:NO openMic:isTalkBack openSpeaker:isTalkBack];//门铃
    sender.highlighted=isTalkBack;
}

#pragma mark JFGSDK delegate
-(void)jfgRTCPNotifyBitRate:(int)bitRate
                videoRecved:(int)videoRecved
                  frameRate:(int)frameRate
                  timesTamp:(int)timesTamp
{
    NSLog(@"bit:%d",bitRate);
}


/*!
 *  摄像头录像分辨率通知
 *
 *  @param width  宽度
 *  @param height 高度
 */
-(void)jfgResolutionNotifyWidth:(int)width
                         height:(int)height
                           peer:(NSString *)peer
{
    
    NSLog(@"[w:%d h:%d]",width,height);
    CGRect frame = playView.frame;
    frame.origin.x = 0;
    frame.origin.y = 64;
    frame.size.height = height;
    playView.frame = frame;
    
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
