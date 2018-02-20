//
//  CNSExchangeCollectionViewCell.m
//  Coinstatus
//
//  Created by 杨弘宇 on 2018/2/11.
//  Copyright © 2018年 Cyandev. All rights reserved.
//

#import "CNSExchangeCollectionViewCell.h"

#import "CNSCardOptionButton.h"

static NSString * const CNSExchangeCollectionViewCellDidRequestClosingCardOptionNotification = @"CNSExchangeCollectionViewCellDidRequestClosingCardOptionNotification";

@interface CNSExchangeCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (nonatomic, strong) CNSCardOptionButton *deleteButton;

@end

@implementation CNSExchangeCollectionViewCell

+ (void)closeCardOptionsInCellsExcept:(CNSExchangeCollectionViewCell *)cell {
    id userInfo;
    
    if (cell) {
        userInfo = @{@"exception": cell};
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:CNSExchangeCollectionViewCellDidRequestClosingCardOptionNotification
     object:nil
     userInfo:userInfo];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(closeCardOption:) name:CNSExchangeCollectionViewCellDidRequestClosingCardOptionNotification
     object:nil];
    
    // TODO: Use pre-rendered background in the future.
    _cardView.layer.masksToBounds = YES;
    _cardView.layer.cornerRadius = 6;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealCardOption:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.contentView addGestureRecognizer:swipeGestureRecognizer];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeCardOption:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.contentView addGestureRecognizer:swipeGestureRecognizer];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.contentView.alpha = 1;
    if (_deleteButton) {
        [_deleteButton removeFromSuperview];
        _deleteButton = nil;
    }
}

- (void)revealCardOption:(id)sender {
    if (_deleteButton) return;
    
    [[self class] closeCardOptionsInCellsExcept:self];
    
    _deleteButton = [[CNSCardOptionButton alloc] initWithFrame:CGRectZero];
    _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_deleteButton setImage:[UIImage imageNamed:@"Trash"] forState:UIControlStateNormal];
    [self addSubview:_deleteButton];
    
    [NSLayoutConstraint
     activateConstraints:@[
                           [_deleteButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
                           [_deleteButton.widthAnchor constraintEqualToConstant:44],
                           [_deleteButton.heightAnchor constraintEqualToConstant:44],
                           [_deleteButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
                           ]];
    
    
    _deleteButton.alpha = 0;
    _deleteButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(20, 0), 0.6, 0.6);
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:10 options:0 animations:^{
        self.contentView.alpha = 0.8;
        _deleteButton.alpha = 1;
        _deleteButton.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)closeCardOption:(id)sender {
    if (!_deleteButton) return;
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSNotification *note = sender;
        id exception = [note.userInfo objectForKey:@"exception"];
        if (self == exception) return;
    }
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:10 options:0 animations:^{
        self.contentView.alpha = 1;
        _deleteButton.alpha = 0;
        _deleteButton.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(20, 0), 0.6, 0.6);
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
