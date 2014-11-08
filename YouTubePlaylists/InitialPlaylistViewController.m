
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
#import "Song.h"

@interface InitialPlaylistViewController ()<NSURLConnectionDataDelegate>
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;
@property(nonatomic, strong) AVAudioPlayer *backgroundMusic;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property(nonatomic, strong) CoreDataHelper* helper;
@end

@implementation InitialPlaylistViewController{
    NSString* cellSelector;
    NSMutableArray* playListNames;
    GoogleRegisteredUserModel* user;
    UIActivityIndicatorView *spinner;
    BackgroundMusicController* audioController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cellSelector = @"PlaylistCell";
    
    
    [self loadSpinner];
    [self appendLongPressGesture];
    [self playMusicInBackground];
//    [self setUpMotionManager];
    
    self.helper = [[CoreDataHelper alloc] init];
    [self.helper setupCoreData];
    
//    [self addDataToCoreData];
    [self loadData];
    
}

-(void) loadData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self.helper.context executeFetchRequest:request error:nil]];
    Song* songObject = [arr objectAtIndex:0];
    NSString* songName = songObject.backgroundMusic;
    
    NSLog(@"DATA: %@", songName);
}

-(void) addDataToCoreData{
    Song *model= [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.helper.context];
//    [model.backgroundSong setValue:@"asdasjdkgasodk" forKey:@"backgroundSong"];
    model.backgroundMusic = @"aslduasda";
    [self.helper saveContext];
}

#pragma mark core motion

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(motion == UIEventSubtypeMotionShake)
    {
        if(audioController.isPlaying == YES){
            [_backgroundMusic stop];
        } else{
            [_backgroundMusic play];
        }
        audioController.isPlaying = !audioController.isPlaying;
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
                [playListNames exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
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

-(void) playMusicInBackground{
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        audioController = [[BackgroundMusicController alloc] init];
        _backgroundMusic = audioController.backgroundMusic;
        
        dispatch_queue_t queue = dispatch_queue_create("com.yourdomain.yourappname", NULL);
        dispatch_async(queue, ^{
            _backgroundMusic.volume = 0.7;
            [_backgroundMusic play];
            audioController.isPlaying = YES;
        });
    }
}

-(void) loadSpinner {
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake((self.view.frame.size.width / 2), 100);
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

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
    
    user = authenticatedUser;
    
    NSString* url = @"https://www.googleapis.com/youtube/v3/playlists?part=snippet&mine=true&key=902472583724-ul05lna38kfh37v8mp18bli09s0b84ti.apps.googleusercontent.com";

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

-(void)connection:(NSURLRequest *) request didReceiveData:(NSData *)data{

    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error: nil];
    NSDictionary* playlistJsonObjects = [[[jsonDict objectForKey:@"items"] valueForKey:@"snippet"] valueForKey:@"title"];
    
    playListNames = [[NSMutableArray alloc] init];
    for (NSString *playlistItem in playlistJsonObjects) {
        
        YouTubePlaylistModel *list = [[YouTubePlaylistModel alloc] init];
        list.playlistTitle = playlistItem;
        
        [playListNames addObject:list];
    }
    
    [spinner stopAnimating];
    [self.subTableView reloadData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"RECIEVED ERROR IS: %@", error);
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return playListNames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellSelector];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellSelector];
    }
    
    cell.textLabel.text = [playListNames[indexPath.row] playlistTitle];
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
    [playListNames removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
