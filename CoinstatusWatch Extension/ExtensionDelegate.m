//
//  ExtensionDelegate.m
//  CoinstatusWatch Extension
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "ExtensionDelegate.h"

#import <WatchConnectivity/WatchConnectivity.h>
#import <ClockKit/ClockKit.h>

#import "CNSExchangeManager.h"

NSNotificationName const ExchangeListDidChangeNotification = @"ExchangeListDidChangedNotification";
NSNotificationName const PriceRetrieverDidUpdateNotification = @"PriceRetrieverDidUpdateNotification";

@interface ExtensionDelegate () <WCSessionDelegate, CNSPriceRetrieverDelegate> {
    CNSPriceRetriever *_priceRetriever;
    NSMutableSet<WKRefreshBackgroundTask *> *_activeBackgroundTasks;
}
@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
    
    WCSession *session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    
    _priceRetriever = [CNSPriceRetriever new];
    _priceRetriever.delegate = self;
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [_priceRetriever startRetrieving];
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
    
    [_priceRetriever stopRetrieving];
    [self scheduleBackgroundRefresh];
}

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    for (WKRefreshBackgroundTask *task in backgroundTasks) {
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [self refreshDataWithBackgroundTask:backgroundTask];
            
            return;
        }
        
        if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
            
            return;
        }
        
        if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            [_activeBackgroundTasks addObject:task];
            
            return;
        }
        
        [task setTaskCompletedWithSnapshot:NO];
    }
}

- (CNSPriceRetriever *)priceRetriever {
    return _priceRetriever;
}

#pragma mark - WCSessionDelegate

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    
}

- (void)sessionDidBecomeInactive:(WCSession *)session {
    
}

- (void)sessionDidDeactivate:(WCSession *)session {
    
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    NSString *action = [userInfo objectForKey:@"action"];
    if ([@"syncExchangeList" isEqualToString:action]) {
        [self syncExchangeList:[userInfo objectForKey:@"payload"]];
    }
    
    NSSet<WKRefreshBackgroundTask *> *aCopy = [_activeBackgroundTasks copy];
    [aCopy enumerateObjectsUsingBlock:^(WKRefreshBackgroundTask * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            [obj setTaskCompletedWithSnapshot:YES];
            [_activeBackgroundTasks removeObject:obj];
        }
    }];
}

#pragma mark -

- (void)syncExchangeList:(id)payload {
    [CNSExchangeManager defaultManager].exchangeList = payload;
    [[NSNotificationCenter defaultCenter] postNotificationName:ExchangeListDidChangeNotification object:nil];
}

- (void)scheduleBackgroundRefresh {
    [[WKExtension sharedExtension] scheduleBackgroundRefreshWithPreferredDate:[NSDate dateWithTimeIntervalSinceNow:1800] userInfo:nil scheduledCompletion:^(NSError * _Nullable error) {
    }];
}

- (void)refreshDataWithBackgroundTask:(WKApplicationRefreshBackgroundTask *)task {
    [_activeBackgroundTasks addObject:task];
    
    [_priceRetriever startRetrieving];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self completeCurrentBackgroundTaskIfNecessary];
    });
}

- (void)completeCurrentBackgroundTaskIfNecessary {
    if ([WKExtension sharedExtension].applicationState != WKApplicationStateActive) {
        [_priceRetriever stopRetrieving];
    }
    
    NSSet<WKRefreshBackgroundTask *> *aCopy = [_activeBackgroundTasks copy];
    [aCopy enumerateObjectsUsingBlock:^(WKRefreshBackgroundTask * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            [obj setTaskCompletedWithSnapshot:YES];
            [_activeBackgroundTasks removeObject:obj];
        }
    }];
    
    [self scheduleBackgroundRefresh];
}

#pragma mark - CNSPriceRetrieverDelegate

- (void)newDataAvailableOfPriceRetriever:(CNSPriceRetriever *)retriever {
    [[NSNotificationCenter defaultCenter] postNotificationName:PriceRetrieverDidUpdateNotification object:nil];
    
    // Trigger ClockKit update.
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    [server.activeComplications enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [server reloadTimelineForComplication:obj];
    }];
    
    [self completeCurrentBackgroundTaskIfNecessary];
}

@end
