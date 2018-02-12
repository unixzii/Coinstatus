//
//  CNSExchange.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSExchange.h"

@implementation CNSExchange

+ (instancetype)exchangeFromSymbol:(NSString *)fsym toSymbol:(NSString *)tsym {
    CNSExchange *instance = [CNSExchange new];
    instance.fromSymbol = fsym;
    instance.toSymbol = tsym;
    return instance;
}

@end
