//
//  SearchSpotify.m
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import "SearchSpotify.h"
#import <Spotify/Spotify.h>
#import "ArtistsData.h"

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
+(void) getArtistsId: (NSString *) artistName completion:(void (^) (NSArray *artistIds)) completion {
    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/search?query=%@&offset=0&limit=2&type=%@&market=US",
                              [artistName stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]],
                              @"artist"];
    [SearchSpotify sendAsyncAPICall:searchString
                  completionHandler: ^void (NSData * data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                      if (!data) { return; }
                      NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                      if (error) { return; }
                      if (completion)
                      {
                          completion(jsonResponse[@"artists"][@"items"]);
                      }
                  }];
//        NSArray *searchedArtist = [SPTArtist artistsFromData:data withResponse:response error: &error];
//        NSLog(@"%@", searchedArtist);
//        NSArray *ahhhh = [SPTArtist artistFromDecodedJSON:jsonResponse error:nil];
}


+(void) getArtistsAlbumsIDs: (NSString *) artistID completion:(void (^) (NSMutableSet * albumIds)) completion {
    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/artists/%@/albums", artistID];
    [SearchSpotify sendAsyncAPICall:searchString
                  completionHandler: ^void (NSData * data,
                                            NSURLResponse * _Nullable response,
                                            NSError * _Nullable error) {
        if (!data) { return; }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                      NSString *artistURI = [@"spotify:artist:" stringByAppendingString: artistID];
//                      NSURLRequest *iOSrequest = [SPTArtist createRequestForArtist:[NSURL URLWithString: artistURI] withAccessToken:nil error:nil];

        NSMutableSet * albumIDs = [[NSMutableSet alloc] init];
        [jsonResponse[@"items"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [albumIDs addObject:obj[@"id"]];
        }];

        if (completion) {
            completion(albumIDs);
        }
    }];
}

+(void) getAlbumReleaseDates: (NSMutableSet *) albumIDs  artistName:(NSString *) artistName completion:(void (^) (ArtistsData *albumMappings)) completion {
    NSString *joinedIds = [SearchSpotify getURLJoinedIds: albumIDs];
    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/albums?ids=%@", joinedIds];
    [SearchSpotify sendAsyncAPICall:searchString
                  completionHandler: ^void (NSData * data,
                                            NSURLResponse * _Nullable response,
                                            NSError * _Nullable error) {
        if (!data) { return; }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        ArtistsData *newReleaseData = [[ArtistsData alloc] initWithAlbumDictionary:jsonResponse[@"albums"] name:artistName];

        if (completion) {
            completion(newReleaseData);
        }

    }];
}

//        [jsonResponse[@"albums"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop, NSDate *currentLatestDate) {
//        }];

+(NSString *) getURLJoinedIds: (NSMutableSet *) albumIds {
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
