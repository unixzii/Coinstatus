//
//  CNSPriceRetriever.m
//  CoinstatusCore
//
//  Created by 杨弘宇 on 2018/2/12.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSPriceRetriever.h"

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#import <PINCache/PINCache.h>

#import "CNSDataCenter.h"

#define MIN_UPDATE_TIME_INTERVAL 30

static NSString * const kCacheName = @"Coinstatus_Price";
static NSString * const kLastUpdateTimeDefaultsKey = @"LastUpdateTime";

@implementation CNSPriceRetriever {
    BOOL _started;
    BOOL _updateInFlight;
    NSTimer *_timer;
    NSDate *_lastUpdateTime;
    PINMemoryCache *_memCache;
    PINDiskCache *_diskCache;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _memCache = [[PINMemoryCache alloc] init];
    _diskCache = [[PINDiskCache alloc] initWithName:kCacheName];
    
#if TARGET_OS_IOS
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_responseToApplicationStateChange:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(_responseToApplicationStateChange:) name:UIApplicationWillResignActiveNotification object:nil];
#endif
    
    return self;
}

- (void)dealloc {
#if TARGET_OS_IOS
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}

- (void)setExchangeList:(NSArray<NSString *> *)exchangeList {
    _exchangeList = exchangeList;
    
    if (_started) {
        [self _downloadLatestData];
    }
}

- (void)startRetrieving {
    if (_started) return;
    _started = YES;
    
    if (_timer) [_timer invalidate];
    
    _timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(_downloadLatestData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    [self _downloadLatestData];
}

- (void)stopRetrieving {
    _started = NO;
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (NSDictionary<NSString *, id> *)infoFromSymbol:(NSString *)fsym {
    id info = [_memCache objectForKey:fsym];
    if (!info) {
        info = [_diskCache objectForKey:fsym];
        [_memCache setObject:info forKey:fsym];
    }
    
    return info;
}

#if TARGET_OS_IOS
- (void)_responseToApplicationStateChange:(NSNotification *)note {
    if (!_started) return;
    
    if ([UIApplicationDidBecomeActiveNotification isEqualToString:note.name]) {
        _started = NO;
        [self startRetrieving];
    } else {
        [_timer invalidate];
        _timer = nil;
    }
}
#endif

- (void)_downloadLatestData {
    if (_updateInFlight) return;
    
    if (!_lastUpdateTime) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _lastUpdateTime = [defaults objectForKey:kLastUpdateTimeDefaultsKey];
        
        if (!_lastUpdateTime) {
            _lastUpdateTime = [NSDate distantPast];
        }
    }
    
    __block BOOL shouldDownload = [[NSDate date] timeIntervalSinceDate:_lastUpdateTime] > MIN_UPDATE_TIME_INTERVAL;
    if (!shouldDownload) {
        [_exchangeList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self infoFromSymbol:[obj componentsSeparatedByString:@"~"].firstObject]) {
                shouldDownload = YES;
                *stop = NO;
            }
        }];
    }
    
    if (shouldDownload) {
        _updateInFlight = YES;
        [[CNSDataCenter defaultCenter] fetchPrices:_exchangeList withCallback:^(id data, NSError * err) {
            _updateInFlight = NO;
            
            if (!data) return;
            
            _lastUpdateTime = [NSDate date];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_lastUpdateTime forKey:kLastUpdateTimeDefaultsKey];
            
            [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                id _USD = [obj objectForKey:@"USD"];
                [_memCache setObject:_USD forKey:key];
                [_diskCache setObject:_USD forKey:key];
            }];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self _notifyDataAvailable];
            }];
        }];
    } else {
        [self _notifyDataAvailable];
    }
}

- (void)_notifyDataAvailable {
    if (_delegate && [_delegate respondsToSelector:@selector(newDataAvailableOfPriceRetriever:)]) {
        [_delegate newDataAvailableOfPriceRetriever:self];
    }
}

@end
