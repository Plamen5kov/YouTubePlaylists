//
//  DetailedPlaylistTableViewController.m
//  YouTubePlaylists
//
//  Created by Admin on 01/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "DetailedPlaylistViewController.h"

@interface DetailedPlaylistViewController ()

@end

@implementation DetailedPlaylistViewController{
    NSArray* arr;
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

    
    [self.tableView reloadData];
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
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] objectAtIndex: 0];
    NSLog(@"#");
    
    cell.videoLength.text = [arr objectAtIndex:indexPath.row];
    //cell.thumbnailImageView.image = [UIImage imageNamed:@"download-mp3-button.jpg"];
    
    cell.videoTitle.text = @"Test";
    
    
    return cell;
}

@end
