//
//  CallingController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/12.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "CallingController.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import <JFGSDK/JFGSDK.h>
#import "TTSUtility.h"
#import "UIImageView+WebCache.h"

@interface CallingController () <JFGSDKCallbackDelegate, JFGSDKPlayVideoDelegate, SDWebImageManagerDelegate> {
    __weak IBOutlet UIView *comingView;
    __weak IBOutlet UIView *videoView;
    __weak IBOutlet UIView *callingView;
    JFGSDKVideoView *playView;
    __weak IBOutlet UIImageView *firstImage;
    AVAudioPlayer *player;
    BOOL isTalkBack;
}

@end

@implementation CallingController

- (void)viewDidLoad {
    [super viewDidLoad];
    isTalkBack = NO;
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"door" ofType:@"mp3"];
//    player = [[AVAudioPlayer alloc]initWithContentsOfURL:
//              [NSURL fileURLWithPath:filePath] error:NULL];
//    [player prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
//    [player play];//播放
    JFGSDKDoorBellCall *device = self.userInfo;
    [NSThread sleepForTimeInterval:1.0];

    if (device.url) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager loadImageWithURL:[NSURL URLWithString:device.url] options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                NSLogMethodArgs(@"成功加载");
                [firstImage setImage:image];
            } else {
                NSLogMethodArgs(@"失败重新加载");
                [NSThread sleepForTimeInterval:1.0];
                [firstImage sd_setImageWithURL:[NSURL URLWithString:device.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image) {
                        NSLogMethodArgs(@"成功加载");
                        [firstImage setImage:image];
                    } else {
                        NSLogMethodArgs(@"失败重新加载");
                        [NSThread sleepForTimeInterval:2.0];
                        [firstImage sd_setImageWithURL:imageURL];
                    }
                }];
            }
        }];
}


    playView = [[JFGSDKVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    playView.delegate = self;
    [videoView addSubview:playView];
    //未加载完毕
}

- (IBAction)acceptCalling:(UIButton *)sender {
    callingView.hidden = NO;
    comingView.hidden = YES;
    JFGSDKDoorBellCall *device = self.userInfo;
    [player stop];
    [playView startLiveRemoteVideo:device.cid];
}

- (IBAction)declineCalling:(UIButton *)sender {
    JFGSDKDoorBellCall *device = self.userInfo;
    [playView startLiveRemoteVideo:device.cid];
    [NSThread sleepForTimeInterval:1.0];
    [playView stopVideo];
    [player stop];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)sounds:(UIButton *)sender {
    isTalkBack = !isTalkBack;
    [playView setAudioForLocal:YES openMic:isTalkBack openSpeaker:isTalkBack];
    [playView setAudioForLocal:NO openMic:isTalkBack openSpeaker:isTalkBack];
    sender.highlighted = isTalkBack;

}

- (IBAction)endCalling:(UIButton *)sender {//要有下线操作
    [playView stopVideo];
    [self dismissViewControllerAnimated:YES completion:nil];
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
