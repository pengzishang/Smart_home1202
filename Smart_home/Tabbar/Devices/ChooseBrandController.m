//
//  ChooseBrandController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/6.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "ChooseBrandController.h"
#import "ConfirmCodeController.h"
#import "NSMutableArray+AddDeviceArray.h"

@interface ChooseBrandController () <UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSArray *brandTitle;
@property(nonatomic, strong) NSMutableArray *searchList;
@property(weak, nonatomic) IBOutlet UITableView *mainTableView;
@property(weak, nonatomic) IBOutlet UINavigationItem *navTitle;


@property(strong, nonatomic) UISearchController *searchController;


@end

@implementation ChooseBrandController

- (NSArray *)brandTitle {
    if (!_brandTitle) {
        _brandTitle = [self.resourseArr getBrandTitle];
    }
    return _brandTitle;
}

- (NSMutableArray *)searchList {
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = YES;
        _searchController.obscuresBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = YES;
    }
    return _searchController;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _mainTableView.tableHeaderView = self.searchController.searchBar;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - UISearchControllerDelegate代理

//测试UISearchController的执行过程

- (void)presentSearchController:(UISearchController *)searchController {
    NSLog(@"presentSearchController");
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    NSLog(@"willDismissSearchController");
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"didDismissSearchController");
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"updateSearchResultsForSearchController");
    NSString *searchString = [searchController.searchBar text];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    if (self.searchList != nil) {
        [self.searchList removeAllObjects];
    }
    self.searchList = [NSMutableArray arrayWithArray:[self.brandTitle filteredArrayUsingPredicate:preicate]];
    [_mainTableView reloadData];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchController.active) {
        return self.searchList.count;
    } else {
        return self.brandTitle.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"brandCell" forIndexPath:indexPath];
    UILabel *titleLab = [cell viewWithTag:1001];
    if (self.searchController.active) {
        titleLab.text = self.searchList[indexPath.row];
    } else {
        titleLab.text = self.brandTitle[indexPath.row];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.searchController.active ? self.searchList[indexPath.row] : self.brandTitle[indexPath.row];
    NSNumber *deviceIndex = @([self.resourseArr getIndexOfTitle:title]);//品牌号从1开始
    self.searchController.active = NO;
    [self.searchController.view removeFromSuperview];
    [self performSegueWithIdentifier:@"chooseCode" sender:deviceIndex];

}


#pragma mark - NavigationSwitchCommonCell

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSNumber *)sender {
    ConfirmCodeController *target = segue.destinationViewController;
    target.deviceType = @(self.deviceType);
    target.deviceInfaredCode = sender.stringValue;
}


@end
