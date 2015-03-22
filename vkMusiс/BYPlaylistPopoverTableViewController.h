//
//  BYPlaylistPopoverTableViewController.h
//  vkMusiс
//
//  Created by George on 14.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BYSong;

@interface BYPlaylistPopoverTableViewController : UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style andBelongingSong:(BYSong*)song;

@end
