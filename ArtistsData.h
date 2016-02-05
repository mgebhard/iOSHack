@import Foundation;

/**
 * The `ArtistsData` class <#what does it do#>
 */
@interface ArtistsData : NSObject
@property NSDate *newestReleaseDate;
@property double timeSinceLastRelease;
@property NSDictionary *albumDateMappings;
@property NSString *newestAlbumName;
@property NSString *albumURL;
@property NSString *artistName;


- (instancetype) initWithAlbumDictionary: (NSArray *)  albumData name: (NSString *) name;

@end
