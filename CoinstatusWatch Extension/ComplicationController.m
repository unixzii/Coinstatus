//
//  ComplicationController.m
//  CoinstatusWatch Extension
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "ComplicationController.h"

#import "ExtensionDelegate.h"
#import "CNSPriceRetriever.h"
#import "CNSExchangeManager.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

- (CLKComplicationTemplate *)getTemplateForComplication:(CLKComplication *)complication withExchange:(NSString *)exchange {
    BOOL placeholder = exchange == nil;

    NSString *fsym;
    NSString *price;
    
    if (!placeholder) {
        CNSPriceRetriever *priceRetriever = ((ExtensionDelegate *) [WKExtension sharedExtension].delegate).priceRetriever;
        
        fsym = [exchange componentsSeparatedByString:@"~"].firstObject;
        price = [NSString stringWithFormat:@"%.2f", [[[priceRetriever infoFromSymbol:fsym] objectForKey:@"PRICE"] doubleValue]];
    }
    
    if (complication.family == CLKComplicationFamilyModularLarge) {
        CLKComplicationTemplateModularLargeTallBody *template = [CLKComplicationTemplateModularLargeTallBody new];
        if (placeholder) {
            template.headerTextProvider = [CLKTextProvider textProviderWithFormat:@"ETH"];
            template.bodyTextProvider = [CLKTextProvider textProviderWithFormat:@"$843.37"];
        } else {
            template.headerTextProvider = [CLKTextProvider textProviderWithFormat:@"%@", fsym];
            template.bodyTextProvider = [CLKTextProvider textProviderWithFormat:@"$%@", price];
        }
        return template;
    } else if (complication.family == CLKComplicationFamilyUtilitarianSmallFlat) {
        CLKComplicationTemplateUtilitarianSmallFlat *template = [CLKComplicationTemplateUtilitarianSmallFlat new];
        if (placeholder) {
            template.textProvider = [CLKTextProvider textProviderWithFormat:@"$843.37"];
        } else {
            template.textProvider = [CLKTextProvider textProviderWithFormat:@"$%@", price];
        }
        return template;
    } else if (complication.family == CLKComplicationFamilyUtilitarianLarge) {
        CLKComplicationTemplateUtilitarianLargeFlat *template = [CLKComplicationTemplateUtilitarianLargeFlat new];
        if (placeholder) {
            template.textProvider = [CLKTextProvider textProviderWithFormat:@"ETH $843.37"];
        } else {
            template.textProvider = [CLKTextProvider textProviderWithFormat:@"%@ $%@", fsym, price];
        }
        return template;
    }
    return nil;
}

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionNone);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    NSString *firstExchange = [CNSExchangeManager defaultManager].exchangeList.firstObject;
    CLKComplicationTemplate *template = [self getTemplateForComplication:complication withExchange:firstExchange];
    
    handler([CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template]);
}

#pragma mark - Placeholder Templates

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    handler([self getTemplateForComplication:complication withExchange:nil]);
}

@end
