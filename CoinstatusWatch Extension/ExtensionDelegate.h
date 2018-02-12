//
//  ExtensionDelegate.h
//  CoinstatusWatch Extension
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <WatchKit/WatchKit.h>

#import "CNSPriceRetriever.h"

FOUNDATION_EXPORT NSNotificationName const ExchangeListDidChangeNotification;
FOUNDATION_EXPORT NSNotificationName const PriceRetrieverDidUpdateNotification;

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>

@property (readonly) CNSPriceRetriever *priceRetriever;

@end
