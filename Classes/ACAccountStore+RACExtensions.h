//
//  ACAccountStore+RACExtensions.h
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import <Accounts/Accounts.h>
#import <ReactiveCocoa.h>
@interface ACAccountStore (RACExtensions)
+ (RACSignal*) rac_accountWithType:(NSString*) accountTypeName options:(NSDictionary*) options;
@end
