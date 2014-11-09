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
    
    //arr = @[@"first video", @"second video", @"third video"];
    
    //register the cell we are going to reload
    UINib* nib = [UINib nibWithNibName:cellIdentifier bundle:nil]; // take the nib
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier]; // register the nib so we can reuse it (tell the table view ... you are gong to use this cell when someone dequeues)
    
    NSMutableString* authToken = [NSMutableString stringWithString:@"Bearer "];
    [authToken appendString: self.playlistInfo.authTokenCurrent];
    NSString *playlitId = self.playlistInfo.playlistId;
    
    [self loadDataWithUser:authToken andPlaylistId:playlitId];
    
    [self.tableView reloadData];
}

-(void)loadDataWithUser: (NSMutableString *) authToken andPlaylistId:(NSString *)playlistId{
    //NSString* playlist = @"PL6rfhdR2eI_MfMTowRqaFlxZbTtU2iac4";
    
    // For a full list of player parameters, see the documentation for the HTML5 player
    // at: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
    NSDictionary *playerVars = @{
                                 @"controls" : @2,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @1,
                                 @"modestbranding" : @1
                                 };
    self.playerView.delegate = self;
    
    [self.playerView loadWithPlaylistId:playlistId playerVars:playerVars];
    
    NSMutableString *link = [NSMutableString stringWithString:@"https://www.googleapis.com/youtube/v3/playlistItems?part=id%2Csnippet%2CcontentDetails%2Cstatus&playlistId="];
    [link appendString:playlistId];

    
    NSLog(@"%@", link);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
    
    //NSString *authToken = @"Bearer ya29.uQBf9gsjY2nAlfNMTVwUICXolgOzrmDOtwu4ZcsuIOddoWN37zbL3U1C1KeZUC0QnO-PgxnfzliwdA";
    [request setValue:authToken forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedData = [NSMutableData dataWithCapacity: 0];

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
    NSError* error = nil;
    
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSUTF8StringEncoding error: &error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON. %@", error);
    }
    else {
        NSLog(@"Array: %@", jsonDict);
    }
    
    NSLog(@"%@", jsonDict);
    NSArray* vTitles = [jsonDict  valueForKeyPath:@"items.snippet.title"];
    NSArray* vIds = [jsonDict  valueForKeyPath:@"items.contentDetails.videoId"];
    NSArray* vThumbnailURLs = [jsonDict  valueForKeyPath:@"items.snippet.thumbnails.default.url"];
    
    NSLog(@"%@", vTitles);
    NSLog(@"%@", vIds);
    NSLog(@"%@", vThumbnailURLs);
    
    videosInPlaylist = [[NSMutableArray alloc]init];
    
    for (int i=0; i< vTitles.count; i++) {
        YouTubeVideoModel *video = [[YouTubeVideoModel alloc]init];
        
        video.vTitle = [vTitles objectAtIndex:i];
        video.vId = [vIds objectAtIndex:i];
        video.vThumbnailURL = [vThumbnailURLs objectAtIndex:i];
        
        //        NSLog(@"%@", video.videoTitle);
        //        NSLog(@"%@", video.videoId);
        //        NSLog(@"%@", video.thumbnailURL);
        
        [videosInPlaylist addObject:video];
    }
    
    [self.tableView reloadData];
    // whatever data structures you are using.
    self.conn = nil;
    self.receivedData = nil;

}
//
//-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//    NSLog(@"RECIEVED ERROR IS: %@", error);
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //return arr.count;
    return videosInPlaylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] objectAtIndex: 0];
    NSLog(@"#");
    NSLog(@"%@", [videosInPlaylist[indexPath.row] vTitle]);
   
    //cell.videoTitle.text = [[videosInPlaylist objectAtIndex:indexPath.row] vTitle];
    cell.videoTitle.text = [videosInPlaylist[indexPath.row] vTitle];
    cell.videoTitle.numberOfLines = 2;
    
    cell.videoId.text = [videosInPlaylist[indexPath.row] vId];
    
    NSString *imageUrl = [videosInPlaylist[indexPath.row] vThumbnailURL];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        cell.thumbnailImageView.image = [UIImage imageWithData:data];
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoDetailsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.videoId.text);
    [self.playerView loadWithVideoId:cell.videoId.text];
}

#pragma mark Helper methods

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

@end
