//
//  SearchSpotify.h
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchSpotify : NSObject

+(void) searchSpotifyFollowerCount:(NSString *) searchText category:(NSString *) category completion:(void (^) (NSArray * artists)) completion;
+(void) getArtistsAlbumsIDs: (NSString *) artistID completion:(void (^) (NSMutableSet * albumIds)) completion;
+(void) getAlbumReleaseDates: (NSMutableSet *) albumIDs completion:(void (^) (NSMutableDictionary * albumMappings)) completion;
+(void) getArtistsId: (NSString *) artistName completion:(void (^) (NSString *artistIds)) completion;
@end
