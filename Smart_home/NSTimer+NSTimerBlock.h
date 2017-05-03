//
//  NSTimer+NSTimerBlock.h
//  Smart_home
//
//  Created by 彭子上 on 2017/5/2.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (NSTimerBlock)
+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
@end
