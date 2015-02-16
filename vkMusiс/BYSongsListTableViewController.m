//
//  BYSongsListTableViewController.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYSongsListTableViewController.h"
#import "BYServerManager.h"
#import "BYPlayerViewController.h"
#import "BYSong.h"

@interface BYSongsListTableViewController ()

@property (strong, nonatomic) NSArray*                      songs;
@property (strong, nonatomic) BYServerManager*              serverManager;
@property (strong, nonatomic) NSMutableDictionary*          parameters;
@property (assign, nonatomic) NSUInteger                    offset;
@property (assign, nonatomic) NSUInteger                    countPackOfSongs;
@property (strong, nonatomic) BYDataManager*                dataManager;

@end

@implementation BYSongsListTableViewController


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
    BYSong* song = [self.songs objectAtIndex:indexPath.row];
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


#pragma mark - Private Methods

- (void)getSongs {
    [self.serverManager getSongsWithParameters:self.parameters onSuccess:^() {
        [self rearrangeTable];
        self.offset+=self.countPackOfSongs;
    } andFailure:nil];
}

- (void)rearrangeTable {
    
    self.songs = nil;
    [self.tableView reloadData];
    
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[BYPlayerViewController class]]) {
        BYPlayerViewController*vc = segue.destinationViewController;
        UITableViewCell* cell = sender;
        NSUInteger index = [[self.tableView indexPathForCell:cell] row];
        vc.currentSong = [self.songs objectAtIndex:index];
        vc.songs = self.songs;
    }
}

#pragma mark - Getters and Setters

- (BYServerManager*)serverManager {
    if (!_serverManager) {
        _serverManager = [BYServerManager sharedManager];
    }
    return _serverManager;
}

- (NSMutableDictionary*)parameters {
    
    if (!_parameters) {
        BYAccessToken* token = self.serverManager.token;
        
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
        _countPackOfSongs = 20;
    }
    return _countPackOfSongs;
}

- (BYDataManager*)dataManager {
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
}

- (NSArray*)songs {
    if (!_songs) {
        NSEntityDescription* songEntity = [NSEntityDescription entityForName:@"BYSong" inManagedObjectContext:self.dataManager.managedObjectContext];
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:songEntity];
        NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modifiedDate" ascending:YES];
        [request setSortDescriptors:@[nameDescriptor]];
        NSManagedObjectContext* moc = [self.dataManager managedObjectContext];
        self.songs = [moc executeFetchRequest:request error:nil];
    }
    return _songs;
}

@end


































