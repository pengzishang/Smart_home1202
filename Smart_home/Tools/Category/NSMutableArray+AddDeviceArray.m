//
//  NSMutableArray+AddDeviceArray.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/4.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "NSMutableArray+AddDeviceArray.h"

@implementation NSMutableArray (AddDeviceArray)

@dynamic brandTitleList;
@dynamic brandTitlePreFixListNOSort;
@dynamic brandTitlePreFixListWithSort;


- (NSUInteger)refreshWithDeviceInfo:(NSDictionary *)info {
    NSString *deviceName = info[@"advertisementData"][@"kCBAdvDataLocalName"];
    NSString *deviceIDstr = [deviceName substringFromIndex:7];

    __block BOOL isContain = NO;
    __block NSUInteger idxCurrent = 0;
    [self enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull objDic, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *storeDeviceName = objDic[@"advertisementData"][@"kCBAdvDataLocalName"];
        NSString *storeDeviceIDstr = [storeDeviceName substringFromIndex:7];
        if ([storeDeviceIDstr isEqualToString:deviceIDstr]) {
            isContain = YES;
            *stop = YES;
            idxCurrent = idx;
        }
    }];
    if (isContain) {
        [self replaceObjectAtIndex:idxCurrent withObject:info];
        return idxCurrent;
    } else {
        [self addObject:info];
        return NSUIntegerMax;
    }

}

- (NSString *)deviceTypeWithID:(NSString *)deviceName {
    return [deviceName substringWithRange:NSMakeRange(5, 1)];
}

- (NSNumber *)getStateCode:(NSString *)deviceFullName {
    NSString *stateCode = [deviceFullName substringWithRange:NSMakeRange(6, 1)];
    NSUInteger stateIndex = [stateCode characterAtIndex:0];
    return @(stateIndex & (0x07));
}

- (NSArray *)getBrandTitle {
    NSMutableArray *titleArr = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull brandObj, NSUInteger idx, BOOL *_Nonnull stop) {
        [titleArr addObject:brandObj[@"brand"]];
    }];
    return [NSArray arrayWithArray:titleArr];
}

- (NSUInteger)getIndexOfTitle:(NSString *)title {
    __block NSUInteger index;
    [self enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull brandObj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([brandObj[@"brand"] isEqualToString:title]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

//-(NSArray *)getBrandTitlePreFixSort:(BOOL)needSort withTitleArr:(NSArray *)titleArr
//{
//    NSMutableArray *titlePreArr=[NSMutableArray array];
////    NSArray <__kindof NSString *>*titleArr=[self getBrandTitle];
//    [titleArr enumerateObjectsUsingBlock:^(__kindof NSString * _Nonnull titleobj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [titlePreArr addObject:[self firstCharactor:titleobj]];
//    }];
//    NSSet *set=[NSSet setWithArray:titlePreArr];//去重复
//    NSSortDescriptor *descriptor=[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
//    NSArray *resultArray=[set sortedArrayUsingDescriptors:@[descriptor]];//排序
//    
//    return needSort?resultArray:titlePreArr;
//}
//
//-(NSArray *)getSectionObj:(NSUInteger)section WithAllTitlePreNOSort:(NSArray *)allTitlePreNOSort WithAllTitlePreSort:(NSArray *)allTitlePreWithSort WithTitleArr:(NSArray *)titleArr
//{
////    NSArray <__kindof NSString *>*allTitlePreNOSort=[self getBrandTitlePreFixSort:NO];
////    NSArray <__kindof NSString *>*allTitlePreWithSort=[self getBrandTitlePreFixSort:YES];
////    NSArray <__kindof NSString *>*titleArr=[self getBrandTitle];
//    
//    NSMutableArray *resultObj=[NSMutableArray array];
//    NSString *targetCharacter=allTitlePreWithSort[section];
//    [allTitlePreNOSort enumerateObjectsUsingBlock:^(__kindof NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isEqualToString:targetCharacter]) {
//            [resultObj addObject:titleArr[idx]];
//        }
//    }];
//    
//    return resultObj;
//}

- (NSString *)firstCharactor:(NSString *)aString {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef) str, NULL, kCFStringTransformMandarinLatin, NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef) str, NULL, kCFStringTransformStripDiacritics, NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}


@end
