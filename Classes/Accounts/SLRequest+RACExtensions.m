//
//  SLRequest+RACExtensions.m
//  Pods
//
//  Created by Stefano Mondino on 27/03/14.
//
//

#import "SLRequest+RACExtensions.h"
#import "ACAccountStore+RACExtensions.h"
@implementation SLRequest (RACExtensions)

+ (RACSignal*) rac_requestForServiceType:(NSString*) type
                           requestMethod:(SLRequestMethod) method
                                     URL:url
                              parameters:params
                                 account:(ACAccount*) account{
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        SLRequest* request = [self requestForServiceType:type requestMethod:method URL:url parameters:params];
        request.account = account;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                [subscriber sendNext:RACTuplePack(responseData,urlResponse)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
        }];
        
        
    }];
}
@end
