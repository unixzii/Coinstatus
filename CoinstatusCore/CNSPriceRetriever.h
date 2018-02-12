//
//  CNSPriceRetriever.h
//  CoinstatusCore
//
//  Created by 杨弘宇 on 2018/2/12.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CNSPriceRetriever;

@protocol CNSPriceRetrieverDelegate <NSObject>

@optional
- (void)newDataAvailableOfPriceRetriever:(CNSPriceRetriever *)retriever;

@end

@interface CNSPriceRetriever : NSObject

@property (nonatomic, copy) NSArray<NSString *> *exchangeList;
@property (nonatomic, weak) id<CNSPriceRetrieverDelegate> delegate;

- (void)startRetrieving;
- (void)stopRetrieving;

- (NSDictionary<NSString *, id> *)getInfoFromSymbol:(NSString *)fsym;

@end
