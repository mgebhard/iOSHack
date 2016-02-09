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

+(void) searchSpotifyFollowerCount:(NSString * _Nullable) searchText category:(NSString *_Nullable) category completion:(void (^_Nullable) (NSArray *_Nullable artists)) completion;
+(void) getArtistsAlbumsIDs: (NSString *_Nullable) artistID completion:(void (^_Nullable) (NSMutableSet * _Nullable albumIds)) completion;
+(void) getAlbumReleaseDates: (NSMutableSet *_Nullable) albumIDs  artistName:(NSString *_Nullable) artistName completion:(void (^_Nullable) (ArtistsData *_Nullable albumMappings)) completion;
+(void) getArtistsId: (NSString *_Nullable) artistName completion:(void (^_Nullable) (NSArray *_Nullable artistIds)) completion;
+(NSString *_Nullable) getURLJoinedIds: (NSMutableSet *_Nullable) albumIds;
+(void) sendAsyncAPICall: (NSString *_Nullable) urlSearchString
       completionHandler:(void(^ _Nullable) (NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error)) completionHandler;
+(void) setRequestHeaders: (NSMutableURLRequest * _Nullable) request;

@end
