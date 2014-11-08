//
//  VideoDetailsTableViewCell.m
//  YouTubePlaylists
//
//  Created by Admin on 11/3/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "VideoDetailsTableViewCell.h"


@implementation VideoDetailsTableViewCell

@synthesize videoTitle = _videoTitle;
@synthesize videoLength = _videoLength;
@synthesize thumbnailImageView = _thumbnailImageView;

- (void)awakeFromNib {
    // Initialization code
    self.videoTitle.text = @"default title";
    //self.selected = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}
//
//- (IBAction)getMp3Button:(id)sender {
//    NSLog(@"%@", sender);
//    
//    MP3DownloaderController *downloader = [[MP3DownloaderController alloc] init];
//    [downloader getMP3File: @"https://www.youtube.com/watch?v=akhmS1D2Ce4"];
//}

-(void)getMp3Button:(id)sender{
    UIView *parent = [sender superview];
    while (parent && ![parent isKindOfClass:[VideoDetailsTableViewCell class]]) {
        parent = parent.superview;
    }
    
    VideoDetailsTableViewCell *cell = (VideoDetailsTableViewCell *)parent;
    MP3DownloaderController *downloader = [[MP3DownloaderController alloc] init];
    NSLog(@"%@", cell.videoId.text);
    [downloader getMP3File: cell.videoId.text];
}

@end
