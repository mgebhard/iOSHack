@import Foundation;
#import <Spotify/Spotify.h>

/**
 * The `ArtistsData` class <#what does it do#>
 */
@interface ArtistsData : NSObject
@property NSDate *newestReleaseDate;
@property NSDictionary *albumDateMappings;
@property NSString *newestAlbumName;
@property NSURL *albumeImageURL;
@property NSString *artistName;
@property NSURL *albumURI;
@property NSArray <SPTPartialTrack *> *tracksOnNewestAlbum;
@property NSMutableArray <NSURL *> *trackURIs;

- (instancetype) initWithAlbumDictionary: (NSArray *)  albumData name: (NSString *) name;

@end
