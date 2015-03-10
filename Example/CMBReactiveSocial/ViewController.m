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
#import <ACAccountStore+RACExtensions.h>
#import <SLRequest+RACExtensions.h>

#import <FBSession+RACExtensions.h>
#import <FBRequestConnection+RACExtensions.h>

// google
#import <GooglePlus.h>
#import <GTLPlus.h>
#import <GPPSignIn+RACExtensions.h>
#import <GTLServicePlus+RACExtensions.h>

#import <CMBOAuthViewController.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self facebookExample];
//    [self facebookSystemExample];
//    [self twitterExample];
//     @weakify(self);
    NSURL* instagramURL = [NSURL URLWithString:@"https://api.instagram.com/oauth/authorize/?client_id=c79c90c23c5b468f9c3f778cf2fae965&redirect_uri=http://cmbreactivesocialdemo&response_type=token"];
        NSURL* linkedinURL = [NSURL URLWithString:@"https://www.linkedin.com/uas/oauth2/authorization?client_id=758g8iyz58vzir&redirect_uri=http://cmbreactivesocialdemo&response_type=code&state=customsecret"];
    NSURL* redirect = [NSURL URLWithString:@"http://cmbreactivesocialdemo"];
    
	[[[self rac_signalForSelector:@selector(viewDidAppear:)] take:1] subscribeCompleted:^{
//        [self googleExample];
        CMBOAuthViewController *vc =  [CMBOAuthViewController new];
        
        [self.navigationController pushViewController:vc animated:YES];
        
        [[vc rac_oauthWithURL:linkedinURL redirectUrl:redirect]
         subscribeNext:^(id x) {
            NSLog(@"%@",[x absoluteString]);
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSError *error) {

    }];
    }];

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

- (void) facebookSystemExample {
    [[ACAccountStore rac_accountWithType:ACAccountTypeIdentifierFacebook options:@{ACFacebookAppIdKey:@"1478533272375250", ACFacebookPermissionsKey: @[@"user_photos", @"email", @"user_birthday", @"user_about_me", @"user_location"]}] subscribeNext:^(ACAccountStore* accountStore) {
        ACAccountType *facebookAccountType =[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        NSArray* accounts = [accountStore accountsWithAccountType:facebookAccountType] ;
        if (accounts.count>0){
            ACAccount * account = [accounts lastObject];
            
            [[SLRequest rac_requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://graph.facebook.com/me"] parameters:nil account:account] subscribeNext:^(RACTuple* x) {
                NSData* data = x.first;
                NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",json) ;
            } error:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
    } error:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void) twitterExample {
    [[ACAccountStore rac_accountWithType:ACAccountTypeIdentifierTwitter options:nil] subscribeNext:^(ACAccountStore* accountStore) {
        ACAccountType *twitterAccountType =[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray* accounts = [accountStore accountsWithAccountType:twitterAccountType] ;
        if (accounts.count>0){
            ACAccount * account = [accounts lastObject];
            
            [[SLRequest rac_requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:@{@"screen_name" :account.username} account:account] subscribeNext:^(RACTuple* x) {
                NSData* data = x.first;
                NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",json) ;
            } error:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
    } error:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void) googleExample {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn disconnect];
    [signIn signOut];
    
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = @"1033453988313.apps.googleusercontent.com";
    signIn.keychainName= @"CMBReactiveSocialExample";
//    kGTLAuthScopePlusLogin    // "https://www.googleapis.com/auth/plus.login" scope => Know your name, basic info, and list of people you're connected to on Google+
//    kGTLAuthScopePlusMe       // Know who you are on Google
//    @"profile"                // "profile" scope
    
    [[signIn rac_signInWithScopes: @[kGTLAuthScopePlusLogin]] subscribeNext:^(GTMOAuth2Authentication* auth) {
        
        GTLServicePlus *plusService = [GTLServicePlus sharedInstance];
        plusService.retryEnabled = YES;

        [plusService setAuthorizer:  auth];
        
        NSLog (@"%@", [GPPSignIn sharedInstance].authentication.userEmail);
        
        // get people information
        [[plusService rac_peopleListCollection: kGTLPlusCollectionVisible] subscribeNext:^(RACTuple *x) {
            GTLServiceTicket *ticket = x.first;
            GTLPlusPeopleFeed *peopleFeed = x.second;
            
            NSLog(@"%@\n\n%@", ticket, peopleFeed.items);
            
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
        
        // get user account information
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
