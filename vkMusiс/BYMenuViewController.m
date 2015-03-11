//
//  BYMenuViewController.m
//  vkMusiс
//
//  Created by George on 06.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYMenuViewController.h"
#import <TWTSideMenuViewController.h>
#import "BYSongsListTableViewController.h"
#import "BYPlaylistTableViewController.h"
#import "BYUtils.h"

@interface BYMenuViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) TWTSideMenuViewController* sideMenuViewController;

@end

@implementation BYMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 60 * 5) / 2.0f, self.view.frame.size.width, 60 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_IPhone" bundle:nil];
    UINavigationController* navC = nil;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isFavorite = TRUE"];
    
    if (indexPath.section == 0) {
        
        BYSongsListTableViewController* vc = nil;
        navC = [storyboard instantiateViewControllerWithIdentifier:@"BYStartNavigationController"];
        vc = (BYSongsListTableViewController*)[navC topViewController];
        vc.menu = BYMenuSongList;
        [self.sideMenuViewController setMainViewController:navC animated:YES closeMenu:YES];
        
    } else if (indexPath.section == 1) {
        
        BYSongsListTableViewController* vc = nil;
        navC   = [storyboard instantiateViewControllerWithIdentifier:@"BYStartNavigationController"];
        vc = (BYSongsListTableViewController*)[navC topViewController];
        ((BYSongsListTableViewController*) vc).predicate = predicate;
        vc.menu = BYMenuFavorites;
        [self.sideMenuViewController setMainViewController:navC animated:YES closeMenu:YES];
        
    } else if (indexPath.section == 2) {
        
//        navC   = [storyboard instantiateViewControllerWithIdentifier:@"BYStartNavigationController"];
//        vc = (BYPlaylistTableViewController*)[navC topViewController];
//        [self.sideMenuViewController setMainViewController:navC animated:YES closeMenu:YES];
//        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:24];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[@"Song List", @"Favorites", @"Playlists", @"Search", @"Settings"];
    NSArray *images = @[@"songListMenu", @"favMenu", @"playlistMenu", @"searchMenu", @"settingsMenu"];
    cell.textLabel.text = titles[indexPath.section];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.section]];
    
    return cell;
}




#pragma mark - Getters and Setters

- (TWTSideMenuViewController*)sideMenuViewController {
    
    if (!_sideMenuViewController) {
        
        UIApplication* app = [UIApplication sharedApplication];
        _sideMenuViewController = (TWTSideMenuViewController*)[app.windows[0] rootViewController];
    
    }
    
    return _sideMenuViewController;
}

@end






















