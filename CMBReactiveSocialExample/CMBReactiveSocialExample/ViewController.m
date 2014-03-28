//
//  ViewController.m
//  CMBReactiveSocialExample
//
//  Created by Stefano Comba on 27/03/14.
//  Copyright (c) 2014 Stefano Comba. All rights reserved.
//

#import "ViewController.h"

// facebook
#import <FacebookSDK.h>
#import <FBSession+RACExtensions.h>
#import <FBRequestConnection+RACExtensions.h>

// google
#import <GooglePlus.h>
#import <GTLPlus.h>
#import <GPPSignIn+RACExtensions.h>
#import <GTLServicePlus+RACExtensions.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self facebookExample];
	[self googleExample];

}

- (void) facebookExample {
    FBSession* session = [[FBSession alloc] initWithAppID:@"1478533272375250" permissions:@[@"user_photos", @"email", @"user_birthday", @"user_about_me", @"user_location"] urlSchemeSuffix:nil tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance]];
    [FBSession setActiveSession:session];
    
    [[session rac_openSessionWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent] subscribeNext:^(id x) {
       [[FBRequestConnection rac_startWithGraphPath:@"me" parameters:nil HTTPMethod:@"GET"] subscribeNext:^(id x) {
          NSLog(@"%@",x) ;
       } error:^(NSError *error) {
           NSLog(@"%@",error);
       }];
    }];
}

- (void) googleExample {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn disconnect];
    [signIn signOut];
    
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = @"1033453988313.apps.googleusercontent.com";
    
//    kGTLAuthScopePlusLogin    // "https://www.googleapis.com/auth/plus.login" scope => Know your name, basic info, and list of people you're connected to on Google+
//    kGTLAuthScopePlusMe       // Know who you are on Google
//    @"profile"                // "profile" scope
    
    [[signIn rac_signInWithScopes: @[kGTLAuthScopePlusLogin]] subscribeNext:^(id x) {
        
        GTLServicePlus *plusService = [GTLServicePlus sharedInstance];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer: [GPPSignIn sharedInstance].authentication];
        
        [[plusService rac_peopleListCollection: kGTLPlusCollectionVisible] subscribeNext:^(RACTuple *x) {
            GTLServiceTicket *ticket = x.first;
            GTLPlusPeopleFeed *peopleFeed = x.second;
            
            NSLog(@"%@\n\n%@", ticket, peopleFeed.items);
            
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
        [[plusService rac_getUser] subscribeNext:^(RACTuple *x) {
            GTLServiceTicket *ticket = x.first;
            GTLPlusPerson *person = x.second;
            NSLog(@"%@\n\n%@", ticket, person.displayName);
            
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
