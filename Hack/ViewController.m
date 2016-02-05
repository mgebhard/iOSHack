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
    UISearchBarDelegate,
    UITableViewDataSource,
    UITableViewDelegate
>
@property UISearchController *searchController;
@property UITableView *tableView;
@property NSArray *artists;
@property NSString *category;
@property UIImageView *imageView;
@property NSArray *scope;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scope = @[@"Artist", @"Track", @"Album"];
    self.category = self.scope[0];
    self.view.backgroundColor = [UIColor redColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style: UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.scopeButtonTitles = self.scope;
    self.searchController.searchBar.delegate = self;
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
    NSString *searchText = searchController.searchBar.text;
    if (![searchText length]) {
        return;
    }

    [SearchSpotify getArtistsId:searchText completion:^(NSString *artistId) {
        [SearchSpotify getArtistsAlbumsIDs:artistId completion:^(NSMutableSet *albumIds) {
            if ([albumIds count]) {
                [SearchSpotify getAlbumReleaseDates:albumIds completion:^(NSDictionary *albumMappings) {
                }];
            } else { return; }
        }];
    }];


//    [SearchSpotify searchSpotifyFollowerCount:searchText
//                                     category: self.category
//                                   completion:^(NSArray *artists) {
//        self.artists = artists;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    }];

}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0) {
    self.category = self.scope[selectedScope];
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.artists count] - 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    cell.textLabel.text = self.artists[indexPath.row][@"name"];

    // No Image associated with artists
    if (![self.artists[indexPath.row][@"images"] count]) {
        return cell;
    }
    NSURL *url = [NSURL URLWithString:self.artists[indexPath.row][@"images"][0][@"url"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];

    self.imageView = [[UIImageView alloc]
                      initWithFrame:CGRectMake(10, 10, 30, 40)];
    self.imageView.image = image;
    [cell addSubview:self.imageView];

    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", self.artists[indexPath.row][@"name"]);
}

@end
