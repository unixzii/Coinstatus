//
//  CNSCurrencyTableViewCell.h
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNSCurrencyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *currencyImageView;
@property (weak, nonatomic) IBOutlet UILabel *coinNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;

@end
