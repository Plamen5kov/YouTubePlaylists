//
//  BackgroundMusicController.h
//  YouTubePlaylists
//
//  Created by Admin on 07/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BackgroundMusicController : NSObject

@property(nonatomic, strong) AVAudioPlayer *backgroundMusic;
@property BOOL isPlaying;

+(BackgroundMusicController*) setUpAudioController;

@end
