//
//  SearchSpotify.m
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import "SearchSpotify.h"

@implementation SearchSpotify

+(void) searchSpotifyFollowerCount:(NSString *) searchText category:(NSString *) category completion:(void (^) (NSArray * artists)) completion {
    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/search?query=%@&offset=0&type=%@&market=US",
                              [searchText stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]],
                              [category lowercaseString]];
    [SearchSpotify sendAsyncAPICall:searchString
                  completionHandler: ^void (NSData * data,
                                            NSURLResponse * _Nullable response,
                                            NSError * _Nullable error) {
        if (!data) { return; }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSArray *searchResults = jsonResponse[[[category lowercaseString] stringByAppendingString:@"s"]][@"items"];

        if (completion)
        {
            completion(searchResults);
        }
    }];
}


//4AK6F7OLvEQ5QYCBNiQWHq One Direction
+(void) getArtistsId: (NSString *) artistName completion:(void (^) (NSString *artistIds)) completion {
    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/search?query=%@&offset=0&limit=2&type=%@&market=US",
                              [artistName stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]],
                              @"artist"];
    [SearchSpotify sendAsyncAPICall:searchString
                  completionHandler: ^void (NSData * data,
                                            NSURLResponse * _Nullable response,
                                            NSError * _Nullable error) {

        if (!data) { return; }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if ([jsonResponse[@"artists"][@"items"] count]) {
            NSString *searchResults = jsonResponse[@"artists"][@"items"][0][@"id"];
            NSLog(@"Computing days since \"%@'s\" last release", jsonResponse[@"artists"][@"items"][0][@"name"]);
            if (completion)
            {
                completion(searchResults);
            }
        }
    }];
}



//4AK6F7OLvEQ5QYCBNiQWHq One Direction
+(void) getArtistsAlbumsIDs: (NSString *) artistID completion:(void (^) (NSMutableSet * albumIds)) completion {
    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/artists/%@/albums", artistID];
    [SearchSpotify sendAsyncAPICall:searchString
                  completionHandler: ^void (NSData * data,
                                            NSURLResponse * _Nullable response,
                                            NSError * _Nullable error) {
        if (!data) { return; }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

        NSMutableSet * albumIDs = [[NSMutableSet alloc] init];
        [jsonResponse[@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [albumIDs addObject:obj[@"id"]];
        }];

        if (completion) {
            completion(albumIDs);
        }
    }];
}


//@"1gMxiQQSg5zeu4htBosASY", @"4gCNyS7pidfK3rKWhB3JOY"]
//    "https://api.spotify.com/v1/albums?ids=1gMxiQQSg5zeu4htBosASY,4gCNyS7pidfK3rKWhB3JOY"
+(void) getAlbumReleaseDates: (NSArray *) albumIDs completion:(void (^) (NSMutableDictionary * albumMappings)) completion {
    NSString *joinedIds = [SearchSpotify getURLJoinedIds: albumIDs];
    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/albums?ids=%@", joinedIds];
    [SearchSpotify sendAsyncAPICall:searchString
                  completionHandler: ^void (NSData * data,
                                            NSURLResponse * _Nullable response,
                                            NSError * _Nullable error) {
        if (!data) { return; }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

        NSMutableDictionary * albumMappings = [[NSMutableDictionary alloc] init];
        NSDate *currentLatestDate = [NSDate distantPast];
        NSString *newestAlbum = @"";
        for (NSDictionary *obj in jsonResponse[@"albums"]){
            NSString *albumName = obj[@"name"];
            NSString *releaseDate = obj[@"release_date"];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateObj = [format dateFromString:releaseDate];
            NSDate *temp = [dateObj laterDate:currentLatestDate];
            if (![currentLatestDate isEqualToDate:temp]) {
                currentLatestDate = temp;
                newestAlbum = albumName;
            }
            [albumMappings setValue:dateObj forKey:albumName];
        }

        double secPerDay =  86400;
        NSLog(@"It has been %f days since the \"%@\" album release which dropped on %@", (currentLatestDate.timeIntervalSinceNow/secPerDay), newestAlbum, currentLatestDate);
//        timeIntervalSinceNow
//        [jsonResponse[@"albums"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop, NSDate *currentLatestDate) {
//        }];

        if (completion) {
            completion(albumMappings);
        }

    }];
}

+(NSString *) getURLJoinedIds: (NSArray *) albumIds {
    //    NSString *joinedIds = [albumIDs componentsJoinedByString:@","];

    NSString *joinedIds = [[NSString alloc] init];
    for (NSString * aId in albumIds) {
        joinedIds = [joinedIds stringByAppendingString:aId];
        joinedIds = [joinedIds stringByAppendingString:@","];
    }
    joinedIds = [joinedIds substringToIndex:[joinedIds length] - 1];
    return joinedIds;
}

+(void) setRequestHeaders: (NSMutableURLRequest *) request {
    [request
     setValue: @"application/json"
     forHTTPHeaderField: @"Accept"];
}

+(void) sendAsyncAPICall: (NSString *) urlSearchString
       completionHandler:(void(^) (NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error)) completionHandler {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlSearchString]];
    [SearchSpotify setRequestHeaders:request];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler: completionHandler] resume];
}

@end
