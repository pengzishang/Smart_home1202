//
//  PopTopView.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/9.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "PopTopView.h"

@implementation PopTopView

+(instancetype)popTopViewInit
{
    return [[[NSBundle mainBundle]loadNibNamed:@"PopTopView" owner:self options:nil] firstObject];

}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
