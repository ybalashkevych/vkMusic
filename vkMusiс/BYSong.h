//
//  BYSong.h
//  vkMusiс
//
//  Created by George on 27.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BYSong : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * audio_id;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * genre_id;
@property (nonatomic, retain) NSNumber * lyrics_id;
@property (nonatomic, retain) NSDate   * modifiedDate;
@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * dataPath;

@end
