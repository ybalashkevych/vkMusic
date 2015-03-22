//
//  BYPlaylistPopoverTableViewController.m
//  vkMusiс
//
//  Created by George on 14.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYPlaylistPopoverTableViewController.h"
#import "BYDataManager.h"
#import "BYSong.h"
#import "BYPlaylist.h"

@interface BYPlaylistPopoverTableViewController ()

@property (strong, nonatomic) NSArray*          playlists;
@property (strong, nonatomic) BYDataManager*    dataManager;
@property (strong, nonatomic) BYSong*           belongingSong;


@end

@implementation BYPlaylistPopoverTableViewController

#pragma mark - Designated Initialzer

- (instancetype)initWithStyle:(UITableViewStyle)style andBelongingSong:(BYSong *)song {
    
    self = [super initWithStyle:style];
    
    if (self) {
        self.belongingSong = song;
    }
    
    return self;
}







#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}







#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"PlaylistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [[self.playlists objectAtIndex:indexPath.row] name];
    
    BYPlaylist* playlist = [self.playlists objectAtIndex:indexPath.row];
    
    if ([playlist.songs containsObject:self.belongingSong]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}







#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        [[self.playlists objectAtIndex:indexPath.row] removeSongsObject:self.belongingSong];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else {
        
        [[self.playlists objectAtIndex:indexPath.row] addSongsObject:self.belongingSong];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    
}







#pragma mark - Getters and Setters

- (NSArray*)playlists {
    
    if (!_playlists) {
        
        NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"BYPlaylist"];
        
        NSError* error = nil;
        _playlists = [moc executeFetchRequest:request error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    }
    
    return _playlists;
    
}

- (BYDataManager*)dataManager {
    
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
    
}



@end














