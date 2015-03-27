//
//  ViewController.m
//  CMBReactiveSocialExample
//
//  Created by Stefano Comba on 27/03/14.
//  Copyright (c) 2014 Stefano Comba. All rights reserved.
//

#import "ViewController.h"
#import <EXTScope.h>
// facebook

#import <ACAccountStore+RACExtensions.h>
#import <SLRequest+RACExtensions.h>

#import <FBSDKGraphRequest+RACExtensions.h>
#import <FBSDKLoginManager+RACExtensions.h>

// google
#import <GooglePlus.h>
#import <GTLPlus.h>
#import <GPPSignIn+RACExtensions.h>
#import <GTLServicePlus+RACExtensions.h>

#import <CMBOAuthViewController.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_instagram;
@property (weak, nonatomic) IBOutlet UIButton *btn_linkedin;
@property (weak, nonatomic) IBOutlet UIButton *btn_facebook;
@property (weak, nonatomic) IBOutlet UIButton *btn_googleplus;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self facebookExample];
//    [self facebookSystemExample];
//    [self twitterExample];
//     @weakify(self);
     @weakify(self);
     NSURL* redirect = [NSURL URLWithString:@"http://cmbreactivesocialdemo"];
    self.btn_instagram.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
         @strongify(self);
        CMBOAuthViewController* vc = [CMBOAuthViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        return [[[vc rac_oauthInstagramWithClientId:@"YOUR_CLIENT_ID" redirectURI:redirect] doCompleted:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }] logNext];
    }];
    
    self.btn_linkedin.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        CMBOAuthViewController* vc = [CMBOAuthViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        return [[[vc rac_oauthLinkedinWithClientId:@"YOUR_CLIENT_ID" redirectURI:redirect state:@"YOUR_CUSTOM_STATE" clientSecret:@"YOUR_CLIENT_SECRET" scope:nil] doCompleted:^{
             @strongify(self);
             [self.navigationController popViewControllerAnimated:YES];
        }] logNext];
    }];
    
    
    
    [self setupFacebook];
    [self setupGooglePlus];
    
}

- (void) setupFacebook {
    
    FBSDKLoginManager* loginManager = [[FBSDKLoginManager alloc] init];
        

    

    self.btn_facebook.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[[[loginManager rac_loginWithReadPermissions:@[@"user_friends", @"email", @"public_profile", @"read_friendlists", @"user_location"]] flattenMap:^RACStream *(id value) {
            return [FBSDKGraphRequest rac_startWithGraphPath:@"me/friendlists" parameters:nil HTTPMethod:@"GET"];
        }]
                 logNext] logError];
    }];
}
- (void) setupGooglePlus {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn disconnect];
    [signIn signOut];
    
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = @"1033453988313.apps.googleusercontent.com";
    signIn.keychainName= @"CMBReactiveSocialExample";
    
    self.btn_googleplus.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[[signIn rac_signInWithScopes: @[kGTLAuthScopePlusLogin]] flattenMap:^RACStream *(GTMOAuth2Authentication* auth) {
            GTLServicePlus *plusService = [GTLServicePlus sharedInstance];
            plusService.retryEnabled = YES;
            [plusService setAuthorizer:  auth];
            return [[plusService rac_peopleListCollection: kGTLPlusCollectionVisible] flattenMap:^RACStream *(RACTuple* x) {
                GTLServiceTicket *ticket = x.first;
                GTLPlusPeopleFeed *peopleFeed = x.second;
                NSLog(@"%@\n\n%@", ticket, peopleFeed.items);
                return [[plusService rac_getUser] logNext];
            }];
        }] logError];
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
