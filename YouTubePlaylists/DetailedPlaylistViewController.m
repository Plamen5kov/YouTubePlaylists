//
//  DetailedPlaylistTableViewController.m
//  YouTubePlaylists
//
//  Created by Admin on 01/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "DetailedPlaylistViewController.h"
#import "YouTubeVideoModel.h"

@interface DetailedPlaylistViewController ()<NSURLConnectionDataDelegate>

@end

@implementation DetailedPlaylistViewController{
    NSArray* arr;
    NSMutableArray* videosInPlaylist;
}

static NSString* cellIdentifier = @"VideoDetailsTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arr = @[@"first video", @"second video", @"third video"];
    
    //register the cell we are going to reload
    UINib* nib = [UINib nibWithNibName:cellIdentifier bundle:nil]; // take the nib
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier]; // register the nib so we can reuse it (tell the table view ... you are gong to use this cell when someone dequeues)
    
    NSString* playlistId = @"PLhBgTdAWkxeCMHYCQ0uuLyhydRJGDRNo5";
    
    // For a full list of player parameters, see the documentation for the HTML5 player
    // at: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
    NSDictionary *playerVars = @{
                                 @"controls" : @0,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @0,
                                 @"modestbranding" : @1
                                 };
    self.playerView.delegate = self;
    
    [self.playerView loadWithPlaylistId:playlistId playerVars:playerVars];
    
    NSString *link = @"https://www.googleapis.com/youtube/v3/playlistItems?part=id%2Csnippet%2CcontentDetails%2Cstatus&playlistId=PL6rfhdR2eI_Mmc1sb4uFtWND_mm_-Na22";
    
    NSLog(@"%@", link);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
    
     NSString *authToken = @"Bearer ya29.uAD3ajMa86NPEAmS_Ghf0dStXzeTXZQ0CfkBlZaEU7U0apDx6uGRWN1KCRwVMx11CXT9C9gTurIyfw";
    [request setValue:authToken forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    [self.tableView reloadData];
}

-(void)connection:(NSURLRequest *) request didReceiveData:(NSData *)data{
    
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error: nil];
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
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"RECIEVED ERROR IS: %@", error);
}


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
    
    NSString *imageUrl = [videosInPlaylist[indexPath.row] vThumbnailURL];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        cell.thumbnailImageView.image = [UIImage imageWithData:data];
    }];
    
    
    
    return cell;
}

@end
