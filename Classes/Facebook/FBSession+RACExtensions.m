//
//  FBSession+ReactiveExtensions.m
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "FBSession+RACExtensions.h"

@implementation FBSession (RACExtensions)


- (RACSignal*) rac_openSessionWithBehavior:(FBSessionLoginBehavior) behavior  {
    __weak FBSession* session = self;
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [session openWithBehavior:behavior completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            //            [self sessionStateChanged:session state:status error:error];
            
            if (!error && status == FBSessionStateOpen){
                [subscriber sendNext: @(status)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
            
        }];

        return [RACDisposable disposableWithBlock:^{
//            [[FBSession activeSession] closeAndClearTokenInformation];
        }];
    }] subscribeOn:[RACScheduler mainThreadScheduler]];
}


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
@end
