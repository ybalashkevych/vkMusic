//
//  BYAudioPlayerController.m
//  vkMusiс
//
//  Created by Yuri Balashkevych on 08.05.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFURLSessionManager.h>
#import "AudioPlayerController.h"
#import "TrackLineSlider.h"
#import "ServerManager.h"

@interface AudioPlayerController ()

@property (assign, nonatomic, getter=isWifiReachable) BOOL wifiReachable;;

@property (strong, nonatomic) AFHTTPRequestOperation    *operation;
@property (strong, nonatomic) AVAudioPlayer             *audioPlayer;
@property (strong, nonatomic) ServerManager             *serverManager;
@property (strong, nonatomic) NSString                  *filePath;
@property (strong, nonatomic) NSNumber                  *progress;
@property (strong, nonatomic) NSTimer                   *timer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTitleOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTitleOffset;
@property (weak, nonatomic) IBOutlet TrackLineSlider    *trackSlider;
@property (weak, nonatomic) IBOutlet UIImageView        *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton           *playBackButton;
@property (weak, nonatomic) IBOutlet UIButton           *playForwardButton;
@property (weak, nonatomic) IBOutlet UILabel            *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel            *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel            *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel            *lastTimeLabel;
@property (weak, nonatomic) IBOutlet UIView             *progressView;


@end

@implementation AudioPlayerController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self configurePlaying];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self invalidateOperation];
    [self killTimer];
    
    [self removeObserver:self forKeyPath:@"progress"];
}

- (void)viewDidLayoutSubviews {
    
        [self configureLabels];
}

- (void)dealloc {
        
    NSLog(@"Dealocated");
}









#pragma mark - Downloading

- (void)downloadPlayingSong {
        
    if ([self playingSongExist]) {
        self.progress = @(1);
        return;
    }
    
    AudioPlayerController* __weak weakSelf = self;
    
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Finished o download to");
        
        weakSelf.progress = @(1);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@",[error localizedDescription]);
        }
        
    }];
    
    [self.operation start];
}








#pragma mark - Audio Player Playback

- (void)play {
    
    if (!self.operation) {
        [self.audioPlayer play];
        
        self.progress = @(1);
    }
    else {
        
        AudioPlayerController* __weak weakSelf = self;
        
        [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
            CGFloat totalPart = (float)totalBytesRead / totalBytesExpectedToRead;
            
            NSLog(@"Download = %f", totalPart);

            if (totalPart - weakSelf.progress.floatValue > 0.1) {
                weakSelf.progress = @(totalPart);
            }
            
        }];
    }
}

- (void)pause {
    
    [self.audioPlayer pause];
    
}

- (void)stop {
    
    [self.audioPlayer stop];
    
}

- (void)next {
    
    if ([self canPlayNext]) {
        
        NSInteger index = [self.songs indexOfObject:self.playingSong];
        self.playingSong = [self.songs objectAtIndex:index + 1];
        [self stop];
        [self configureNewSong];
        [self configurePlaying];
        
    }
    [self canPlayPrevious];
}

- (void)previous {
    
    if ([self canPlayPrevious]) {
        
        NSInteger index = [self.songs indexOfObject:self.playingSong];
        self.playingSong = [self.songs objectAtIndex:index - 1];
        [self stop];
        [self configureNewSong];
        [self configurePlaying];
        
    }
    [self canPlayNext];
}

- (BOOL)canPlayNext {
    
    if ([self.playingSong isEqual:[self.songs lastObject]]) {
        self.playForwardButton.enabled = NO;
        return NO;
    } else {
        self.playForwardButton.enabled = YES;
        return YES;
    }
    
}

- (BOOL)canPlayPrevious {
    
    if ([self.playingSong isEqual:[self.songs firstObject]]) {
        self.playBackButton.enabled = NO;
        return NO;
    } else  {
        self.playBackButton.enabled = YES;
        return YES;
    }
    
}








#pragma mark - Synchronization currentTime

- (void)updateTrackSlider {
    
    CGFloat currentTime = self.audioPlayer.currentTime;
    self.trackSlider.value = currentTime;
    [self configureTimeLabels];

}

- (void)updateProgressView:(CGFloat)percentage {
    
    CGRect trackRect = [self.trackSlider trackRectForBounds:self.trackSlider.bounds];
    
    CGFloat widthConst = CGRectGetWidth(trackRect)*percentage;
    
    self.widthProgressView.constant = widthConst;
    
    [UIView animateWithDuration:1.f animations:^{
        
        [self.progressView layoutIfNeeded];
        
    }];
    
    self.trackSlider.progress = percentage;
    
    if ((int)percentage == 1) {
        [UIView animateWithDuration:0.01f animations:^{
            self.progressView.alpha = 0;
        }];
    }
}








#pragma mark - Actions

- (IBAction)actionTrackSliderValueChange:(UISlider*)sender {
    
    self.audioPlayer.currentTime = sender.value;
}

- (IBAction)actionPauseOrPlay:(UIButton*)sender {
    
    UIImage *playImage   = [UIImage imageNamed:@"play"];
    UIImage *pauseImage  = [UIImage imageNamed:@"pause"];
    
    if ([[sender backgroundImageForState:UIControlStateNormal] isEqual:pauseImage]) {
        
        [sender setBackgroundImage:playImage forState:UIControlStateNormal];
        [self.audioPlayer pause];
        
    } else {
        
        [sender setBackgroundImage:pauseImage forState:UIControlStateNormal];
        [self.audioPlayer play];
    }
}

- (IBAction)actionPlayNextSong:(UIButton*)sender {
    
    [self next];
    
}

- (IBAction)actionPlayPreviousSong:(UIButton*)sender {
    
    [self previous];
    
}








#pragma mark - Playing Configuration

- (void)configureNewSong {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self killTimer];
        [self invalidateOperation];
        self.audioPlayer    = nil;
        self.filePath       = nil;
    });
}

- (void)configureTrackSlider {
    
    self.progressView.alpha             = 0.6;
    self.widthProgressView.constant     = 0;
    self.trackSlider.maximumValue       = [self.playingSong.duration floatValue];
    self.trackSlider.value              = 0;
    
    [self.view layoutIfNeeded];
    
}

- (void)configurePlaying {
    
    if (![self isWifiReachable] && ![self playingSongExist]) {
        [self next];
    }
    
    [self setCoverImage];
    [self configureTrackSlider];
    [self downloadPlayingSong];
    [self play];
    [self startTimer];
}

- (void)invalidateOperation {
    
    if ([self.operation isExecuting]) {
        
        [self.operation pause];
        [self.operation cancel];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileManager removeItemAtPath:self.filePath error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    self.operation = nil;
    
}








#pragma mark - UIView Configuration

- (void)configureRollString {
    
    self.titleLabel.text = self.playingSong.title;
    
    self.rightTitleOffset.constant = 16;
        self.leftTitleOffset.priority = UILayoutPriorityFittingSizeLevel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIView animateWithDuration:2
                              delay:2
                            options:(UIViewAnimationOptionCurveLinear|
                                     UIViewAnimationOptionAllowUserInteraction|
                                     UIViewAnimationOptionBeginFromCurrentState|
                                     UIViewAnimationOptionRepeat|
                                     UIViewAnimationOptionAutoreverse)
                         animations:^{
                             
                             [self.titleLabel layoutIfNeeded];
                             
                         } completion:nil];
    });
}

- (void)configureArtistLabel {
    
    self.artistLabel.text = self.playingSong.artist;
    
}

- (void)configureTimeLabels{
    
    NSInteger currentTime   = self.audioPlayer.currentTime;
    NSInteger lastTime      = [self.playingSong.duration integerValue] - currentTime;
    
    NSString *currentTimeStr = [self stringFromSeconds:currentTime];
    NSString *lastTimeStr    = [self stringFromSeconds:lastTime];
    
    self.currentTimeLabel.text = currentTimeStr;
    self.lastTimeLabel.text = lastTimeStr;
}

- (void)configureLabels {
    
    [self configureRollString];
    [self configureArtistLabel];
    [self configureNavigationTitle];
    
}

- (NSString*)stringFromSeconds:(NSUInteger)seconds {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSString* time = [formatter stringFromDate:date];
    return time;
    
}

- (void)configureNavigationTitle {
    
    NSInteger indexOfPlayingSong = [self.songs indexOfObject:self.playingSong];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", (long)indexOfPlayingSong, (long)self.songs.count];
    
}









#pragma mark - Getting Cover Image

- (void)setCoverImage {
    
    NSURL *fileURL = [NSURL URLWithString:self.filePath];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL
                                            options:nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"commonMetadata", nil];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                           withKey:AVMetadataCommonKeyArtwork
                                                          keySpace:AVMetadataKeySpaceCommon];
        
        if (artworks.count) {
            AVMetadataItem *metadataItem = [artworks firstObject];
            
            if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                
                NSDictionary *d = [metadataItem.value copyWithZone:nil];
                [self.coverImageView setImage:[UIImage imageWithData:[d objectForKey:@"data"]]];
                
            } else if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                
                [self.coverImageView setImage:[UIImage imageWithData:[metadataItem.value copyWithZone:nil]]];
            }
        } else {
            
            [self getContentAndCoverImage];
            
        }
    }];
}

- (void)getContentAndCoverImage {
    
    NSDictionary *parameters = @{@"method":@"track.getInfo",
                                @"api_key":@"c681c1f8fcace0d8a742a178848ddcab",
                                 @"format":@"json",
                                 @"artist":self.playingSong.artist,
                                  @"track":self.playingSong.title};
    
    AudioPlayerController __weak *weakSelf = self;
    
    [self.serverManager getContentAndCoverImageForSong:self.playingSong withParameters:parameters onSuccess:^(NSString *imagePath) {
        
        UIImage *placeholder = [UIImage imageNamed:@"emptyCover"];
        NSURL *imageURL = [NSURL URLWithString:imagePath];
        [weakSelf.coverImageView setImageWithURL:imageURL placeholderImage:placeholder];
        
    } andFailure:nil];
    
}









#pragma mark - Timer 

- (void)startTimer {
    
    [self.timer isValid];
}

- (void)killTimer {
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
}









#pragma mark - Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"progress"]) {
        
        [self updateProgressView:self.progress.floatValue];
        
        if (self.progress.floatValue > 0.1) {
            if (![self.audioPlayer isPlaying]) {
                [self.audioPlayer play];
            }
        }
        if ((int)self.progress.floatValue == 1) {
            _progress = @(0);
        }
    }
}









#pragma mark - File Manager

- (BOOL)playingSongExist {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager fileExistsAtPath:self.filePath];
    
}









#pragma mark - Getters and Setters

- (AVAudioPlayer*)audioPlayer {
    
    if (!_audioPlayer) {
        
        NSError* error = nil;
        NSURL *fileURL = [NSURL URLWithString:self.filePath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    return _audioPlayer;
}

- (AFHTTPRequestOperation*)operation {
    
    if (!_operation) {
        
        if ([self playingSongExist]) {
            return nil;
        }
        
        NSURL *url = [NSURL URLWithString:self.playingSong.urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        _operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        _operation.outputStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [_operation setCompletionQueue:queue];
    }
    
    return _operation;
    
}

- (NSString*)filePath {
    
    if (!_filePath) {
        
        NSString *fileName = [NSString stringWithFormat:@"%@.mp3", self.playingSong.audio_id];
        _filePath = [DOCUMENTS stringByAppendingPathComponent:fileName];
        
    }
    return _filePath;
}

- (NSTimer*)timer {
    
    if (!_timer) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTrackSlider) userInfo:nil repeats:YES];
    }
    
    return _timer;
}

- (ServerManager*)serverManager {
    
    if (!_serverManager) {
        
        _serverManager = [[ServerManager alloc] init];
        _serverManager.baseURL = [NSURL URLWithString:@"http://ws.audioscrobbler.com/2.0/"];
        
    }
    return _serverManager;
    
}

- (BOOL)isWifiReachable {
    
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (NULL, (__bridge CFURLRef)[NSURL URLWithString:@"www.vk.com"]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        NSLog (@"Connection is Available");
        return YES;
    }
    else
    {
        NSLog (@"Connection is down");
        return NO;
    }
    
}


@end















