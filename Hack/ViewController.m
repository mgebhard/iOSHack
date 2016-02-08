//
//  ViewController.m
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import "ViewController.h"
#import "SearchSpotify.h"
#import "NewReleaseViewController.h"

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
@property NSMutableDictionary<NSString *,ArtistsData *> *dropDate;
@property NSTimer *searchTimer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scope = @[@"DROP DAY", @"Artist", @"Track", @"Album"];
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
    if (![searchController.searchBar.text length]) {
        return;
    }

    [self.searchTimer invalidate];
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
}

- (void)performSearch {
    NSString *searchText = self.searchController.searchBar.text;
    
    if (self.category == self.scope[0]) {
        [SearchSpotify getArtistsId:searchText completion:^(NSArray *allArtists) {
            self.artists = allArtists;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            self.dropDate = [[NSMutableDictionary alloc] init];
            for (NSDictionary *artistData in allArtists) {
                [SearchSpotify getArtistsAlbumsIDs: artistData[@"id"] completion:^(NSMutableSet *albumIds) {
                    if ([albumIds count]) {
                        [SearchSpotify getAlbumReleaseDates:albumIds artistName:artistData[@"name"] completion:^(ArtistsData *albumMappings) {
                            [self.dropDate setObject:albumMappings forKey:albumMappings.artistName];
                        }];
                    } else { return; }
                }];
            }
        }];
    } else {
        [SearchSpotify searchSpotifyFollowerCount:searchText
                                         category: self.category
                                       completion:^(NSArray *artists) {
            self.artists = artists;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0) {
    self.category = self.scope[selectedScope];
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.artists count];
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
    cell.imageView.image = image;

    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.category == self.scope[0]) {
        NewReleaseViewController *secondView = [[NewReleaseViewController alloc] init];
        secondView.artistPageData = self.dropDate[self.artists[indexPath.row][@"name"]];
        [self.navigationController pushViewController:secondView animated:YES];
    }
}

@end
