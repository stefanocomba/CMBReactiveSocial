//
//  FBSession+ReactiveExtensions.h
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "FBSDKLoginManager.h"
#import <ReactiveCocoa.h>
@interface FBSDKLoginManager (RACExtensions)
- (RACSignal*) rac_loginWithReadPermissions:(NSArray*) permissions ;
@end
