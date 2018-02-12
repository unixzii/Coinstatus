//
//  CNSMainViewController.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSMainViewController.h"

#import "CNSExchangeCollectionViewCell.h"
#import "CNSExchange.h"
#import "CNSExchangeManager.h"
#import "CNSPriceRetriever.h"

@interface CNSMainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CNSPriceRetrieverDelegate> {
    CNSPriceRetriever *_priceRetriever;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIStackView *placeholderView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (nonatomic, strong) NSMutableArray<CNSExchange *> *exchangeList;

@end

@implementation CNSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ((UICollectionViewFlowLayout *) _collectionView.collectionViewLayout).estimatedItemSize = CGSizeMake(0, 60);
    
    // Manually set the line number due to an IB bug that contents are shown incorrectly.
    _placeholderLabel.numberOfLines = 0;
    
    _priceRetriever = [CNSPriceRetriever new];
    _priceRetriever.delegate = self;
    
    [self loadExchangeList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadExchangeList {
    _exchangeList = [@[] mutableCopy];
    
    id exchangeList = [CNSExchangeManager defaultManager].exchangeList;
    
    [exchangeList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> *comps = [obj componentsSeparatedByString:@"~"];
        CNSExchange *exchange = [CNSExchange exchangeFromSymbol:comps.firstObject toSymbol:comps.lastObject];
        [_exchangeList addObject:exchange];
    }];
    
    _priceRetriever.exchangeList = exchangeList;
    [_priceRetriever startRetrieving];
    
    [_collectionView reloadData];
}

#pragma mark - Navigation

- (IBAction)backInMain:(UIStoryboardSegue *)segue {
    // No-op
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [((CNSExchangeCollectionViewCell *) obj) closeCardOption:nil];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = _exchangeList.count;
    _placeholderView.hidden = count != 0;
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CNSExchangeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    CNSExchange *exchange = [_exchangeList objectAtIndex:indexPath.row];
    
    cell.exchangeLabel.text = [NSString stringWithFormat:@"%@ ~ %@", exchange.fromSymbol, exchange.toSymbol];
    if (exchange.value.doubleValue == 0) {
        cell.valueLabel.text = @"--";
    } else {
        cell.valueLabel.text = [NSString stringWithFormat:@"%.2f", exchange.value.doubleValue];
    }
    
    return cell;
}

#pragma mark - CNSPriceRetrieverDelegate

- (void)newDataAvailableOfPriceRetriever:(CNSPriceRetriever *)retriever {
    [_exchangeList enumerateObjectsUsingBlock:^(CNSExchange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id info = [retriever getInfoFromSymbol:obj.fromSymbol];
        obj.value = [NSDecimalNumber decimalNumberWithString:[[info objectForKey:@"PRICE"] stringValue]];
    }];
    
    [_collectionView reloadData];
}

@end
