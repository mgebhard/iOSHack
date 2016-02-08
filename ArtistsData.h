@import Foundation;

/**
 * The `ArtistsData` class <#what does it do#>
 */
@interface ArtistsData : NSObject
@property NSDate *newestReleaseDate;
@property double timeSinceLastRelease;
@property NSDictionary *albumDateMappings;
@property NSString *newestAlbumName;
@property NSURL *albumeImageURL;
@property NSString *artistName;
@property NSURL *albumURI;
@property NSURL *trackURI;

- (instancetype) initWithAlbumDictionary: (NSArray *)  albumData name: (NSString *) name;

@end
