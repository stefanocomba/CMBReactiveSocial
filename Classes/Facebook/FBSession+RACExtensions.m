//
//  FBSession+ReactiveExtensions.m
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "FBSession+RACExtensions.h"
#import "ACAccountStore+RACExtensions.h"
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


//- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
//{
//    // If the session was opened successfully
//    if (!error && state == FBSessionStateOpen){
//        NSLog(@"Session opened");
//        // Show the user the logged-in UI
//        [self userLoggedIn];
//        return;
//    }
//    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
//        // If the session is closed
//        NSLog(@"Session closed");
//        // Show the user the logged-out UI
//        [self userLoggedOut];
//    }
//
//    // Handle errors
//    if (error){
//        NSLog(@"Error");
//        NSString *alertText;
//        NSString *alertTitle;
//        // If the error requires people using an app to make an action outside of the app in order to recover
//        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
//            alertTitle = @"Something went wrong";
//            alertText = [FBErrorUtility userMessageForError:error];
//            [self showMessage:alertText withTitle:alertTitle];
//        } else {
//
//            // If the user cancelled login, do nothing
//            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
//                NSLog(@"User cancelled login");
//
//                // Handle session closures that happen outside of the app
//            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
//                alertTitle = @"Session Error";
//                alertText = @"Your current session is no longer valid. Please log in again.";
//                [self showMessage:alertText withTitle:alertTitle];
//
//                // Here we will handle all other errors with a generic error message.
//                // We recommend you check our Handling Errors guide for more information
//                // https://developers.facebook.com/docs/ios/errors/
//            } else {
//                //Get more error information from the error
//                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
//
//                // Show the user an error message
//                alertTitle = @"Something went wrong";
//                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
//                [self showMessage:alertText withTitle:alertTitle];
//            }
//        }
//        // Clear this token
//        [FBSession.activeSession closeAndClearTokenInformation];
//        // Show the user the logged-out UI
//        [self userLoggedOut];
//    }
//}
@end
