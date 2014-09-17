//
//  BTCValueView.h
//  Coins
//
//  Created by Sam Soffes on 4/23/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

@import UIKit;

@interface BTCValueView : UIView

@property (nonatomic) NSDictionary *conversionRates;

@property (nonatomic, readonly) UIButton *valueButton;
@property (nonatomic, readonly) UIButton *quantityButton;

- (CGFloat)verticalSpacing;

@end
