//
//  YouTubeSignInViewController.m
//  YouTubePlaylists
//
//  Created by Admin on 11/4/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "YouTubeSignInViewController.h"
#import "InitialPlaylistViewController.h"


NSString *client_id = @"902472583724-ul05lna38kfh37v8mp18bli09s0b84ti.apps.googleusercontent.com";
NSString *secret = @"LYJ4H6xFFdGGhlHswxhAGJXC";
NSString *callback =  @"http://localhost";
//NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile+https://www.google.com/reader/api/0/subscription";
NSString *scope = @"https://gdata.youtube.com+https://www.googleapis.com/auth/userinfo.profile";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";

@interface YouTubeSignInViewController()<NSURLConnectionDelegate>
@end

@implementation YouTubeSignInViewController{
    
    GoogleRegisteredUserModel *currentUser;
    InitialPlaylistViewController *initialPlaylistViewController;
}

@synthesize webview,isLogin,isReader;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeLogInRequest];
}

-(void) makeLogInRequest{
    NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&data-requestvisibleactions=%@",
                     client_id, callback, scope, visibleactions];
    
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //    [indicator startAnimating];
    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
//                NSLog(@"oAuth verifier: %@",verifier);
                break;
            }
        }
        
        if (verifier) {
            NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", verifier,client_id,secret,callback];
            NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/token"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            receivedData = [[NSMutableData alloc] init];
            
        } else {
            NSLog(@"Error!");
        }
        
        [self loadInitialView];
        
        return NO;
    }
    return YES;
}

-(void) loadInitialView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:[NSBundle mainBundle]];
    initialPlaylistViewController = [storyboard instantiateViewControllerWithIdentifier:@"InitialViewNib"];
    
    [self presentViewController:initialPlaylistViewController animated:YES completion:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //if error
    NSError *jsonError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:&jsonError];
    
    if(jsonError) {
        // check the error description
        NSLog(@"JSON ERROR: %@", [jsonError localizedDescription]);
    }
    
    //if all data is recieved
    currentUser = [[GoogleRegisteredUserModel alloc]init];
    currentUser.accessToken = [jsonDictionary valueForKey:@"access_token"];
    
    [initialPlaylistViewController loadDataWithUser:currentUser];
}

@end
