//
//  BTCCurrencyPickerTableViewController.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCCurrencyPickerTableViewController.h"
#import "BTCTableViewCell.h"

@interface BTCCurrencyPickerTableViewController ()
@property (nonatomic) NSDictionary *currencies;
@property (nonatomic) NSArray *currencyOrder;
@property (nonatomic) NSString *selectedKey;
@end

@implementation BTCCurrencyPickerTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = NSLocalizedString(@"CURRENCY", nil);

	[self.tableView registerClass:[BTCTableViewCell class] forCellReuseIdentifier:@"Cell"];

	NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"currencies" ofType:@"json"]];
	NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	self.currencies = JSON[@"currencies"];
	self.currencyOrder = JSON[@"order"];
	self.selectedKey = [[NSUserDefaults standardUserDefaults] objectForKey:kBTCSelectedCurrencyKey];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currencyOrder indexOfObject:self.selectedKey] inSection:0];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];

	[self.navigationController setNavigationBarHidden:NO animated:animated];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.currencyOrder.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;

	NSString *key = self.currencyOrder[indexPath.row];

	cell.textLabel.text = self.currencies[key];
	cell.detailTextLabel.text = key;

	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *key = self.currencyOrder[indexPath.row];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:key forKey:kBTCSelectedCurrencyKey];
	[userDefaults synchronize];

	[[NSNotificationCenter defaultCenter] postNotificationName:kBTCCurrencyDidChangeNotificationName object:key];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
