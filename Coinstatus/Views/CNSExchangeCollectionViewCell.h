//
//  CNSExchangeCollectionViewCell.h
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNSExchangeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *exchangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

+ (void)closeCardOptionsInCellsExcept:(CNSExchangeCollectionViewCell *)cell;

- (void)revealCardOption:(id)sender;
- (void)closeCardOption:(id)sender;

@end
