//
//  CNSAddCurrencyViewController.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSAddCurrencyViewController.h"

#import <AFNetworking/UIKit+AFNetworking.h>

#import "CNSCoin.h"
#import "CNSDataCenter.h"
#import "CNSCurrencyTableViewCell.h"

@interface CNSAddCurrencyViewController () <UISearchResultsUpdating>

@property (nonatomic, copy) NSArray<CNSCoin *> *coinList;
@property (nonatomic, copy) NSArray<CNSCoin *> *originalCoinList;

@end

@implementation CNSAddCurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchResultsUpdater = self;
    
    if ([self.navigationItem respondsToSelector:@selector(setSearchController:)]) {
        self.navigationItem.searchController = searchController;
    } else {
        self.tableView.tableHeaderView = searchController.searchBar;
    }
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 74;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadDataClearingCache) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.refreshControl beginRefreshing];
    // A workaround for UIRefreshControl bug, see:
    // https://stackoverflow.com/questions/14718850/uirefreshcontrol-beginrefreshing-not-working-when-uitableviewcontroller-is-ins
    if (![self.tableView respondsToSelector:@selector(safeAreaInsets)]) {
        CGFloat y = self.tableView.contentOffset.y - CGRectGetHeight(self.refreshControl.frame);
        [self.tableView setContentOffset:CGPointMake(0, y) animated:YES];
    }
    
    [self loadData];
}

- (void)loadDataClearingCache {
    [[CNSDataCenter defaultCenter] clearCoinListCache];
    [self loadData];
}

- (void)loadData {
    [[CNSDataCenter defaultCenter] fetchCoinListWithCallback:^(id list, NSError *err) {
        if (list) {
            BOOL freshLoad = _coinList == nil;
            _coinList = list;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (freshLoad) {
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    [self.tableView reloadData];
                }
            }];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.refreshControl endRefreshing];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _coinList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CNSCurrencyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    CNSCoin *coin = [_coinList objectAtIndex:indexPath.row];
    
    cell.currencyImageView.image = nil;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:coin.imageURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [cell.currencyImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:nil failure:nil];
    cell.coinNameLabel.text = coin.coinName;
    cell.symbolLabel.text = coin.symbol;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_delegate) return;
    if (![_delegate respondsToSelector:@selector(addCurrencyViewController:didSelectCoinWithSymbol:)]) return;
    
    CNSCoin *coin = [_coinList objectAtIndex:indexPath.row];
    [_delegate addCurrencyViewController:self didSelectCoinWithSymbol:coin.symbol];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (!_originalCoinList) {
        _originalCoinList = _coinList;
    }
    
    NSString *keyword = searchController.searchBar.text;
    
    if (keyword.length == 0) {
        _coinList = _originalCoinList;
        _originalCoinList = nil;
    } else {
        _coinList = [_originalCoinList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"coinName CONTAINS %@ OR symbol CONTAINS %@", keyword, [keyword uppercaseString]]];
    }
    [self.tableView reloadData];
}

@end
