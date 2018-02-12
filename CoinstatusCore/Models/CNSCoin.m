//
//  CNSCoin.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSCoin.h"

static NSString * const kCNSCoinNameKey = @"CNSCoinName";
static NSString * const kCNSCoinCoinNameKey = @"CNSCoinCoinName";
static NSString * const kCNSCoinImageURLKey = @"CNSCoinImageURL";
static NSString * const kCNSCoinSymbolKey = @"CNSCoinSymbol";

@implementation CNSCoin

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) return nil;
    
    _name = [aDecoder decodeObjectForKey:kCNSCoinNameKey];
    _coinName = [aDecoder decodeObjectForKey:kCNSCoinCoinNameKey];
    _imageURL = [aDecoder decodeObjectForKey:kCNSCoinImageURLKey];
    _symbol = [aDecoder decodeObjectForKey:kCNSCoinSymbolKey];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:kCNSCoinNameKey];
    [aCoder encodeObject:_coinName forKey:kCNSCoinCoinNameKey];
    [aCoder encodeObject:_imageURL forKey:kCNSCoinImageURLKey];
    [aCoder encodeObject:_symbol forKey:kCNSCoinSymbolKey];
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) copy = [[[self class] allocWithZone:zone] init];
    copy->_name = [_name copy];
    copy->_coinName = [_coinName copy];
    copy->_imageURL = [_imageURL copy];
    copy->_symbol = [_symbol copy];
    return copy;
}

@end
