//
//  CNSExchange.h
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNSExchange : NSObject

@property (nonatomic, copy) NSString *fromSymbol;
@property (nonatomic, copy) NSString *toSymbol;
@property (nonatomic, assign) uint16_t flags;
@property (nonatomic, copy) NSDecimalNumber *value;

+ (instancetype)exchangeFromSymbol:(NSString *)fsym toSymbol:(NSString *)tsym;

@end
