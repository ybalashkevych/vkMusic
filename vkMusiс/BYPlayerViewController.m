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
@property (strong, nonatomic) id                timeObserver;

@end

@implementation BYPlayerViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak BYPlayerViewController* weakSelf = self;
    
    CMTime time = CMTimeMakeWithSeconds(1.f, 10);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:time queue:nil usingBlock:^(CMTime time) {
        NSLog(@"%f", CMTimeGetSeconds(time));
        NSLog(@"%d",[weakSelf.currentSong.duration integerValue]);
        if (CMTimeGetSeconds(time) >= [weakSelf.currentSong.duration floatValue]) {
            [weakSelf setNextSong];
            [weakSelf configurePlayer];
            [weakSelf prepareToPlay];
            [weakSelf actionPlaySong:weakSelf.playButton];
        }
        
    }];
    [self prepareToPlay];
    [self actionPlaySong:self.playButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player removeTimeObserver:self.timeObserver];
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
        
        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",self.currentSong.audio_id];
        NSString* filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData* songData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentSong.urlString] options:NSDataReadingMappedAlways error:nil];
            [songData writeToFile:filePath atomically:YES];
        }
    }];
    [self.queue addOperation:downloadSong];
}

- (BYSong*)setNextSong {
    NSUInteger index = [self.songs indexOfObject:self.currentSong];
    index++;
    if ([self.songs count] > index - 1) {
        self.currentSong = [self.songs objectAtIndex:index];
        self.fileURL = nil;
    }
    return self.currentSong;
}

- (BYSong*)setPreviousSong {
    NSInteger index = [self.songs indexOfObject:self.currentSong];
    index--;
    if (index >= 0) {
        self.currentSong = [self.songs objectAtIndex:index];
        self.fileURL = nil;
    }
    return self.currentSong;
}

- (void)prepareToPlay {

    [self downloadInBackground];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [self.titleButton setTitle:[NSString stringWithFormat:@"%@ - %@", self.currentSong.artist, self.currentSong.title] forState:UIControlStateNormal];
}

- (void)configurePlayer {
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.fileURL]];
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

- (IBAction)actionPlayBackAndForward:(UIButton *)sender {
    
    if ([sender isEqual:self.playBackButton]) {
        [self setPreviousSong];
        [self configurePlayer];
        [self prepareToPlay];
        [self actionPlaySong:self.playButton];

    }
    else if ([sender isEqual:self.playForwardButton]) {
        [self setNextSong];
        [self configurePlayer];
        [self prepareToPlay];
        [self actionPlaySong:self.playButton];

    }
    
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
        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",self.currentSong.audio_id];
        NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            _fileURL = [NSURL fileURLWithPath:filePath];
        }
        else {
            _fileURL = [NSURL URLWithString:self.currentSong.urlString];
        }
    }
    return _fileURL;
    
}


@end



















