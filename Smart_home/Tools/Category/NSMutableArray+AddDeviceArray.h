//
//  NSMutableArray+AddDeviceArray.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/4.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (AddDeviceArray)

@property(nonatomic, strong, readonly) NSArray *brandTitleList;
@property(nonatomic, strong, readonly) NSArray *brandTitlePreFixListWithSort;
@property(nonatomic, strong, readonly) NSArray *brandTitlePreFixListNOSort;

- (NSUInteger)refreshWithDeviceInfo:(NSDictionary *)info;

//-(NSArray *)getBrandTitlePreFixSort:(BOOL)needSort withTitleArr:(NSArray *)titleArr;

- (NSArray *)getBrandTitle;

- (NSUInteger)getIndexOfTitle:(NSString *)title;

//-(NSArray *)getSectionObj:(NSUInteger)section WithAllTitlePreNOSort:(NSArray *)allTitlePreNOSort WithAllTitlePreSort:(NSArray *)allTitlePreWithSort WithTitleArr:(NSArray *)titleArr;

@end
