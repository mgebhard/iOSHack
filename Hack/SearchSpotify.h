//
//  SearchSpotify.h
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchSpotify : NSObject

+(void) searchSpotifyFollowerCount:(NSString *) artist completion:(void (^) (NSNumber * followerCount)) completion;

@end
