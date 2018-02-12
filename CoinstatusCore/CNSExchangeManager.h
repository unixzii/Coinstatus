//
//  CNSExchangeManager.h
//  CoinstatusCore
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNSExchangeManager : NSObject

/**
 User selected exchange list.
 Content format: @"fsym~tsym"
 */
@property (nonatomic) NSArray<NSString *> *exchangeList;

+ (instancetype)defaultManager;

@end
