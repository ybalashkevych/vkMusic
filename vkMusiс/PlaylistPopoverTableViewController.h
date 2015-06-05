//
//  BYPlaylistPopoverTableViewController.h
//  vkMusiс
//
//  Created by George on 14.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Song;

@interface PlaylistPopoverTableViewController : UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style andBelongingSong:(Song*)song;

@end
