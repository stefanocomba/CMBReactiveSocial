//
//  GPPSignIn+RACExtensions.h
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import <ReactiveCocoa.h>
#import <GoogleOpenSource.h>
#import <GooglePlus.h>

@interface GPPSignIn (RACExtensions)
- (RACSignal *) rac_signInWithScopes: (NSArray *) scopes;
@end
