//
//  CNSAddCurrencyViewController.h
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CNSAddCurrencyViewController;

@protocol CNSAddCurrencyViewControllerDelegate <NSObject>
@optional
- (void)addCurrencyViewController:(CNSAddCurrencyViewController *)vc didSelectCoinWithSymbol:(NSString *)symbol;
@end

@interface CNSAddCurrencyViewController : UITableViewController

@property (weak, nonatomic) id<CNSAddCurrencyViewControllerDelegate> delegate;

@end
