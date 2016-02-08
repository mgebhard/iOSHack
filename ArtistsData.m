#import "ArtistsData.h"
#import "SearchSpotify.h"
#import <Spotify/Spotify.h>

@implementation ArtistsData: NSObject
double const SecondsPerDay = 86400;

- (instancetype) initWithAlbumDictionary: (NSArray *)  albumData name: (NSString *) name{
    self = [super init];

    NSMutableDictionary * albumMappings = [[NSMutableDictionary alloc] init];
    self.newestReleaseDate = [NSDate distantPast];
    for (NSDictionary *obj in albumData){
        NSString *albumName = obj[@"name"];
        NSString *releaseDate = obj[@"release_date"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateObj = [format dateFromString:releaseDate];
        NSDate *temp = [dateObj laterDate:self.newestReleaseDate];
        if (![self.newestReleaseDate isEqualToDate:temp]) {
            self.newestReleaseDate = temp;
            self.newestAlbumName = albumName;
            self.albumeImageURL = [[NSURL alloc] initWithString:obj[@"images"][0][@"url"] relativeToURL: nil];
            self.albumURI = [[NSURL alloc] initWithString:obj[@"uri"] relativeToURL: nil];
        }
        [albumMappings setValue:dateObj forKey:albumName];
    }
    
    self.albumDateMappings = albumMappings;
    self.artistName = name;

    [SPTAlbum albumWithURI:self.albumURI accessToken:nil market:nil callback:^(NSError *error, id object) {
        self.trackURIs = [[NSMutableArray alloc] init];
        if ([object respondsToSelector:@selector(tracksForPlayback)]) {
            self.tracksOnNewestAlbum = [object performSelector:@selector(tracksForPlayback)];
            for (SPTPartialTrack *track in self.tracksOnNewestAlbum) {
                [self.trackURIs addObject:track.playableUri];
            }
        }
     }];



    return self;
}


@end
