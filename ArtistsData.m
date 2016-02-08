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
            self.albumURL = obj[@"images"][0][@"url"];
            self.albumURI = [[NSURL alloc] initWithString:obj[@"uri"] relativeToURL: nil];
        }
        [albumMappings setValue:dateObj forKey:albumName];
    }
    
    self.albumDateMappings = albumMappings;
    self.timeSinceLastRelease = self.newestReleaseDate.timeIntervalSinceNow/SecondsPerDay;
    self.artistName = name;

    [SPTAlbum albumWithURI:self.albumURI accessToken:nil market:nil callback:^(NSError *error, id object) {
        NSLog(@"%@", object);
        //        SPTAlbum *album = ((SPTAlbum *) object);
        //        NSArray<SPTPartialTrack *> *tracks = album.tracksForPlayback;
        if ([object respondsToSelector:@selector(tracksForPlayback)]) {
            NSArray<SPTPartialTrack *> *tracks = [object performSelector:@selector(tracksForPlayback)];
            NSLog(@"%@", tracks);
            self.trackURI = [tracks[0] performSelector:@selector(playableUri)];
        }
     }];



    return self;
}


@end
