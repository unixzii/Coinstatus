//
//  CNSDataCenter.h
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSInteger CNSDataCenterInvalidResponseError;

typedef void(^CNSDataCenterCallback)(id, NSError *);

@interface CNSDataCenter : NSObject

+ (instancetype)defaultCenter;

- (void)clearCoinListCache;
- (void)fetchCoinListWithCallback:(CNSDataCenterCallback)block;

- (void)fetchPrices:(NSArray<NSString *> *)list withCallback:(CNSDataCenterCallback)block;

@end
