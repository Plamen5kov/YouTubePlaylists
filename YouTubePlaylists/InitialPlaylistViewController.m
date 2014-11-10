
//  ViewController.m
//  YouTubePlaylists
//
//  Created by Admin on 10/29/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "InitialPlaylistViewController.h"
#import "GoogleRegisteredUserModel.h"
#import "YouTubeSignInViewController.h"
#import "YouTubePlaylistModel.h"
#import "BackgroundMusicController.h"
#import <CoreMotion/CoreMotion.h>
#import "CoreDataHelper.h"
#import "CoreDataContainer.h"
#import "AppDelegate.h"
#import "DetailedPlaylistViewController.h"

@interface InitialPlaylistViewController ()<NSURLConnectionDataDelegate>
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end

@implementation InitialPlaylistViewController{
    NSString* cellSelector;
    NSMutableArray* playList;
    GoogleRegisteredUserModel* user;
//    UIActivityIndicatorView *spinner;
    AppDelegate* appDel;
    NSString* authenticationToken;
    NSMutableData *receivedData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cellSelector = @"PlaylistCell";
    receivedData = [[NSMutableData alloc]init];
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel loadSpinnerWithContext:self];
    [self appendLongPressGesture];
    [appDel.backgroundMusic play];
//    [self setUpMotionManager];
    
}

-(void) addCurrentPlaylistId: (NSString *) playlistId{
    CoreDataContainer *model= [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataContainer" inManagedObjectContext:appDel.coreDataHelper.context];
    model.ytPlaylistId = playlistId;
    [appDel.coreDataHelper saveContext];
}

#pragma mark core motion

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

//alternative to shake
//-(void) setUpMotionManager{
//
//    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
//    motionManager.deviceMotionUpdateInterval = 0.1/60.0;
//    
//    if (motionManager.deviceMotionAvailable ) {
//        id queue = [NSOperationQueue currentQueue];
//        [motionManager startDeviceMotionUpdatesToQueue:queue
//                                           withHandler:^ (CMDeviceMotion *motionData, NSError *error) {
//                                               CMAttitude *attitude = motionData.attitude;
//                                               CMAcceleration gravity = motionData.gravity;
//                                               CMAcceleration userAcceleration = motionData.userAcceleration;
//                                               CMRotationRate rotate = motionData.rotationRate;
//                                               CMCalibratedMagneticField field = motionData.magneticField;
//
//                                               if(audioController.isPlaying == YES){
//                                                   [_backgroundMusic stop];
//                                               } else{
//                                                   [_backgroundMusic play];
//                                               }
//                                               audioController.isPlaying = !audioController.isPlaying;
//                                           }];
//    }
//}

-(void) appendLongPressGesture {
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.subTableView addGestureRecognizer:self.longPressGesture];
}


- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.subTableView];
    NSIndexPath *indexPath = [self.subTableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.subTableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.subTableView addSubview:snapshot];
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
                [playList exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.subTableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.subTableView cellForRowAtIndexPath:sourceIndexPath];
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

#pragma mark - Helper methods

- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

-(void) loadDataWithUser: (GoogleRegisteredUserModel *) authenticatedUser{
    
    authenticationToken = authenticatedUser.accessToken;
    
    NSString* url = @"https://www.googleapis.com/youtube/v3/playlists?part=snippet&maxResults=50&mine=true&key=902472583724-ul05lna38kfh37v8mp18bli09s0b84ti.apps.googleusercontent.com";

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //request config
    NSMutableString* authToken = [NSMutableString stringWithString:@"Bearer "];
    [authToken appendString: authenticatedUser.accessToken];
    [request setValue:authToken forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDataDelegate protocol

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:receivedData options:NSUTF8StringEncoding error: nil];
    //    NSDictionary* playlistJsonObjects = [[[jsonDict objectForKey:@"items"] valueForKey:@"snippet"] valueForKey:@"title"];
    NSDictionary* playlistJsonObjects = [jsonDict objectForKey:@"items"];
    
    playList = [[NSMutableArray alloc] init];
    for (NSString *playlistItem in playlistJsonObjects) {
        
        NSString* currentTitle = [[playlistItem valueForKey:@"snippet"] valueForKey:@"title"];
        NSString* currentId = [playlistItem valueForKey:@"id"];
        
        YouTubePlaylistModel *list = [[YouTubePlaylistModel alloc] init];
        list.playlistTitle = currentTitle;
        list.playlistId = currentId;
        list.authTokenCurrent = authenticationToken;
        
        [playList addObject:list];
    }
    
    [appDel.spinner stopAnimating];
    [self.subTableView reloadData];

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"RECIEVED ERROR IS: %@", error);
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* selectedPlaylistId = ((YouTubePlaylistModel *)([playList objectAtIndex:indexPath.row])).playlistId;
    NSLog(@"SELECTED PLAYLIST ID: %@", selectedPlaylistId);
    [self addCurrentPlaylistId:selectedPlaylistId];
    
    //take detailsController from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:[NSBundle mainBundle]];
    DetailedPlaylistViewController* detailsController = [storyboard instantiateViewControllerWithIdentifier:@"detailsController"];
    
    //push property
    YouTubePlaylistModel* currentPlaylistInfo = [playList objectAtIndex: indexPath.row];
    detailsController.playlistInfo = currentPlaylistInfo;
    
    //take navigation controller from story board
    UINavigationController* detailsNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"detailsNavController"];
    
    //push details controller in navigation controller
    [detailsNavigationController pushViewController:detailsController animated:YES];
    [self presentViewController:detailsNavigationController animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return playList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellSelector];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellSelector];
    }
    
    cell.textLabel.text = [playList[indexPath.row] playlistTitle];
    //may add more properties from YoutubePlaylistModel
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [playList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Segue


-(IBAction) rerutnToInitialViewController :(UIStoryboardSegue *) segue{
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailsSegue"]){
        YouTubePlaylistModel* currentPlaylistInfo = [playList objectAtIndex:[[sender indexPath] row]];
        DetailedPlaylistViewController* detailsController = [segue destinationViewController];
        detailsController.playlistInfo = currentPlaylistInfo;
    }
}

@end
