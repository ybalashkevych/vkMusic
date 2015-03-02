//
//  BYPlayerViewController.m
//  vkMusiс
//
//  Created by George on 11.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//


#import "BYPlayerViewController.h"
#import "BYSongsListTableViewController.h"
#import "BYServerManager.h"
#import <UIImageView+AFNetworking.h>
#import "BYDataManager.h"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

static const float deltaChangeOfSeekingTime = 15.f;

@interface BYPlayerViewController () <NSURLSessionDelegate>

@property (strong, nonatomic) NSURL*                    fileURL;
@property (strong, nonatomic) id                        timeObserver;
@property (strong, nonatomic) BYServerManager*          serverManager;
@property (strong, nonatomic) NSDictionary*             parameters;
@property (strong, nonatomic) BYDataManager*            dataManager;
@property (strong, nonatomic) NSURLSessionDataTask*     downloadDataTask;
@property (strong, nonatomic) NSURLSessionDataTask*     downloadImageTask;
@property (strong, nonatomic) NSURLSession*             session;
@property (strong, nonatomic) NSOperationQueue*         queue;

@end

@implementation BYPlayerViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak BYPlayerViewController* weakSelf = self;
    
    CMTime time = CMTimeMakeWithSeconds(1.f, 10);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:time queue:nil usingBlock:^(CMTime time) {
        if (![weakSelf.currentTimeSlider isHighlighted]) {
            weakSelf.currentTimeSlider.value = CMTimeGetSeconds(time);
        }
        weakSelf.beginTimeLabel.text        = [weakSelf stringFromSeconds:weakSelf.currentTimeSlider.value];
        NSInteger secondsToEnd              = [weakSelf.currentSong.duration integerValue] - weakSelf.currentTimeSlider.value;
        weakSelf.endTimeLabel.text          = [weakSelf stringFromSeconds:secondsToEnd];
        
       // NSLog(@"%f", CMTimeGetSeconds(time));
       // NSLog(@"%d",[weakSelf.currentSong.duration integerValue]);
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)dealloc {

    [self resetSession];

    NSLog(@"dealloc");
}

#pragma mark - Private Methods

- (void)downloadInBackground {
    
    [self resetSession];
    
    __weak BYPlayerViewController* weakSelf = self;
    NSBlockOperation* blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",weakSelf.currentSong.audio_id];
        NSString* path = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            NSURL* url = [NSURL URLWithString:self.currentSong.urlString];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            
            weakSelf.downloadDataTask = [weakSelf.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"%@", [error localizedDescription]);
                    
                } else {
                    [data writeToFile:path atomically:YES];
                }
            }];
            [weakSelf.downloadDataTask resume];
        }

    }];
    
    [blockOperation setQueuePriority:NSOperationQueuePriorityLow];
    [self.queue addOperation:blockOperation];
}

- (void)getContentAndCoverImage {
    [self.serverManager getContentAndCoverImageForSong:self.currentSong withParameters:self.parameters onSuccess:^{
        [self downloadAndSetCoverImage];
    } andFailure:nil];
}

- (BYSong*)setNextSong {
    NSUInteger index = [self.songs indexOfObject:self.currentSong];
    index++;
    if ([self.songs count] > index) {
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
    
    self.parameters = nil;
    [self getContentAndCoverImage];
    self.currentTimeSlider.maximumValue = [self.currentSong.duration floatValue];
    self.currentTimeSlider.value        = 0.f;
    [self downloadInBackground];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [self.titleButton setTitle:[NSString stringWithFormat:@"%@ - %@", self.currentSong.artist, self.currentSong.title] forState:UIControlStateNormal];
}

- (void)configurePlayer {
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.fileURL]];
}

- (NSString*)stringFromSeconds:(NSUInteger)seconds {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSString* time = [formatter stringFromDate:date];
    return time;
}

- (void)seekToTime:(CGFloat)time {
    
    CMTime curTime = self.player.currentTime;
    CGFloat neededTime = time + CMTimeGetSeconds(curTime);
    [self.player seekToTime:CMTimeMakeWithSeconds(neededTime, 10)];
}

- (void)downloadAndSetCoverImage {

    NSString* fileName = [NSString stringWithFormat:@"%@.png",self.currentSong.audio_id];
    NSString* path = [DOCUMENTS stringByAppendingPathComponent:fileName];
    NSURL* url = [NSURL URLWithString:self.currentSong.imagePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path] && url) {
        
        NSData* imageData = [NSData dataWithContentsOfURL:url];
        [imageData writeToFile:path atomically:YES];
        self.backgroundImageView.image = [UIImage imageWithData:imageData];
        
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:path] && url) {
        
        [self.backgroundImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:path]]];

    } else {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"bg"]];
        
    }
    
   }

- (void)resetSession {
    
    [self.downloadDataTask cancel];
    self.downloadDataTask = nil;
    self.session.configuration.URLCache = nil;
    self.session = nil;
}

#pragma mark - Actions

- (void)actionPlaySong:(UIButton*)sender {
    
    UIImage* playImage      = [UIImage imageNamed:@"play"];
    UIImage* pauseImage     = [UIImage imageNamed:@"pause"];
    
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

- (IBAction)actionChangeCurrentTime:(UISlider *)sender {
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value, 10)];

}

- (IBAction)actionMoveAndReturn:(UIButton *)sender {
    
    if ([sender isEqual:self.returnButton]) {
        [self seekToTime:-deltaChangeOfSeekingTime];
        
    } else if ([sender isEqual:self.moveButton]) {
        [self seekToTime:deltaChangeOfSeekingTime];
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

- (NSURL*)fileURL {
    
    if (!_fileURL) {

        NSString* fileName = [NSString stringWithFormat:@"%@.mp3",self.currentSong.audio_id];
        NSString* filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            _fileURL = [NSURL fileURLWithPath:filePath];
        }
        
        else {
            _fileURL = [NSURL URLWithString:self.currentSong.urlString];
        }
    }
    return _fileURL;
    
}


- (BYServerManager*)serverManager {
    if (!_serverManager) {
        _serverManager = [[BYServerManager alloc] init];
        _serverManager.baseURL = [NSURL URLWithString:@"http://ws.audioscrobbler.com/2.0/"];
    }
    return _serverManager;
}

- (NSDictionary*)parameters {
    if (!_parameters) {
        _parameters = @{@"method":@"track.getInfo",
                        @"api_key":@"c681c1f8fcace0d8a742a178848ddcab",
                        @"format":@"json",
                        @"artist":self.currentSong.artist,
                        @"track":self.currentSong.title};
    }
    return _parameters;
}

- (BYDataManager*)dataManager {
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
}


- (NSURLSession*)session {
    if (!_session) {
        
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

- (NSOperationQueue*)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

@end











