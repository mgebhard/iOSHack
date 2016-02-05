#import "ArtistsData.h"

@implementation ArtistsData: NSObject
double const SecondsPerDay = 86400;

- (instancetype) initWithAlbumDictionary: (NSArray *)  albumData name: (NSString *) name{
    self = [super init];
    NSMutableDictionary * albumMappings = [[NSMutableDictionary alloc] init];
    NSDate *currentLatestDate = [NSDate distantPast];
    NSString *newestAlbum = @"";
    NSString *albumURL = @"";
    for (NSDictionary *obj in albumData){
        NSString *albumName = obj[@"name"];
        NSString *releaseDate = obj[@"release_date"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateObj = [format dateFromString:releaseDate];
        NSDate *temp = [dateObj laterDate:currentLatestDate];
        if (![currentLatestDate isEqualToDate:temp]) {
            currentLatestDate = temp;
            newestAlbum = albumName;
            albumURL = obj[@"images"][0][@"url"];
        }
        [albumMappings setValue:dateObj forKey:albumName];
    }
    
    self.albumDateMappings = albumMappings;
    self.newestReleaseDate = currentLatestDate;
    self.timeSinceLastRelease = currentLatestDate.timeIntervalSinceNow/SecondsPerDay;
    self.newestAlbumName = newestAlbum;
    self.albumURL = albumURL;
    self.artistName = name;

    return self;
}


@end
