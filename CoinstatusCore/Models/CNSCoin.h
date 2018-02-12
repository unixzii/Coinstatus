//
//  CNSCoin.h
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNSCoin : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *coinName;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSString *symbol;

@end
