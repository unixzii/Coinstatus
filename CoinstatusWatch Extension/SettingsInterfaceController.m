//
//  SettingsInterfaceController.m
//  CoinstatusWatch Extension
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <WatchConnectivity/WatchConnectivity.h>

#import "SettingsInterfaceController.h"

@interface SettingsInterfaceController ()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *forceSyncButton;

@end

@implementation SettingsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (IBAction)forceSync {
    [self.forceSyncButton setEnabled:NO];
    [self animateWithDuration:0.4 animations:^{
        [self.forceSyncButton setAlpha:0.6];
    }];
    
    WCSession *session = [WCSession defaultSession];
    if (!session.isReachable) {
        [self presentAlertControllerWithTitle:@"Sync Failed"
                                      message:@"Ensure your iPhone is nearby and counterpart app is in foreground."
                               preferredStyle:WKAlertControllerStyleAlert
                                      actions:@[[WKAlertAction actionWithTitle:@"Dismiss" style:WKAlertActionStyleDefault handler:^{}]]];
        [self.forceSyncButton setAlpha:1];
        [self.forceSyncButton setEnabled:YES];
        return;
    }
    
    NSDictionary *msg = @{@"action": @"forceSync"};
    [session sendMessage:msg replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentAlertControllerWithTitle:@"Succeeded"
                                          message:@"Request has been received, please wait for sync finished."
                                   preferredStyle:WKAlertControllerStyleAlert
                                          actions:@[[WKAlertAction actionWithTitle:@"Dismiss" style:WKAlertActionStyleDefault handler:^{}]]];
            [self.forceSyncButton setAlpha:1];
            [self.forceSyncButton setEnabled:YES];
        }];
    } errorHandler:^(NSError * _Nonnull error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentAlertControllerWithTitle:@"Sync Failed"
                                          message:@"An excepted error occurred while communicating with iPhone."
                                   preferredStyle:WKAlertControllerStyleAlert
                                          actions:@[[WKAlertAction actionWithTitle:@"Dismiss" style:WKAlertActionStyleDefault handler:^{}]]];
            [self.forceSyncButton setAlpha:1];
            [self.forceSyncButton setEnabled:YES];
        }];
    }];
}

@end
