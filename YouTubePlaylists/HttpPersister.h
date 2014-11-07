//
//  HttpPersister.h
//  YouTubePlaylists
//
//  Created by Admin on 01/11/2014.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpPersister : NSObject

// make http get request and return id responce (we will cast the id later to what we need) / the method returns status code(optional handling)
-(id) getWithUrl: (NSString *) specifficURL;
//normal and with callback

// make http post request and  ....
-(id) postWithUrl: (NSString *) specifficUrl
       andHeaders: (NSString *) headers
       andUrlBody: (NSString *) urlBody;
// normal and with callback
//-(id) postWithBlock: (^)(NSString * inputUrl);

// make http put request and  .... (method optional)
//-(id) putWithUrl: (NSString *) specifficUrl
//       andHeaders: (NSString *) headers
//       andUrlBody: (NSString *) urlBody;

@end
