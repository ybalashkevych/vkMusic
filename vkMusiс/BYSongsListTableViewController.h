//
//  BYSongsListTableViewController.h
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYUtils.h"

@interface BYSongsListTableViewController : UITableViewController

@property (strong, nonatomic) NSPredicate*  predicate;
@property (assign, nonatomic) BYMenu        menu;
@property (strong, nonatomic) NSArray*      songs;


- (IBAction)actionShowMenu:(UIBarButtonItem*)sender;

@end
