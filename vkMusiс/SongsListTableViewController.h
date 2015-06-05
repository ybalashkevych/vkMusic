//
//  BYSongsListTableViewController.h
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

@interface SongsListTableViewController : UITableViewController

@property (strong, nonatomic) NSPredicate*  predicate;
@property (strong, nonatomic) NSArray*      songs;
@property (assign, nonatomic) BYMenu        menu;


- (IBAction)actionShowMenu:(UIBarButtonItem*)sender;

@end
