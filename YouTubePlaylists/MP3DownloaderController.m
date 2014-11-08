//
//  MP3Downloader.m
//  YouTubePlaylists
//
//  Created by Admin on 10/30/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "MP3DownloaderController.h"

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
//    
//    if(self.conn) {
//        NSLog(@"Connection Successful");
//    } else {
//        self.receivedData = nil;
//        NSLog(@"Connection could not be made");
//    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    // Release the connection and the data object
    // by setting the properties (declared elsewhere)
    // to nil.  Note that a real-world app usually
    // requires the delegate to manage more than one
    // connection at a time, so these lines would
    // typically be replaced by code to iterate through
    // whatever data structures you are using.
    self.conn = nil;
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    // do something with the data
    // receivedData is declared as a property elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    NSError *error = nil;
    NSDate *timestamp = [NSDate date];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *ytplDirPath = [documentsDirectory stringByAppendingPathComponent:@"YTPL"];
    
    NSLog(@"%@", ytplDirPath);
    
    BOOL isDirExists = [self isDirectoryExists:ytplDirPath];
    NSLog(@"isDirExists: %hhd", isDirExists);
    
    if (!isDirExists) {
        NSLog(@"creating directory");
        [self createDirectory:ytplDirPath];
    }
    
    NSString *fullPath = [ytplDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"song_%@.mp3", timestamp]]; //add our song
    
    [self.receivedData writeToFile:fullPath options:NSDataWritingWithoutOverwriting error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    // Release the connection and the data object
    // by setting the properties (declared elsewhere)
    // to nil.  Note that a real-world app usually
    // requires the delegate to manage more than one
    // connection at a time, so these lines would
    // typically be replaced by code to iterate through
    // whatever data structures you are using.
    self.conn = nil;
    self.receivedData = nil;
}

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

@end
