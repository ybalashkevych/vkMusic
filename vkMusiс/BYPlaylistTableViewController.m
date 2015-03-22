//
//  BYPlaylistTableViewController.m
//  vkMusiс
//
//  Created by George on 12.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYPlaylistTableViewController.h"
#import "BYDataManager.h"
#import <TWTSideMenuViewController.h>
#import "BYPlaylist.h"
#import "BYSongsListTableViewController.h"

@interface BYPlaylistTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BYDataManager*                dataManager;
@property (strong, nonatomic) NSFetchedResultsController*   fetchResultController;

@end

@implementation BYPlaylistTableViewController

#pragma merk - View Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem* add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(actionAddNewPlaylist:)];
    
    NSMutableArray* items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    [items addObject:add];
    self.navigationItem.rightBarButtonItems = items;
    [self createPlaylistForCachedSongs];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}






#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.fetchResultController.fetchedObjects count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"PlaylistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSArray* playlists = self.fetchResultController.fetchedObjects;
    cell.textLabel.text = [[playlists objectAtIndex:indexPath.row] name];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [self deletePlaylistAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
}







#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}








#pragma mark - Actions

- (IBAction)actionEditTable:(UIBarButtonItem *)sender {
    
    BOOL isEditing = self.tableView.editing;
    
    if (isEditing) {
        
        [sender setTitle:@"Edit"];
        
    } else {
        
        [sender setTitle:@"Done"];
        
    }
    [self.tableView setEditing:(isEditing ^ 1) animated:YES];
    
}

- (IBAction)actionShowMenu:(UIBarButtonItem *)sender {
    
    UIApplication* app = [UIApplication sharedApplication];
    
    TWTSideMenuViewController* sideController = (TWTSideMenuViewController*)[app.windows[0] rootViewController];
    
    [sideController openMenuAnimated:YES completion:nil];
    
}

- (void)actionAddNewPlaylist:(UIBarButtonItem*)sender {
    
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"New Playlist"
                                                                message:@"Enter playlist name"
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction* save = [UIAlertAction actionWithTitle:@"Save"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action)
    {
        
        BYPlaylist* playlist = [NSEntityDescription insertNewObjectForEntityForName:@"BYPlaylist"
                                                             inManagedObjectContext:self.dataManager.managedObjectContext];
        
        NSError* error = nil;
        
        if (error) {
            
            NSLog(@"%@", [error localizedDescription]);
            
        } else {
            
            playlist.name = [[ac.textFields firstObject] text];
            [self.dataManager saveContext];

        }
        
        
        
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [ac addAction:save];
    [ac addAction:cancel];
    [self presentViewController:ac animated:YES completion:nil];
    
}






#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showPlaylistSongList"]) {
        
        UITableViewCell* cell = sender;
        NSInteger index = [[self.tableView indexPathForCell:cell] row];
        BYPlaylist* selectedPlaylist = [self.fetchResultController.fetchedObjects objectAtIndex:index];
        
        BYSongsListTableViewController* destVC = segue.destinationViewController;
        destVC.songs = [selectedPlaylist.songs allObjects];
        destVC.menu = BYMenuPlaylist;
        
    }
    
}






#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}







#pragma mark - Private Methods

- (void)deletePlaylistAtIndexPath:(NSIndexPath*)indexPath {
    
    BYPlaylist* playlist = [self.fetchResultController.fetchedObjects objectAtIndex:indexPath.row];
    NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
    [moc deleteObject:playlist];
    [self.dataManager saveContext];
    
}

- (void)createPlaylistForCachedSongs {
    
    NSEntityDescription* playlistEntity = [NSEntityDescription entityForName:@"BYPlaylist" inManagedObjectContext:self.dataManager.managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name LIKE 'Cached'"];
    [request setEntity:playlistEntity];
    [request setPredicate:predicate];
    
    NSManagedObjectContext* moc = self.dataManager.managedObjectContext;

    BYPlaylist* playlistCachedSongs = [[moc executeFetchRequest:request error:nil] firstObject];
    
    NSError* error = nil;
    NSEntityDescription* songEntity = [NSEntityDescription entityForName:@"BYSong" inManagedObjectContext:self.dataManager.managedObjectContext];
    
    NSPredicate* predicateForCached = [NSPredicate predicateWithFormat:@"isCached == YES"];
    [request setEntity:songEntity];
    [request setPredicate:predicateForCached];
    NSArray* cachedSongs = [moc executeFetchRequest:request error:&error];
    
    if (error) {
        
        NSLog(@"%@", [error localizedDescription]);
        
    } else if (!playlistCachedSongs && cachedSongs.count) {
        
        BYPlaylist* playlistCachedSongs = [NSEntityDescription insertNewObjectForEntityForName:@"BYPlaylist" inManagedObjectContext:moc];
                playlistCachedSongs.name = @"Cached";
                [playlistCachedSongs addSongs:[NSSet setWithArray:cachedSongs]];
        
    } else if (playlistCachedSongs && cachedSongs.count) {
        
        [playlistCachedSongs addSongs:[NSSet setWithArray:cachedSongs]];
        
    }
    
    [self.dataManager saveContext];
    
}







#pragma mark - Getters and Setters

- (BYDataManager*)dataManager {
    
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    
    return _dataManager;
}

- (NSFetchedResultsController*)fetchResultController {
    
    if (!_fetchResultController) {

        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"BYPlaylist"];
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
        _fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        NSError* error = nil;
        [_fetchResultController performFetch:&error];
        
        _fetchResultController.delegate = self;
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    }
    
    return _fetchResultController;
    
}


@end
























