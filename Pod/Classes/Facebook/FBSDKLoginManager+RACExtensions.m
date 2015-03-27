//
//  FBSession+ReactiveExtensions.m
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "FBSDKLoginManager+RACExtensions.h"
#import "FBSDKAccessToken.h"
@implementation FBSDKLoginManager (RACExtensions)

- (RACSignal*) rac_loginWithReadPermissions:(NSArray*) permissions {
    __weak FBSDKLoginManager *loginManager = self;

    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if ([FBSDKAccessToken currentAccessToken] != nil) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }
        else {
            [loginManager logInWithReadPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if (!error){
                    [subscriber sendNext: result];
                    [subscriber sendCompleted];
                }
                else {
                    [subscriber sendError:error];
                }
            }];
        }
        return [RACDisposable disposableWithBlock:^{
//            [[FBSession activeSession] closeAndClearTokenInformation];
        }];
    }] subscribeOn:[RACScheduler mainThreadScheduler]];
}

/*
- (RACSignal*) rac_publishWithPermissions:(NSArray *) permissions defaultAudience:(FBSessionDefaultAudience) defaultAudience {
    __weak FBSession* session = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [session requestNewPublishPermissions:permissions defaultAudience:defaultAudience completionHandler:^(FBSession *session, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:session];
                [subscriber sendCompleted];
            }
        }];

        
       return [RACDisposable disposableWithBlock:^{
           
       }];
    }];
}
 */
@end
