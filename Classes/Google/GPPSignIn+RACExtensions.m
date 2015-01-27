//
//  GPPSignIn+RACExtensions.m
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "GPPSignIn+RACExtensions.h"

@interface GPPSignIn () <GPPSignInDelegate>

@end

@implementation GPPSignIn (RACExtensions)

- (RACSignal *) rac_signInWithScopes: (NSArray *) scopes {
    __weak GPPSignIn *gpp = self;
    gpp.attemptSSO = YES;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACDisposable* disposable = [[gpp rac_signalForSelector:@selector(finishedWithAuth:error:) fromProtocol:@protocol(GPPSignInDelegate)] subscribeNext:^(RACTuple *x) {
            NSError *error = x.second;
            if (error) {
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:x.first];
                [subscriber sendCompleted];
            }
        }];

        gpp.delegate = nil;
        gpp.delegate = gpp;
        gpp.scopes= scopes;
        [gpp authenticate];
        
        return disposable;
    }];
}

@end
