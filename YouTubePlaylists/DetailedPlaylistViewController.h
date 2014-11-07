//
//  DetailedPlaylistTableViewController.h
//  YouTubePlaylists
//
//  Created by Admin on 01/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDetailsTableViewCell.h"
#import "YTPlayerView.h"

@interface DetailedPlaylistViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, YTPlayerViewDelegate>

@property (strong, nonatomic) IBOutlet YTPlayerView *playerView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
