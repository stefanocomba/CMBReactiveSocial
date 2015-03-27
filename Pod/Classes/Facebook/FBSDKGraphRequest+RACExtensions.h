//
//  FBRequestConnection+RACExtensions.h
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//


#import "FBSDKGraphRequest.h"
#import <ReactiveCocoa.h>

@interface FBSDKGraphRequest (RACExtensions)
+(RACSignal *) rac_startWithGraphPath: (NSString *)graphPath parameters:(NSDictionary *) parameters HTTPMethod:(NSString *) method ;
+(RACSignal*) rac_getUserInfo;
@end
