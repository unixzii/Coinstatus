//
//  CNSExchangeManager.m
//  CoinstatusCore
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSExchangeManager.h"

static NSString * const kExchangeListDefaultsKey = @"ExchangeList";

@implementation CNSExchangeManager {
    NSArray<NSString *> *_exchangeList;
}

+ (instancetype)defaultManager {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [self new];
        }
    });
    return instance;
}

- (void)setExchangeList:(NSArray<NSString *> *)exchangeList {
    _exchangeList = exchangeList;
    exchangeList = [exchangeList copy];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:exchangeList forKey:kExchangeListDefaultsKey];
    
}

- (NSArray<NSString *> *)exchangeList {
    if (_exchangeList) return _exchangeList;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *list = [defaults objectForKey:kExchangeListDefaultsKey];
    if (!list) return @[];
    return list;
}

@end
