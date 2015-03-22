//
//  BYSong.h
//  vkMusiс
//
//  Created by Yuri Balashkevych on 22.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BYPlaylist;

@interface BYSong : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * audio_id;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * genre_id;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSNumber * isCached;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSNumber * lyrics_id;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) NSNumber * playlist_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSSet *playlists;
@end

@interface BYSong (CoreDataGeneratedAccessors)

- (void)addPlaylistsObject:(BYPlaylist *)value;
- (void)removePlaylistsObject:(BYPlaylist *)value;
- (void)addPlaylists:(NSSet *)values;
- (void)removePlaylists:(NSSet *)values;

@end
