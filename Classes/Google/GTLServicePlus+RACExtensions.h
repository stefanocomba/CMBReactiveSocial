//
//  GTLServicePlus+RACExtensions.h
//  Pods
//
//  Created by Stefano Comba on 28/03/14.
//
//

#import <GoogleOpenSource.h>
#import <ReactiveCocoa.h>

@interface GTLServicePlus (RACExtensions)
+(GTLServicePlus *) sharedInstance;
-(RACSignal *) rac_getUser;
-(RACSignal *) rac_peopleListCollection: (NSString *) collection;
-(RACSignal *) rac_executeQuery: (GTLQueryPlus *) query;
@end
