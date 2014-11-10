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

    @property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;
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
    
//    [self setUpBackground];
    
    [self appendLongPressGesture];
    
    [self registerReusableCell];
    
    [self makePlaylistItemsRequest];
    
    [self.tableView reloadData];
    
    [self attachGestureListener];
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

//-(void)cellSwipe:(UISwipeGestureRecognizer *)gesture
//{
//    CGPoint location = [gesture locationInView:self.tableView];
//
//    NSLog(@"%f", location.x);
//    NSLog(@"%f", location.y);
////    CGPoint location = [gesture locationInView:self.tableView];
////    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:location];
////    UITableViewCell *swipedCell  = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
////    
////    //Your own code...
//}

- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [videosInPlaylist removeObjectAtIndex:indexPath.row];
//    }
        [videosInPlaylist removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

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

-(void) setUpBackground{
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"apple.jpg"]];
    [self.tableView setAlpha:0.5];
}

-(void) appendLongPressGesture {
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:self.longPressGesture];
}


- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [videosInPlaylist exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}

-(void) attachGestureListener {
    UISwipeGestureRecognizer *showExtrasSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipe:)];
    showExtrasSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:showExtrasSwipe];
}

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
