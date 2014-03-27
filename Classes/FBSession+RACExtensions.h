//
//  FBSession+ReactiveExtensions.h
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "FBSession.h"
#import <ReactiveCocoa.h>
@interface FBSession (RACExtensions)
- (RACSignal*) rac_openSessionWithBehavior:(FBSessionLoginBehavior) behavior;
@end
