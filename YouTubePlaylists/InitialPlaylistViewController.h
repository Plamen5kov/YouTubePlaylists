//
//  ViewController.h
//  YouTubePlaylists
//
//  Created by Admin on 10/29/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GooglePlus/GooglePlus.h>
#import "GoogleRegisteredUserModel.h"

@interface InitialPlaylistViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *subTableView;

-(void) loadDataWithUser: (GoogleRegisteredUserModel *) authenticatedUser;

-(IBAction) rerutnToInitialViewController :(UIStoryboardSegue *) segue;

@end