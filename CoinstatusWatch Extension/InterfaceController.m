//
//  InterfaceController.m
//  CoinstatusWatch Extension
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "InterfaceController.h"

#import "ExtensionDelegate.h"
#import "CNSExchangeManager.h"

@implementation PriceRowController
@end

@interface InterfaceController ()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *table;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *placeholderLabel;

@property (nonatomic, copy) NSArray<NSString *> *exchangeList;

@end

@implementation InterfaceController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_syncExchangeList) name:ExchangeListDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reloadData) name:PriceRetrieverDidUpdateNotification object:nil];
    
    [self _syncExchangeList];
}

- (void)_syncExchangeList {
    NSArray<NSString *> *list = [CNSExchangeManager defaultManager].exchangeList;
    if (!list || list.count == 0) {
        [self.placeholderLabel setHidden:NO];
        [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.table.numberOfRows)]];
        return;
    }
    
    _exchangeList = list;
    ((ExtensionDelegate *) [WKExtension sharedExtension].delegate).priceRetriever.exchangeList = list;
    
    [self.placeholderLabel setHidden:YES];
    [self.table setNumberOfRows:list.count withRowType:@"Row"];
    
    [list enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fsym = [obj componentsSeparatedByString:@"~"].firstObject;
        PriceRowController *row = [self.table rowControllerAtIndex:idx];
        [row.titleLabel setText:[NSString stringWithFormat:@"%@ ~ USD", fsym]];
    }];
}

- (void)_reloadData {
    CNSPriceRetriever *priceRetriever = ((ExtensionDelegate *) [WKExtension sharedExtension].delegate).priceRetriever;

    [_exchangeList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fsym = [obj componentsSeparatedByString:@"~"].firstObject;
        PriceRowController *row = [self.table rowControllerAtIndex:idx];
        
        id info = [priceRetriever getInfoFromSymbol:fsym];
        NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:[[info objectForKey:@"PRICE"] stringValue]];
        
        [row.bodyLabel setText:[NSString stringWithFormat:@"%.2f", price.doubleValue]];
    }];
}

- (IBAction)showSettings {
    [self presentControllerWithName:@"Settings" context:nil];
}

@end



