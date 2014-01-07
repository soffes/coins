//
//  BTCValueViewController.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCValueViewController.h"
#import "BTCConversionProvider.h"
#import "BTCCurrencyPickerTableViewController.h"
#import "BTCTickingButton.h"
#import "BTCTextField.h"

#import <QuartzCore/QuartzCore.h>
#import <SAMGradientView/SAMGradientView.h>
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "UIColor+Coins.h"

@interface BTCValueViewController () <UITextFieldDelegate, SSPullToRefreshViewDelegate>
@property (nonatomic, readonly) UIButton *inputButton;
@property (nonatomic, readonly) BTCTextField *textField;
@property (nonatomic, readonly) UIButton *valueButton;
@property (nonatomic, readonly) BTCTickingButton *updateButton;
@property (nonatomic, readonly) UIButton *doneButton;
@property (nonatomic) UIPopoverController *currencyPopover;
@property (nonatomic) BOOL controlsHidden;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL autoRefreshing;
@property (nonatomic) NSTimer *autoRefreshTimer;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) SSPullToRefreshView *pullToRefresh;
@property (nonatomic, readonly) SAMGradientView *backgroundView;
@end

@implementation BTCValueViewController

#pragma mark - Accessors

@synthesize textField = _textField;
@synthesize valueButton = _valueButton;
@synthesize inputButton = _inputButton;
@synthesize updateButton = _updateButton;
@synthesize doneButton = _doneButton;
@synthesize scrollView =_scrollView;
@synthesize pullToRefresh = _pullToRefresh;
@synthesize backgroundView = _backgroundView;

- (BTCTextField *)textField {
	if (!_textField) {
		_textField = [[BTCTextField alloc] init];
		_textField.delegate = self;
		_textField.alpha = 0.0f;

		NSString *number = [[NSUserDefaults standardUserDefaults] stringForKey:kBTCNumberOfCoinsKey];
		_textField.text = [number isEqualToString:@"0"] ? nil : number;
	}
	return _textField;
}


- (UIButton *)valueButton {
	if (!_valueButton) {
		_valueButton = [[UIButton alloc] init];
		_valueButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80.0f : 50.0f];
		_valueButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		_valueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
		[_valueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_valueButton addTarget:self action:@selector(pickCurrency:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _valueButton;
}


- (UIButton *)inputButton {
	if (!_inputButton) {
		_inputButton = [[UIButton alloc] init];
		_inputButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 30.0f : 20.0f];
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
		[_doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];

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


- (void)setLoading:(BOOL)loading {
	_loading = loading;

	if (loading) {
		self.updateButton.format = NSLocalizedString(@"UPDATING", nil);
		[self.pullToRefresh startLoading];
	} else {
		self.updateButton.format = NSLocalizedString(@"UPDATED_FORMAT", nil);
		[self.pullToRefresh finishLoading];
	}
}


- (UIScrollView *)scrollView {
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] init];
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceVertical = YES;
	}
	return _scrollView;
}


- (SSPullToRefreshView *)pullToRefresh {
	if (!_pullToRefresh) {
		_pullToRefresh = [[SSPullToRefreshView alloc] initWithScrollView:self.scrollView delegate:self];
		_pullToRefresh.defaultContentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);

		SSPullToRefreshSimpleContentView *contentView = [[SSPullToRefreshSimpleContentView alloc] init];
		contentView.statusLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
		contentView.statusLabel.font = [UIFont fontWithName:@"Avenir-Light" size:12.0f];
		contentView.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		_pullToRefresh.contentView = contentView;
	}
	return _pullToRefresh;
}


- (SAMGradientView *)backgroundView {
	if (!_backgroundView) {
		_backgroundView = [[SAMGradientView alloc] init];
		_backgroundView.backgroundColor = [UIColor clearColor];
		_backgroundView.gradientColors = @[
			[UIColor btc_blueColor],
			[UIColor btc_purpleColor]
		];
		_backgroundView.dimmedGradientColors = _backgroundView.gradientColors;
	}
	return _backgroundView;
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
		[UIColor btc_blueColor],
		[UIColor btc_purpleColor]
	];
	gradient.gradientLocations = @[@0.5f, @0.51f];
	gradient.dimmedGradientColors = gradient.gradientColors;
	[self.view addSubview:gradient];

	[self.view addSubview:self.scrollView];
	[self pullToRefresh];

	gradient = [[SAMGradientView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 30.0f)];
	gradient.backgroundColor = [UIColor clearColor];
	gradient.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	gradient.gradientColors = @[
		[UIColor btc_blueColor],
		[[UIColor btc_blueColor] colorWithAlphaComponent:0.0f]
	];
	gradient.gradientLocations = @[@0.6f, @1];
	gradient.dimmedGradientColors = gradient.gradientColors;
	[self.view addSubview:gradient];

	[self.scrollView addSubview:self.backgroundView];

	self.automaticallyAdjustsScrollViewInsets = NO;

	[self.scrollView addSubview:self.textField];
	[self.scrollView addSubview:self.valueButton];
	[self.scrollView addSubview:self.inputButton];
	[self.view addSubview:self.updateButton];
	[self.scrollView addSubview:self.doneButton];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls:)];
	[self.scrollView addGestureRecognizer:tap];

	[self _update];
	[self refresh:nil];
	[self _preferencesDidChange];

	[self setControlsHidden:[[NSUserDefaults standardUserDefaults] boolForKey:kBTCControlsHiddenKey] animated:NO];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(_textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(_update) name:kBTCCurrencyDidChangeNotificationName object:nil];
	[notificationCenter addObserver:self selector:@selector(_preferencesDidChange) name:NSUserDefaultsDidChangeNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(_updateTimerPaused:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(_updateTimerPaused:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(refresh:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];

	CGSize size = self.view.bounds.size;
	CGFloat offset = -20.0f;
	CGSize labelSize = [self.valueButton sizeThatFits:CGSizeMake(size.width, 200.0f)];
	labelSize.width = fminf(size.width - 20.0f, labelSize.width);

	self.scrollView.frame = self.view.bounds;
	self.scrollView.contentSize = self.view.bounds.size;
	self.backgroundView.frame = self.view.bounds;

	self.valueButton.frame = CGRectMake(roundf((size.width - labelSize.width) / 2.0f), roundf((size.height - labelSize.height) / 2.0f) + offset, labelSize.width, labelSize.height);
	self.inputButton.frame = CGRectMake(20.0f, CGRectGetMaxY(self.valueButton.frame) + offset + 10.0f, size.width - 40.0f, 44.0f);
	self.updateButton.frame = CGRectMake(44.0f, size.height - 44.0f, size.width - 88.0f, 44.0f);
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self _update];
	[self.navigationController setNavigationBarHidden:YES animated:animated];

	[self.updateButton startTicking];

	self.autoRefreshing = [[NSUserDefaults standardUserDefaults] boolForKey:kBTCAutomaticallyRefreshKey];

	if ([[NSUserDefaults standardUserDefaults] doubleForKey:kBTCNumberOfCoinsKey] == 0.0) {
		[self setEditing:YES animated:animated];
	}
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self.updateButton stopTicking];

	self.autoRefreshing = NO;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];

	BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
	CGSize size = self.view.bounds.size;
	CGRect doneFrame = CGRectMake(size.width - 80.0f, 16.0f + (statusBarHidden ? 4.0f : 20.0f), 60.0f, 32.0f);
	CGRect topDoneFrame = doneFrame;
	topDoneFrame.origin.y -= 40.0f;

	CGFloat inputWidth = fminf(size.width - 40.0f, 500.0f);
	CGRect inputFrame = CGRectMake(roundf((size.width - inputWidth) / 2.0f), CGRectGetMinY(self.valueButton.frame) - 108.0f, inputWidth, 54.0f);
	if (self.view.bounds.size.height < 500) {
		inputFrame.origin.y += 14.0f;
	}

	CGRect downInputFrame = inputFrame;
	downInputFrame.origin.y = self.inputButton.frame.origin.y;

	if (editing) {
		self.textField.frame = downInputFrame;
		self.doneButton.frame = topDoneFrame;
	}

	void (^animations)(void) = ^{
		self.textField.alpha = editing ? 1.0f : 0.0f;
		self.textField.frame = editing ? inputFrame : downInputFrame;

		self.valueButton.alpha = editing ? 0.0f : 1.0f;
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


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[self.currencyPopover dismissPopoverAnimated:YES];
}


#pragma mark - Actions

- (void)refresh:(id)sender {
	if (self.loading) {
		return;
	}

	self.loading = YES;

	[[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates) {
		[self _update];
		self.loading = NO;
	}];
}


- (void)pickCurrency:(id)sender {
	BTCCurrencyPickerTableViewController *viewController = [[BTCCurrencyPickerTableViewController alloc] init];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		navigationController.navigationBar.titleTextAttributes = @{
			NSForegroundColorAttributeName: [UIColor btc_blueColor],
			NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0f]
		};

		self.currencyPopover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
		[self.currencyPopover presentPopoverFromRect:self.valueButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
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


#pragma mark - Private

- (void)setControlsHidden:(BOOL)controlsHidden animated:(BOOL)animated {
	UIApplication *application = [UIApplication sharedApplication];

	if (_controlsHidden == controlsHidden) {
		if (application.statusBarHidden != controlsHidden) {
			[application setStatusBarHidden:controlsHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
		}
		return;
	}
	_controlsHidden = controlsHidden;

	[application setStatusBarHidden:_controlsHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:_controlsHidden forKey:kBTCControlsHiddenKey];
	[userDefaults synchronize];

	void (^animations)(void) = ^{
		self.updateButton.alpha = _controlsHidden ? 0.0f : 1.0f;
		[self viewDidLayoutSubviews];
	};

	if (animated) {
		[UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:animations completion:nil];
	} else {
		animations();
	}
}


- (void)_textFieldDidChange:(NSNotification *)notification {
	NSString *string = [self.textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:@([string doubleValue]) forKey:kBTCNumberOfCoinsKey];
	[userDefaults synchronize];

	[self _update];
}


- (void)_update {
	NSDictionary *conversionRates = [[BTCConversionProvider sharedProvider] lastConversionRates];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.currencyPopover dismissPopoverAnimated:YES];
	}

	self.updateButton.date = conversionRates[@"updatedAt"];

	static NSNumberFormatter *currencyFormatter = nil;
	static dispatch_once_t currencyOnceToken;
	dispatch_once(&currencyOnceToken, ^{
		currencyFormatter = [[NSNumberFormatter alloc] init];
		currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	});

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	currencyFormatter.currencyCode = [userDefaults stringForKey:kBTCSelectedCurrencyKey];
	CGFloat value = [self.textField.text floatValue] * [conversionRates[currencyFormatter.currencyCode] floatValue];
	[self.valueButton setTitle:[currencyFormatter stringFromNumber:@(value)] forState:UIControlStateNormal];

	static NSNumberFormatter *numberFormatter = nil;
	static dispatch_once_t numberOnceToken;
	dispatch_once(&numberOnceToken, ^{
		numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
		numberFormatter.currencySymbol = @"";
		numberFormatter.minimumFractionDigits = 0;
		numberFormatter.maximumFractionDigits = 10;
		numberFormatter.roundingMode = NSNumberFormatterRoundDown;
	});

	// Ensure it's a double for backwards compatibility with 1.0
	NSNumber *number = @([[userDefaults stringForKey:kBTCNumberOfCoinsKey] doubleValue]);

	NSString *title = [numberFormatter stringFromNumber:number];
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
	[self toggleControls:textField];
	return NO;
}


#pragma mark - SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
	[self refresh:view];
}


- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view {
	return !self.loading && !self.editing;
}

@end
