//
//  BTCValueViewController.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCValueViewController.h"
#import "BTCConversionProvider.h"
#import "BTCCurrencyPickerTableViewController.h"

#import <SAMTextField/SAMTextField.h>

@interface BTCValueViewController () <UITextFieldDelegate>
@property (nonatomic) NSDictionary *conversionRates;
@property (nonatomic, readonly) SAMTextField *textField;
@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UIButton *currencyButton;
@end

@implementation BTCValueViewController

#pragma mark - Accessors

@synthesize textField = _textField;
@synthesize label = _label;
@synthesize currencyButton = _currencyButton;

- (UITextField *)textField {
	if (!_textField) {
		_textField = [[SAMTextField alloc] init];
		_textField.keyboardType = UIKeyboardTypeDecimalPad;
		_textField.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
		_textField.delegate = self;
		_textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kBTCNumberOfCoinsKey];
		_textField.font = [UIFont fontWithName:@"Avenir" size:18.0f];
		_textField.textColor = [UIColor darkTextColor];
		_textField.textEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
	}
	return _textField;
}


- (UILabel *)label {
	if (!_label) {
		_label = [[UILabel alloc] init];
		_label.font = [UIFont fontWithName:@"Avenir" size:18.0f];
		_label.textColor = [UIColor darkTextColor];
	}
	return _label;
}


- (UIButton *)currencyButton {
	if (!_currencyButton) {
		_currencyButton = [[UIButton alloc] init];
		_currencyButton.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
		[_currencyButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
		[_currencyButton addTarget:self action:@selector(pickCurrency:) forControlEvents:UIControlEventTouchUpInside];
		_currencyButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:18.0f];
	}
	return _currencyButton;
}


#pragma mark - NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.automaticallyAdjustsScrollViewInsets = NO;

	self.textField.frame = CGRectMake(20.0f, 40.0f, 280.0f, 44.0f);
	[self.view addSubview:self.textField];

	self.label.frame = CGRectMake(20.0f, 100.0f, 280.0f, 44.0f);
	[self.view addSubview:self.label];

	self.currencyButton.frame = CGRectMake(20.0f, 200.0f, 80.0f, 44.0f);
	[self.view addSubview:self.currencyButton];

	[[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates) {
		self.conversionRates = conversionRates;

		dispatch_async(dispatch_get_main_queue(), ^{
			[self _update];
		});
	}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.textField becomeFirstResponder];

	NSString *currency = [[NSUserDefaults standardUserDefaults] stringForKey:kBTCSelectedCurrencyKey];
	[self.currencyButton setTitle:currency forState:UIControlStateNormal];

	[self _update];

	[self.navigationController setNavigationBarHidden:YES animated:animated];
}


#pragma mark - Actions

- (void)pickCurrency:(id)sender {
	BTCCurrencyPickerTableViewController *viewController = [[BTCCurrencyPickerTableViewController alloc] init];
	[self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - Private

- (void)_textFieldDidChange:(NSNotification *)notification {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:@([self.textField.text floatValue]) forKey:kBTCNumberOfCoinsKey];
	[userDefaults synchronize];

	[self _update];
}


- (void)_update {
	static NSNumberFormatter *numberFormatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	});

	numberFormatter.currencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:kBTCSelectedCurrencyKey];
	CGFloat value = [self.textField.text floatValue] * [self.conversionRates[numberFormatter.currencyCode] floatValue];
	self.label.text = [numberFormatter stringFromNumber:@(value)];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self _update];
	[textField resignFirstResponder];
	return NO;
}

@end
