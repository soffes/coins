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
#import "BTCValueView.h"

#import <QuartzCore/QuartzCore.h>
#import <SAMGradientView/SAMGradientView.h>
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "UIColor+Coins.h"

@interface BTCValueViewController () <UITextFieldDelegate, SSPullToRefreshViewDelegate>
@property (nonatomic, readonly) BTCTextField *textField;
@property (nonatomic, readonly) UIButton *doneButton;
@property (nonatomic) UIPopoverController *currencyPopover;
@property (nonatomic) BOOL controlsHidden;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL autoRefreshing;
@property (nonatomic) NSTimer *autoRefreshTimer;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) SSPullToRefreshView *pullToRefresh;
@property (nonatomic, readonly) SAMGradientView *backgroundView;
@property (nonatomic, readonly) BTCValueView *valueView;
@property (nonatomic, readonly) BTCTickingButton *updateButton;
@property (nonatomic, readonly) NSLayoutConstraint *doneButtonTopConstraint;
@property (nonatomic, readonly) NSLayoutConstraint *textFieldTopConstraint;
@end

@implementation BTCValueViewController

#pragma mark - Accessors

@synthesize textField = _textField;
@synthesize doneButton = _doneButton;
@synthesize scrollView =_scrollView;
@synthesize pullToRefresh = _pullToRefresh;
@synthesize backgroundView = _backgroundView;
@synthesize valueView = _valueView;
@synthesize updateButton = updateButton;
@synthesize doneButtonTopConstraint = _doneButtonTopConstraint;
@synthesize textFieldTopConstraint = _textFieldTopConstraint;

- (BTCTextField *)textField {
	if (!_textField) {
		_textField = [[BTCTextField alloc] init];
		_textField.translatesAutoresizingMaskIntoConstraints = NO;
		_textField.delegate = self;
		_textField.alpha = 0.0f;

		NSString *number = [[NSUserDefaults btc_sharedDefaults] stringForKey:kBTCNumberOfCoinsKey];
		_textField.text = [number isEqualToString:@"0"] ? nil : number;
	}
	return _textField;
}


- (UIButton *)doneButton {
	if (!_doneButton) {
		_doneButton = [[UIButton alloc] init];
		_doneButton.translatesAutoresizingMaskIntoConstraints = NO;
		_doneButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14.0f];
		_doneButton.alpha = 0.0f;
		[_doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateNormal];
		[_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[_doneButton addTarget:self action:@selector(toggleControls:) forControlEvents:UIControlEventTouchUpInside];
		[_doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
		_doneButton.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);

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


- (SAMGradientView *)backgroundView {
	if (!_backgroundView) {
		_backgroundView = [[SAMGradientView alloc] init];
		_backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
		_backgroundView.gradientColors = @[
			[UIColor btc_blueColor],
			[UIColor btc_purpleColor]
		];
		_backgroundView.dimmedGradientColors = _backgroundView.gradientColors;
	}
	return _backgroundView;
}


- (BTCValueView *)valueView {
	if (!_valueView) {
		_valueView = [[BTCValueView alloc] init];

		[_valueView.valueButton addTarget:self action:@selector(pickCurrency:) forControlEvents:UIControlEventTouchUpInside];
		[_valueView.inputButton addTarget:self action:@selector(startEditing:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _valueView;
}


- (BTCTickingButton *)updateButton {
	if (!updateButton) {
		updateButton = [[BTCTickingButton alloc] init];
		updateButton.translatesAutoresizingMaskIntoConstraints = NO;
		[updateButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.3f] forState:UIControlStateNormal];
		[updateButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.8f] forState:UIControlStateHighlighted];
		updateButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:12.0f];
		updateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
		[updateButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
	}
	return updateButton;
}


- (void)setLoading:(BOOL)loading {
	_loading = loading;

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:_loading];

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
		_scrollView.translatesAutoresizingMaskIntoConstraints = NO;
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


- (NSLayoutConstraint *)doneButtonTopConstraint {
	if (!_doneButtonTopConstraint) {
		_doneButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
		_doneButtonTopConstraint.priority = UILayoutPriorityRequired;
		[self updateDoneButtonTopLayoutConstraint];
	}
	return _doneButtonTopConstraint;
}


- (NSLayoutConstraint *)textFieldTopConstraint {
	if (!_textFieldTopConstraint) {
		_textFieldTopConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
		_textFieldTopConstraint.priority = UILayoutPriorityDefaultHigh;
	}
	return _textFieldTopConstraint;
}


#pragma mark - NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.automaticallyAdjustsScrollViewInsets = NO;
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];

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
	[self.backgroundView addSubview:self.valueView];
	[self.view addSubview:self.updateButton];
	[self.view addSubview:self.textField];
	[self.view addSubview:self.doneButton];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls:)];
	[self.scrollView addGestureRecognizer:tap];

	[self update];
	[self refresh:nil];
	[self preferencesDidChange];

	[self setControlsHidden:[[NSUserDefaults btc_sharedDefaults] boolForKey:kBTCControlsHiddenKey] animated:NO];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(update) name:kBTCCurrencyDidChangeNotificationName object:nil];
	[notificationCenter addObserver:self selector:@selector(preferencesDidChange) name:NSUserDefaultsDidChangeNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(updateTimerPaused:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(updateTimerPaused:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(refresh:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

	[self setupViewConstraints];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self update];
	[self.navigationController setNavigationBarHidden:YES animated:animated];

	[self.updateButton startTicking];

	self.autoRefreshing = [[NSUserDefaults btc_sharedDefaults] boolForKey:kBTCAutomaticallyRefreshKey];

	if ([[NSUserDefaults btc_sharedDefaults] doubleForKey:kBTCNumberOfCoinsKey] == 0.0) {
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

	if (editing) {
		[self.view addConstraint:self.doneButtonTopConstraint];
		[self.view addConstraint:self.textFieldTopConstraint];
		[self.textField becomeFirstResponder];
	} else {
		[self.view removeConstraint:self.doneButtonTopConstraint];
		[self.view removeConstraint:self.textFieldTopConstraint];
		[self.textField resignFirstResponder];
	}

	void (^animations)(void) = ^{
		self.textField.alpha = editing ? 1.0f : 0.0f;
		self.doneButton.alpha = self.textField.alpha;
		self.valueView.valueButton.alpha = editing ? 0.0f : 1.0f;
		self.valueView.inputButton.alpha = self.valueView.valueButton.alpha;
	};

	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:1.0f animations:animations completion:nil];
		[UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:1.0f animations:^{
			[self.view layoutIfNeeded];
		} completion:nil];
	} else {
		animations();
	}
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[self.currencyPopover dismissPopoverAnimated:YES];
	[self updateDoneButtonTopLayoutConstraint];
}


#pragma mark - Actions

- (void)refresh:(id)sender {
	if (self.loading) {
		return;
	}

	self.loading = YES;

	[[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates) {
		[self update];
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
		[self.currencyPopover presentPopoverFromRect:self.valueView.valueButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
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

- (void)setupViewConstraints {
	NSDictionary *views = @{
		@"scrollView": self.scrollView,
		@"backgroundView": self.backgroundView,
		@"valueView": self.valueView,
		@"updateButton": self.updateButton,
		@"textField": self.textField,
		@"doneButton": self.doneButton
	};

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:kNilOptions metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:kNilOptions metrics:nil views:views]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.valueView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.valueView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.valueView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.valueView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];


	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[updateButton]-|" options:kNilOptions metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[updateButton]-10-|" options:kNilOptions metrics:nil views:views]];

	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
	constraint.priority = UILayoutPriorityDefaultLow;
	[self.view addConstraint:constraint];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[doneButton]-|" options:kNilOptions metrics:nil views:views]];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(20@500)-[textField(<=500@600)]-(20@500)-|" options:kNilOptions metrics:nil views:views]];
	constraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.valueView.valueButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
	constraint.priority = UILayoutPriorityDefaultLow;
	[self.view addConstraint:constraint];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];

	constraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.doneButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:20.0f];
	constraint.priority = UILayoutPriorityRequired;
	[self.view addConstraint:constraint];
}


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
	[self updateDoneButtonTopLayoutConstraint];

	NSUserDefaults *userDefaults = [NSUserDefaults btc_sharedDefaults];
	[userDefaults setBool:_controlsHidden forKey:kBTCControlsHiddenKey];
	[userDefaults synchronize];

	void (^animations)(void) = ^{
		self.updateButton.alpha = _controlsHidden ? 0.0f : 1.0f;
		[self.view layoutIfNeeded];
	};

	if (animated) {
		[UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:animations completion:nil];
	} else {
		animations();
	}
}


- (void)textFieldDidChange:(NSNotification *)notification {
	NSString *string = [self.textField.text stringByReplacingOccurrencesOfString:@"," withString:@"."];

	NSUserDefaults *userDefaults = [NSUserDefaults btc_sharedDefaults];
	[userDefaults setObject:@([string doubleValue]) forKey:kBTCNumberOfCoinsKey];
	[userDefaults synchronize];

	[self update];
}


- (void)update {
	NSDictionary *conversionRates = [[BTCConversionProvider sharedProvider] latestConversionRates];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.currencyPopover dismissPopoverAnimated:YES];
	}

	self.updateButton.date = conversionRates[@"updatedAt"];
	self.valueView.conversionRates = conversionRates;

	[self viewDidLayoutSubviews];
}


- (void)preferencesDidChange {
	[UIApplication sharedApplication].idleTimerDisabled = [[NSUserDefaults btc_sharedDefaults] boolForKey:kBTCDisableSleepKey];
	[self updateTimerPaused:nil];
}


- (void)updateTimerPaused:(NSNotification *)notification {
	BOOL active = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
	self.autoRefreshing = active && [[NSUserDefaults btc_sharedDefaults] boolForKey:kBTCAutomaticallyRefreshKey];
}


- (void)keyboardWillChangeFrame:(NSNotification *)notification {
	CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	self.textFieldTopConstraint.constant = fminf(keyboardFrame.size.height, keyboardFrame.size.width) / -2.0f;
}


- (void)updateDoneButtonTopLayoutConstraint {
	CGFloat constant = 10.0f;

	if (!self.controlsHidden) {
		constant += 20.0f;
	}

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		constant += 6.0f;
	}

	self.doneButtonTopConstraint.constant = constant;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self toggleControls:textField];
	return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (self.editing) {
		[self setEditing:NO animated:YES];
	}
}


#pragma mark - SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
	[self refresh:view];
}


- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view {
	return !self.loading && !self.editing;
}

@end
