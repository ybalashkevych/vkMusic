//
//  BYSongsListTableViewController.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYSongsListTableViewController.h"
#import "BYServerManager.h"

@interface BYSongsListTableViewController ()

@property (strong, nonatomic) NSArray*          songs;
@property (strong, nonatomic) BYServerManager*  serverManager;

@end

@implementation BYSongsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.serverManager authorize];
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
    if (cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}


#pragma mark - Getters and Setters

- (BYServerManager*)serverManager {
    if (!_serverManager) {
        _serverManager = [BYServerManager sharedManager];
    }
    return _serverManager;
}



@end





















