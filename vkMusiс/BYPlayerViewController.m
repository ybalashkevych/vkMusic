//
//  BYPlayerViewController.m
//  vkMusiс
//
//  Created by George on 11.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYPlayerViewController.h"

@interface BYPlayerViewController ()

@property (strong, nonatomic) NSData*           songData;
@property (strong, nonatomic) NSOperationQueue* queue;

@end

@implementation BYPlayerViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[downloadSong start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionPlaySong:(id)sender {
//    NSBlockOperation* downloadSong = [NSBlockOperation blockOperationWithBlock:^{
//        self.songData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.song.urlString] options:NSDataReadingMappedAlways error:nil];
//
//    }];
//    [self.queue addOperation:downloadSong];
        [self.player play];
}

#pragma mark - Getters and Setters

- (AVPlayer*)player {
    if (!_player) {
        NSError* error = nil;
        _player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.song.urlString]];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    return _player;
}

- (NSOperationQueue*)queue {
    if (!_queue) {
        _queue = [NSOperationQueue currentQueue];
    }
    return _queue;
}


@end



















