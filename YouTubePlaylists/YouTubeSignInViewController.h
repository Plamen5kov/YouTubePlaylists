//
//  YouTubeSignInViewController.h
//  YouTubePlaylists
//
//  Created by Admin on 11/4/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleRegisteredUserModel.h"
#import "InitialPlaylistViewController.h"


@interface YouTubeSignInViewController : UIViewController<UIWebViewDelegate> {
    IBOutlet UIWebView *webview;
    NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, retain) NSString *isLogin;
@property (assign, nonatomic) Boolean isReader;

//@property (strong, nonatomic) InitialPlaylistViewController* initialViewController;

@end
