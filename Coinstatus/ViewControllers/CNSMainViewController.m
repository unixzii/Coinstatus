//
//  CNSMainViewController.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSMainViewController.h"

#import "AppDelegate.h"
#import "CNSExchangeCollectionViewCell.h"
#import "CNSExchange.h"
#import "CNSExchangeManager.h"
#import "CNSPriceRetriever.h"

@interface CNSMainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CNSPriceRetrieverDelegate> {
    CNSPriceRetriever *_priceRetriever;
    BOOL _interactiveMovementInFlight;
    BOOL _dataUpdatingDeferred;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIStackView *placeholderView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (nonatomic, strong) NSMutableArray<CNSExchange *> *exchangeList;

@end

@implementation CNSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self restoreCollectionViewLayoutConfigurations];
    [_collectionView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dragCollectionViewItem:)]];
    
    // Manually set the line number due to an IB bug that contents are shown incorrectly.
    _placeholderLabel.numberOfLines = 0;
    
    _priceRetriever = [CNSPriceRetriever new];
    _priceRetriever.delegate = self;
    
    [self loadExchangeList];
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

- (void)saveExchangeList {
    NSMutableArray<NSString *> *exchangeList = [NSMutableArray array];
    [_exchangeList enumerateObjectsUsingBlock:^(CNSExchange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [exchangeList addObject:[NSString stringWithFormat:@"%@~%@", obj.fromSymbol, obj.toSymbol]];
    }];
    
    [CNSExchangeManager defaultManager].exchangeList = exchangeList;
    [((AppDelegate *) [UIApplication sharedApplication].delegate) syncExchangeListWithWatch];
}

- (void)dragCollectionViewItem:(UILongPressGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:_collectionView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *downIndexPath = [_collectionView indexPathForItemAtPoint:location];
        if (downIndexPath) {
            // Interactively moving cells will be resize to the layout's estimatedItemSize.
            // To make cells display reasonable, we need to that to current cells' actual
            // size.
            UICollectionViewFlowLayout *layout = (id) _collectionView.collectionViewLayout;
            UIView *cell = [_collectionView cellForItemAtIndexPath:downIndexPath];
            layout.estimatedItemSize = cell.bounds.size;
            
            _interactiveMovementInFlight = YES;
            [_collectionView beginInteractiveMovementForItemAtIndexPath:downIndexPath];
            
            [_priceRetriever stopRetrieving];
        }
        
        return;
    }
    
    if (!_interactiveMovementInFlight) return;
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        [_collectionView updateInteractiveMovementTargetPosition:location];
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [_collectionView endInteractiveMovement];
    } else if (sender.state == UIGestureRecognizerStateCancelled) {
        [_collectionView cancelInteractiveMovement];
    }
    
    [self restoreCollectionViewLayoutConfigurations];
    if (_dataUpdatingDeferred) {
        _dataUpdatingDeferred = NO;
        [_collectionView reloadData];
    }
    
    _interactiveMovementInFlight = NO;
    
    [_priceRetriever startRetrieving];
}

- (void)restoreCollectionViewLayoutConfigurations {
    UICollectionViewFlowLayout *layout = (id) _collectionView.collectionViewLayout;
    layout.estimatedItemSize = CGSizeMake(300, 60);
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

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;  // Yes, we can!
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id item = [_exchangeList objectAtIndex:sourceIndexPath.item];
    [_exchangeList removeObjectAtIndex:sourceIndexPath.item];
    [_exchangeList insertObject:item atIndex:destinationIndexPath.item];
    
    [self saveExchangeList];
}

#pragma mark - CNSPriceRetrieverDelegate

- (void)newDataAvailableOfPriceRetriever:(CNSPriceRetriever *)retriever {
    [_exchangeList enumerateObjectsUsingBlock:^(CNSExchange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id info = [retriever infoFromSymbol:obj.fromSymbol];
        obj.value = [NSDecimalNumber decimalNumberWithString:[[info objectForKey:@"PRICE"] stringValue]];
    }];
    
    if (_interactiveMovementInFlight) {
        _dataUpdatingDeferred = YES;
        return;
    }
    
    [_collectionView reloadData];
}

@end
