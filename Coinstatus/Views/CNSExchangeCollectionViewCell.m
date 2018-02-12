//
//  CNSExchangeCollectionViewCell.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSExchangeCollectionViewCell.h"

#import "CNSCardOptionButton.h"

@interface CNSExchangeCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (nonatomic, strong) CNSCardOptionButton *deleteButton;

@end

@implementation CNSExchangeCollectionViewCell {
    CGSize _cachedSize;
    NSLayoutConstraint *_widthConstrait;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // TODO: Use pre-rendered background in the future.
    _cardView.layer.masksToBounds = YES;
    _cardView.layer.cornerRadius = 6;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealCardOption:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_cardView addGestureRecognizer:swipeGestureRecognizer];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeCardOption:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_cardView addGestureRecognizer:swipeGestureRecognizer];
}

- (void)revealCardOption:(id)sender {
    CGRect buttonFrame;
    buttonFrame.origin = CGPointMake(CGRectGetWidth(self.frame) - 62, 0);
    buttonFrame.size = CGSizeMake(54, CGRectGetHeight(self.frame));
    _deleteButton = [[CNSCardOptionButton alloc] initWithFrame:buttonFrame];
    [_deleteButton setImage:[UIImage imageNamed:@"Trash"] forState:UIControlStateNormal];
    [self addSubview:_deleteButton];
    
    _deleteButton.alpha = 0;
    _deleteButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(20, 0), 0.6, 0.6);
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:10 options:0 animations:^{
        _cardView.transform = CGAffineTransformMakeTranslation(-56, 0);
        _deleteButton.alpha = 1;
        _deleteButton.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)closeCardOption:(id)sender {
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:10 options:0 animations:^{
        _cardView.transform = CGAffineTransformIdentity;
        _deleteButton.alpha = 0;
        _deleteButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(62, 0), 0.6, 0.6);
    } completion:^(BOOL finished) {
        [_deleteButton removeFromSuperview];
        _deleteButton = nil;
    }];
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    layoutAttributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    
    UICollectionView *collectionView = (id) self.superview;
    CGFloat containerWidth = CGRectGetWidth(collectionView.frame);
    if ([collectionView respondsToSelector:@selector(adjustedContentInset)]) {
        containerWidth -= collectionView.adjustedContentInset.left + collectionView.adjustedContentInset.right;
    } else {
        containerWidth -= collectionView.contentInset.left + collectionView.contentInset.right;
    }
    
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        containerWidth = CGRectGetWidth(collectionView.readableContentGuide.layoutFrame);
    }
    
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    size.width = containerWidth;
    if (!CGSizeEqualToSize(layoutAttributes.frame.size, size)) {
        CGRect frame = layoutAttributes.frame;
        frame.size = size;
        layoutAttributes.frame = frame;
    }
    
    return layoutAttributes;
}

@end
