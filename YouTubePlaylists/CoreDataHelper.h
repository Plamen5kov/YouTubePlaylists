//
//  CoreDataHelper.h
//  YouTubePlaylists
//
//  Created by Admin on 08/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, strong) NSManagedObjectContext* context;
@property (nonatomic, strong) NSManagedObjectModel* model;
@property (nonatomic, strong) NSPersistentStoreCoordinator* cordinator;
@property (nonatomic, strong) NSPersistentStore* store;

-(void)saveContext;
-(void)setupCoreData;

@end
