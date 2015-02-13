//
//  BYPlayerViewController.h
//  vkMusiс
//
//  Created by George on 11.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BYSong.h"

@interface BYPlayerViewController : UIViewController

@property (strong, nonatomic) BYSong* song;
@property (strong, nonatomic) AVPlayer* player;

- (IBAction)actionPlaySong:(id)sender;

@end
