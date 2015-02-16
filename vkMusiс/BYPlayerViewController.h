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
#import "BYSongsListTableViewController.h"

@interface BYPlayerViewController : UIViewController


@property (strong, nonatomic) NSArray*          songs;
@property (strong, nonatomic) BYSong*           currentSong;
@property (strong, nonatomic) AVPlayer*         player;
@property (weak, nonatomic) IBOutlet UIButton*  playButton;
@property (weak, nonatomic) IBOutlet UIButton*  playBackButton;
@property (weak, nonatomic) IBOutlet UIButton*  playForwardButton;
@property (weak, nonatomic) IBOutlet UIButton*  titleButton;

- (IBAction)actionPlaySong:(UIButton*)sender;
- (IBAction)actionDissmissController:(UIButton*)sender;
- (IBAction)actionPlayBackAndForward:(UIButton*)sender;

@end
