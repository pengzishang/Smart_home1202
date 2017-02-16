//
//  LaunchView.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/7.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "LaunchView.h"

typedef void(^ok)(void);

@interface LaunchView ()

@property(strong, nonatomic) ok completeReturn;

@end

@implementation LaunchView


- (instancetype)initWithFrame:(CGRect)frame images:(NSArray<__kindof NSString *> *)imgNames complete:(void (^)(void))complete {
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = YES;
        self.contentSize = CGSizeMake(Screen_Width * imgNames.count, Screen_Height);
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        if (complete) {
            self.completeReturn = ^() {
                complete();
            };
        }
        [self addGuideImgWithArr:imgNames];

    }
    return self;
}

- (void)addGuideImgWithArr:(NSArray<__kindof NSString *> *)names {
    [names enumerateObjectsUsingBlock:^(__kindof NSString *_Nonnull name, NSUInteger idx, BOOL *_Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(idx * Screen_Width, 0, Screen_Width, Screen_Height)];
        imageView.image = [UIImage imageNamed:name];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0) {
        [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y)];
    }
    if (scrollView.contentOffset.x > Screen_Width * 2) {

        [UIView animateWithDuration:1.0 animations:^{
            self.alpha = 0.0;
        }                completion:^(BOOL finished) {
            [NSThread sleepForTimeInterval:1.5];
            if (self.completeReturn) {
                _completeReturn();
            }
            [self removeFromSuperview];

        }];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
