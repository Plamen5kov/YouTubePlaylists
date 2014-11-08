//
//  YouTubePlaylistModel.h
//  YouTubePlaylists
//
//  Created by Admin on 01/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YouTubePlaylistModel : NSObject

@property (strong, nonatomic) NSString* playlistTitle;

-(instancetype) initWithData: (NSData*) data;

@end