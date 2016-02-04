//
//  ViewController.m
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import "ViewController.h"
#import "SearchSpotify.h"


@interface ViewController ()
<
    UISearchResultsUpdating,
    UITableViewDataSource,
    UITableViewDelegate
>
@property UISearchController *searchController;
@property UITableView *tableView;
@property NSArray *artists;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor redColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style: UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"identifier"];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = self.view.bounds;
}

#pragma mark UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    NSLog(@"%@", searchController.searchBar.text);
    if (![searchController.searchBar.text length]) {
        return;
    }

    [SearchSpotify searchSpotifyFollowerCount:searchController.searchBar.text completion:^(NSArray *artists) {
        self.artists = artists;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];

}

#pragma mark UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.artists count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];

    cell.textLabel.text = self.artists[indexPath.row][@"name"];
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", self.artists[indexPath.row][@"name"]);
}

@end
