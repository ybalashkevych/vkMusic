//
//  BYSongsListTableViewController.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "SongsListTableViewController.h"
#import <TWTSideMenuViewController.h>
#import "AudioPlayerController.h"
#import "ServerManager.h"
#import "Playlist.h"
#import "Utils.h"
#import "Song.h"

@interface SongsListTableViewController ()

@property (strong, nonatomic) TWTSideMenuViewController*    menuController;
@property (strong, nonatomic) ServerManager*              serverManager;
@property (strong, nonatomic) DataManager*                dataManager;

@property (strong, nonatomic) NSMutableDictionary*          parameters;
@property (assign, nonatomic) NSUInteger                    countPackOfSongs;
@property (assign, nonatomic) NSUInteger                    offset;

@end

@implementation SongsListTableViewController

#pragma mark - View Cycle

- (void)loadView {
    
    [super loadView];
    
    if (!self.serverManager.token) {
        [self.serverManager authorizeWithCompletionBlock:^{
            [self getSongs];
        }];
    }
    else {
        [self getSongs];
    }

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem* rightBarButonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(actionEditSongList:)];
    self.navigationItem.rightBarButtonItem = rightBarButonItem;

    switch (self.menu) {
        case BYMenuSongList:
            self.navigationItem.title = @"Song List";
            break;
        case BYMenuFavorites:
            self.navigationItem.title = @"Favorites";
            break;
        case BYMenuPlaylist:
            self.navigationItem.title = @"Playlist list";
        default:
            break;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}






#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.songs count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    Song* song = [self.songs objectAtIndex:indexPath.row];
    cell.textLabel.text         = song.title;
    cell.detailTextLabel.text   = song.artist;
    
    if (indexPath.row == self.offset - 1) {

        [self.parameters setValue:@(self.offset) forKey:@"offset"];
        [self getSongs];
    }
    
    NSLog(@"%d", indexPath.row);
    NSLog(@"%d", self.offset);
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Song* song = [self.songs objectAtIndex:indexPath.row];
    
    if (self.menu == BYMenuFavorites) {
        
        BOOL isFavorite = NO;
        
        [song setIsFavorite:@(isFavorite)];
        self.songs = nil;
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
         
    } else if (self.menu == BYMenuSongList) {
        
        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",song.audio_id];
        NSString* filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError* error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
        
        NSDictionary* params = @{@"audio_id":song.audio_id,
                                 @"owner_id":song.owner_id,
                                 @"v":@"5.28",
                                 @"access_token":self.serverManager.token};
        
        [self deleteSongWithParameters:params];
        NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
        NSMutableArray* songs = [NSMutableArray arrayWithArray:self.songs];
        [songs removeObject:song];
        self.songs = songs;
        [moc deleteObject:song];
        [self.dataManager saveContext];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
    } else if (self.menu == BYMenuPlaylist) {
        
        NSEntityDescription* playlistEntity = [NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:self.dataManager.managedObjectContext];
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name LIKE 'Cached'"];
        [request setEntity:playlistEntity];
        [request setPredicate:predicate];
        
        NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
        
        Playlist* playlistCachedSongs = [[moc executeFetchRequest:request error:nil] firstObject];
        Song* deletingSong = [self.songs objectAtIndex:indexPath.row];
        [playlistCachedSongs removeSongsObject:deletingSong];
        deletingSong.isCached = NO;
        
        NSMutableArray* songs = [NSMutableArray arrayWithArray:self.songs];
        [songs removeObject:song];
        self.songs = songs;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",deletingSong.audio_id];
        NSString* filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError* error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
        
        [self.dataManager saveContext];
        
    }
    
}






#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (self.menu) {
        case BYMenuSongList:
            return UITableViewCellEditingStyleDelete;
            break;
        case BYMenuFavorites:
            return UITableViewCellEditingStyleDelete;
            break;
        default:
            return UITableViewCellEditingStyleDelete;
            break;
    }
    
}






#pragma mark - Actions

- (IBAction)actionShowMenu:(UIBarButtonItem *)sender {
    
    [self.menuController openMenuAnimated:YES completion:^(BOOL finished) {
        
    }];
    
}

- (void)actionEditSongList:(UIBarButtonItem*)sender {
    
    BOOL isEditing = self.tableView.isEditing;
    
    if (isEditing) {
        [sender setTitle:@"Edit"];
    } else {
        [sender setTitle:@"Done"];
    }
    
    switch (self.menu) {
        case BYMenuSongList:
            [self editStyleForSongList];
            break;
            
        case BYMenuFavorites:
            [self editStyleForFavorites];
            break;
            
        case BYMenuPlaylist:
            [self editStyleForPlaylist];
            
        default:
            
            [self editStyleForSongList];
            break;
    }

    [self.tableView setEditing:(isEditing ^ 1) animated:YES];

}






#pragma mark - Private Methods

- (void)getSongs {
    [self.serverManager getSongsWithParameters:self.parameters onSuccess:^() {
        
        [self rearrangeTable];
        self.offset+=self.countPackOfSongs;
    } andFailure:nil];
    
}

- (void)rearrangeTable {
    
    if (self.menu == BYMenuPlaylist) {
        return;
    }
    
    self.songs = nil;
    [self.tableView reloadData];
    
}

- (void)editStyleForFavorites {

    
    
}

- (void)editStyleForSongList {
    
    
    
}

- (void)editStyleForPlaylist {
    
    
    
}

- (void) deleteSongWithParameters:(NSDictionary*)params {
    //params: @"audio_id" : "", @"owner_if" : "" , @"v" : "5.29"
    [self.serverManager postDeleteSongWithParameters:params onSuccess:^{
    } andFailure:nil];
    
}







#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[AudioPlayerController class]]) {
        
        AudioPlayerController*vc = segue.destinationViewController;
        UITableViewCell* cell = sender;
        NSUInteger index = [[self.tableView indexPathForCell:cell] row];
        vc.playingSong = [self.songs objectAtIndex:index];
        vc.songs = self.songs;
        
    }
    
}







#pragma mark - Getters and Setters

- (ServerManager*)serverManager {
    
    if (!_serverManager) {
        
        _serverManager = [ServerManager sharedManager];
        
    }
    
    return _serverManager;
}

- (NSMutableDictionary*)parameters {
    
    if (!_parameters) {
        
        AccessToken* token = self.serverManager.token;
        _parameters = [NSMutableDictionary dictionaryWithDictionary:
                       @{@"owner_id":token.user_id,
                        @"offset":@(self.offset),
                        @"count":@(self.countPackOfSongs),
                        @"v":@"5.28",
                        @"access_token":token.token}];
        
    }
    
    return _parameters;
}


- (NSUInteger)offset {
    
    if (!_offset) {
        _offset = 0;
    }
    
    return _offset;
}

- (NSUInteger)countPackOfSongs {
    
    if (!_countPackOfSongs) {
        _countPackOfSongs = 200;
    }
    
    return _countPackOfSongs;
}

- (DataManager*)dataManager {
    
    if (!_dataManager) {
        _dataManager = [DataManager sharedManager];
    }
    
    return _dataManager;
}

- (NSArray*)songs {
    
    if (!_songs && self.menu != BYMenuPlaylist) {
        
        NSEntityDescription* songEntity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:self.dataManager.managedObjectContext];
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        
        [request setEntity:songEntity];
        
        [request setPredicate:self.predicate];
        
        NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifiedDate" ascending:YES];
        
        [request setSortDescriptors:@[nameDescriptor]];
        
        NSManagedObjectContext* moc = [self.dataManager managedObjectContext];
        
        self.songs = [moc executeFetchRequest:request error:nil];
    }
    
    return _songs;
}

- (TWTSideMenuViewController*)menuController {
    
    if (!_menuController) {
        
        UIApplication* app = [UIApplication sharedApplication];

        _menuController = (TWTSideMenuViewController*)[app.windows[0] rootViewController];
    
    }
    
    return _menuController;
}


@end


































