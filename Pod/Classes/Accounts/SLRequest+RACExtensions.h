//
//  SLRequest+RACExtensions.h
//  Pods
//
//  Created by Stefano Mondino on 27/03/14.
//
//

#import <Social/Social.h>
#import <ReactiveCocoa.h>

@interface SLRequest (RACExtensions)
+ (RACSignal*) rac_requestForServiceType:(NSString*) type
                           requestMethod:(SLRequestMethod) method
                                     URL:url
                              parameters:params
                                 account:(ACAccount*) account;
@end
