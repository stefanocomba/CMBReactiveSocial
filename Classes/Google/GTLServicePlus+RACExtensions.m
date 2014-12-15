//
//  GTLServicePlus+RACExtensions.m
//  Pods
//
//  Created by Stefano Comba on 28/03/14.
//
//

#import "GTLServicePlus+RACExtensions.h"
#import <GPPSignIn.h>

@implementation GTLServicePlus (RACExtensions)

static GTLServicePlus* sharedInstance = nil;

+(GTLServicePlus *) sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[GTLServicePlus alloc] init];
    }
    return sharedInstance;
}

-(RACSignal *) rac_getUser {
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    return [self rac_executeQuery:query];
}

-(RACSignal *) rac_peopleListCollection: (NSString *) collection {
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleListWithUserId:@"me" collection:collection];
    return [self rac_executeQuery:query];
}

-(RACSignal *) rac_executeQuery: (GTLQueryPlus *) query {
    
    __weak GTLServicePlus* plusService = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        [plusService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
            if (!error) {
                [subscriber sendNext: RACTuplePack(ticket, object)];
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
