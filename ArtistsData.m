#import "ArtistsData.h"
#import "SearchSpotify.h"
#import <Spotify/Spotify.h>

@implementation ArtistsData: NSObject

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

    return self;
}

-(NSString *) getCountUp {
    // Get conversion to months, days, hours, minutes, seconds
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitSecond;
    NSDateComponents *breakdownInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.newestReleaseDate  toDate: [NSDate date]  options:0];
    NSString *totalDate = [NSString stringWithFormat: @"%li years : %li months : %li days : %li hours : %li minutes", (long)[breakdownInfo year],
                           (long)[breakdownInfo month], (long)[breakdownInfo day], (long)[breakdownInfo hour], (long)[breakdownInfo minute]];
    NSArray <NSString *> *invalidDates = @[@"0 years : ", @"0 months : ", @"0 days : ", @"0 hours : ", @"0 minuts" ];
    for (id parseZeroString in invalidDates) {
        totalDate = [totalDate stringByReplacingOccurrencesOfString:parseZeroString withString:@""];
    }

    return totalDate;

}

@end
