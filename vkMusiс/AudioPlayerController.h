//
//  BYAudioPlayerController.h
//  vkMusiс
//
//  Created by Yuri Balashkevych on 08.05.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "SongsListTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Song.h"

@interface AudioPlayerController : UIViewController

@property (strong, nonatomic) NSArray               *songs;
@property (strong, nonatomic) Song                  *playingSong;

@end
