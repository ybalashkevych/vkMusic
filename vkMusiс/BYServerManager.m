//
//  BYServerManager.m
//  vkMusiс
//
//  Created by George on 09.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYServerManager.h"
#import "BYLoginViewController.h"
#import "BYSong.h"

@interface BYServerManager()

@property (strong, nonatomic) NSURL*                        baseURL;
@property (strong, nonatomic) NSFetchedResultsController*   fetchResultsController;

@end

@implementation BYServerManager

#pragma mark - Singleton

+ (BYServerManager*)sharedManager {
    static BYServerManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BYServerManager alloc] init];
    });
    return manager;
}

#pragma mark - API

- (void)getSongsWithParameters:(NSDictionary *)params onSuccess:(void (^)())success andFailure:(void (^)(NSError *error))failure {
    
    [self.requestManager GET:@"audio.get" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",[responseObject objectForKey:@"response"]);
        
        NSArray* items = [[responseObject objectForKey:@"response"] objectForKey:@"items"];
        
        NSEntityDescription* songEntity = [NSEntityDescription entityForName:@"BYSong" inManagedObjectContext:self.dataManager.managedObjectContext];
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:songEntity];
        NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        [request setSortDescriptors:@[nameDescriptor]];
        NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
                
        for (NSDictionary* item in items) {
            
    
            BYSong* song = [[BYSong alloc] initWithEntity:songEntity insertIntoManagedObjectContext:self.dataManager.managedObjectContext];
            
            song.title      = [item objectForKey:@"title"];
            song.artist     = [item objectForKey:@"artist"];
            song.urlString  = [item objectForKey:@"url"];
            song.audio_id   = [item objectForKey:@"id"];
            song.owner_id   = [item objectForKey:@"owner_id"];
            song.lyrics_id  = [item objectForKey:@"lyrics_id"];
            song.duration   = [item objectForKey:@"duration"];
            song.genre_id   = [item objectForKey:@"genre_id"];
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"audio_id = %@",song.audio_id];
            [request setPredicate:predicate];
            NSArray* objects = [moc executeFetchRequest:request error:nil];
            
            NSLog(@"%@",objects);
            
            if ([objects count] > 1) {
                [moc deleteObject:song];
            }
        }
        
        NSError* error = nil;
        
        [self.dataManager.managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        if (success) {
            success();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Authorization

- (void)authorizeWithCompletionBlock:(void (^)())completion {
    
    BYLoginViewController* vc = [[BYLoginViewController alloc] initWithCompletionBlock:^(BYAccessToken *token) {

       self.token = token;
        if (completion) {
            completion();
        }
        
    }];

    UINavigationController* navC = [[UINavigationController alloc] initWithRootViewController:vc];

    UIApplication* app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];
    UIViewController* mainVC = [[windows firstObject] rootViewController];
    [mainVC presentViewController:navC animated:NO completion:nil];
    
}

#pragma mark - Getters and Setters

- (BYAccessToken*)token {
    if (!_token) {
        NSData* encodedToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
        if (encodedToken) {
            _token = [NSKeyedUnarchiver unarchiveObjectWithData:encodedToken];
            NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];
            NSDate* expirationDate = _token.expirationDate;
            
            if ([now compare:expirationDate] == NSOrderedDescending) {
                _token = nil;
            }
        }
    }
    return _token;
}

- (AFHTTPRequestOperationManager*)requestManager {
    
    if (!_requestManager) {
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
    }
    
    return _requestManager;

}

- (NSURL*)baseURL {
    if (!_baseURL) {
        _baseURL = [NSURL URLWithString:@"https://api.vk.com/method/"];
    }
    return _baseURL;
}

- (AFURLSessionManager*)sessionManager {
    
    if (!_sessionManager) {
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _sessionManager;
    
}

- (BYDataManager*)dataManager {
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
}

@end











