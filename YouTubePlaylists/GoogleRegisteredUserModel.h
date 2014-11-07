//
//  UserModel.h
//  YouTubePlaylists
//
//  Created by Admin on 11/1/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleRegisteredUserModel : NSObject

@property (weak, nonatomic) NSString* fullName;
@property (weak, nonatomic) NSString* email;
@property (weak, nonatomic) NSString* gender;
@property (weak, nonatomic) NSString* googleID;
@property (weak, nonatomic) NSString* accessToken;

@end
