//
//  BYPlayerViewController.m
//  vkMusiс
//
//  Created by George on 11.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//


#import "BYPlayerViewController.h"

#import "BYSongsListTableViewController.h"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]


@interface BYPlayerViewController ()

@property (strong, nonatomic) NSOperationQueue* queue;
@property (strong, nonatomic) NSURL*            fileURL;

@end

@implementation BYPlayerViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self downloadInBackground];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [self.titleButton setTitle:[NSString stringWithFormat:@"%@ - %@", self.song.artist, self.song.title] forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.player = nil;
    [[self.queue.operations firstObject] setQueuePriority:NSOperationQueuePriorityVeryLow];
}

- (void)dealloc {
    [self.queue cancelAllOperations];
    NSLog(@"dealloc");
}

#pragma mark - Private Methods

- (void)downloadInBackground {
    
    NSBlockOperation* downloadSong = [NSBlockOperation blockOperationWithBlock:^{
        NSData* songData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.song.urlString] options:NSDataReadingMappedAlways error:nil];
        
        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",self.song.audio_id];
        NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        [songData writeToFile:filePath atomically:YES];
        
    }];
    [self.queue addOperation:downloadSong];
}

#pragma mark - Actions

- (void)actionPlaySong:(UIButton*)sender {
    
    UIImage* playImage      = [UIImage imageNamed:@"play.png"];
    UIImage* pauseImage     = [UIImage imageNamed:@"pause.png"];
    
    if ([[sender backgroundImageForState:UIControlStateNormal] isEqual:playImage]) {
        [sender setBackgroundImage:pauseImage forState:UIControlStateNormal];
        [self.player play];

    }
    else  {
        [sender setBackgroundImage:playImage forState:UIControlStateNormal];
        [self.player pause];
    }
    
}

- (IBAction)actionDissmissController:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters and Setters

- (AVPlayer*)player {
    if (!_player) {
        NSError* error = nil;
        _player = [[AVPlayer alloc] initWithURL:self.fileURL];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    return _player;
}

- (NSOperationQueue*)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSURL*)fileURL {
    
    if (!_fileURL) {
        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",self.song.audio_id];
        NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            _fileURL = [NSURL fileURLWithPath:filePath];
        }
        else {
            _fileURL = [NSURL URLWithString:self.song.urlString];
        }
    }
    return _fileURL;
    
}


@end



















