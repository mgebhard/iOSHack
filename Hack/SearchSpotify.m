//
//  SearchSpotify.m
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import "SearchSpotify.h"

@implementation SearchSpotify

+(void) searchSpotifyFollowerCount:(NSString *) artist completion:(void (^) (NSNumber * followerCount)) completion {

    NSString * searchString = [NSString stringWithFormat: @"https://api.spotify.com/v1/search?query=%@%@",
                               [artist stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]],
                               @"&offset=0&limit=2&type=artist&market=US"];

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: searchString]];

    [request
        setValue: @"application/json"
        forHTTPHeaderField: @"Accept"];

    [request
        setValue: @"Bearer BQBbJlBy0zpVDi9w6b2WoO4wH98Mu6jPRXDmzjodRzMrLXPIpRUXoX24-_WbVtFXL5ijFBaXUGRNejgWAJ48rXgjL1kpw8AOTygDRN0TDZ93f1EfCciDdRfQ18srWFAT7vcs4ava7Zp3HyE"
        forHTTPHeaderField: @"Authorization"];

    NSLog(@"%@", request);
    NSLog(@"%@", request.allHTTPHeaderFields);

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            return;
        }
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSNumber *followerCount = jsonResponse[@"artists"][@"items"][0][@"followers"][@"total"];

        if (completion)
        {
            completion(followerCount);
        }


    }] resume];


}

@end
