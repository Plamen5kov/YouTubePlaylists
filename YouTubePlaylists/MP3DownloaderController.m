//
//  MP3Downloader.m
//  YouTubePlaylists
//
//  Created by Admin on 10/30/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "MP3DownloaderController.h"
#import <UIKit/UIKit.h>

@interface MP3DownloaderController()<NSURLConnectionDelegate>
    @property (strong, nonatomic) NSMutableData* receivedData;
    @property (strong, nonatomic) NSURLConnection *conn;
@end

@implementation MP3DownloaderController
    NSString *apiURL = @"http://youtubeinmp3.com/fetch/?video=https://www.youtube.com/watch?v=";

-(instancetype)init{
    if(self = [super init])
    {
        self.receivedData = [[NSMutableData alloc] init];
        self.receivedData = [NSMutableData dataWithCapacity: 0];
    }
    return self;
}

-(void)getMP3File:(NSString *)pathToFile{
    NSString *link = [NSString stringWithFormat:@"%@%@", apiURL, pathToFile];
    
    NSLog(@"%@", link);
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:link]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];
    
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(self.conn) {
        NSLog(@"Connection Successful");
    } else {
        self.receivedData = nil;
        NSLog(@"Connection could not be made");
    }
}

#pragma mark NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.conn = nil;
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];

    //use notification bar
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    //prepare to save
    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    NSError *error = nil;
    NSDate *timestamp = [NSDate date];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *ytplDirPath = [documentsDirectory stringByAppendingPathComponent:@"YTPL"];
    
    //if dir exists
    BOOL isDirExists = [self isDirectoryExists:ytplDirPath];
    NSLog(@"isDirExists: %hhd", isDirExists);
    
    if (!isDirExists) {
        NSLog(@"creating directory");
        [self createDirectory:ytplDirPath];
    }
    
    //create file in path
    NSString *fullPath = [ytplDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"song_%@.mp3", timestamp]]; // save song
    [self.receivedData writeToFile:fullPath options:NSDataWritingWithoutOverwriting error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    NSLog(@"%@", ytplDirPath); //where the song got saved (put in notification)
   
    [self scheduleNotificationWithDate:timestamp];
    
    self.conn = nil;
    self.receivedData = nil;
}

#pragma mark Directory methods

-(BOOL)isDirectoryExists: (NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    return isDir;
}

-(void)createDirectory:(NSString *) path{
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if (!success || error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    NSAssert(success, @"Failed to create folder at path:%@", path);
}

#pragma mark Helper methods 

- (void) scheduleNotificationWithDate: (NSDate*) date{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:3];
    localNotification.fireDate = date;//[NSDate dateWithTimeIntervalSinceNow:3];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"Downloaded song successfuly";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
