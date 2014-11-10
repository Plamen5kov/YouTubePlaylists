//
//  VideoDetailsTableViewCell.h
//  YouTubePlaylists
//
//  Created by Admin on 11/3/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MP3DownloaderController.h"

@interface VideoDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (weak, nonatomic) IBOutlet UILabel *videoLength;
@property (weak, nonatomic) IBOutlet UIButton *donloadToMP3Button;
@property (strong, nonatomic) IBOutlet UILabel *videoId;


- (IBAction)getMp3Button:(id)sender;

@end
