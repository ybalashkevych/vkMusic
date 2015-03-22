//
//  BYPlaylist.h
//  vkMusiс
//
//  Created by Yuri Balashkevych on 22.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BYSong;

@interface BYPlaylist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *songs;
@end

@interface BYPlaylist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(BYSong *)value;
- (void)removeSongsObject:(BYSong *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

@end
