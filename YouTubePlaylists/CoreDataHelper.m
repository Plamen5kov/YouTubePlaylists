//
//  CoreDataHelper.m
//  TourDiary
//
//  Created by admin on 11/5/14.
//  Copyright (c) 2014 brezoev. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

NSString* storeFilename = @"CDatabase.sqlite";

-(NSString*)applicationDocumentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(id) init{
    self = [super init];
    if(self){
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _cordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_context setPersistentStoreCoordinator:_cordinator];
    }
    
    return self;
}

-(NSURL*) storeURL{
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

-(NSURL*) applicationStoresDirectory{
    NSLog(@"application stores directory");
    NSURL* storesDirectory =
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]
     URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[storesDirectory path]]){
        NSError* error = nil;
        if([fileManager createDirectoryAtURL:storesDirectory
                 withIntermediateDirectories:YES
                                  attributes:nil
                                       error:&error]){
            
        }
        else{
            
        }
    }
    return  storesDirectory;
    
}

-(void) loadStore{
    
    if(_store){
        return;
    }
    NSError* error = nil;
    
    _store = [_cordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
    if(!_store){
        NSLog(@"Failed to add Store. Error : %@", error);
        abort();
    }
    else{
        NSLog(@"Successfully added store %@", _store);
    }
}

-(void) setupCoreData{
    NSLog(@"set up core data");
    [self loadStore];
}

-(void)saveContext{
    if([_context hasChanges]){
        NSError* error = nil;
        if([_context save:&error]){
            NSLog(@"_context SAVED");
        }
        else{
            NSLog(@"No changes skip save");
        }
    }
}
@end