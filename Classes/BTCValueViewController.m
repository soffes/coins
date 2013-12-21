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
#import "BTCTickingButton.h"

#import <QuartzCore/QuartzCore.h>
#import <SAMTextField/SAMTextField.h>
#import <SAMGradientView/SAMGradientView.h>
#import "UIImage+Vector.h"

@interface BTCValueViewController () <UITextFieldDelegate>
@property (nonatomic) NSDictionary *conversionRates;
@property (nonatomic, readonly) UIButton *inputButton;
@property (nonatomic, readonly) SAMTextField *textField;
@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UIButton *currencyButton;
@property (nonatomic, readonly) BTCTickingButton *updateButton;
@property (nonatomic, readonly) UIButton *doneButton;
@property (nonatomic) UIPopoverController *currencyPopover;
@property (nonatomic) BOOL controlsHidden;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL autoRefreshing;
@property (nonatomic) NSTimer *autoRefreshTimer;
@end

@implementation BTCValueViewController

#pragma mark - Accessors

@synthesize textField = _textField;
@synthesize label = _label;
@synthesize currencyButton = _currencyButton;
@synthesize inputButton = _inputButton;
@synthesize updateButton = _updateButton;
@synthesize doneButton = _doneButton;

- (UITextField *)textField {
	if (!_textField) {
		_textField = [[SAMTextField alloc] init];
		_textField.keyboardType = UIKeyboardTypeDecimalPad;
		_textField.delegate = self;
		_textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kBTCNumberOfCoinsKey];
		_textField.font = [UIFont fontWithName:@"Avenir-Light" size:20.0f];
		_textField.textColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
		_textField.textAlignment = NSTextAlignmentCenter;
		_textField.textEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
		_textField.alpha = 0.0f;
		_textField.tintColor = [UIColor whiteColor];
		_textField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];

		_textField.layer.cornerRadius = 5.0f;
	}
	return _textField;
}


- (UILabel *)label {
	if (!_label) {
		_label = [[UILabel alloc] init];
		_label.font = [UIFont fontWithName:@"Avenir-Heavy" size:50.0f];
		_label.textColor = [UIColor whiteColor];
		_label.adjustsFontSizeToFitWidth = YES;
		_label.textAlignment = NSTextAlignmentCenter;
	}
	return _label;
}


- (UIButton *)currencyButton {
	if (!_currencyButton) {
		_currencyButton = [[UIButton alloc] init];
		[_currencyButton addTarget:self action:@selector(pickCurrency:) forControlEvents:UIControlEventTouchUpInside];
		[_currencyButton setImage:[UIImage imageWithPDFNamed:@"gear" tintColor:[UIColor colorWithWhite:1.0f alpha:0.5f] height:20.0f] forState:UIControlStateNormal];
	}
	return _currencyButton;
}


- (UIButton *)inputButton {
	if (!_inputButton) {
		_inputButton = [[UIButton alloc] init];
		_inputButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:20.0f];
		[_inputButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateNormal];
		[_inputButton addTarget:self action:@selector(startEditing:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _inputButton;
}


- (BTCTickingButton *)updateButton {
	if (!_updateButton) {
		_updateButton = [[BTCTickingButton alloc] init];
		[_updateButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.3f] forState:UIControlStateNormal];
		[_updateButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.8f] forState:UIControlStateHighlighted];
		_updateButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:12.0f];
		_updateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
		[_updateButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _updateButton;
}


- (UIButton *)doneButton {
	if (!_doneButton) {
		_doneButton = [[UIButton alloc] init];
		_doneButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0f];
		_doneButton.alpha = 0.0f;
		[_doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateNormal];
		[_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[_doneButton addTarget:self action:@selector(toggleControls:) forControlEvents:UIControlEventTouchUpInside];
		[_doneButton setTitle:@"Done" forState:UIControlStateNormal];

		_doneButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
		_doneButton.layer.borderWidth = 1.0f;
		_doneButton.layer.cornerRadius = 5.0f;

	}
	return _doneButton;
}


- (void)setControlsHidden:(BOOL)controlsHidden {
	[self setControlsHidden:controlsHidden animated:YES];
}


- (void)setAutoRefreshing:(BOOL)autoRefreshing {
	if (_autoRefreshing == autoRefreshing) {
		return;
	}

	_autoRefreshing = autoRefreshing;

	if (_autoRefreshing) {
		self.autoRefreshTimer = [NSTimer timerWithTimeInterval:60.0 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:self.autoRefreshTimer forMode:NSRunLoopCommonModes];
	} else {
		[self.autoRefreshTimer invalidate];
	}
}


#pragma mark - NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	SAMGradientView *gradient = [[SAMGradientView alloc] initWithFrame:self.view.bounds];
	gradient.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	gradient.gradientColors = @[
		[UIColor colorWithRed:0.102f green:0.451f blue:0.635f alpha:1.0f],
		[UIColor colorWithRed:0.302f green:0.235f blue:0.616f alpha:1.0f]
	];
	gradient.dimmedGradientColors = gradient.gradientColors;
	[self.view addSubview:gradient];

	self.automaticallyAdjustsScrollViewInsets = NO;

	[self.view addSubview:self.textField];
	[self.view addSubview:self.label];
	[self.view addSubview:self.currencyButton];
	[self.view addSubview:self.inputButton];
	[self.view addSubview:self.updateButton];
	[self.view addSubview:self.doneButton];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls:)];
	[self.view addGestureRecognizer:tap];

	[self refresh:nil];
	[self _preferencesDidChange];

	[self setControlsHidden:[[NSUserDefaults standardUserDefaults] boolForKey:kBTCControlsHiddenKey] animated:NO];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(_textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(_update) name:kBTCCurrencyDidChangeNotificationName object:nil];
	[notificationCenter addObserver:self selector:@selector(_preferencesDidChange) name:NSUserDefaultsDidChangeNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(_updateTimerPaused:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(_updateTimerPaused:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];

	CGSize size = self.view.bounds.size;
	CGFloat offset = -20.0f;
	CGSize labelSize = [self.label sizeThatFits:CGSizeMake(size.width, 200.0f)];
	labelSize.width = fminf(300.0f, labelSize.width);

	self.label.frame = CGRectMake(roundf((size.width - labelSize.width) / 2.0f), roundf((size.height - labelSize.height) / 2.0f) + offset, labelSize.width, labelSize.height);
	self.inputButton.frame = CGRectMake(20.0f, CGRectGetMaxY(self.label.frame) + offset + 10.0f, size.width - 40.0f, 44.0f);
	self.currencyButton.frame = CGRectMake(size.width - 44.0f, size.height - 44.0f, 44.0f, 44.0f);
	self.updateButton.frame = CGRectMake(44.0f, size.height - 44.0f, size.width - 88.0f, 44.0f);
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self _update];
	[self.navigationController setNavigationBarHidden:YES animated:animated];

	[self.updateButton startTicking];

	self.autoRefreshing = [[NSUserDefaults standardUserDefaults] boolForKey:kBTCAutomaticallyRefreshKey];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self.updateButton stopTicking];

	self.autoRefreshing = NO;
}


#pragma mark - Actions

- (void)refresh:(id)sender {
	if (self.loading) {
		return;
	}

	self.loading = YES;
	self.updateButton.format = @"Updating…";

	[[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates) {
		self.conversionRates = conversionRates;

		[self _update];

		self.updateButton.format = @"Updated %@";
		self.updateButton.date = conversionRates[@"updatedAt"];
		self.loading = NO;
	}];
}


- (void)pickCurrency:(id)sender {
	BTCCurrencyPickerTableViewController *viewController = [[BTCCurrencyPickerTableViewController alloc] init];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		navigationController.navigationBar.titleTextAttributes = @{
			NSForegroundColorAttributeName: [UIColor colorWithRed:0.102f green:0.451f blue:0.635f alpha:1.0f],
			NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0f]
		};

		self.currencyPopover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
		[self.currencyPopover presentPopoverFromRect:self.currencyButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
		return;
	}

	[self.navigationController pushViewController:viewController animated:YES];
}


- (void)toggleControls:(id)sender {
	if (self.editing) {
		[self setEditing:NO animated:YES];
		return;
	}

	self.controlsHidden = !self.controlsHidden;
}


- (void)startEditing:(id)sender {
	[self setEditing:YES animated:YES];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];

	BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
	CGSize size = self.view.bounds.size;
	CGRect doneFrame = CGRectMake(size.width - 80.0f, 16.0f + (statusBarHidden ? 4.0f : 20.0f), 60.0f, 32.0f);
	CGRect topDoneFrame = doneFrame;
	topDoneFrame.origin.y -= 40.0f;

	if (editing) {
		self.textField.frame = self.inputButton.frame;
		self.doneButton.frame = topDoneFrame;
	}

	void (^animations)(void) = ^{
		self.textField.alpha = editing ? 1.0f : 0.0f;
		self.textField.frame = editing ? CGRectMake(20.0f, CGRectGetMinY(self.label.frame) - 108.0f, size.width - 40.0f, 44.0f) : self.inputButton.frame;

		self.label.alpha = editing ? 0.0f : 1.0f;
		self.inputButton.alpha = editing ? 0.0f : 1.0f;

		self.doneButton.frame = editing ? doneFrame : topDoneFrame;
		self.doneButton.alpha = editing ? 1.0f : 0.0f;

	};

	if (animated) {
		[UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:1.0f animations:animations completion:nil];
	} else {
		animations();
	}

	if (editing) {
		[self.textField becomeFirstResponder];
	} else {
		[self.textField resignFirstResponder];
	}
}


#pragma mark - Private

- (void)setControlsHidden:(BOOL)controlsHidden animated:(BOOL)animated {
	if (_controlsHidden == controlsHidden) {
		return;
	}
	_controlsHidden = controlsHidden;

	[[UIApplication sharedApplication] setStatusBarHidden:_controlsHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:_controlsHidden forKey:kBTCControlsHiddenKey];
	[userDefaults synchronize];

	void (^animations)(void) = ^{
		self.currencyButton.alpha = _controlsHidden ? 0.0f : 1.0f;
		self.updateButton.alpha = self.currencyButton.alpha;
		[self viewDidLayoutSubviews];
	};

	if (animated) {
		[UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:animations completion:nil];
	} else {
		animations();
	}
}


- (void)_textFieldDidChange:(NSNotification *)notification {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:@([self.textField.text floatValue]) forKey:kBTCNumberOfCoinsKey];
	[userDefaults synchronize];

	[self _update];
}


- (void)_update {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.currencyPopover dismissPopoverAnimated:YES];
	}

	static NSNumberFormatter *currencyFormatter = nil;
	static dispatch_once_t currencyOnceToken;
	dispatch_once(&currencyOnceToken, ^{
		currencyFormatter = [[NSNumberFormatter alloc] init];
		currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	});

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	currencyFormatter.currencyCode = [userDefaults stringForKey:kBTCSelectedCurrencyKey];
	CGFloat value = [self.textField.text floatValue] * [self.conversionRates[currencyFormatter.currencyCode] floatValue];
	self.label.text = [currencyFormatter stringFromNumber:@(value)];

	static NSNumberFormatter *numberFormatter = nil;
	static dispatch_once_t numberOnceToken;
	dispatch_once(&numberOnceToken, ^{
		numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
		numberFormatter.currencySymbol = @"";
		numberFormatter.minimumFractionDigits = 0;
		numberFormatter.maximumFractionDigits = 10;
	});

	NSString *title = [numberFormatter stringFromNumber:[userDefaults objectForKey:kBTCNumberOfCoinsKey]];
	[self.inputButton setTitle:[NSString stringWithFormat:@"%@ BTC", title] forState:UIControlStateNormal];
	[self viewDidLayoutSubviews];
}


- (void)_preferencesDidChange {
	[UIApplication sharedApplication].idleTimerDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:kBTCDisableSleepKey];
	[self _updateTimerPaused:nil];
}


- (void)_updateTimerPaused:(NSNotification *)notification {
	BOOL active = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
	self.autoRefreshing = active && [[NSUserDefaults standardUserDefaults] boolForKey:kBTCAutomaticallyRefreshKey];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self _update];
	[textField resignFirstResponder];
	return NO;
}

@end
