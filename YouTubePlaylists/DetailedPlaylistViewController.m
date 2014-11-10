//
//  DetailedPlaylistTableViewController.m
//  YouTubePlaylists
//
//  Created by Admin on 01/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "DetailedPlaylistViewController.h"
#import "YouTubeVideoModel.h"
#import "GoogleRegisteredUserModel.h"
#import "AppDelegate.h"
#import "CoreDataContainer.h"

@interface DetailedPlaylistViewController ()<NSURLConnectionDelegate>
    @property (strong, nonatomic) NSMutableData* receivedData;
    @property (strong, nonatomic) NSURLConnection *conn;
@end

@implementation DetailedPlaylistViewController{
    NSArray* arr;
    NSMutableArray* videosInPlaylist;
    AppDelegate* appDel;
}

static NSString* cellIdentifier = @"VideoDetailsTableViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel loadSpinnerWithContext:self];
    
    [self registerReusableCell];
    
    [self makePlaylistItemsRequest];
    
    [self.tableView reloadData];
}

#pragma mark playlist requests

-(void) makePlaylistItemsRequest{
    NSMutableString* authToken = [NSMutableString stringWithString:@"Bearer "];
    [authToken appendString: self.playlistInfo.authTokenCurrent];
    NSString *playlitId = self.playlistInfo.playlistId;
    
    [self loadDataWithUser:authToken andPlaylistId:playlitId];
}


-(void)loadDataWithUser: (NSMutableString *) authToken andPlaylistId:(NSString *)playlistId{
   
    self.playerView.delegate = self;
    
    NSDictionary *playerVars = @{
                                 @"controls" : @2,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @1,
                                 @"modestbranding" : @1
                                 };
    [self.playerView loadWithPlaylistId:playlistId playerVars:playerVars];
    
    NSMutableString *link = [NSMutableString stringWithString:@"https://www.googleapis.com/youtube/v3/playlistItems?part=id%2Csnippet%2CcontentDetails%2Cstatus&maxResults=50&playlistId="];
    [link appendString:playlistId];
    
    //make request for passed playlist
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
    
    [request setValue:authToken forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedData = [NSMutableData dataWithCapacity: 0];

}

#pragma mark NSConnection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
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
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError* error = nil;
    
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSUTF8StringEncoding error: &error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON. %@", error);
    }
    else {
        NSLog(@"Array: %@", jsonDict);
    }
    
    //get songs from playlist
    NSArray* vTitles = [jsonDict  valueForKeyPath:@"items.snippet.title"];
    NSArray* vIds = [jsonDict  valueForKeyPath:@"items.contentDetails.videoId"];
    NSArray* vThumbnailURLs = [jsonDict  valueForKeyPath:@"items.snippet.thumbnails.default.url"];

    videosInPlaylist = [[NSMutableArray alloc]init];
    
    for (int i=0; i< vTitles.count; i++) {
        YouTubeVideoModel *video = [[YouTubeVideoModel alloc]init];
        
        video.vTitle = [vTitles objectAtIndex:i];
        video.vId = [vIds objectAtIndex:i];
        video.vThumbnailURL = [vThumbnailURLs objectAtIndex:i];
        
        [videosInPlaylist addObject:video];
    }
    
    [appDel.spinner stopAnimating];
    [self.tableView reloadData];
    
    self.conn = nil;
    self.receivedData = nil;
}

#pragma mark TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return videosInPlaylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier]; //use registered cell
    
    cell.videoTitle.text = [videosInPlaylist[indexPath.row] vTitle];
    cell.videoTitle.numberOfLines = 2;
    cell.videoId.text = [videosInPlaylist[indexPath.row] vId];
    NSString *imageUrl = [videosInPlaylist[indexPath.row] vThumbnailURL];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]]
                                                                    queue:[NSOperationQueue mainQueue]
                                                        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                            
                                                            cell.thumbnailImageView.image = [UIImage imageWithData:data];
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoDetailsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.playerView loadWithVideoId:cell.videoId.text];
}

#pragma mark Helper methods

-(NSString *) loadSelectedPlaylistId{
    NSString* selectedPlaylistId;
    NSFetchRequest *request;
    @try {
        request = [NSFetchRequest fetchRequestWithEntityName:@"CoreDataContainer"];
        NSMutableArray *resultArray = [NSMutableArray arrayWithArray:[appDel.coreDataHelper.context executeFetchRequest:request error:nil]];
        CoreDataContainer* songObject = [resultArray objectAtIndex:0];
        NSString* playlistId = songObject.ytPlaylistId;
        NSLog(@"DATA: %@", playlistId);
        selectedPlaylistId = playlistId;
    }
    @catch (NSException *exception) {
        NSLog(@"data loading failed");
    }
    @finally {
        request = nil;
    }
    return selectedPlaylistId;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(motion == UIEventSubtypeMotionShake)
    {
        if(appDel.audioController.isPlaying == YES){
            [appDel.backgroundMusic stop];
        } else{
            [appDel.backgroundMusic play];
        }
        appDel.audioController.isPlaying = !appDel.audioController.isPlaying;
    }
}

-(void) registerReusableCell {
    //register the cell we are going to reload
    UINib* nib = [UINib nibWithNibName:cellIdentifier bundle:nil]; // take the nib
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier]; // register the nib so we can reuse it (tell the table view ... you are gong to use this cell when someone dequeues)
}

@end
