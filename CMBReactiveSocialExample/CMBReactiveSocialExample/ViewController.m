//
//  ViewController.m
//  SCReactiveSocialExample
//
//  Created by Stefano Comba on 27/03/14.
//  Copyright (c) 2014 Stefano Comba. All rights reserved.
//

#import "ViewController.h"
#import <FacebookSDK.h>
#import <ACAccountStore+RACExtensions.h>
#import <SLRequest+RACExtensions.h>

#import <FBSession+RACExtensions.h>
#import <FBRequestConnection+RACExtensions.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
        
    }];
    
    /*
     FBSession* session = [[FBSession alloc] initWithAppID:@"1478533272375250" permissions:@[@"user_photos", @"email", @"user_birthday", @"user_about_me", @"user_location"] urlSchemeSuffix:nil tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance]];
     [FBSession setActiveSession:session];
     
     [[session rac_openSessionWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent] subscribeNext:^(id x) {
     [[FBRequestConnection rac_startWithGraphPath:@"me" parameters:nil HTTPMethod:@"GET"] subscribeNext:^(id x) {
     NSLog(@"%@",x) ;
     } error:^(NSError *error) {
     NSLog(@"%@",error);
     }];
     }];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
