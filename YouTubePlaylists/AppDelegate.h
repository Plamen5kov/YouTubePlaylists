//
//  AppDelegate.h
//  YouTubePlaylists
//
//  Created by Admin on 10/29/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackgroundMusicController.h"
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
    UINavigationController *navigation;
    
}

@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic) UINavigationController *navigation;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (nonatomic, strong) BackgroundMusicController* audioController;
@property(nonatomic, strong) AVAudioPlayer *backgroundMusic;

@property(nonatomic, strong) CoreDataHelper* coreDataHelper;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
-(void) loadSpinnerWithContext: (UIViewController*) delegate;
    
- (NSURL *)applicationDocumentsDirectory;


@end

//@interface AppDelegate : UIResponder <UIApplicationDelegate>
//
//@property (strong, nonatomic) UIWindow *window;
//
//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//
//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;
//
//@end

