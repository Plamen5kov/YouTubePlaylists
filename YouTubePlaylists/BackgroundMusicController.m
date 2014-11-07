//
//  BackgroundMusicController.m
//  YouTubePlaylists
//
//  Created by Admin on 07/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "BackgroundMusicController.h"

@implementation BackgroundMusicController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpAudioPlayer];
    }
    return self;
}

+(BackgroundMusicController*) setUpAudioController{
    return [self init];
}

-(void) setUpAudioPlayer{
    NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"chill"
                                               withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile
                                                                  error:nil];
    self.backgroundMusic.numberOfLoops = -1;
}

@end
