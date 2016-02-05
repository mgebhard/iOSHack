//
//  SearchSpotify.h
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArtistsData.h"

@interface SearchSpotify : NSObject

+(void) searchSpotifyFollowerCount:(NSString *) searchText category:(NSString *) category completion:(void (^) (NSArray * artists)) completion;
+(void) getArtistsAlbumsIDs: (NSString *) artistID completion:(void (^) (NSMutableSet * albumIds)) completion;
+(void) getAlbumReleaseDates: (NSMutableSet *) albumIDs  artistName:(NSString *) artistName completion:(void (^) (ArtistsData *albumMappings)) completion;
+(void) getArtistsId: (NSString *) artistName completion:(void (^) (NSArray *artistIds)) completion;
+(NSString *) getURLJoinedIds: (NSMutableSet *) albumIds;
+(void) sendAsyncAPICall: (NSString *) urlSearchString
       completionHandler:(void(^) (NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error)) completionHandler;
+(void) setRequestHeaders: (NSMutableURLRequest *) request;

@end
