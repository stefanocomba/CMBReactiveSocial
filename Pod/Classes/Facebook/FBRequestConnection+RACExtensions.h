//
//  FBRequestConnection+RACExtensions.h
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "FBRequestConnection.h"
#import <ReactiveCocoa.h>

@interface FBRequestConnection (RACExtensions)
+(RACSignal *) rac_startWithGraphPath: (NSString *)graphPath parameters:(NSDictionary *) parameters HTTPMethod:(NSString *) method ;
+(RACSignal*) rac_getUserInfo;
@end
