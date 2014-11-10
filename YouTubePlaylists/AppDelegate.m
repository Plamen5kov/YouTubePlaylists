//
//  AppDelegate.m
//  YouTubePlaylists
//
//  Created by Admin on 10/29/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "YouTubeSignInViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
//{
//
//    BackgroundMusicController* audioController;
//}

@synthesize navigation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationSupportsShakeToEdit = YES;
    [self playMusicInBackground];
    
    //accept notifications
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                                                       UIUserNotificationTypeAlert|
                                                       UIUserNotificationTypeBadge|
                                                       UIUserNotificationTypeSound
                                                                                        categories:nil]];
    }
    self.coreDataHelper = [[CoreDataHelper alloc] init];
    [self.coreDataHelper setupCoreData];
    
    return YES;
}

-(void) loadSpinnerWithContext: (UIViewController*) delegate {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake((delegate.view.frame.size.width / 2), (delegate.view.frame.size.height / 2));
    [delegate.view addSubview:self.spinner];
    [self.spinner startAnimating];
}

-(void) playMusicInBackground{
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        self.audioController = [[BackgroundMusicController alloc] init];
        _backgroundMusic = self.audioController.backgroundMusic;
        
        dispatch_queue_t queue = dispatch_queue_create("background.music.task", NULL);
        dispatch_async(queue, ^{
            _backgroundMusic.volume = 0.7;
            [_backgroundMusic play];
            self.audioController.isPlaying = YES;
        });
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
