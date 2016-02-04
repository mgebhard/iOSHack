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

    NSString *searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/search?query=%@&offset=0&limit=2&type=%@&market=US",
                              [searchText stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]],
                              [category lowercaseString]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: searchString]];

    [request
        setValue: @"application/json"
        forHTTPHeaderField: @"Accept"];

    NSLog(@"%@", request);
    NSLog(@"%@", request.allHTTPHeaderFields);

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            return;
        }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

        NSArray *searchResults = jsonResponse[[[category lowercaseString] stringByAppendingString:@"s"]][@"items"];


        if (completion)
        {
            completion(searchResults);
        }


    }] resume];


}

@end
