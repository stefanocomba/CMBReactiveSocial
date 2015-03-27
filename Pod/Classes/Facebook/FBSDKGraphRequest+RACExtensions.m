//
//  FBRequestConnection+RACExtensions.m
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "FBSDKGraphRequest+RACExtensions.h"

@implementation FBSDKGraphRequest (RACExtensions)


+(RACSignal*) rac_getUserInfo {
    return [self rac_startWithGraphPath:@"me" parameters:nil HTTPMethod:@"GET"];
}

+(RACSignal *) rac_startWithGraphPath: (NSString *)graphPath parameters:(NSDictionary *) parameters HTTPMethod:(NSString *) method  {

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        FBSDKGraphRequest* graphRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:parameters];
        [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            ;
        }];
    }];
}

@end
